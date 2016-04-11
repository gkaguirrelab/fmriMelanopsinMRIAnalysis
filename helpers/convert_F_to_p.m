function convert_F_to_p(session_dir,subject_name,runNums,func,thresh,SUBJECTS_DIR)

% Converts the fstat1.nii.gz volume to pval.nii.gz in feat/stats directory.
% Also saves a pval.mask.nii.gz volume, where pval.nii.z < thresh = 1.
%
%   Outputs are also projected to anatomical space, specified by
%   'subject_name'
%
%   Usage:
%   convert_F_to_p(session_dir,subject_name,runNums,func,thresh,SUBJECTS_DIR)
%
%   Written by Andrew S Bock Nov 2015

%% set defaults
if ~exist('thresh','var')
    thresh = 0.05; % p-value threshold
end
if ~exist('SUBJECTS_DIR','var')
    SUBJECTS_DIR = getenv('SUBJECTS_DIR');
end
volnames = {'fstat1' 'zfstat1' 'pval' 'pval.mask'};
%% get bold dirs
d = find_bold(session_dir);
%% Get the feat stats dir
for i = runNums
    statsDir = fullfile(session_dir,d{i},[func '.feat'],'stats');
    dof = load(fullfile(statsDir,'dof'));
    fstat = load_nifti(fullfile(statsDir,'fstat1.nii.gz'));
    pval = fstat;
    % Convert Fstats to p-values
    pval.vol = 1-fcdf(fstat.vol,1,dof);
    % Save volumes
    save_nifti(pval,fullfile(statsDir,'pval.nii.gz'));
    sigind = pval.vol<thresh;
    pval.vol = zeros(size(pval.vol));
    pval.vol(sigind) = 1;
    save_nifti(pval,fullfile(statsDir,'pval.mask.nii.gz'));
    % Project to anatomical space
    tmpreg = listdir(fullfile(session_dir,d{i},'*bbreg.dat'),'files');
    reg = fullfile(session_dir,d{i},tmpreg{1});
    for v = 1:length(volnames)
        invol = fullfile(statsDir,[volnames{v} '.nii.gz']);
        targvol = fullfile(SUBJECTS_DIR,subject_name,'mri','T1.mgz');
        outvol = fullfile(statsDir,[volnames{v} '.anat.nii.gz']);
        mri_vol2vol(invol,targvol,outvol,reg);
    end
end