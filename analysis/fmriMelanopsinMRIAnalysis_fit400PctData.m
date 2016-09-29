%% Iterate over the subjects
inputParams.dataDir = '/data/jag/MELA/MelanopsinMR';

%% HERO_asb1 
subjectID = 'HERO_asb1'; sessDir = '032416';
inputParams.stimulusFile = fullfile(inputParams.sessionDir,'MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat');
inputParams.responseFile = fullfile(inputParams.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01/wdrf.tf.nii.gz');
inputParams.anatRefRun = fullfile(inputParams.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01');
fmriMelanopsinMRIAnalysis_packetFit(inputParams);


    %% Iterate over the sessions
    for sn = 1:length(sessList);
        inputParams.sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_asb1/032416/';
        inputParams.stimulusFile = fullfile(inputParams.sessionDir,'MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat');
        inputParams.responseFile = fullfile(inputParams.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01/wdrf.tf.nii.gz');
        inputParams.anatRefRun = fullfile(inputParams.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01');
        fmriMelanopsinMRIAnalysis_packetFit(inputParams);
    end
end

