% fmriMaxMel_main
%
% Code to analyze the MaxMel collection of data.

%% Housekeeping
clearvars; close all; clc;
warning on;

%% Hardcoded parameters of analysis

% Define cache behavior
kernelCacheBehavior='load';
carryOverResponseBehavior='skip';
meanEvokedResponseBehavior='load';
fitDEDUModelBehavior='load';
rodScotopicControlBehavior='make';
rodPhotopicControlBehavior='make';

ExptLabels={'LMSCRF','MelCRF','SplatterControlCRF','RodControlScotopic','RodControlPhotopic'};
RegionLabels={'V1_0_1.5deg','V1_5_25deg','V1_40_60deg'};

kernelStructCellArrayHash='d8946ffc4fa9c210dd2458bed3070a81';
meanEvokedHash='7a590b91eb2c034160aa6201b471b34c';
deduFitsHash='399482fb50adca097598cf6211ee43ef';

% Packet hash array ordered by ExptLabels then RegionLabels
PacketHashArray{1,:}={'f383ad67a6dbd052d3b68e1a993f6b93',...
    '799deb29bdf79321196f5c53d0679a9a',...
    '95bdc5dd5bc493b8c8b174f88bd3e1ba'};

PacketHashArray{2,:}={'6b7b5aec92e81dfcea8c076364c0b67d',...
    '6596dbaac26d5a007f9358a74973e378',...
    '4b185a7be53f188bd1f124cac78c7f51'};

PacketHashArray{3,:}={'68d23863092a9195632cf210d7a90aa9',...
    'eb406441091b293e156eccf0954f26c3',...
    '501560902a291bcacd3b172c98df67ff'};

PacketHashArray{4,:}={'6939bbf2b4a94099f7e4d8675050b938',...
    'c9e33fa8705bd06b4885b65420c63ddc',...
    '434a3800e449942c04e6e1a3989886c0'};

PacketHashArray{5,:}={'2d4d7d6bdfadf61d51a45184bae7807c',...
    '2da7196e692caf04c08751a96724ae92',...
    '62706c1a5756e6642fc866faa1860636'};

% Discover user name and find the Dropbox directory
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxAnalysisDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/fmriMelanopsinMRIAnalysis/');

dropBoxHEROkernelStructDir = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/Team Documents/Cross-Protocol Subjects/HERO_kernelStructCache/');


%% Pick a region and define the list of packet files
stimulatedRegion=2; % The primary region of analysis
packetFiles=cell(length(ExptLabels),1);
for ii=1:length(ExptLabels)
    packetFiles{ii}=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{ii} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{ii}{stimulatedRegion} '.mat']);
end


%% Make or load the empirical HRF (aka, kernel) for each subject
switch kernelCacheBehavior
    case 'make'
        fprintf('Making the kernelStructCellArray\n');
        
        [kernelStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles(1:3,:));
        notes='Average evoked response to attention events from 5-25 degree region of V1. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the LMS CRF, Mel CRF, and Splatter CRF experiments';
        
        % Save the plot of the HRFs
        plotFileName=fullfile(dropboxAnalysisDir, 'Figures', 'EmpiricalHRFs.pdf');
        fmriMaxMel_suptitle(plotHandle,[RegionLabels{stimulatedRegion} '- Empirical HRFs']);
        set(gca,'FontSize',6);
        set(plotHandle,'Renderer','painters');
        print(plotHandle, plotFileName, '-dpdf', '-fillpage');
        close(plotHandle);
        
        % Loop across subjects and save the HRF for each subject
        % Also calculate a subjectScaler to adjust other response amplitudes
        % based upon HRF amplitude
        for ss=1:length(kernelStructCellArray)
            kernelStruct=kernelStructCellArray{ss};
            kernelStruct.metaData.notes=notes;
            
            % calculate and save the amplitude of response
            subjectScaler(ss)=max(kernelStruct.values);
            
            % calculate the hex MD5 hash for the hrfKernelStructCellArray
            kernelStructHash = DataHash(kernelStruct);
            
            % Set path to the cache and save it using the MD5 hash name
            kernelStructFileName=fullfile(dropBoxHEROkernelStructDir, [kernelStruct.metaData.subjectName '_hrf_' kernelStructHash '.mat']);
            save(kernelStructFileName,'kernelStruct','-v7.3');
            fprintf(['Saved a kernelStruct with hash ID ' kernelStructHash '\n']);
        end
        % Save the set of HRFs for all subjects for ease of use later
        kernelStructCellArrayHash = DataHash(kernelStructCellArray);
        kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
        save(kernelStructCellArrayFileName,'kernelStructCellArray','-v7.3');
        fprintf(['Saved a kernelStructCellArray with hash ID ' kernelStructCellArrayHash '\n']);
    case 'load'
        fprintf('Loading the kernelStructCellArray\n');
        % Load the kernelStructCellArray
        kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
        load(kernelStructCellArrayFileName);
        % Loop across subjects and  calculate a subjectScaler to adjust other response amplitudes
        % based upon HRF amplitude
        for ss=1:length(kernelStructCellArray)
            kernelStruct=kernelStructCellArray{ss};
            subjectScaler(ss)=max(kernelStruct.values);
        end
    otherwise
        error('You must either make or load the kernelStructCellArray');
end % switch on kernelCacheBehavior


%% Conduct the carry-over response analysis
switch carryOverResponseBehavior
    case 'make'
        fprintf('Analyzing carry-over effects\n');
        
        % Obtain the carry-over matrix for the LMS, Mel, and Splatter stimuli and save plot
        for experiment=1:3
            [responseMatrix, plotHandle] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFiles{experiment}, kernelStructCellArrayFileName);
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_MeanCarryOverMatrix.pdf']);
            saveas(plotHandle,plotFileName);
            close(plotHandle);
        end % loop over stimuli
    otherwise
        fprintf('Skipping analysis of carry-over effects\n');
end % switch for carryOverResponseBehavior

%% Make or load the average evoked responses
switch meanEvokedResponseBehavior
    case 'make'
        fprintf('Obtaining mean evoked responses\n');
        for experiment=1:3
            % Derive mean evoked response
            [responseStructCellArray, plotHandleBySubject, plotHandleByStimulus, plotHandleFitsBySubject] = fmriMaxMel_DeriveMeanEvokedResponse(packetFiles{experiment}, subjectScaler);
            
            % save plot x subject
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_CRFs_bySubject.pdf']);
            fmriMaxMel_suptitle(plotHandleBySubject,[RegionLabels{stimulatedRegion} '-' ExptLabels{experiment} ' - CRFs']);
            set(gca,'FontSize',6);
            set(plotHandleBySubject,'Renderer','painters');
            print(plotHandleBySubject, plotFileName, '-dpdf', '-fillpage');
            close(plotHandleBySubject);
            
            % save plot x stimulus
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_CRFs_byStimulus.pdf']);
            fmriMaxMel_suptitle(plotHandleByStimulus,[RegionLabels{stimulatedRegion} '-' ExptLabels{experiment} ' - CRFs']);
            set(gca,'FontSize',6);
            set(plotHandleByStimulus,'Renderer','painters');
            print(plotHandleByStimulus, plotFileName, '-dpdf', '-fillpage');
            close(plotHandleByStimulus);
            
            % save time-series plots
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_FourierFitsToTimeSeriesBySubject.pdf']);
            fmriMaxMel_suptitle(plotHandleFitsBySubject,[RegionLabels{stimulatedRegion} '-' ExptLabels{experiment} ' - Time series fits']);
            set(gca,'FontSize',6);
            set(plotHandleFitsBySubject,'Renderer','painters');
            print(plotHandleFitsBySubject, plotFileName, '-dpdf', '-fillpage');
            close(plotHandleFitsBySubject);
            
            % store the responseStructCellArray
            meanEvokedResponsesCellArray{experiment}=responseStructCellArray;
        end
        % Save the meanEvokedResponsesCellArray
        meanEvokedHash = DataHash(meanEvokedResponsesCellArray);
        meanEvokedFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_meanEvokedResponse_' meanEvokedHash '.mat']);
        save(meanEvokedFileName,'meanEvokedResponsesCellArray','-v7.3');
        fprintf(['Saved the meanEvokedResponsesCellArray with hash ID ' meanEvokedHash '\n']);
    case 'load'
        fprintf('Loading mean evoked responses\n');
        meanEvokedFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_meanEvokedResponse_' meanEvokedHash '.mat']);
        load(meanEvokedFileName);
    otherwise
        error('Need to either make or load the average responses');
end % switch on meanEvokedResponseBehavior


%% Fit the duration model for the 400% Mel and LMS, and the 200% LMS
switch fitDEDUModelBehavior
    
    case 'make'
        [meanDurations, semDurations, meanAmplitudes, semAmplitudes, plotHandles] = fmriMaxMel_fitDEDUModelToAvgResponse(meanEvokedResponsesCellArray, kernelStructCellArray);        
        % Save plots
        for dd=1:length(plotHandles)
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{dd} '_DurationModelFit_bySubject.pdf']);
            fmriMaxMel_suptitle(plotHandles{dd},[RegionLabels{stimulatedRegion} '-' ExptLabels{dd} ' - DurationModelFitbySubject']);
            set(gca,'FontSize',6);
            set(plotHandles{dd},'Renderer','painters');
            print(plotHandles{dd}, plotFileName, '-dpdf', '-fillpage');
            close(plotHandles{dd});
        end
        % Save the mean and SEM durations
        deduFitsHash = DataHash([meanDurations, semDurations, meanAmplitudes, semAmplitudes]);
        deduFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_fitsDEDUModel_' deduFitsHash '.mat']);
        save(deduFileName,'meanDurations','semDurations','meanAmplitudes','semAmplitudes','-v7.3');
        fprintf(['Saved the DEDU model fits with hash ID ' deduFitsHash '\n']);
    case 'load'
        fprintf('Loading DEDU model fits\n');
        deduFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_fitsDEDUModel_' deduFitsHash '.mat']);
        load(deduFileName);
    otherwise
        fprintf('Skipping analysis of delay model\n');
end

fmriMaxMel_PlotDEDUResults( meanAmplitudes, meanDurations, semAmplitudes, semDurations)


%
%
%         % Obtain the average evoked response for each subject and stimulus type
%         if strcmp(rodScotopicControlBehavior,'make')
%             packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{4} '_' RegionLabels{2} '_' PacketHashArray{4}{2} '.mat']);
%             load(packetFile);
%
%             % Load the kernelStructCellArray
%             kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
%             load(kernelStructCellArrayFileName);
%
%             % Measure the amplitude of responses for the rod control
%             tfeHandle = tfeIAMP('verbosity','none');
%
%             % Convert response.values to % change units
%             % Set the stimuli to have zero onsets
%             for xx=1:size(packetCellArray,1)
%                 for yy=1:size(packetCellArray,2)
%                     signal=packetCellArray{xx,yy}.response.values;
%                     signal=(signal-nanmean(signal))/nanmean(signal);
%                     packetCellArray{xx,yy}.response.values=signal;
%                     stimulus=packetCellArray{xx,yy}.stimulus.values;
%                     stimulus=stimulus-min(min(stimulus));
%                     packetCellArray{xx,yy}.stimulus.values=stimulus;
%                 end
%             end
%
%             kernelMapper=[1,3,4];
%
%             for ss=1:3
%
%                 thePacket=tfeHandle.concatenatePackets(packetCellArray(ss,:),'stimValueExtender',0);
%                 thePacket.kernel = prepareHRFKernel(kernelStructCellArray{kernelMapper(ss)});
%
%                 % Downsample the stimulus to 100msec temporal resolution
%                 msecsToModel=max(thePacket.stimulus.timebase)+1;
%                 modelResolution=100;
%                 newTimebase=linspace(0,msecsToModel-modelResolution,msecsToModel/modelResolution);
%                 thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newTimebase);
%
%                 defaultParamsInfo.nInstances=size(thePacket.stimulus.values,1);
%                 [paramsFit,fVal,modelResponseStruct] = ...
%                     tfeHandle.fitResponse(thePacket,...
%                     'defaultParamsInfo',defaultParamsInfo);
%
%                 figure
%                 tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
%                 hold on
%                 tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
%                 hold off
%                 for ii=1:length(thePacket.stimulus.metaData.stimLabels)
%                     meanResp=mean(paramsFit.paramMainMatrix( find(thePacket.stimulus.metaData.stimTypes==ii) ) );
%                     fprintf([thePacket.stimulus.metaData.stimLabels{ii} '   ' num2str(meanResp*100) '\n']);
%                 end % loop over stimuli
%             end % loop over subjects
%
%         end  % run rod control analysis
%
%
%         if strcmp(rodPhotopicControlBehavior,'make')
%             packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{5} '_' RegionLabels{2} '_' PacketHashArray{5}{2} '.mat']);
%             load(packetFile);
%
%             % Load the kernelStructCellArray
%             kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
%             load(kernelStructCellArrayFileName);
%
%             % Measure the amplitude of responses for the rod control
%             tfeHandle = tfeIAMP('verbosity','none');
%
%             % Convert response.values to % change units
%             % Set the stimuli to have zero onsets
%             for xx=1:size(packetCellArray,1)
%                 for yy=1:size(packetCellArray,2)
%                     if ~isempty(packetCellArray{xx,yy})
%                         signal=packetCellArray{xx,yy}.response.values;
%                         signal=(signal-nanmean(signal))/nanmean(signal);
%                         packetCellArray{xx,yy}.response.values=signal;
%                         stimulus=packetCellArray{xx,yy}.stimulus.values;
%                         stimulus=stimulus-min(min(stimulus));
%                         packetCellArray{xx,yy}.stimulus.values=stimulus;
%                     end
%                 end
%             end
%
%             counter=[5,6,6];
%
%             for ss=1:3
%
%                 thePacket=tfeHandle.concatenatePackets(packetCellArray(ss,1:counter(ss)),'stimValueExtender',0);
%                 thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
%
%                 % Downsample the stimulus to 100msec temporal resolution
%                 msecsToModel=max(thePacket.stimulus.timebase)+1;
%                 modelResolution=100;
%                 newTimebase=linspace(0,msecsToModel-modelResolution,msecsToModel/modelResolution);
%                 thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newTimebase);
%
%                 defaultParamsInfo.nInstances=size(thePacket.stimulus.values,1);
%                 [paramsFit,fVal,modelResponseStruct] = ...
%                     tfeHandle.fitResponse(thePacket,...
%                     'defaultParamsInfo',defaultParamsInfo,...
%                     'searchMethod','linearRegression');
%
%                 figure
%                 tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
%                 hold on
%                 tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
%                 hold off
%                 for ii=1:length(thePacket.stimulus.metaData.stimLabels)
%                     meanResp=mean(paramsFit.paramMainMatrix( find(thePacket.stimulus.metaData.stimTypes==ii) ) );
%                     fprintf([thePacket.stimulus.metaData.stimLabels{ii} '   ' num2str(meanResp*100) '\n']);
%                 end % loop over stimuli
%             end % loop over subjects
%
%         end  % run rod control analysis