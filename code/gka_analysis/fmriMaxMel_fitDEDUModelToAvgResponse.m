function [meanAmplitude, semAmplitude, meanDuration, semDuration, xValFVal] = fmriMaxMel_fitDEDUModelToAvgResponse(eventResponseStruct, kernelStruct, plotHandle)
%

verbosity='none';

stimulusDeltaT=1; % time resolution of the stimulus model, in msecs

% Construct the model object
tfeHandle = tfeDEDU('verbosity',verbosity);


% Build a packet with a mean response and an impulse stimulus
thePacket.response = eventResponseStruct;
thePacket.kernel = kernelStruct;
thePacket.kernel.values = thePacket.kernel.values - thePacket.kernel.values(1);
thePacket.kernel = normalizeKernelArea( thePacket.kernel );
check=diff(thePacket.response.timebase);
responseDeltaT=check(1);
totalDuration=max(thePacket.response.timebase)+responseDeltaT;
thePacket.stimulus.timebase=0:stimulusDeltaT:totalDuration-stimulusDeltaT;
thePacket.stimulus.values=thePacket.stimulus.timebase*0;
thePacket.stimulus.values(1) = 1;
thePacket.stimulus.metaData.stimLabels={'event'};
thePacket.stimulus.metaData.stimTypes=[1];
thePacket.metaData=thePacket.response.metaData;

% Prepare the set of run responses
runResponses=thePacket.response.runs*100;

% Prep the run by run responses
goodRuns= find(~isnan(runResponses(:,1)));
runResponses=runResponses(goodRuns,:);
meanInitialValue=mean(runResponses(:,1));
runResponses=runResponses-meanInitialValue;
nRuns=size(runResponses,1);
defaultParamsInfo.nInstances=1;

% Bootstrap-resample the run-by-run data to create different mean
% responses and fit these. Retain the duration parameter
for bb=1:100
    runIdx=randsample(1:nRuns,nRuns,true);
    resampleMean=mean(runResponses(runIdx,:));
    thePacket.response.values=resampleMean;
    
    % Perform the fit and record the params
    [paramsFit,~,~] = ...
        tfeHandle.fitResponse(thePacket,...
        'defaultParamsInfo', defaultParamsInfo,...
        'DiffMinChange',0.01,...
        'errorType','1-r2');
    amplitudeArray(bb)=paramsFit.paramMainMatrix(1);
    durationArray(bb)=paramsFit.paramMainMatrix(2);
end
meanAmplitude=mean(amplitudeArray);
semAmplitude=std(amplitudeArray);
meanDuration=mean(durationArray);
semDuration=std(durationArray);

% Calculate the LOO fVal for the DEDU model
for rr=1:nRuns
    packetCellArray{rr}=thePacket;
    packetCellArray{rr}.response.values=runResponses(rr,:);
    % Adjust the amplitude of the responses by the
    % subjectScaler
    packetCellArray{rr}.response.values = ...
        packetCellArray{rr}.response.values;
end
[ xValFitStructure, ~, ~ ] = ...
    crossValidateFits( packetCellArray, tfeHandle, ...
    'defaultParamsInfo', defaultParamsInfo,...
    'DiffMinChange',0.01,...
    'errorType','1-r2',...
    'partitionMethod','splitHalf',...
    'maxPartitions',500,...
    'aggregateMethod','median');

xValFVal=1-median(xValFitStructure.testfVals);

% Plot the fit
thePacket.response = eventResponseStruct;

[paramsFit,fVal,modelResponseStruct] = ...
    tfeHandle.fitResponse(thePacket,...
    'defaultParamsInfo', defaultParamsInfo,...
    'DiffMinChange',0.01,...
    'errorType','1-r2');
hold on
fmriMaxMel_PlotEvokedResponse( plotHandle, modelResponseStruct.timebase, modelResponseStruct.values, [], 'ylim', [-0.5 1],'xAxisAspect', 0.5, 'lineColor', [1 0 0]);
if xValFVal < 0
    text(plotHandle, 2,-0.25,['r2 (xval) = ' sprintf('%0.2f',1-fVal) ' (' sprintf('%0.2f',xValFVal) ')'],'FontSize',6,'Color','red')
else
    text(plotHandle, 2,-0.25,['r2 (xval) = ' sprintf('%0.2f',1-fVal) ' (' sprintf('%0.2f',xValFVal) ')'],'FontSize',6)
end
hold off

clear tfeHandle

end % function