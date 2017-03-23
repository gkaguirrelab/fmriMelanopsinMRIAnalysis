function [ plotHandle ] = fmriMaxMel_AnalyzeRodControl( packetFile, kernelStructCellArray )


% Instantiate the tfe
tfeHandle = tfeIAMP('verbosity','none');

% Loop across subjects and  calculate a subjectScaler to adjust other response amplitudes
% based upon HRF amplitude
for ss=1:length(kernelStructCellArray)
    kernelStruct=kernelStructCellArray{ss};
    subjectScaler(ss)=max(kernelStruct.values);
end
subjectScaler=subjectScaler ./ mean(subjectScaler);

% Load the packetCellArray to be fit
load(packetFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));
if nStimuli~=3
    error('The rod control analysis expects three stimulus types');
end

stimLabelA = packetCellArray{1,1}.stimulus.metaData.stimLabels{2};
stimLabelA = stimLabelA(23:34);
stimLabelB = packetCellArray{1,1}.stimulus.metaData.stimLabels{3};
stimLabelB = stimLabelB(23:34);


% Set the plot to have a double-wide column for the time-series fit, and one
% column with the resulting amplitude plot.
nPlotRows = nSubjects;
nPlotCols = 2;

% Prepare to plot the evoked and fit responses by subject
plotHandle=figure();
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

fitResults=NaN(nSubjects,nRuns,3);

% Loop over subjects
for ss=1:nSubjects
        
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % Combine instances of the same stimulus
            thePacket.stimulus = combineStimInstances( thePacket.stimulus );
            nInstances=size(thePacket.stimulus.values,1);
            defaultParamsInfo.nInstances = nInstances;
            
            % Add the HRF for this subject
            kernelStruct=kernelStructCellArray{ss};
            kernelStruct.values = kernelStruct.values - kernelStruct.values(1);
            kernelStruct = normalizeKernelArea( kernelStruct );
            thePacket.kernel=kernelStruct;

            % fit the IAMP model
            [paramsFit,fVal,modelResponseStruct] = ...
                tfeHandle.fitResponse(thePacket,...
                'defaultParamsInfo', defaultParamsInfo, ...
                'searchMethod','linearRegression', ...
                'errorType','1-r2');
            
            paramValues=paramsFit.paramMainMatrix./subjectScaler(ss);
            fitResults(ss,rr,:)=paramValues;
            
            % Build vectors for the data and the model fit to be used for
            % plotting later. This routine will fail if the first packet is
            % empty, which shouldn't happen.  ¯\_(")_/¯
            if rr==1
                subjectMetaData{ss}=thePacket.metaData;
                subjectDataSeries=thePacket.response.values;
                subjectFitSeries=modelResponseStruct.values;
                subjectTimebase=thePacket.response.timebase;
                check = diff(thePacket.response.timebase);
                fVals(rr)=1-fVal;
                deltaT = check(1);
            else
                subjectDataSeries=[subjectDataSeries thePacket.response.values];
                subjectFitSeries=[subjectFitSeries modelResponseStruct.values];
                nextTimePoint=max(subjectTimebase)+deltaT;
                subjectTimebase=[subjectTimebase thePacket.response.timebase+nextTimePoint];
                fVals(rr)=1-fVal;
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
    
    % Create a plot of the average response to the Mel and L?M modulations
    % against the background condition
    stimAAmps=fitResults(ss,:,2)-fitResults(ss,:,1);
    stimBAmps=fitResults(ss,:,3)-fitResults(ss,:,1);
    stimAMean=nanmean(stimAAmps);
    stimASEM=nanstd(stimAAmps)/sqrt(length(stimAAmps)-sum(isnan(stimAAmps)));
    stimBMean=nanmean(stimBAmps);
    stimBSEM=nanstd(stimBAmps)/sqrt(length(stimBAmps)-sum(isnan(stimBAmps)));
    errorbar(subPlotHandle{ss,2},[1 2],[stimAMean stimBMean]*100,[stimASEM stimBSEM]*100,'ro');
    xlim(subPlotHandle{ss,2},[0 3]);
    ylim(subPlotHandle{ss,2},[-0.5 1]);
    pbaspect(subPlotHandle{ss,2},[1 1 1])
    title(subPlotHandle{ss,2},'Mean ±SEM across runs','Interpreter', 'none');
    ylabel(subPlotHandle{ss,2},'% BOLD change');
    xlab={' ',stimLabelA,stimLabelB,''};
    set(subPlotHandle{ss,2},'Xtick',[0:3])
    set(subPlotHandle{ss,2},'XTickLabel',xlab);
    set(subPlotHandle{ss,2},'FontSize',6);
    box(subPlotHandle{ss,2},'off');
    hline = refline(subPlotHandle{ss,2},[0 0]);
    set(hline,'LineStyle',':')
end % loop over subjects




end

