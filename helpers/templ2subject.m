function templ2subject (session_dir, subject_name, SUBJECTS_DIR, hemis)
% Projects anatomical templates to subject space for Visual Cortex and LGN.
% Needs to run before projecting copes and plotting FIR/TTF responses.
% Requirements: cvs registration for the Freesurfer subject.
% 
% Usage :
% 
% session_dir = '/data/jag/MELA/HERO_gka1/030216';
% subject_name = 'HERO_gka1_7T';
% SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
% 
%  hemis = {...
%         'lh'...
%         'rh'...
%         };
%
% templ2subject (session_dir, subject_name, SUBJECTS_DIR, hemis)
%
%% Project Visual Cortex anatomical template to subject space

project_template(session_dir,subject_name);
%% Project LGN anatomical template to subject space
 for hh = 1:length(hemis)
    hemi = hemis{hh};
%LGN variables
in_vol = fullfile('~/data/' , [hemi '.LGN.prob.nii.gz']);
out_vol =  fullfile(session_dir, [hemi '.LGN.prob.nii.gz']);
ref_vol = fullfile (SUBJECTS_DIR , subject_name, '/mri/T1.mgz');

apply_cvs_inverse(in_vol,out_vol,ref_vol,subject_name,SUBJECTS_DIR)

 end


