% script to copy the starting files in RERUN_MelanopsinMR

%% Set dirs
fromDir = '/data/jag/MELA/MelanopsinMR';
toDir = '/Users/giulia/Desktop/fMRIdata';

%% set what to copy

foldersToCopy = { ...
    'PulseOx' ...
    'MatFiles' ...
    'DICOMS' ...
    };


%% HERO_asb1
subjDir =  'HERO_asb1';
sessDirs = {'032416' '040716' '051016' '060716' '060816' '101916'};
for ss = 1:length(sessDirs)
    mkdir (fullfile(toDir,subjDir,sessDirs{ss}))
   for ff = 1:length(foldersToCopy)
       copyfile (fullfile(fromDir,subjDir,sessDirs{ss},foldersToCopy{ff}) , fullfile(toDir,subjDir,sessDirs{ss},foldersToCopy{ff}));
   end 
end

%% HERO_aso1
subjDir = 'HERO_aso1';
sessDirs = {'032516' '033016' '042916' '053116' '060116'};
for ss = 1:length(sessDirs)
    mkdir (fullfile(toDir,subjDir,sessDirs{ss}))
   for ff = 1:length(foldersToCopy)
       copyfile (fullfile(fromDir,subjDir,sessDirs{ss},foldersToCopy{ff}) , fullfile(toDir,subjDir,sessDirs{ss},foldersToCopy{ff}));
   end 
end

%% HERO_gka1
subjDir = 'HERO_gka1';
sessDirs = {'033116' '040116' '050616' '060216' '060616' '101916' '102416'};
for ss = 1:length(sessDirs)
    mkdir (fullfile(toDir,subjDir,sessDirs{ss}))
   for ff = 1:length(foldersToCopy)
       copyfile (fullfile(fromDir,subjDir,sessDirs{ss},foldersToCopy{ff}) , fullfile(toDir,subjDir,sessDirs{ss},foldersToCopy{ff}));
   end 
end

%% HERO_mxs1
subjDir = 'HERO_mxs1';
sessDirs = {'040616' '040816' '050916' '060916' '061016_Mel' '062816' '101916' '102416'};
for ss = 1:length(sessDirs)
    mkdir (fullfile(toDir,subjDir,sessDirs{ss}))
   for ff = 1:length(foldersToCopy)
       copyfile (fullfile(fromDir,subjDir,sessDirs{ss},foldersToCopy{ff}) , fullfile(toDir,subjDir,sessDirs{ss},foldersToCopy{ff}));
   end 
end
