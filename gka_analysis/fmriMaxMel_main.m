% fmriMaxMel_main
%
% Code to analyze the MaxMel collection of data.

%% Housekeeping
clearvars; close all; clc;
warning on;

%% Hardcoded parameters of analysis

% Define cache behavior
kernelCacheBehavior='make';


ExptLabels={'LMSCRF','MelCRF','SplatterControlCRF','RodControlScotopic','RodControlPhotopic'};
RegionLabels={'V1_0_1.5deg','V1_5_25deg','V1_40_60deg'};

% Packet hash array ordered by ExptLabels then RegionLabels
PacketHashArray{1,:}={'f383ad67a6dbd052d3b68e1a993f6b93',...
    '33aade327084361cdbd16d28a307b367',...
    '1534121251748a537b6069a35df0be5c'};

PacketHashArray{2,:}={'6b7b5aec92e81dfcea8c076364c0b67d',...
    '7abdab90af307de17cf809c5628aefc0',...
    'b6cdbd7ad1cf357547105753610fcee5'};

PacketHashArray{3,:}={'68d23863092a9195632cf210d7a90aa9',...
    'eb406441091b293e156eccf0954f26c3',...
    '501560902a291bcacd3b172c98df67ff'};

PacketHashArray{4,:}={'6939bbf2b4a94099f7e4d8675050b938',...
    '643a6326f8678ddb165d9fd855e31ca6',...
    'cd66ee42860175f2ae03315d858157a5'};

PacketHashArray{5,:}={'2d4d7d6bdfadf61d51a45184bae7807c',...
    '0ab27e7bd27021c557de9ed36779ccb4',...
    'c706d7eb48eb776165e5361be58cc097'};

% Discover user name and find the Dropbox directory
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/fmriMelanopsinMRIAnalysis/');

dropBoxHEROkernelStructDir = ...
    fullfile('/Users', userName, ...
    'Dropbox-Aguirre-Brainard-Lab/Team Documents/Cross-Protocol Subjects/HERO_kernelStructCache/');


% Derive the empirical HRF for each subject if so instructed
if strcmp(kernelCacheBehavior,'make')
    
    % Set up the packetNames for the 5-25° field for the LMS, Mel, and
    % Splatter experiments
    packetFiles={fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{1} '_' RegionLabels{2} '_' PacketHashArray{1}{2} '.mat']),...
        fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{2} '_' RegionLabels{2} '_' PacketHashArray{2}{2} '.mat']),...
        fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{3} '_' RegionLabels{2} '_' PacketHashArray{3}{2} '.mat'])};
    
    [responseStructCellArray] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles);
    
    notes='Average evoked response to attention events from 5-25 degree region of V1. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the LMS CRF, Mel CRF, and Splatter CRF experiments';
    
    for ss=1:length(responseStructCellArray)        
        kernelStruct=responseStructCellArray{ss};
        kernelStruct.metaData.notes=notes;
        
        % calculate the hex MD5 hash for the hrfKernelStructCellArray
        kernelStructHash = DataHash(kernelStruct);
        
        % Set path to the cache and save it using the MD5 hash name
        kernelStructFileName=fullfile(dropBoxHEROkernelStructDir, [kernelStruct.metaData.subjectName '_hrf_' kernelStructHash '.mat']);
        save(kernelStructFileName,'kernelStruct','-v7.3');
        fprintf(['Saved a kernelStruct with hash ID ' kernelStructHash '\n']);        
    end
    
end % make HRFs


