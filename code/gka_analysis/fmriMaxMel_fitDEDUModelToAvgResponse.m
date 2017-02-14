function [durationArray, plotHandle] = fmriMaxMel_fitDEDUModelToAvgResponse(meanEvokedResponsesCellArray, kernelStructCellArray, exptIdx, stimulusIdx)
%

verbosity='none';

stimulusDeltaT=1; % time resolution of the stimulus model, in msecs

% Construct the model object
tfeHandle = tfeDEDU('verbosity','none');

% Get the dimensions of the data
nSubjects=size(kernelStructCellArray,2);

plotHandle=figure();
for ss=1:nSubjects
    
    clear thePacket
    
    % Build a packet with a mean response and an impulse stimulus
    thePacket.response = meanEvokedResponsesCellArray{exptIdx}{ss,stimulusIdx};
    thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
    check=diff(thePacket.response.timebase);
    responseDeltaT=check(1);
    totalDuration=max(thePacket.response.timebase)+responseDeltaT;
    thePacket.stimulus.timebase=0:stimulusDeltaT:totalDuration-stimulusDeltaT;
    thePacket.stimulus.values=thePacket.stimulus.timebase*0;
    thePacket.stimulus.values(1) = 1;
    thePacket.stimulus.metaData.stimLabels={'meanResponse'};
    thePacket.stimulus.metaData.stimTypes=[1];
    thePacket.metaData=[];
    
    % Prepare the set of run responses
    runResponses=thePacket.response.runs;
    
    % Prep the run by run responses
    goodRuns= find(~isnan(runResponses(:,1)));
    runResponses=runResponses(goodRuns,:);
    meanInitialValue=mean(runResponses(:,1));
    runResponses=runResponses-meanInitialValue;
    nRuns=size(runResponses,1);

    defaultParamsInfo.nInstances=1;
    % Obtain the fit for the mean response and plot this
    [paramsFit,fVal,modelResponseStruct] = ...
        tfeHandle.fitResponse(thePacket,...
        'defaultParamsInfo', defaultParamsInfo,...
        'DiffMinChange',0.01);

    subplot(4,1,ss)
    tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
    hold on
    tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
    hold off
    
    % Bootstrap-resample the run-by-run data to create different mean
    % responses and fit these. Retain the duration parameter
    for bb=1:100
      runIdx=randsample(1:nRuns,nRuns,true);
      resampleMean=mean(runResponses(runIdx,:));
      thePacket.response.values=resampleMean;
          [paramsFit,~,~] = ...
        tfeHandle.fitResponse(thePacket,...
        'defaultParamsInfo', defaultParamsInfo,...
        'DiffMinChange',0.01);
    durationBoots(bb,ss)=paramsFit.paramMainMatrix(2);
    end
        
end

clear tfeHandle

end % function