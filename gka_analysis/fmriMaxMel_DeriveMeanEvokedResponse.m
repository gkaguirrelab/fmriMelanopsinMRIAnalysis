function [responseStructCellArray, plotHandleBySubject, plotHandleByStimulus] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile, subjectScaler)
% function [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray)
%

verbosity='none';

% Set some parameters for the evoked response derivation
msecsToModel=14000;
numFourierComponents=14;

% Loads into memory the variable packetCellArray
load(packetFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

% Assume that the attention event is the last stimulusType
nStimuli=nStimuli-1;

for ss=1:nSubjects
    
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        
        if rr==1
            subjectMetaData{ss}=thePacket.metaData;
        end
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % Loop over the stimuli
            for ii=1:nStimuli
                
                [ responseStruct ] = ...
                    fmriMaxMel_FitFourierBasis(thePacket, ii, ...
                    msecsToModel, numFourierComponents);
                
                if (ii==1 && ss==1 && rr==1)
                    timebase=responseStruct.timebase;
                    responseMatrix=NaN(nStimuli,nSubjects,nRuns,length(responseStruct.values));
                end
                
                responseMatrix(ii,ss,rr,:)=responseStruct.values;
            end % loop over stimulus types
        end % check for not empty packet
    end % loop over runs
end % loop over subjects



% obtain the mean across all measures for each
% subject / stimulus
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
        responseStruct.timebase=timebase;
        responseStruct.values=meanResponse;
        responseStruct.sem=semResponse;
        responseStruct.metaData.subjectName=subjectMetaData{ss}.subjectName;
        responseStruct.metaData.numberEvents=runCount;
        responseStruct.metaData.units='%change';
        responseStructCellArray{ss,ii}=responseStruct;
        acrossStimResponse(ii,:)=meanResponse;
        % plot the mean response and error
        lineColorBase = [(1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1)];
        fmriMaxMel_PlotEvokedResponse( subPlotHandle{ss}, timebase, meanResponse, [], 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', responseStruct.metaData.subjectName);
    end % loop over stimuli
    
    % Obtain the amplitude of the average response to all stimuli for a
    % given subject    
    subjectScaler(ss)=max(mean(acrossStimResponse));
    
end % loop over subjects

subjectScaler=subjectScaler ./ mean(subjectScaler);
subjectScaler

% Add the average across subjects

for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values;% ./ subjectScaler(ss);
    end
    meanResponse=nanmean(dataMatrix);
    % plot the mean response and error
    lineColorBase = [(1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1) (1+nStimuli-ii)/(nStimuli+1)];
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{nSubjects+1}, timebase, meanResponse, [], 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', 'subject mean (with subject scaler)');
end % loop over stimuli
hold off


% obtain the mean and SEM of the response across subjects for each stimulus
plotHandleByStimulus=figure();
set(gcf, 'PaperSize', [8.5 11]);
for ii=1:nStimuli
    subPlotHandle{ii}=subplot(nStimuli,1,ii);
end
hold on

for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values;% ./ subjectScaler(ss);
    end
    meanResponse=nanmean(dataMatrix);
    semResponse=nanstd(dataMatrix)/sqrt(nSubjects);
    % plot the mean response and error
    lineColorBase = [1 0 0];
    fmriMaxMel_PlotEvokedResponse( subPlotHandle{ii}, timebase, meanResponse, semResponse, 'ylim', [-0.5 1], 'lineColor', lineColorBase, 'plotTitle', ['stimulus ' num2str(ii) ' (with subjectScaler) ± SEM subjects']);
end % loop over stimuli
hold off



end % function