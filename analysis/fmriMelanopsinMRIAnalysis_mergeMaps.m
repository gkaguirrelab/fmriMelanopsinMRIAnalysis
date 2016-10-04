%% Iterate over the subjects
inputParams.dataDir = '/data/jag/MELA/MelanopsinMR';

%% HERO_asb1
subjIDs = {'HERO_asb1' 'HERO_asb1' 'HERO_aso1' 'HERO_aso1' 'HERO_gka1' 'HERO_gka1' 'HERO_mxs1' 'HERO_mxs1'};
sessionIDs = {'032416' '040716' '032516' '033016' '033116' '040116' '040616' '040816'};

%% Define the maps to be merged
mapsToBeMerged = [1 2 ; 3 4 ; 5 6 ; 7 8];
varExplainedThreshold = 0.005;

for ii = 1:length(mapsToBeMerged)
    map1 = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 1)}, sessionIDs{mapsToBeMerged(ii, 1)}, 'stats', 'avg_err.nii.gz'));
    map2 = load_nifti(fullfile(inputParams.dataDir, subjIDs{mapsToBeMerged(ii, 2)}, sessionIDs{mapsToBeMerged(ii, 2)}, 'stats', 'avg_err.nii.gz'));
    sum(sum(sum(((map1.vol > varExplainedThreshold) & (map2.vol > varExplainedThreshold))))) / sum(sum(sum(((map1.vol > varExplainedThreshold) | (map2.vol > varExplainedThreshold)))))
end