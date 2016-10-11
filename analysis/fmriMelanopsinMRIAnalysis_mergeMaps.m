%% Iterate over the subjects
inputParams.dataDir = '/data/jag/MELA/MelanopsinMR';

%% HERO_asb1
subjIDs = {'HERO_asb1' 'HERO_asb1' 'HERO_aso1' 'HERO_aso1' 'HERO_gka1' 'HERO_gka1' 'HERO_mxs1' 'HERO_mxs1'};
sessionIDs = {'032416' '040716' '032516' '033016' '033116' '040116' '040616' '040816'};

%% Define the maps to be merged
mapsToBeMerged = [1 2 ; 3 4 ; 5 6 ; 7 8];
varExplainedThreshold = 0.005;
eccRange = [2.5 32];

% Iterate over the maps
for ii = 1:length(mapsToBeMerged)
    map1 = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 1)}, ...
        sessionIDs{mapsToBeMerged(ii, 1)}, 'stats', 'avg_varexp.nii.gz'));
    map2 = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 2)}, ...
        sessionIDs{mapsToBeMerged(ii, 2)}, 'stats', 'avg_varexp.nii.gz'));

    [map1vol, volDims] = fmriMelanopsinMRIANalysis_flattenVolume(map1);
    map2vol = fmriMelanopsinMRIANalysis_flattenVolume(map2);
    
    areas = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 1)}, ...
        sessionIDs{mapsToBeMerged(ii, 1)}, 'Series_012_fMRI_MaxMelPulse_A_AP_run01', 'mh.areas.func.vol.nii.gz'));
    areasvol = fmriMelanopsinMRIANalysis_flattenVolume(areas);
    ecc = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 1)}, ...
        sessionIDs{mapsToBeMerged(ii, 1)}, 'Series_012_fMRI_MaxMelPulse_A_AP_run01', 'mh.ecc.func.vol.nii.gz'));
    eccvol = fmriMelanopsinMRIANalysis_flattenVolume(ecc);
    
    ROI_V1              = (abs(areasvol)==1 & ...
        eccvol>eccRange(1) & eccvol<eccRange(2));
    ROI_V2V3            = ((abs(areasvol)==2 | abs(areasvol)==3) & ...
        eccvol>eccRange(1) &eccvol<eccRange(2));
    

    map1_2 = (ROI_V1) & (map1vol > varExplainedThreshold & map2vol > varExplainedThreshold);

    map0 = map1;
    map0.vol = fmriMelanopsinMRIANalysis_unflattenVolume(map1_2, volDims);
    save_nifti(map0, fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 1)}, sessionIDs{mapsToBeMerged(ii, 1)}, 'stats', 'avg_varexp_thresh.nii.gz'));
end