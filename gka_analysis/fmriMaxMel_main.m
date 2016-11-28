% fmriMaxMel_main
%
% Code to analyze the MaxMel collection of data.

%% Housekeeping
clearvars; close all; clc;
warning on;

%% Hardcoded parameters of analysis

% Define cache behavior
kernelCacheBehavior='make';
meanEvokedResponseBehavior='make';
rodScotopicControlBehavior='make';
rodPhotopicControlBehavior='make';

ExptLabels={'LMSCRF','MelCRF','SplatterControlCRF','RodControlScotopic','RodControlPhotopic'};
RegionLabels={'V1_0_1.5deg','V1_5_25deg','V1_40_60deg'};
stimulatedRegion=2; % The primary region of analysis

kernelStructCellArrayHash='9b003a07f79e59b5ee02b1afb48c7ccc';

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
    'Dropbox-Aguirre-Brainard-Lab/Team Documents/Cross-Protocol Subjects/HERO_kernelStructCache/');


%% Derive the empirical HRF for each subject
if strcmp(kernelCacheBehavior,'make')
    
    % Set up the packetNames for the 5-25° field for the LMS, Mel, and
    % Splatter experiments. Obtain the HRFs.
    packetFiles={fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{1} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{1}{stimulatedRegion} '.mat']),...
        fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{2} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{2}{stimulatedRegion} '.mat']),...
        fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{3} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{3}{stimulatedRegion} '.mat'])};
    [kernelStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles);
    notes='Average evoked response to attention events from 5-25 degree region of V1. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the LMS CRF, Mel CRF, and Splatter CRF experiments';
    
    % Save the plot of the HRFs
    plotFileName=fullfile(dropboxAnalysisDir, 'Figures', 'EmpiricalHRFs.pdf');
    set(plotHandle,'Renderer','painters');
    print(plotHandle, plotFileName, '-dpdf', '-fillpage');
    close(plotHandle);
    
    % Loop across subjects and save the HRF for each subject
    for ss=1:length(kernelStructCellArray)
        kernelStruct=kernelStructCellArray{ss};
        kernelStruct.metaData.notes=notes;
        
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
    
end % make HRFs


%% Obtain the average evoked responses and model the neural duration
if strcmp(meanEvokedResponseBehavior,'make')
    packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{1} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{1}{stimulatedRegion} '.mat']);
    [LMS_responseStructCellArray, plotHandle] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile);
    plotFileName=fullfile(dropboxAnalysisDir, 'Figures', 'LMS_CRFs.pdf');
    fmriMaxMel_suptitle(plotHandle,'LMS CRFs');
    set(gca,'FontSize',6); 
    set(plotHandle,'Renderer','painters');
    print(plotHandle, plotFileName, '-dpdf', '-fillpage');
    close(plotHandle);
    
    packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{2} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{2}{stimulatedRegion} '.mat']);
    [Mel_responseStructCellArray, plotHandle] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile);
    plotFileName=fullfile(dropboxAnalysisDir, 'Figures', 'Mel_CRFs.pdf');
    fmriMaxMel_suptitle(plotHandle,'Mel CRFs');
    set(gca,'FontSize',6); 
    set(plotHandle,'Renderer','painters');
    print(plotHandle, plotFileName, '-dpdf', '-fillpage');
    close(plotHandle);
        
    packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{3} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{3}{stimulatedRegion} '.mat']);
    [Splatter_responseStructCellArray, plotHandle] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile);
    plotFileName=fullfile(dropboxAnalysisDir, 'Figures', 'Splatter_CRFs.pdf');
    fmriMaxMel_suptitle(plotHandle,'Splatter CRFs');
    set(gca,'FontSize',6); 
    set(plotHandle,'Renderer','painters');
    print(plotHandle, plotFileName, '-dpdf', '-fillpage');
    close(plotHandle);
    
    
    % Load the kernelStructCellArray
    kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
    load(kernelStructCellArrayFileName);
    
    % Fit the 400% contrast response for the LMS and Mel with the DEDU model
    figure
    tfeHandle = tfeDEDU('verbosity','none');
    
    for ss=1:4
        thePacket.response = LMS_responseStructCellArray{ss,5};
        thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
        thePacket.stimulus = thePacket.response;
        thePacket.stimulus.values = thePacket.stimulus.values*0;
        thePacket.stimulus.values(1) = 1;
        thePacket.metaData = [];
        
        defaultParamsInfo.nInstances=1;
        [paramsFit,fVal,modelResponseStruct] = ...
            tfeHandle.fitResponse(thePacket,...
            'defaultParamsInfo', defaultParamsInfo, ...
            'DiffMinChange',0.001);
        subplot(4,1,ss)
        tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
        hold on
        tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
        hold off
        fprintf('Model parameter from fits:\n');
        tfeHandle.paramPrint(paramsFit);
        fprintf('\n');
    end
    
    % Fit the 400% contrast response for the LMS and Mel with the DEDU model
    figure
    for ss=1:4
        thePacket.response = Mel_responseStructCellArray{ss,5};
        thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
        thePacket.stimulus = thePacket.response;
        thePacket.stimulus.values = thePacket.stimulus.values*0;
        thePacket.stimulus.values(1) = 1;
        thePacket.metaData = [];
        
        defaultParamsInfo.nInstances=1;
        [paramsFit,fVal,modelResponseStruct] = ...
            tfeHandle.fitResponse(thePacket,...
            'defaultParamsInfo', defaultParamsInfo, ...
            'DiffMinChange',0.001);
        subplot(4,1,ss)
        tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
        hold on
        tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
        hold off
        fprintf('Model parameter from fits:\n');
        tfeHandle.paramPrint(paramsFit);
        fprintf('\n');
    end
    
    clear tfeHandle
    
end  % make average evoked responses.


% Obtain the average evoked response for each subject and stimulus type
if strcmp(rodScotopicControlBehavior,'make')
    packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{4} '_' RegionLabels{2} '_' PacketHashArray{4}{2} '.mat']);
    load(packetFile);
    
    % Load the kernelStructCellArray
    kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
    load(kernelStructCellArrayFileName);
    
    % Measure the amplitude of responses for the rod control
    tfeHandle = tfeIAMP('verbosity','none');
    
    % Convert response.values to % change units
    % Set the stimuli to have zero onsets
    for xx=1:size(packetCellArray,1)
        for yy=1:size(packetCellArray,2)
            signal=packetCellArray{xx,yy}.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            packetCellArray{xx,yy}.response.values=signal;
            stimulus=packetCellArray{xx,yy}.stimulus.values;
            stimulus=stimulus-min(min(stimulus));
            packetCellArray{xx,yy}.stimulus.values=stimulus;
        end
    end
    
    kernelMapper=[1,3,4];
    
    for ss=1:3
        
        thePacket=tfeHandle.concatenatePackets(packetCellArray(ss,:),'stimValueExtender',0);
        thePacket.kernel = prepareHRFKernel(kernelStructCellArray{kernelMapper(ss)});
        
        % Downsample the stimulus to 100msec temporal resolution
        msecsToModel=max(thePacket.stimulus.timebase)+1;
        modelResolution=100;
        newTimebase=linspace(0,msecsToModel-modelResolution,msecsToModel/modelResolution);
        thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newTimebase);
        
        defaultParamsInfo.nInstances=size(thePacket.stimulus.values,1);
        [paramsFit,fVal,modelResponseStruct] = ...
            tfeHandle.fitResponse(thePacket,...
            'defaultParamsInfo',defaultParamsInfo);
        
        figure
        tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
        hold on
        tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
        hold off
        for ii=1:length(thePacket.stimulus.metaData.stimLabels)
            meanResp=mean(paramsFit.paramMainMatrix( find(thePacket.stimulus.metaData.stimTypes==ii) ) );
            fprintf([thePacket.stimulus.metaData.stimLabels{ii} '   ' num2str(meanResp*100) '\n']);
        end % loop over stimuli
    end % loop over subjects
    
end  % run rod control analysis


if strcmp(rodPhotopicControlBehavior,'make')
    packetFile=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{5} '_' RegionLabels{2} '_' PacketHashArray{5}{2} '.mat']);
    load(packetFile);
    
    % Load the kernelStructCellArray
    kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
    load(kernelStructCellArrayFileName);
    
    % Measure the amplitude of responses for the rod control
    tfeHandle = tfeIAMP('verbosity','none');
    
    % Convert response.values to % change units
    % Set the stimuli to have zero onsets
    for xx=1:size(packetCellArray,1)
        for yy=1:size(packetCellArray,2)
            if ~isempty(packetCellArray{xx,yy})
            signal=packetCellArray{xx,yy}.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            packetCellArray{xx,yy}.response.values=signal;
            stimulus=packetCellArray{xx,yy}.stimulus.values;
            stimulus=stimulus-min(min(stimulus));
            packetCellArray{xx,yy}.stimulus.values=stimulus;
            end
        end
    end
    
    counter=[5,6,6];
    
    for ss=1:3
        
        thePacket=tfeHandle.concatenatePackets(packetCellArray(ss,1:counter(ss)),'stimValueExtender',0);
        thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
        
        % Downsample the stimulus to 100msec temporal resolution
        msecsToModel=max(thePacket.stimulus.timebase)+1;
        modelResolution=100;
        newTimebase=linspace(0,msecsToModel-modelResolution,msecsToModel/modelResolution);
        thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newTimebase);
        
        defaultParamsInfo.nInstances=size(thePacket.stimulus.values,1);
        [paramsFit,fVal,modelResponseStruct] = ...
            tfeHandle.fitResponse(thePacket,...
            'defaultParamsInfo',defaultParamsInfo,...
            'searchMethod','linearRegression');
        
        figure
        tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
        hold on
        tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
        hold off
        for ii=1:length(thePacket.stimulus.metaData.stimLabels)
            meanResp=mean(paramsFit.paramMainMatrix( find(thePacket.stimulus.metaData.stimTypes==ii) ) );
            fprintf([thePacket.stimulus.metaData.stimLabels{ii} '   ' num2str(meanResp*100) '\n']);
        end % loop over stimuli
    end % loop over subjects
    
end  % run rod control analysis