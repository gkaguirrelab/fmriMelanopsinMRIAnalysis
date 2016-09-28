%% Iterate over the subjects
subList = listdir(fullfile(inputParams.dataDir,'HERO_*'),'dirs');
for ss = 1:length(subList) % Iterate over subjects
    
    % Figure out how many sessions we have
    sessList = listdir(fullfile(inputParams.dataDir,subList{ss}),'dirs');
    
    %% Iterate over the sessions
    for sn = 1:length(sessList);
        inputParams.sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_asb1/032416/';
        inputParams.stimulusFile = fullfile(inputParams.sessionDir,'MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat');
        inputParams.responseFile = fullfile(inputParams.sessionDir,'Series_012_fMRI_MaxMelPulse_A_AP_run01/wdrf.tf.nii.gz');
        fmriMelanopsinMRIAnalysis_packetFit(inputParams)
    end
end

