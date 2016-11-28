function [responseStructCellArray] = fmriMaxMel_DeriveMeanEvokedResponse(packetFile)
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




% obtain the mean and SEM of the response across all measures for each
% subject / stimulus
figure
responseStructCellArray=[];
for ss=1:nSubjects
    subplot(nSubjects+1,1,ss);
    for ii=1:nStimuli
        subjectMatrix=squeeze(responseMatrix(ii,ss,:,:));
        runCount=sum(~isnan(subjectMatrix(:,1)));
        meanResponse=squeeze(nanmean(subjectMatrix))*100;
        meanResponse=meanResponse-meanResponse(1);
        semResponse=squeeze(nanmean(subjectMatrix))*100/sqrt(runCount);
        responseStruct.timebase=timebase;
        responseStruct.values=meanResponse;
        responseStruct.sem=semResponse;
        responseStruct.metaData.subjectName=subjectMetaData{ss}.subjectName;
        responseStruct.metaData.numberEvents=runCount;
        responseStruct.metaData.units='%change';
        responseStructCellArray{ss,ii}=responseStruct;
        plot(meanResponse);
        hold on
    end % loop over stimuli
    hold off
end % loop over subjects

% Add the average across subjects
subplot(nSubjects+1,1,nSubjects+1);
for ii=1:nStimuli
    dataMatrix=[];
    for ss=1:nSubjects
        dataMatrix(ss,:)=responseStructCellArray{ss,ii}.values;
    end
    meanResponse=nanmean(dataMatrix);
    semResponse=nanmean(dataMatrix)/sqrt(nSubjects);
    plot(meanResponse);
    ylim([-0.5 1]);
    hold on
end % loop over stimuli

end % function