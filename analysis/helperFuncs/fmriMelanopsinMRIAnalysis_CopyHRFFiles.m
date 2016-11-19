function fmriMelanopsinMRIAnalysis_CopyHRFFiles(srcSessionDir, trgSessionDir)
% fmriMelanopsinMRIAnalysis_CopyHRFFiles(srcSession, trgSession)

% Copy over the HRF
if ~exist(fullfile(srcSessionDir, 'HRF'), 'dir');
   error('Source folder does not exist.'); 
end

fprintf('> Starting copy...');
copyfile(fullfile(srcSessionDir, 'HRF'), fullfile(trgSessionDir, 'HRF'));
fprintf('Done!\n');