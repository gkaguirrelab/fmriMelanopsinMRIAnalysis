function fmriMelanopsinMRIAnalysis_fit400PctData(inputParams)
% fmriMelanopsinMRIAnalysis_fit400PctData(inputParams)
%
% Fits the 400% data
%
% 10/1/2016     ms      Wrote it.

%% Iterate over the subjects
subjIDs = {'HERO_asb1' 'HERO_asb1' 'HERO_aso1' 'HERO_aso1' 'HERO_gka1' 'HERO_gka1' 'HERO_mxs1' 'HERO_mxs1'};
sessionIDs = {'032416' '040716' '032516' '033016' '033116' '040116' '040616' '040816'};

for ss = 1:length(subjIDs);
    subjID = subjIDs{ss}; sessionID = sessionIDs{ss};
    inputParams.sessionDir = fullfile(inputParams.dataDir, subjID, sessionID);
    inputParams.outDir = fullfile(inputParams.sessionDir, 'stats');
    if ~isdir(inputParams.outDir);
        mkdir(inputParams.outDir);
    end;
    boldDirs = find_bold(inputParams.sessionDir);
    matDir                          = fullfile(inputParams.sessionDir,'MatFiles');
    matFiles                        = listdir(matDir,'files');
    for b = 1:length(boldDirs)
        inputParams.stimulusFile = fullfile(matDir, matFiles{b});
        inputParams.responseFile = fullfile(inputParams.sessionDir, boldDirs{b}, 'wdrf.tf.nii.gz');
        inputParams.anatRefRun = fullfile(inputParams.sessionDir, boldDirs{1});
        [fitAmp(:, b) fitErr(:, b)] = fmriMelanopsinMRIAnalysis_fit400PctDataSingleRun(inputParams);
    end
    % AVerage across run
    fitAmpMean = mean(fitAmp, 2);
    fitErrMean = mean(fitErr, 2);
    
    % Create an empty volume template
    tmp0 = load_nifti(inputParams.responseFile);
    volDims = size(tmp0.vol);
    
    % Carry over the values
    amp0 = tmp0;
    amp0.vol = reshape(fitAmpMean, volDims(1), volDims(2), volDims(3), 1);
    err0 = tmp0;
    err0.vol = reshape(fitErrMean, volDims(1), volDims(2), volDims(3), 1);
    
    % Save out the data
    save_nifti(amp0, fullfile(inputParams.outDir, 'avg_amp.nii.gz'));
    save_nifti(err0, fullfile(inputParams.outDir, 'avg_varexp.nii.gz'));
end