function fmriMelanopsinMRIAnalysis_packetFit(inputParams)
% fmriMelanopsinMRIAnalysis_packetFit(inputParams)
%
% Fit packets.
%
% 9/26/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (fun_with_packets.m)

%% Construct the model object once and reuse it.
temporalFit = tfeIAMP('verbosity','none');
params0 = temporalFit.defaultParams();
paramLockMatrix = [];

%% Set initial params
params.packetType       = 'bold';
params.stimulusFile     = inputParams.stimulusFile;
params.responseFile     = inputParams.responseFile;

%% Load the response file
resp                    = load_nifti(params.responseFile);
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
params.respTimeBase     = 0:TR:(runDur*TR)-TR;

%% Load the stimulus file
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);

%% Extract the attention events
eventTimes = fmriMelanopsinMRIAnalysis_getAttentionEvents(params);

%% Set some parameters for the HRF modeling
HRFdur              = 16000;
numFreqs            = HRFdur/1000;

%% Flatten the volume
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
flatVolPSC              = NaN*zeros(size(flatVol));
cleanDataPSC            = NaN*zeros(size(flatVol));

%% If 'bold', get HRF
if strcmp(params.packetType,'bold')
    params.hrfFile      = fullfile(params.sessionDir,'HRF','V1.mat');
end

%% Iterate over all voxels
for ii = 1:size(flatVol, 1)
    % Convert to % signal change, and remove the HRF.
    flatVolPSC(ii, :)             = convert_to_psc(flatVol(ii, :));
    [~, cleanDataPSC(ii, :)]      = deriveHRF(flatVolPSC(ii, :)',eventTimes,TR*1000,HRFdur,numFreqs);
    
    % Re-center the data.
    % <?> Not sure if we should do this.
    
    % Make a packet
    params.timeSeries       = cleanDataPSC(ii, :);
    thePacket               = makePacket(params);
    
    % Fit packet here.
    [paramsFit,fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket,...
        'defaultParamsInfo', defaultParamsInfo, ...
        'paramLockMatrix',paramLockMatrix, ...
        'searchMethod','linearRegression');
end



