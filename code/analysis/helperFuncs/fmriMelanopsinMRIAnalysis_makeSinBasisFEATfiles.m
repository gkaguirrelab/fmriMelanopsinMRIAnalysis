function fmriMelanopsinMRIAnalysis_makeSinBasisFEATfiles(outFile,funcVol,anatVol,EVs)

%% find and load design file
% note that this assumes that the template file is in the same folder as
% this function
functionPath = which ('fmriMelanopsinMRIAnalysis_makeSinBasisFEATfiles');
[templatePath, ~, ~] = fileparts(functionPath);

%% Load in template
templateFile = fullfile(templatePath,'sinBasis14_Template.fsf');
    
%% Load functional volume
tmp = load_nifti(funcVol);
%% Set design values
DESIGN.TR = num2str(tmp.pixdim(5)/1000); % TR is in msec, convert to sec
if tmp.pixdim(5) < 100 % use 100, in case very short TR is used (i.e. multi-band)
    error('TR is not in msec');
end
DESIGN.VOLS = num2str(tmp.dim(5));
DESIGN.STANDARD = anatVol;
DESIGN.TOTAL_VOXELS = num2str(tmp.dim(2)*tmp.dim(3)*tmp.dim(4)*tmp.dim(5));
DESIGN.FEAT_DIR = funcVol;
for i = 1:length(EVs)
    eval(['DESIGN.EV' num2str(i,'%03d') ' = ''' EVs{i} ''';']);
end
disp(DESIGN);
fin = fopen(templateFile,'rt');
fout = fopen(outFile,'wt');
fields = fieldnames(DESIGN);
while(~feof(fin))
    s = fgetl(fin);
    for f = 1:length(fields)
        s = strrep(s,['DESIGN_' fields{f}],DESIGN.(fields{f}));
    end
    fprintf(fout,'%s\n',s);
    %disp(s)
end
fclose(fin);
