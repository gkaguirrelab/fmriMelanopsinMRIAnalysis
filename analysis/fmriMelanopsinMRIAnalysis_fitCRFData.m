function fmriMelanopsinMRIAnalysis_fit400PctData(inputParams)
% fmriMelanopsinMRIAnalysis_fit400PctData(inputParams)
%
% Fits the 400% data
%
% 10/1/2016     ms      Wrote it.

%% Copy over the params
params = inputParams;

%% Iterate over the subjects
subjIDs = {'HERO_asb1' 'HERO_asb1' 'HERO_asb1'};
sessionIDs = {'051016' '060716'  '060816'};
sessionRef = '032416'; % This is where we take the mask from
maskName = 'avg_varexp_thresh.nii.gz';

for ss = 1:length(subjIDs);
    subjID = subjIDs{ss}; sessionID = sessionIDs{ss};
    params.sessionDir = fullfile(params.dataDir, subjID, sessionID);
    params.outDir = fullfile(params.sessionDir, 'stats');
    if ~isdir(params.outDir);
        mkdir(params.outDir);
    end;
    boldDirs = find_bold(params.sessionDir);
    matDir                          = fullfile(params.sessionDir,'MatFiles');
    matFiles                        = listdir(matDir,'files');
    
    % Iterate over BOLD dirs
    for b = 1:length(boldDirs)
        params.stimulusFile = fullfile(matDir, matFiles{b});
        params.responseFile = fullfile(params.sessionDir, boldDirs{b}, 'wdrf.tf.nii.gz');
        params.anatRefRun = fullfile(params.sessionDir, boldDirs{1});
        params.maskFile = fullfile(params.dataDir, subjID, sessionRef, 'stats', maskName);
        
        fprintf('* <strong>Loading response file</strong>...');
        resp                    = load_nifti(params.responseFile);
        fprintf('\tDONE.\n');
        % Flatten the volume
        [respvol, volDims] = fmriMelanopsinMRIAnalysis_flattenVolume(resp);

        fprintf('* <strong>Loading mask file</strong>...');
        maskfile                    = load_nifti(params.maskFile);
        fprintf('\tDONE.\n');
        % Flatten the mask
        maskvol = fmriMelanopsinMRIAnalysis_flattenVolume(maskfile);
        
        % Assemble the average response
        theResp(:, b) = mean(respvol(find(maskvol), :));
        
        % Get the stimulus values
        [params.stimValues, params.stimTimeBase, params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);
        %keyboard
    end
    % Aberage across run
    fitAmpMean = mean(fitAmp, 2);
    fitErrMean = mean(fitErr, 2);
    
    % Create an empty volume template
    tmp0 = load_nifti(params.responseFile)
    volDims = size(tmp0.vol);
    
    % Carry over the values
    amp0 = tmp0;
    amp0.vol = reshape(fitAmpMean, volDims(1), volDims(2), volDims(3), 1);
    err0 = tmp0;
    err0.vol = reshape(fitErrMean, volDims(1), volDims(2), volDims(3), 1);
    
    % Save out the data
    save_nifti(amp0, fullfile(params.outDir, 'avg_amp.nii.gz'));
    save_nifti(err0, fullfile(params.outDir, 'avg_varexp.nii.gz'));
end