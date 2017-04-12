% make csv files for FEAT analysis
%% set savePath
savePath = '/Users/giulia/Desktop/TEST/MELAregressors';

%% Set Dropbox directory
%get hostname (for melchior's special dropbox folder settings)
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));
if strcmp(hostname,'melchior.uphs.upenn.edu')
    dropboxDir = '/Volumes/Bay_2_data/giulia/Dropbox-Aguirre-Brainard-Lab';
else
    % Get user name
    [~, tmpName] = system('whoami');
    userName = strtrim(tmpName);
    dropboxDir = ['/Users/' userName '/Dropbox-Aguirre-Brainard-Lab'];
end



%% load files and names
packets.MEL400 = load(fullfile(dropboxDir,'MELA_analysis/fmriMelanopsinMRIAnalysis/packetCache/MelanopsinMR_MaxMel400Pct_V1_5_25deg_618e569cc7d15f0ba6be2efd13fc1bc8.mat'));
packets.LMS400 = load(fullfile(dropboxDir,'MELA_analysis/fmriMelanopsinMRIAnalysis/packetCache/MelanopsinMR_MaxLMS400Pct_V1_5_25deg_a45d3bad8efe3479556043e5aba548ad.mat'));

subjectNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

stimulusTypes  = { ...
    'MEL400' ...
    'LMS400' ...
    };

%% make regressors
for ss = 1:length (subjectNames)
    for tt = 1: length(stimulusTypes)
        for rr = 1:length(packets.(stimulusTypes{tt}).packetCellArray)
            if ~isempty (packets.(stimulusTypes{tt}).packetCellArray{ss,rr})
                % make stim struct
                stimStruct = combineStimInstances(makeImpulseStimStruct(packets.(stimulusTypes{tt}).packetCellArray{ss,rr}.stimulus));
                
                % get regressor values for 3 column file
                stimOnset = stimStruct.timebase(find(stimStruct.values(1,:))) ./1000; %[sec]
                atOnset = stimStruct.timebase(find(stimStruct.values(2,:))) ./1000; %[sec]
                duration = 0.001; %[sec]
                weight = 1;
                
                % make regressors
                stimEV = [stimOnset' duration *ones(length(stimOnset),1) weight *ones(length(stimOnset),1)];
                atEV = [atOnset' duration *ones(length(atOnset),1) weight *ones(length(atOnset),1)];
                
                % save out regressors
                stimRegrName = [subjectNames{ss} '_' stimulusTypes{tt} '_run' num2str(rr, '%02g') '_stimulus'];
                atRegrName = [subjectNames{ss} '_' stimulusTypes{tt} '_run' num2str(rr, '%02g') '_attentionTask'];
                
                dlmwrite(fullfile(savePath, stimRegrName), stimEV, '\t');
                dlmwrite(fullfile(savePath, atRegrName), atEV, '\t');
                clear stimOnset atOnset stimEV atEV
            else
                continue
            end
        end
    end
end
