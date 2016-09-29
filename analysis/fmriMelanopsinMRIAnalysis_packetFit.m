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
params.respTimeBase     = 0:TR:(runDur*TR)-TR;

%% Load the stimulus file
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);

% Resample the stimulus time base
params.stimValues = params.stimValues(:, 1:100:end);
params.stimTimeBase = params.stimTimeBase(1:100:end);

% Extract only the stimulus
params.stimValues = sum(params.stimValues(find(params.stimMetaData.stimTypes == 1), :));

% Mean center the stimulus
params.stimValues = params.stimValues - mean(params.stimValues);

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

%% Get the HRF
    params.hrfFile      = fullfile(params.sessionDir,'HRF','V1.mat');

%% Iterate over all voxels
%tic;

%% Construct the model object once and reuse it.
temporalFit = tfeIAMP('verbosity','none');
params0 = temporalFit.defaultParams();
paramLockMatrix = [];
defaultParamsInfo.nInstances = 1;

% Convolve the stimulus outside of the loop once
params.respValues             = zeros(size(flatVol(1, :)));
thePacket0                     = makePacket(params);
convolvedStimulus = temporalFit.applyKernel(thePacket0.stimulus,thePacket0.kernel);

%progBar = ProgressBar(size(flatVol, 1), 'looping..');
tic;
for ii = 1:size(flatVol, 1)
    if ~all(flatVol(ii, :) == 0)
        % Convert to % signal change, and remove the HRF
        flatVolPSC            = convert_to_psc(flatVol(ii, :));
        [~, cleanDataPSC]      = deriveHRF(flatVolPSC',eventTimes,TR*1000,HRFdur,numFreqs);
        cleanDataPSC = cleanDataPSC';
        
        % Re-center the data
        cleanDataPSC = cleanDataPSC - mean(cleanDataPSC);
        
        % Only fit if we actually have non-NaN data
        
        % Make a packet
        thePacket = thePacket0;
        thePacket.response.values = cleanDataPSC;
        thePacket.kernel.values = [];
        thePacket.kernel.timebase = [];
        thePacket.kernel.metaData = [];
        
        % Fit packet here
        [paramsFit,fVal,modelResponseStruct] = ...
            temporalFit.fitResponse(thePacket, ...
            'defaultParamsInfo', defaultParamsInfo, ...
            'paramLockMatrix', paramLockMatrix, ...
            'searchMethod','linearRegression');
        fitAmp(ii) = paramsFit.paramMainMatrix(1);
        fitErr(ii) = fVal;
    else
        fitAmp(ii) = NaN;
        fitErr(ii) = NaN;
    end
end
toc