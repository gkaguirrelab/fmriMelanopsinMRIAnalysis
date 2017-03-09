function [responseStructCellArray, deduFitData, plotHandleAverages] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile, kernelStructCellArray, subjectScaler)
% function [responseStructCellArray, deduFitData, plotHandleAverages] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile, kernelStructCellArray, subjectScaler)
%

verbosity='full';

% Set some parameters for the evoked response derivation
msecsToModel=16000;
numFourierComponents=16;

% Loop across subjects and  calculate a subjectScaler to adjust other response amplitudes
% based upon HRF amplitude
for ss=1:length(kernelStructCellArray)
    kernelStruct=kernelStructCellArray{ss};
    subjectScaler(ss)=max(kernelStruct.values);
end
subjectScaler=subjectScaler ./ mean(subjectScaler);

% Loads into memory the variable packetCellArray
load(packetFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Identify the stimulus type
stimType=packetCellArray{1,1}.stimulus.metaData.stimLabels;
stimType=stimType{1};
switch stimType
    case 'MelanopsinMRMaxLMS_PulseMaxLMS_3s_CRF16sSegment_025Pct'
        lineColorBase=[.25 .25 .25];
    case 'MelanopsinMRMaxMel_PulseMaxMel_3s_CRF16sSegment_025Pct'
        lineColorBase=[0 0 1];
    case 'MelanopsinMR_SplatterControlPulse_3s_CRF16sSegment_025Pct'
        lineColorBase=[1 0 0];
    case 'MelanopsinMRMaxLMS_PulseMaxLMS_3s_MaxContrast16sSegment_400Pct'
        lineColorBase=[.25 .25 .25];
    case 'MelanopsinMRMaxMel_PulseMaxMel_3s_MaxContrast16sSegment_400Pct'
        lineColorBase=[0 0 1];
end

% Check the number of stimuli in the first packet.
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

% Assume that the attention event is the last stimulusType
nStimuli=nStimuli-1;

% Set all plots to have the same number of rows and columns, including a
% row for average responses, and 2 columns for the Fourier fit to the raw
% time series
nPlotRows = nSubjects+1;
nPlotCols = max([nStimuli+1,6]);

% Prepare to plot the evoked and fit responses by subject
plotHandleAverages=figure();
set(gcf, 'PaperSize', [8.5 11]);
for ss=1:nPlotRows
    for ii=1:nPlotCols
        if ii==1
            subPlotHandle{ss,ii}=subplot(nPlotRows,nPlotCols+1,[(ss-1)*(nPlotCols+1)+1, (ss-1)*(nPlotCols+1)+2]);
        else
            subPlotHandle{ss,ii}=subplot(nPlotRows,nPlotCols+1,(ss-1)*(nPlotCols+1)+ii+1);
        end
    end
end
hold on

% Loop over subjects
for ss=1:nSubjects
    
    if strcmp(verbosity,'full')
        fprintf(['\tFitting Fourier model to obtain mean response for subject ' strtrim(num2str(ss)) '\n']);
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
                
                % Adjust the modeled response amplitude by the subject
                % scaler, and save
                responseMatrix(ii,ss,rr,:)=eventResponseStruct.values ./ subjectScaler(ss);
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
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{ss,1}, subjectTimebase, subjectDataSeries*100, [],...
        'ylim', [-3 3], 'lineColor', [.5 .5 .5],'lineWidth',.2,...
        'xTick',10,'xAxisAspect',1, 'xUnits', 'Time [mins]')
    hold on
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{ss,1}, subjectTimebase, subjectFitSeries*100, [],...
        'ylim', [-3 3], 'lineColor', [1 0 0],'lineWidth',0.1,...
        'plotTitle', [subjectMetaData{ss}.subjectName ' r2= ' strtrim(num2str(mean(fVals))) ],...
        'xTick',10,'xAxisAspect',1, 'xUnits', 'Time [mins]')
    hold off
    
end % loop over subjects

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
        eventResponseStruct.runs=subjectMatrix;
        eventResponseStruct.metaData.subjectName=subjectMetaData{ss}.subjectName;
        eventResponseStruct.metaData.numberEvents=runCount;
        eventResponseStruct.metaData.units='%change [subect scaler]';
        responseStructCellArray{ss,ii}=eventResponseStruct;
        acrossStimResponse(ii,:)=meanResponse;
        % plot the across-run mean response and SEM (by run) error
        % only show the plot axes for the first subject / first contrast level
        if ii==1
            dataOnly=false;
        else
            dataOnly=true;
        end
        fmriMaxMel_PlotEvokedResponse( subPlotHandle{ss,ii+1}, timebase, meanResponse, semResponse, 'dataOnly', dataOnly, 'ylim', [-0.5 1], 'xAxisAspect', 1, 'yAxisAspect', 2, 'lineColor', lineColorBase, 'plotTitle', [eventResponseStruct.metaData.subjectName ' ±SEM runs [' num2str(runCount) '] - w/subject scaler']);
        % Perform the DEDU model fit, and plot this
        [meanAmplitude, semAmplitude, meanDuration, semDuration, xValFVal] = ...
            fmriMaxMel_fitDEDUModelToAvgResponse(eventResponseStruct, kernelStructCellArray{ss}, subPlotHandle{ss,ii+1});
        deduFitData{ss,ii}.meanAmplitude= meanAmplitude;
        deduFitData{ss,ii}.semAmplitude= semAmplitude;
        deduFitData{ss,ii}.meanDuration= meanDuration;
        deduFitData{ss,ii}.semDuration= semDuration;
        deduFitData{ss,ii}.xValFVal= xValFVal;
    end % loop over stimuli
    
    
end % loop over subjects

% Calculate the average evoked response across subjects
for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values;
    end
    meanResponse=nanmean(dataMatrix);
    semResponse=nanstd(dataMatrix)/sqrt(nSubjects);
    % plot the mean response and error
    % only show the plot axes for the first contrast level
    if ii==1
        dataOnly=false;
    else
        dataOnly=true;
    end
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{nPlotRows, ii+1}, timebase, meanResponse, semResponse, 'dataOnly', dataOnly, 'ylim', [-0.5 1],'xAxisAspect', 1, 'yAxisAspect', 2, 'lineColor', lineColorBase, 'plotTitle', ['stimulus ' num2str(ii) ' ± SEM subjects (w/subject scaler)']);
end % loop over stimuli
hold off



end % function