% Example script outlining how to use 'makePacket'
%
%   Written by Andrew S Bock Sep 2016

%% Set initial params
params.packetType       = 'bold';
params.sessionDir       = '/data/jag/MELA/MelanopsinMR/HERO_asb1/032416';
params.runNum           = 1;
params.stimulusFile     = fullfile(params.sessionDir,'MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat');
params.responseFile     = fullfile(params.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01/wdrf.tf.nii.gz');
%% load the response file
resp                    = load_nifti(params.responseFile);
TR                      = resp.pixdim(5)/1000;
runDur                  = size(resp.vol,4);
params.respTimeBase     = 0:TR:(runDur*TR)-TR;
%% laod the stimulus file
[params.stimValues,params.stimTimeBase,params.stimMetaData] = fmriMelanopsinMRImakeStimStruct(params);
%% If 'bold', get HRF
if strcmp(params.packetType,'bold')
    params.hrfFile      = fullfile(params.sessionDir,'HRF','V1.mat');
end
%% run 'dummyFit' for every voxel
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
% Convert to percent signal change
pscVol                  = convert_to_psc(flatVol);
B                       = nan(1,size(pscVol,1));
R2                      = nan(1,size(pscVol,1));
progBar                 = ProgressBar(size(pscVol,1),'looping..');
for i = 1:size(pscVol,1)
    params.respValues       = pscVol(i,:);
    packet                  = makePacket(params);
    eventNum                = 1; % first stimulus event
    [B(i),R2(i)]            = dummyFit(packet,eventNum);
    progBar(i);
end
%% run 'dummyFit' for V1 only
anatFile                = fullfile(params.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01','mh.areas.func.vol.nii.gz');
anat                    = load_nifti(anatFile);
V1ind                   = find(abs(anat.vol)==1);
volDims                 = size(resp.vol);
flatVol                 = reshape(resp.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));
% Convert to percent signal change
pscVol                  = convert_to_psc(flatVol);
% Pull out the V1 signal
V1signal                = pscVol(V1ind,:);
medianV1                = median(V1signal,1);
% run dummyFit
params.respValues       = medianV1;
packet                  = makePacket(params);
for eventNum = 1:size(packet.stimulus.values, 1)
[B(eventNum),R2(eventNum)]                  = dummyFit(packet,eventNum);
end