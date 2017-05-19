function fmriMelanopsinMRIAnalysis_generateRegressors(params)

% generate csv files for FEAT analysis


%% load files and names
packets.MEL400 = load(params.packets.MEL400);
packets.LMS400 = load(params.packets.LMS400);

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
                
                dlmwrite(fullfile(params.savePath, stimRegrName), stimEV, '\t');
                dlmwrite(fullfile(params.savePath, atRegrName), atEV, '\t');
                clear stimOnset atOnset stimEV atEV
            else
                continue
            end
        end
    end
end
