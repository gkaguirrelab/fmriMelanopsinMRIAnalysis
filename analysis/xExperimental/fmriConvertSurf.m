addpath(genpath('/Applications/freesurfer/matlab'));
setenv('FREESURFER_HOME', '/Applications/freesurfer');
setenv('SUBJECTS_DIR', '/Applications/freesurfer/subjects');
setenv('FSFAST_HOME', '/Applications/freesurfer/fsfast');
setenv('FSF_OUTPUT_FORMAT', 'nii.gz');
setenv('FSL_DIR', '/usr/local/fsl');
setenv('FSLDIR', '/usr/local/fsl');
setenv('MNI_DIR', '/Applications/freesurfer/mni');
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');

setenv('PATH', [getenv('PATH') ':/Applications/freesurfer/bin'])

dataDir = '/Users/mspits/Desktop/FishersMaps';

whichDir = 'LMS';
switch whichDir
    case 'Mel'
        theSessions = {'HERO_asb1_MelPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_aso1_MelPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_gka1_MelPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_mxs1_MelPulses_400pct_Fisher_pval.anat.nii.gz'};
    case 'LMS'
        theSessions = {'HERO_asb1_LMSPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_aso1_LMSPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_gka1_LMSPulses_400pct_Fisher_pval.anat.nii.gz' ...
            'HERO_mxs1_LMSPulses_400pct_Fisher_pval.anat.nii.gz'};
end

allData = [];

for ss = 1:length(theSessions)
    inputVol = theSessions{ss};
    subjID = [inputVol(1:9) '_MaxMel'];
    volRoot = allwords(inputVol);
    
    %% Convert to surface
    outputVol = [volRoot{1} '.anat.surf.lh.nii.gz'];
    cmd = ['mri_vol2surf --mov ' fullfile(dataDir, inputVol) ' --regheader ' subjID ' --hemi lh --o ' fullfile(dataDir, outputVol)];
    system(cmd);
    
    outputVol = [volRoot{1} '.anat.surf.rh.nii.gz'];
    cmd = ['mri_vol2surf --mov ' fullfile(dataDir, inputVol) ' --regheader ' subjID ' --hemi rh --o ' fullfile(dataDir, outputVol)];
    system(cmd);
    
    %%
    inputVol = [volRoot{1} '.anat.surf.lh.nii.gz'];
    outputVol = [volRoot{1} '.fsaverage_sym.surf.lh.nii.gz'];
    mri_surf2surf(subjID,'fsaverage_sym',fullfile(dataDir, inputVol),fullfile(dataDir, outputVol),'lh');
    lh = load_nifti(fullfile(dataDir, outputVol));
    allData = [allData lh.vol];
    
    inputVol = [volRoot{1} '.anat.surf.rh.nii.gz'];
    outputVol = [volRoot{1} '.fsaverage_sym.surf.rh.nii.gz'];
    mri_surf2surf([subjID '/xhemi'],'fsaverage_sym',fullfile(dataDir, inputVol),fullfile(dataDir, outputVol),'lh');
    rh = load_nifti(fullfile(dataDir, outputVol));
    allData = [allData rh.vol];
end

%%
threshVal = .05;
allData0 = allData;
allData = fisher_z_corr(allData0);
tmp = mean(allData, 2);
thresh = tmp < threshVal;
surface_plot('logp',log(tmp), 'fsaverage_sym', 'lh', 'inflated',thresh,0.85,'full',1,[90,-20]);
%delete(findall(gcf,'Type','light'));
savefigs('png', ['~/Desktop/' whichDir])
%%
tmp(:) = NaN;
surface_plot('logp',log(tmp), 'fsaverage_sym', 'lh', 'inflated',thresh,0.85,'full',1,[90,-20]);
%delete(findall(gcf,'Type','light'));
savefigs('png', ['~/Desktop/Empty'])

%%
if ~exist('angle-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/angle-template-2.5.sym.mgh
end
if ~exist('areas-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/areas-template-2.5.sym.mgh
end
if ~exist('eccen-template-2.5.sym.mgh', 'file')
    !wget https://cfn.upenn.edu/aguirreg/public/ES_template/mgh_files/eccen-template-2.5.sym.mgh
end%% Show the eccentricity range

tmp(:) = NaN;
surface_plot('logp',log(tmp), 'fsaverage_sym', 'lh', 'inflated',thresh,0.85,'full',1,[90,-20]);
%delete(findall(gcf,'Type','light'));
savefigs('png', ['~/Desktop/Empty'])

areasTmp = MRIread('areas-template-2.5.sym.mgh');
areas = abs([areasTmp.vol(:)]);

eccTmp = MRIread('eccen-template-2.5.sym.mgh');
ecc = abs([eccTmp.vol(:)]);

idx = (areas == 1) & (ecc > 2.5) & (ecc < 32);

surface_plot('logp',idx, 'fsaverage_sym', 'lh', 'inflated',idx,[],[],[],[90,-20]);
%savefigs('png', ['~/Desktop/Areas'])


%
% %%
% tmp = load_nifti(fullfile(dataDir, outputVol));
% tmp.vol = icdf('normal',tmp.vol,0,1);
% outputVol = [volRoot{1} '.z_trans.fsaverage_sym.surf.lh.nii.gz'];
% save_nifti(tmp, fullfile(dataDir, outputVol));
%
% %%
% threshVal = -5;
% inData = load_nifti(fullfile(dataDir, outputVol));
% thresh = inData.vol<threshVal;
% surface_plot('zstat',inData.vol, 'fsaverage_sym', 'lh', 'inflated',thresh);
%
% %% icdf('normal',[1],0,1)
%
% size(allData)
% %%
% allData0 = allData;
% allData(allData == 0) = eps;
% logTmp = log(allData);
% sumLogTmp = -2*sum(logTmp, 4);
% chiSqMean = mean(sumLogTmp, 2);
% pVal = 1 - chi2cdf(chiSqMean,2*size(sumLogTmp, 2));
% threshVal = .1;
% thresh = pVal < threshVal;
%
% surface_plot('logp', log(pVal), 'fsaverage_sym', 'lh', 'inflated',thresh);
%
