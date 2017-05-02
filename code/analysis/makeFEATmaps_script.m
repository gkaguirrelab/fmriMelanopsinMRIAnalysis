params.dataDir = '/data/jag/MELA/MelanopsinMR';


%% HERO_asb1
subject_name = 'HERO_asb1_MaxMel';
subj_name = 'HERO_asb1';

% mel
session_dir = fullfile(params.dataDir, 'HERO_asb1/032416');
runNums = 1:11; % Number of BOLD runs
condition = '_MEL400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums

% lms
session_dir = fullfile(params.dataDir, 'HERO_asb1/040716');
runNums = 1:10; % Number of BOLD runs
condition = '_LMS400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums

%% HERO_aso1

subject_name = 'HERO_aso1_MaxMel';
subj_name = 'HERO_aso1';

% mel
session_dir = fullfile(params.dataDir, 'HERO_aso1/032516');
runNums = 1:11; % Number of BOLD runs
condition = '_MEL400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums

% lms
session_dir = fullfile(params.dataDir, 'HERO_aso1/033016');
runNums = 1:12; % Number of BOLD runs
condition = '_LMS400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums
%% HERO_gka1

subject_name = 'HERO_gka1_MaxMel';
subj_name = 'HERO_gka1';

% mel
session_dir = fullfile(params.dataDir, 'HERO_gka1/033116');
runNums = 1:12; % Number of BOLD runs
condition = '_MEL400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums
% lms
session_dir = fullfile(params.dataDir, 'HERO_gka1/040116');
runNums = 1:12; % Number of BOLD runs
condition = '_LMS400_';

Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)



clear runNums



%% HERO_mxs1

subject_name = 'HERO_mxs1_MaxMel';
subj_name = 'HERO_mxs1';

% mel
session_dir = fullfile(params.dataDir, 'HERO_mxs1/040616');
runNums = 1:12; % Number of BOLD runs
condition = '_MEL400_';


Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)

clear runNums
% lms
session_dir = fullfile(params.dataDir, 'HERO_mxs1/040816');
runNums = 1:12; % Number of BOLD runs
condition = '_LMS400_';

Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = 's5.wdrf.tf';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
output_dir = '/Users/giulia/Desktop/TEST' ;
inAnatomicalSpace = true;
fisher_combined_prob_test(output_dir, session_dir,subj_name, runNums,func,condition, inAnatomicalSpace)



clear runNums



%% project all maps in fsaverage_sym space

disp('Projecting  all maps in fsaverage_sym space...');
maps = dir(fullfile(output_dir, '*zval.anat*'));
hemis  = { ...
    'lh' ...
    'rh' ...
    };
for mm = 1 : length(maps)
    for hh = 1: length(hemis)
        thisMap = fullfile(maps(mm).folder, maps(mm).name);
        subjName = [maps(mm).name(1:10) 'MaxMel'];
        outputMap1 = fullfile(output_dir, [maps(mm).name(1:end -11) 'surf.' hemis{hh} '.nii.gz']);
        system( ['mri_vol2surf --mov '  thisMap ' --regheader ' subjName ' --hemi ' hemis{hh} ' --o ' outputMap1] )
        outputMap2 = fullfile(output_dir, [maps(mm).name(1:end -11) 'fsaverage_sym.' hemis{hh} '.nii.gz']);
        if strcmp(hemis{hh},'lh')
            mri_surf2surf(subjName,'fsaverage_sym',outputMap1,outputMap2,hemis{hh});
        else
            mri_surf2surf([subjName '/xhemi'],'fsaverage_sym',outputMap1,outputMap2,'lh');
        end
    end
end


%% average all the maps

disp('Averaging maps...');

maps = dir(fullfile(output_dir, '*MEL400_Fisher_zval.fsaverage_sym*'));
allHemis = [];
for mm = 1 : length(maps)
    thisMap = fullfile(maps(mm).folder, maps(mm).name);
    thisHemi = load_nifti(thisMap);
    allHemis = [allHemis, abs(thisHemi.vol)];
end
avgMap = mean(allHemis,2);

% Save nifti
thisHemi.vol = avgMap;
save_nifti(thisHemi,fullfile(output_dir, ['MEL400_averageMap.nii.gz']));

clear thisHemi
clear thisMap
clear maps

maps = dir(fullfile(output_dir, '*LMS400_Fisher_zval.fsaverage_sym*'));
    allHemis = [];
for mm = 1 : length(maps)
    thisMap = fullfile(maps(mm).folder, maps(mm).name);
    thisHemi = load_nifti(thisMap);
    allHemis = [allHemis,abs(thisHemi.vol)];
end
avgMap = mean(allHemis,2);

% Save nifti
thisHemi.vol = avgMap;
save_nifti(thisHemi,fullfile(output_dir, ['LMS400_averageMap.nii.gz']));

clear thisHemi
clear thisMap
clear maps

%% project p values


disp('Projecting  all p values in fsaverage_sym space...');
maps = dir(fullfile(output_dir, '*pval.anat*'));
hemis  = { ...
    'lh' ...
    'rh' ...
    };
for mm = 1 : length(maps)
    for hh = 1: length(hemis)
        thisMap = fullfile(maps(mm).folder, maps(mm).name);
        subjName = [maps(mm).name(1:10) 'MaxMel'];
        outputMap1 = fullfile(output_dir, [maps(mm).name(1:end -11) 'surf.' hemis{hh} '.nii.gz']);
        system( ['mri_vol2surf --mov '  thisMap ' --regheader ' subjName ' --hemi ' hemis{hh} ' --o ' outputMap1] )
        outputMap2 = fullfile(output_dir, [maps(mm).name(1:end -11) 'fsaverage_sym.' hemis{hh} '.nii.gz']);
        if strcmp(hemis{hh},'lh')
            mri_surf2surf(subjName,'fsaverage_sym',outputMap1,outputMap2,hemis{hh});
        else
            mri_surf2surf([subjName '/xhemi'],'fsaverage_sym',outputMap1,outputMap2,'lh');
        end
    end
end


%% do Fisher's test

  disp('Averaging maps...');

maps = dir(fullfile(output_dir, '*MEL400_Fisher_pval.fsaverage_sym*'));
allHemis = [];
for mm = 1 : length(maps)
    thisMap = fullfile(maps(mm).folder, maps(mm).name);
    thisHemi = load_nifti(thisMap);
    
    tmp(:, :, :, mm) = thisHemi.vol;
end

tmp(tmp == 0) = NaN;
logTmp = (log(tmp));
sumLogTmp =( -2*sum(logTmp, 4));
thisHemi.vol = sumLogTmp;
fprintf('\t * Saving out Fisher''s test...');
save_nifti(thisHemi,fullfile(output_dir,'MEL400_pval_Fisher_Chisq.sym.nii.gz'));
fprintf('done!');

clear thisHemi
clear thisMap
clear maps


maps = dir(fullfile(output_dir, '*LMS400_Fisher_pval.fsaverage_sym*'));
allHemis = [];
for mm = 1 : length(maps)
    thisMap = fullfile(maps(mm).folder, maps(mm).name);
    thisHemi = load_nifti(thisMap);
    
    tmp(:, :, :, mm) = thisHemi.vol;
end

tmp(tmp == 0) = NaN;
logTmp = (log(tmp));
sumLogTmp =( -2*sum(logTmp, 4));
thisHemi.vol = sumLogTmp;
fprintf('\t * Saving out Fisher''s test...');
save_nifti(thisHemi,fullfile(output_dir,'LMS400_pval_Fisher_Chisq.sym.nii.gz'));
fprintf('done!');
 

clear thisHemi
clear thisMap
clear maps
