function fmriMelanopsinMRIAnalysis_packetFit(inputParams)
% fmriMelanopsinMRIAnalysis_packetFit(inputParams)
%
% Fit packets.
%
% 9/26/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (fun_with_packets.m)

%% Set initial params
params                  = inputParams;
params.packetType       = 'bold';

%% Load the response file
resp                    = load_nifti(params.responseFile);
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
params.respTimeBase     = (0:TR:(runDur*TR)-TR)*1000;

%% Load the stimulus file
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);

% Extract only the stimulus
params.stimValues = sum(params.stimValues(find(params.stimMetaData.stimTypes == 1), :));

%% Extract the attention events
eventTimes = fmriMelanopsinMRIAnalysis_getAttentionEvents(params);

%% Set some parameters for the HRF modeling
HRFdur              = 16000;
numFreqs            = HRFdur/1000;

%% Flatten the volume
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
fitAmp                  = NaN*zeros(size(flatVol, 1), 1);
fitErr                  = NaN*zeros(size(flatVol, 1), 1);
flatVolPSC = NaN*zeros(size(flatVol));

%% Get the HRF
params.hrfFile      = fullfile(params.sessionDir,'HRF','V1.mat');

%% Load in the relevant voxels
eccRange                 = [2.5 32]; % based on MaxMel data
params.boldDir = fileparts(params.responseFile);

eccFile             = fullfile(inputParams.anatRefRun, 'mh.ecc.func.vol.nii.gz');
areasFile           = fullfile(inputParams.anatRefRun, 'mh.areas.func.vol.nii.gz');
eccData             = load_nifti(eccFile);
areaData            = load_nifti(areasFile);
ROI_V1              = find(abs(areaData.vol)==1 & ...
    eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
ROI_V2V3            = find((abs(areaData.vol)==2 | abs(areaData.vol)==3) & ...
    eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
ROI = [ROI_V1 ; ROI_V2V3];

%% Iterate over the relevant voxels
% Set up a @tfe object to do convolution
temporalFit                     = tfeIAMP('verbosity','none');
params0                         = temporalFit.defaultParams();
paramLockMatrix                 = [];
defaultParamsInfo.nInstances    = 1;
params.respValues               = zeros(size(flatVol(1, :)));
thePacket0                      = makePacket(params);

% Convolve and resample the stimulus
convolvedStimulus = temporalFit.applyKernel(thePacket0.stimulus,thePacket0.kernel);
regressionMatrixStruct = temporalFit.resampleTimebase(convolvedStimulus,thePacket0.response.timebase); %,varargin{:});

% Mean center the convolved, resampled stimulus
regressionMatrixStruct.values = regressionMatrixStruct.values - mean(regressionMatrixStruct.values);
thePacket0.stimulus.timebase = thePacket0.response.timebase;
thePacket0.stimulus.values = regressionMatrixStruct.values;

tic;
% Pre-allocate
cleanDataPSC = NaN*ones(size(flatVolPSC));

%% Loop over the ROI voxels
for ii = 1:length(ROI)
    % Extract the indices from this ROI
    idx = ROI(ii);
    
    % Create a cleaned up version of the time series by removing the HRF
    % Convert to % signal change, and remove the HRF
    flatVolPSC(idx, :) = convert_to_psc(flatVol(idx, :));
    [~, cleanDataPSC(idx, :)]      = deriveHRF(flatVolPSC(idx, :)', eventTimes,TR*1000, HRFdur, numFreqs);
    
    % Re-center the data
    cleanDataPSC(idx, :) = cleanDataPSC(idx, :) - mean(cleanDataPSC(idx, :));
    
    % Make a packet
    thePacket = thePacket0;
    thePacket.response.values = cleanDataPSC(idx, :);
    
    % Clear the kernel because we do not want to convolve inside the tfe
    % object
    thePacket.kernel.values = [];
    thePacket.kernel.timebase = [];
    thePacket.kernel.metaData = [];
    
    % Fit packet here
    [paramsFit, fVal] = ...
        temporalFit.fitResponse(thePacket, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'paramLockMatrix', paramLockMatrix, ...
        'searchMethod','linearRegression', ...
        'errorType', '1-r2');
    fitAmp(idx) = paramsFit.paramMainMatrix(1);
    fitErr(idx) = 1-fVal;
end
toc;

keyboard