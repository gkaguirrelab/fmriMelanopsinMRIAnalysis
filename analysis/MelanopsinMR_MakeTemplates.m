% Download the retinotopy templates (V2.5 from the Wiki).
currDir = pwd;
anatTemplateDir = '/data/jag/MELA/anat_templates';
if ~exist(anatTemplateDir, 'dir')
   mkdir(anatTemplateDir); 
end
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

% Set up template files
templateFiles = {fullfile(anatTemplateDir, 'eccen-template-2.5.sym.mgh') ...
    fullfile(anatTemplateDir, 'angle-template-2.5.sym.mgh') ...
    fullfile(anatTemplateDir, 'areas-template-2.5.sym.mgh')};

% HERO_asb1
subjDir = '/data/jag/MELA/MelanopsinMR/HERO_asb1';
subjectName = 'HERO_asb1_MaxMel';
project_template(fullfile(subjDir, '032416'), subjectName, templateFiles);
project_template(fullfile(subjDir, '040716'), subjectName, templateFiles);
project_template(fullfile(subjDir, '051016'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060716'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060816'), subjectName, templateFiles);

% HERO_aso1
subjDir = '/data/jag/MELA/MelanopsinMR/HERO_aso1';
subjectName = 'HERO_aso1_MaxMel';
project_template(fullfile(subjDir, '032516'), subjectName, templateFiles);
project_template(fullfile(subjDir, '033016'), subjectName, templateFiles);
project_template(fullfile(subjDir, '042916'), subjectName, templateFiles);
project_template(fullfile(subjDir, '053116'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060116'), subjectName, templateFiles);

% HERO_gka1
subjDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_gka1_MaxMel';
project_template(fullfile(subjDir, '033116'), subjectName, templateFiles);
project_template(fullfile(subjDir, '040116'), subjectName, templateFiles);
project_template(fullfile(subjDir, '050616'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060216'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060616'), subjectName, templateFiles);

% HERO_mxs1
subjDir = '/data/jag/MELA/MelanopsinMR/HERO_mxs1';
subjectName = 'HERO_mxs1_MaxMel';
project_template(fullfile(subjDir, '040616'), subjectName, templateFiles);
project_template(fullfile(subjDir, '040816'), subjectName, templateFiles);
project_template(fullfile(subjDir, '050916'), subjectName, templateFiles);
project_template(fullfile(subjDir, '060916'), subjectName, templateFiles);
project_template(fullfile(subjDir, '061016_Mel'), subjectName, templateFiles);
project_template(fullfile(subjDir, '062816'), subjectName, templateFiles);