function [responseStructCellArray, plotHandle] = fmriMaxMel_DeriveEmpiricalHRFs(packetFiles)
% function [packetCellArray] = fmriBDFM_DeriveHRFsForPacketCellArray(packetCellArray)
%

verbosity='none';

% Set some parameters for the HRF derivation
msecsToModel=14000;
numFourierComponents=14;

% Since the number of runs can vary across subjects / experiments, I'll
% hard code the max number here. It is not harmful for this value to be
% larger than the actual maximum number of runs across subjects /
% experiments. If too small, the routine will (appropriately) crash.
maxNRuns=12;

nPackets=length(packetFiles);

for pp=1:nPackets
    
    % Loads into memory the variable packetCellArray
    load(packetFiles{pp});
    
    nSubjects=size(packetCellArray,1);
    nRuns=size(packetCellArray,2);
    
    for ss=1:nSubjects
        
        for rr=1:nRuns
            thePacket=packetCellArray{ss,rr};
            
            if rr==1
                subjectMetaData{ss}=thePacket.metaData;
            end
            
            if ~isempty(thePacket)
                
                % Check the number of stimuli in the first packet. Assume that the
                % attention event is the last stimulusType
                nStimuli=length(unique(thePacket.stimulus.metaData.stimTypes));
                stimIndex=nStimuli;
                                
                % Convert response.values to % change units
                signal=thePacket.response.values;
                signal=(signal-nanmean(signal))/nanmean(signal);
                thePacket.response.values=signal;
                
                [ responseStruct ] = ...
                    fmriMaxMel_FitFourierBasis(thePacket, stimIndex, ...
                    msecsToModel, numFourierComponents);
                
                if (pp==1 && ss==1 && rr==1)
                    timebase=responseStruct.timebase;
                    responseMatrix=NaN(nPackets,nSubjects,maxNRuns,length(responseStruct.values));
                end
                
                responseMatrix(pp,ss,rr,:)=responseStruct.values;
                
            end % check for not empty packet
        end % loop over runs
    end % loop over subjects
end % loop over packets


% Obtain the mean and SEM of the HRF response across all measures for each
% subject and place this in the responseStructCellArray that will be
% returned. Also, make a plot of the HRFs and return a plotHandle

plotHandle=figure();
set(plotHandle,'PaperSize',[4,11])
responseStructCellArray=[];
for ss=1:nSubjects
    subplot(nSubjects+1,1,ss);
    subjectMatrix=squeeze(responseMatrix(:,ss,:,:));
    runCount=sum(sum(~isnan(subjectMatrix(:,:,1))));
    meanResponse=squeeze(nanmean(nanmean(subjectMatrix)))*100;
    meanResponse=meanResponse-meanResponse(1);
    semResponse=squeeze(nanmean(nanmean(subjectMatrix)))*100/sqrt(runCount);
    responseStruct.timebase=timebase;
    responseStruct.values=meanResponse';
    responseStruct.sem=semResponse';
    responseStruct.metaData.subjectName=subjectMetaData{ss}.subjectName;
    responseStruct.metaData.numberEvents=runCount;
    responseStruct.metaData.units='%change';
    responseStructCellArray{ss}=responseStruct;
    plot(timebase/1000,meanResponse,'Color',[1 0 0]);
    hold on
    plot(timebase/1000,meanResponse+semResponse,'Color',[0.5 0.5 0.5]);
    plot(timebase/1000,meanResponse-semResponse,'Color',[0.5 0.5 0.5]);
    ylim([-0.5 2]);
    xlim([0 14]);
    title(responseStruct.metaData.subjectName,'Interpreter', 'none'); axis square;
    xlabel('Time [secs]'); ylabel('% BOLD change');
        set(gca,'Xtick',0:1:14)

set(gca,'FontSize',6); 
end % loop over subjects

% Add the average across subjects
subplot(nSubjects+1,1,nSubjects+1);
dataMatrix=[];
for ss=1:nSubjects
    dataMatrix(ss,:)=responseStructCellArray{ss}.values;
end
meanResponse=nanmean(dataMatrix);
semResponse=nanmean(dataMatrix)/sqrt(nSubjects);
plot(timebase/1000,meanResponse,'Color',[1 0 0]);
hold on
plot(timebase/1000,meanResponse+semResponse,'Color',[0.5 0.5 0.5]);
plot(timebase/1000,meanResponse-semResponse,'Color',[0.5 0.5 0.5]);
ylim([-0.5 2]);
xlim([0 14]);
title('mean across subject'); axis square;
xlabel('Time [secs]'); ylabel('% BOLD change');
    set(gca,'Xtick',0:1:14)
set(gca,'FontSize',6); 
fmriMaxMel_suptitle(plotHandle,'HRFs for each subject');
set(gca,'FontSize',6); 
end % function