function [fitAmpVol fitErrVol] = fmriMelanopsinMRIAnalysis_fit400PctDataSingleRun(inputParams)
% fmriMelanopsinMRIAnalysis_fit400PctDataSingleRun(inputParams)
%
% Fit packets.
%
% 9/26/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (fun_with_packets.m)

fprintf('\n***');
fprintf('\n* Working on <strong>%s</strong>', inputParams.sessionDir);

%% Set initial params
fprintf('\n* <strong>Defining parameters</strong>...');
params                  = inputParams;
params.packetType       = 'bold';
fprintf('\t\tDONE.\n');

%% Load the stimulus file
fprintf('* <strong>Extracting stimulus parameters</strong>...');
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);

% Extract only the stimulus
params.stimValues = sum(params.stimValues(find(params.stimMetaData.stimTypes == 1), :));
fprintf('\tDONE.\n');

%% Extract the attention events
fprintf('* <strong>Extracting attention events</strong>...');
eventIdx = 2;
attentionEventTimes = fmriMelanopsinMRIAnalysis_getStimulusEvents(params, eventIdx);
fprintf('\tDONE.\n');

%% Extract the stimulus events
fprintf('* <strong>Extracting stimulus events</strong>...');
eventIdx = 1;
stimulusEventTimes = fmriMelanopsinMRIAnalysis_getStimulusEvents(params, eventIdx);
fprintf('\t\tDONE.\n');

%% Load the response file
fprintf('* <strong>Loading response file</strong>...');
resp                    = load_nifti(params.responseFile);
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
params.respTimeBase     = (0:TR:(runDur*TR)-TR)*1000;
fprintf('\tDONE.\n');

%% Set some parameters for the HRF modeling
HRFdur              = 16000;
numFreqs            = HRFdur/1000;

%% Flatten the volume
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
flatVolPSC = NaN*zeros(size(flatVol));

%% Get the HRF
params.hrfFile      = fullfile(params.sessionDir,'HRF','V1.mat');

%% Load in the relevant voxels
fprintf('* <strong>Prepare anatomical template</strong>...');
eccRange                 = [2.5 32]; % based on MaxMel data
params.boldDir = fileparts(params.responseFile);

eccFile             = fullfile(inputParams.anatRefRun, 'mh.ecc.func.vol.nii.gz');
areasFile           = fullfile(inputParams.anatRefRun, 'mh.areas.func.vol.nii.gz');
eccData             = load_nifti(eccFile);
areaData            = load_nifti(areasFile);
DO_ECC = false;
if DO_ECC
    ROI_V1              = find(abs(areaData.vol)==1 & ...
        eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
    ROI_V2V3            = find((abs(areaData.vol)==2 | abs(areaData.vol)==3) & ...
        eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
else
    ROI_V1              = find(abs(areaData.vol)==1);
    ROI_V2V3            = find((abs(areaData.vol)==2 | abs(areaData.vol)==3));
end
ROI = [ROI_V1 ; ROI_V2V3];
fprintf('\tDONE.\n');

fitAmp                  = NaN*zeros(size(ROI));
fitErr                  = NaN*zeros(size(ROI));
predictedDataAmpModel   = NaN*zeros(size(ROI, 1), size(resp.vol, 4));
cleanDataPSC            = NaN*zeros(size(ROI, 1), size(resp.vol, 4));


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

%% Loop over the ROI voxels
fprintf('* <strong>Iterating over voxels</strong>...\n');
for ii = 1:length(ROI)
    % Extract the indices from this ROI
    idx = ROI(ii);
    
    % Create a cleaned up version of the time series by removing the HRF
    % Convert to % signal change, and remove the HRF
    flatVolPSC(idx, :) = convert_to_psc(flatVol(idx, :));
    [~, cleanDataPSC(ii, :)]      = deriveHRF(flatVolPSC(idx, :)', attentionEventTimes, TR*1000, HRFdur, numFreqs);
    
    % Re-center the data
    cleanDataPSC(ii, :) = cleanDataPSC(ii, :) - mean(cleanDataPSC(ii, :));
    
    % Make a packet
    thePacket = thePacket0;
    thePacket.response.values = cleanDataPSC(ii, :);

    %% Fit an amplitude model
    % Clear the kernel because we do not want to convolve inside the tfe
    % object
    thePacket.kernel.values = [];
    thePacket.kernel.timebase = [];
    thePacket.kernel.metaData = [];

    % Fit packet here
    [paramsFit, fVal, modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'paramLockMatrix', paramLockMatrix, ...
        'searchMethod','linearRegression', ...
        'errorType', '1-r2');
    fitAmp(ii) = paramsFit.paramMainMatrix(1);
    fitErr(ii) = 1-fVal;
    predictedDataAmpModel(ii, :) = modelResponseStruct.values;
    if mod(ii, 100) == 0
        fprintf('  > Voxel %g / %g\n', ii, length(ROI));
    end
end

% Move the data over to the non-ROI representation, i.e. in the whole brain
fitAmpVol = NaN*ones(volDims(1)*volDims(2)*volDims(3), 1);
fitAmpVol(ROI) = fitAmp;
fitErrVol = NaN*ones(volDims(1)*volDims(2)*volDims(3), 1);
fitErrVol(ROI) = fitErr;

toc;
fprintf('\tDONE.\n');