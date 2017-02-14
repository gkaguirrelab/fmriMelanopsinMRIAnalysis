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

   % Build a packet with a mean response and an impulse stimulus

    thePacket.response = meanEvokedResponsesCellArray{exptIdx}{ss,stimulusIdx};
    thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
    check=diff(thePacket.response.timebase);
    responseDeltaT=check(1);
    totalDuration=max(thePacket.response.timebase)+responseDeltaT;
    thePacket.stimulus.timebase=0:stimulusDeltaT:totalDuration-stimulusDeltaT;
    thePacket.stimulus.values=thePacket.stimulus.timebase*0;
    thePacket.stimulus.values(1) = 1;
    
   % Build a packetCellArray by copying over the run-by-run responses into the model packet
   runResponses=thePacket.response.runs;
   nRuns=size(runResponses,1);
   for rr=1:nRuns
   packetCellArray{rr}=thePacket;
   theResponse=runResponses(rr,:);
   % set the mean of the initial value to zero across runs
   theResponse=theResponse-thePacket.response.values(1);
   packetCellArray{rr}.response.values=theResponse;
   end
   
    
    
    
    defaultParamsInfo.nInstances=1;

         [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
             'partitionMethod','bootstrap', ...
             'maxPartitions',100, ...
             'aggregateMethod', 'mean',...
             'verbosity', 'none',...
             'errorType', '1-r2', ...
             'DiffMinChange', 0.001,...
             'verbosity','full');

    subplot(4,1,ss)
    tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
    hold on
    tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
    hold off
    durationArray(ss)=paramsFit.paramMainMatrix(3);
end

clear tfeHandle

end % function