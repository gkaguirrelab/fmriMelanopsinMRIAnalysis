% fmriMaxMel_main
%
% Code to analyze the MaxMel collection of data.

%% Housekeeping
clearvars; close all; clc;
warning on;

%% Hardcoded parameters of analysis

% Define cache behavior
kernelCacheBehavior='make';
meanEvokedResponseBehavior='load';
carryOverResponseBehavior='skip';
rodControlBehavior='skip';

region = 'V2' ; % can be {'V1', 'V2', 'V3'};

switch region
    case 'V1'
        % The components that define the different packetCache files
        ExptLabels={'LMSCRF','MelCRF','SplatterControlCRF','MaxLMS400Pct','MaxMel400Pct','RodControlScotopic','RodControlPhotopic'};
        RegionLabels={'V1_0_1.5deg','V1_5_25deg','V1_40_60deg'};
        
        % The set of hashes the define the data and results
        kernelStructCellArrayHash='1ba4a33ed4f33a37cc2c4e92957e1742';
        meanEvokedHash='1d42dc538c8ebeb7e8595be8a8406cca';
        deduFitsHash='13b945241e8b527afa7033cb96f08187';
        
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
        
        PacketHashArray{4,:}={'7183b32247e38e57d9f79837e356364b',...
            'a45d3bad8efe3479556043e5aba548ad',...
            '9620037cb005cab3e1a8c77d8fad065d'};
        
        PacketHashArray{5,:}={'69c04e554b19ad70d8df10e9f390c96a',...
            '618e569cc7d15f0ba6be2efd13fc1bc8',...
            'fccae2cbaac87497b217e67cfa1f7361'};
        
        PacketHashArray{6,:}={'6939bbf2b4a94099f7e4d8675050b938',...
            'c9e33fa8705bd06b4885b65420c63ddc',...
            '434a3800e449942c04e6e1a3989886c0'};
        
        PacketHashArray{7,:}={'2d4d7d6bdfadf61d51a45184bae7807c',...
            '2da7196e692caf04c08751a96724ae92',...
            '62706c1a5756e6642fc866faa1860636'};
        
    case 'V2'
         % The components that define the different packetCache files
        ExptLabels={'MaxLMS400Pct','MaxMel400Pct'};
        RegionLabels={'V2_0_1.5deg','V2_5_25deg','V2_40_60deg'};
        
%         % The set of hashes the define the data and results
%         kernelStructCellArrayHash='1ba4a33ed4f33a37cc2c4e92957e1742';
        meanEvokedHash='1d42dc538c8ebeb7e8595be8a8406cca';
%         deduFitsHash='13b945241e8b527afa7033cb96f08187';
        
        % Packet hash array ordered by ExptLabels then RegionLabels
        PacketHashArray{1,:}={'03e81a74ee1eebdb26347f45e8646abc',...
            'b78c97069da69f2e5137cb60de410843',...
            'bee949a888766c7b2a05cc6153d7cfa6'};
        
        PacketHashArray{2,:}={'a55c987854a857a808640f716849235b',...
            'd980eea4703eee88d76adb2355135ad9',...
            '4a928c80f6c3847bffe296e13a328e91'};
        
    case 'V3'
         % The components that define the different packetCache files
        ExptLabels={'MaxLMS400Pct','MaxMel400Pct'};
        RegionLabels={'V3_0_1.5deg','V3_5_25deg','V3_40_60deg'};
        
%         % The set of hashes the define the data and results
%         kernelStructCellArrayHash='1ba4a33ed4f33a37cc2c4e92957e1742';
        meanEvokedHash='1d42dc538c8ebeb7e8595be8a8406cca';
%         deduFitsHash='13b945241e8b527afa7033cb96f08187';
        
        % Packet hash array ordered by ExptLabels then RegionLabels
        PacketHashArray{1,:}={'c2e57f1c14a394bde529031ec74d51da',...
            'f55fb6357b2c1f8bf369d73a933a8819',...
            'ba2319fcde7d551688c9dd9d8ed9f8eb'};
        
        PacketHashArray{2,:}={'5af3a4dbb1142470a0d5c9999c550843',...
            'c21387f1ccc551ccd76cf5fdc12c511d',...
            'c8fce6518d03c3ce491e0b65dfd0e2cc'};
        
end

% Discover user name and find the Dropbox directory
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));
if strcmp(hostname,'melchior.uphs.upenn.edu') %melchior has some special dropbox folder settings
    dropboxDir = '/Volumes/Bay_2_data/giulia/Dropbox-Aguirre-Brainard-Lab';
else % other machines use the standard dropbox location
    [~, userName] = system('whoami');
    userName = strtrim(userName);
    dropboxDir = ...
        fullfile('/Users', userName, ...
        '/Dropbox (Aguirre-Brainard Lab)');
end

dropboxAnalysisDir = ...
    fullfile(dropboxDir, 'MELA_analysis/fmriMelanopsinMRIAnalysis/');

dropBoxHEROkernelStructDir = ...
    fullfile(dropboxDir, 'Team Documents/Cross-Protocol Subjects/HERO_kernelStructCache/');


%% Pick a region to analyze and define the list of packet files
stimulatedRegion=2; % The primary region of analysis
packetFiles=cell(length(ExptLabels),1);
for ii=1:length(ExptLabels)
    packetFiles{ii}=fullfile(dropboxAnalysisDir, 'packetCache', ['MelanopsinMR_' ExptLabels{ii} '_' RegionLabels{stimulatedRegion} '_' PacketHashArray{ii}{stimulatedRegion} '.mat']);
end


%% Make or load the empirical HRF (aka, kernel) for each subject
switch kernelCacheBehavior
    case 'make'
        fprintf('Making the kernelStructCellArray\n');
        
        
        switch region
            case 'V1'
                [kernelStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles(1:5,:));
                notes='Average evoked response to attention events from 5-25 degree region of V1. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the LMS CRF, Mel CRF, and Splatter CRF, and the 400%LMS and 400%Mel experiments';
            case 'V2'
                [kernelStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles(1:2,:));
                notes='Average evoked response to attention events from 5-25 degree region of V2. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the 400%LMS and 400%Mel experiments';
            case 'V3'
                [kernelStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles(1:2,:));
                notes='Average evoked response to attention events from 5-25 degree region of V3. Each event was a 500 msec dimming of the OneLight stimulus. Events taken from all runs of the 400%LMS and 400%Mel experiments';
        end
        % Save the plot of the HRFs
        plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [region '_EmpiricalHRFs.pdf']);
        fmriMaxMel_suptitle(plotHandle,[RegionLabels{stimulatedRegion} '- Empirical HRFs']);
        set(gca,'FontSize',6);
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
    case 'load'
        fprintf('Loading the kernelStructCellArray\n');
        % Load the kernelStructCellArray
        kernelStructCellArrayFileName=fullfile(dropboxAnalysisDir,'kernelCache', [RegionLabels{stimulatedRegion} '_hrf_' kernelStructCellArrayHash '.mat']);
        load(kernelStructCellArrayFileName);
    otherwise
        error('You must either make or load the kernelStructCellArray');
end % switch on kernelCacheBehavior



%% Make or load the average evoked responses and perform DEDU fitting
switch meanEvokedResponseBehavior
    case 'make'
        fprintf('Obtaining mean evoked responses\n');
        for experiment=1:2
            % Derive mean evoked response
            [responseStructCellArray, deduFitDataExperiment, plotHandleAverages] = fmriMaxMel_DeriveMeanEvokedResponse(packetFiles{experiment}, kernelStructCellArray);
            deduFitData{experiment}=deduFitDataExperiment;
            % save plot of response averages
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_' region '_TrialMeanResponses.pdf']);
            fmriMaxMel_suptitle(plotHandleAverages,[RegionLabels{stimulatedRegion} '-' ExptLabels{experiment} ' - CRFs']);
            set(gca,'FontSize',6);
            set(plotHandleAverages,'Renderer','painters');
            print(plotHandleAverages, plotFileName, '-dpdf', '-fillpage');
            close(plotHandleAverages);            
            % store the responseStructCellArray
            meanEvokedResponsesCellArray{experiment}=responseStructCellArray;
        end
        % Save the meanEvokedResponsesCellArray
        meanEvokedHash = DataHash(meanEvokedResponsesCellArray);
        meanEvokedFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_meanEvokedResponse_' meanEvokedHash '.mat']);
        save(meanEvokedFileName,'meanEvokedResponsesCellArray','-v7.3');
        fprintf(['Saved the meanEvokedResponsesCellArray with hash ID ' meanEvokedHash '\n']);
        % Save the DEDU model fits
        deduFitsHash = DataHash(deduFitData);
        deduFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_fitsDEDUModel_' deduFitsHash '.mat']);
        save(deduFileName,'deduFitData','-v7.3');
        fprintf(['Saved the deduFitData with hash ID ' deduFitsHash '\n']);
        % Create and save the CRF plots for the DEDU model amplitude
        % responses
        subjectNameFunc=@(x) meanEvokedResponsesCellArray{1}{x,1}.metaData.subjectName;
        [figHandle]=fmriMaxMel_makeCRFResultFigure( deduFitData, subjectNameFunc, 'amplitude');
        plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [region '_AmplitudeCRFsFromDEDUFit.pdf']);
        set(figHandle,'Renderer','painters');
        print(figHandle, plotFileName, '-dpdf', '-fillpage');
        close(figHandle);
        subjectNameFunc=@(x) meanEvokedResponsesCellArray{1}{x,1}.metaData.subjectName;
        [figHandle]=fmriMaxMel_makeCRFResultFigure( deduFitData, subjectNameFunc, 'duration');
        plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [region '_DurationCRFsFromDEDUFit.pdf']);
        set(figHandle,'Renderer','painters');
        print(figHandle, plotFileName, '-dpdf', '-fillpage');
        close(figHandle);
        % Save a demo plot of the DEDU model for one HRF
        [plotHandle] = fmriMaxMel_makeDEDUDemoPlot(kernelStructCellArray{3});
        plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [region '_ExampleDEDUModelParamSpace.pdf']);
        set(gca,'FontSize',6);
        set(plotHandle,'Renderer','painters');
        print(plotHandle, plotFileName, '-dpdf', '-fillpage');
        close(plotHandle);        
    case 'load'
        fprintf('Loading mean evoked responses\n');
%         meanEvokedFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_meanEvokedResponse_' meanEvokedHash '.mat']);
        meanEvokedFileName=fullfile(dropboxAnalysisDir,'analysisCache', ['V1_5_25deg_meanEvokedResponse_' meanEvokedHash '.mat']);
        load(meanEvokedFileName);
        fprintf('Loading deduFitData\n');
%         deduFileName=fullfile(dropboxAnalysisDir,'analysisCache', [RegionLabels{stimulatedRegion} '_fitsDEDUModel_' deduFitsHash '.mat']);
        deduFileName=fullfile(dropboxAnalysisDir,'analysisCache', ['V1_5_25deg_fitsDEDUModel_' deduFitsHash '.mat']);
        load(deduFileName);
    otherwise
        fprintf('Skipping analysis of mean evoked responses\n');        
end % switch on meanEvokedResponseBehavior


%% Conduct the carry-over response analysis
switch carryOverResponseBehavior
    case 'make'
        fprintf('Analyzing carry-over effects\n');
        
        % Obtain the carry-over matrix for the LMS, Mel, and Splatter stimuli and save plot
        for experiment=1:3
            [responseMatrix, plotHandle] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFiles{experiment}, deduFitData{experiment}, kernelStructCellArray);
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{experiment} '_' region '_CarryOverEffects.pdf']);
            saveas(plotHandle,plotFileName);
            close(plotHandle);
        end % loop over stimuli
    otherwise
        fprintf('Skipping analysis of carry-over effects\n');
end % switch for carryOverResponseBehavior


%% Anayze the rod control experiment
switch rodControlBehavior
    case 'make'
        fprintf('Analyzing rod control experiment\n');
        controlExptIDs=[6,7];
        for ii=1:length(controlExptIDs)
            % conduct analysis
            [plotHandle]=fmriMaxMel_AnalyzeRodControl(packetFiles{controlExptIDs(ii)}, kernelStructCellArray);
            % save plot
            plotFileName=fullfile(dropboxAnalysisDir, 'Figures', [ExptLabels{controlExptIDs(ii)} '_Responses.pdf']);
            fmriMaxMel_suptitle(plotHandle,[RegionLabels{stimulatedRegion} '-' ExptLabels{controlExptIDs(ii)} ' - Responses']);
            set(gca,'FontSize',6);
            set(plotHandle,'Renderer','painters');
            print(plotHandle, plotFileName, '-dpdf', '-fillpage');
            close(plotHandle);
        end
    otherwise
        fprintf('Skipping rod control analysis');
end % switch on rodControlBehavior
