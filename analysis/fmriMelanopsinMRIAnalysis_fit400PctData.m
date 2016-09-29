%% Iterate over the subjects
inputParams.dataDir = '/data/jag/MELA/MelanopsinMR';

%% HERO_asb1
subjID = 'HERO_asb1'; sessionID = '032416';
sessionDir = fullfile(inputParams.dataDir, subjID, sessionID);
boldDirs = find_bold(sessionDir);
matDir                          = fullfile(sessionDir,'MatFiles');
matFiles                        = listdir(matDir,'files');
for b = 1:length(boldDirs)
    inputParams.stimulusFile = fullfile(matDir, matFiles{b});
    inputParams.responseFile = fullfile(sessionDir, boldDirs{b}, 'wdrf.tf.nii.gz');
    inputParams.anatRefRun = fullfile(sessionDir, boldDirs{1});
    fmriMelanopsinMRIAnalysis_packetFit(inputParams);
end

inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_asb1/040716');

inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_aso1/032516');
inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_aso1/033016');

inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_gka1/033116');
inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_gka1/040116');

inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_mxs1/040616');
inputParams.sessionDir       = fullfile(inputParams.dataDir, 'HERO_mxs1/040816');
