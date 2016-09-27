function fmriMelanopsinMRIAnalysis_packetFit(inputParams)
% fmriMelanopsinMRIAnalysis_packetFit(inputParams)
%
% Fit packets.
%
% 9/26/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (fun_with_packets.m)

%% Set initial params
params.packetType       = 'bold';
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/032416';
params.runNum           = 1;
params.stimulusFile     = fullfile(params.sessionDir,'MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat');
params.responseFile     = fullfile(params.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01/wdrf.tf.nii.gz');

%% Load the response file
resp                    = load_nifti(params.responseFile);
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
params.respTimeBase     = 0:TR:(runDur*TR)-TR;

%% Load the stimulus file
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);

%% Extract the attenion events
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
    flatVolPSC(ii, :)             = convert_to_psc(flatVol(ii, :));
    [~, cleanDataPSC(ii, :)]      = deriveHRF(flatVolPSC(ii, :)',eventTimes,TR*1000,HRFdur,numFreqs);
    % Fit packet here.
end