function [responseStructCellArray, plotHandleBySubject, plotHandleByStimulus, plotHandleFitsBySubject] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile, subjectScaler)
% function [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray)
%

verbosity='full';

% Set some parameters for the evoked response derivation
msecsToModel=16000;
numFourierComponents=16;

% Loads into memory the variable packetCellArray
load(packetFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

% Assume that the attention event is the last stimulusType
nStimuli=nStimuli-1;

% Prepare to plot the time series data and the fit
plotHandleFitsBySubject=figure();
set(gcf, 'PaperSize', [8.5 11]);

% Loop over subjects
for ss=1:nSubjects
    
    if strcmp(verbosity,'full')
        fprintf(['\tFitting Fourier model to obtain mean response for subject' strtrim(num2str(ss)) '\n']);
    end
    
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % Loop over the stimuli
            for ii=1:nStimuli
                
                [ eventResponseStruct, fVal, modelResponseStruct ] = ...
                    fmriMaxMel_FitFourierBasis(thePacket, ii, ...
                    msecsToModel, numFourierComponents);
                
                if (ii==1 && ss==1 && rr==1)
                    timebase=eventResponseStruct.timebase;
                    responseMatrix=NaN(nStimuli,nSubjects,nRuns,length(eventResponseStruct.values));
                end
                
                responseMatrix(ii,ss,rr,:)=eventResponseStruct.values;
            end % loop over stimulus types
            
            % Build vectors for the data and the model fit to be used for
            % plotting later. This routine will fail if the first packet is
            % empty, which shouldn't happen.  ¯\_(")_/¯
            if rr==1
                subjectMetaData{ss}=thePacket.metaData;
                subjectDataSeries=thePacket.response.values;
                subjectFitSeries=modelResponseStruct.values;
                subjectTimebase=thePacket.response.timebase;                
                check = diff(thePacket.response.timebase);
                fVals(rr)=fVal;
                deltaT = check(1);
            else
                subjectDataSeries=[subjectDataSeries thePacket.response.values];
                subjectFitSeries=[subjectFitSeries modelResponseStruct.values];
                nextTimePoint=max(subjectTimebase)+deltaT;
                subjectTimebase=[subjectTimebase thePacket.response.timebase+nextTimePoint];
                fVals(rr)=fVal;
            end % check for first packet
        end % check for not empty packet
    end % loop over runs
    
    % Plot the time-series data and fits for this subject
    tmpHandle=subplot(nSubjects,1,ss);
    fmriMaxMel_PlotEvokedResponse( tmpHandle, subjectTimebase, subjectDataSeries*100, [],...
        'ylim', [-2 2], 'lineColor', [.5 .5 .5],'lineWidth',.75,...
        'plotTitle', [subjectMetaData{ss}.subjectName ' r2= ' strtrim(num2str(mean(fVals)))],...
        'xTick',60,'xAxisAspect',20)
    hold on
    fmriMaxMel_PlotEvokedResponse( tmpHandle, subjectTimebase, subjectFitSeries*100, [],...
        'ylim', [-2 2], 'lineColor', [1 0 0],'lineWidth',0.25,...
        'plotTitle', [subjectMetaData{ss}.subjectName ' r2= ' strtrim(num2str(mean(fVals)))],...
        'xTick',60,'xAxisAspect',20)
    hold off
    
end % loop over subjects


% Prepare to plot the evoked and fit responses by subject
plotHandleBySubject=figure();
set(gcf, 'PaperSize', [8.5 11]);
for ss=1:nSubjects+1
    subPlotHandle{ss}=subplot(nSubjects+1,1,ss);
end
hold on

% While we are looping over stimuli and subjects, obtain the average
% response across stimuli for each subject. This is then used to adjust the
% amplitude of the data from each subject prior to averaging.

responseStructCellArray=[];
for ss=1:nSubjects
    
    acrossStimResponse=[];
    
    for ii=1:nStimuli
        subjectMatrix=squeeze(responseMatrix(ii,ss,:,:));
        runCount=sum(~isnan(subjectMatrix(:,1)));
        meanResponse=squeeze(nanmean(subjectMatrix))*100;
        meanResponse=meanResponse-meanResponse(1);
        semResponse=squeeze(nanstd(subjectMatrix))*100/sqrt(runCount);
        eventResponseStruct.timebase=timebase;
        eventResponseStruct.values=meanResponse;
        eventResponseStruct.sem=semResponse;
        eventResponseStruct.metaData.subjectName=subjectMetaData{ss}.subjectName;
        eventResponseStruct.metaData.numberEvents=runCount;
        eventResponseStruct.metaData.units='%change';
        responseStructCellArray{ss,ii}=eventResponseStruct;
        acrossStimResponse(ii,:)=meanResponse;
        % plot the mean response and error
        lineColorBase = [(1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1)];
        fmriMaxMel_PlotEvokedResponse( subPlotHandle{ss}, timebase, meanResponse, [], 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', eventResponseStruct.metaData.subjectName);
    end % loop over stimuli
    
    
end % loop over subjects

% The subjectScaler is an array of HRF amplitudes, one for each subject.
% We adjust these to have a mean of unity, and then use this to scale
% responses from each subject prior to calculating the across-subject
% evoked response average
subjectScaler=subjectScaler ./ mean(subjectScaler);

% Calculate the average evoked response by stimulus and subject
for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values ./ subjectScaler(ss);
    end
    meanResponse=nanmean(dataMatrix);
    % plot the mean response and error
    lineColorBase = [(1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1)];
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{nSubjects+1}, timebase, meanResponse, [], 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', 'subject mean (w/subject scaler)');
end % loop over stimuli
hold off

% obtain the mean and SEM of the response across subjects for each stimulus
plotHandleByStimulus=figure();
set(gcf, 'PaperSize', [8.5 11]);
for ii=1:nStimuli
    subPlotHandle{ii}=subplot(max([5,nStimuli]),1,ii);
end
hold on

for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values ./ subjectScaler(ss);
    end
    meanResponse=nanmean(dataMatrix);
    semResponse=nanstd(dataMatrix)/sqrt(nSubjects);
    % plot the mean response and error
    lineColorBase = [1 0 0];
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{ii}, timebase, meanResponse, semResponse, 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', ['stimulus ' num2str(ii) ' ± SEM subjects (w/subject scaler)']);
end % loop over stimuli
hold off



end % function