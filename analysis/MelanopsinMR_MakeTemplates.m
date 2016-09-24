% Download the retinotopy templates (V2.5 from the Wiki).
currDir = pwd;
!wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/angle-template-2.5.sym.mgh
!wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/eccen-template-2.5.sym.mgh
!wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/areas-template-2.5.sym.mgh

% Convert to .nii.gz
!mri_covert angle-template-2.5.sym.mgh angle-template-2.5.sym.nii.gz
!mri_covert eccen-template-2.5.sym.mgh eccen-template-2.5.sym.nii.gz
!mri_covert areas-template-2.5.sym.mgh areas-template-2.5.sym.nii.gz

% Set up template files
templateFiles = {'eccen-template-2.5.sym.nii.gz' 'angle-template-2.5.sym.nii.gz' 'areas-template-2.5.sym.nii.gz'};

% HERO_asb1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_asb1';
subjectName = 'HERO_asb1_MaxMel';
project_template(sessionDir, subjectName);

% HERO_aso1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_aso1';
subjectName = 'HERO_aso1_MaxMel';
project_template(sessionDir, subjectName);

% HERO_gka1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_gka1_MaxMel';
project_template(sessionDir, subjectName);

% HERO_mxs1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_mxs1_MaxMel';
project_template(sessionDir, subjectName);

