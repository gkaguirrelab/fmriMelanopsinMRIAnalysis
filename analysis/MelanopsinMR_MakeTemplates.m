% Download the retinotopy templates (V2.5 from the Wiki).
currDir = pwd;
anatTemplateDir = '/data/jag/MELA/anat_templates';
cd(anatTemplateDir);
if ~exist('angle-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/angle-template-2.5.sym.mgh
end
if ~exist('areas-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/areas-template-2.5.sym.mgh
end
if ~exist('eccen-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/eccen-template-2.5.sym.mgh
end

% Convert to .nii.gz
if ~exist('angle-template-2.5.sym.nii.gz', 'file')
    !mri_convert angle-template-2.5.sym.mgh angle-template-2.5.sym.nii.gz
end
if ~exist('eccen-template-2.5.sym.nii.gz', 'file')
    !mri_convert eccen-template-2.5.sym.mgh eccen-template-2.5.sym.nii.gz
end
if ~exist('areas-template-2.5.sym.nii.gz', 'file')
    !mri_convert areas-template-2.5.sym.mgh areas-template-2.5.sym.nii.gz
end

% Set up template files
templateFiles = {fullfile(anatTemplateDir, 'eccen-template-2.5.sym.nii.gz') ...
    fullfile(anatTemplateDir, 'angle-template-2.5.sym.nii.gz') ...
    fullfile(anatTemplateDir, 'areas-template-2.5.sym.nii.gz')};

% HERO_asb1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_asb1';
subjectName = 'HERO_asb1_MaxMel';
project_template(sessionDir, subjectName, templateFiles);

% HERO_aso1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_aso1';
subjectName = 'HERO_aso1_MaxMel';
project_template(sessionDir, subjectName, templateFiles);

% HERO_gka1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_gka1_MaxMel';
project_template(sessionDir, subjectName, templateFiles);

% HERO_mxs1
sessionDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_mxs1_MaxMel';
project_template(sessionDir, subjectName, templateFiles);

