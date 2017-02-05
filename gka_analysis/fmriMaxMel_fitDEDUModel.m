function [durationArray, plotHandle] = fmriMaxMel_fitDEDUModel(meanEvokedResponsesCellArray, kernelStructCellArray, exptIdx, stimulusIdx)
% function [delayArray, plotHandle] = fmriMaxMel_fitDEDUModel(meanEvokedResponsesCellArray, kernelStructCellArray, exptIdx, stimulusIdx)
%

verbosity='none';

% Construct the model object
tfeHandle = tfeDEDU('verbosity','none');

% Get the dimensions of the data
nSubjects=size(kernelStructCellArray,2);

plotHandle=figure();

for ss=1:nSubjects
    thePacket.response = meanEvokedResponsesCellArray{exptIdx}{ss,stimulusIdx};
    thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
    thePacket.stimulus = thePacket.response;
    thePacket.stimulus.values = thePacket.stimulus.values*0;
    thePacket.stimulus.values(1) = 1;
    thePacket.metaData = [];
    
    defaultParamsInfo.nInstances=1;
    [paramsFit,fVal,modelResponseStruct] = ...
        tfeHandle.fitResponse(thePacket,...
        'defaultParamsInfo', defaultParamsInfo, ...
        'DiffMinChange',0.001);
    subplot(4,1,ss)
    tfeHandle.plot(thePacket.response,'NewWindow',false,'DisplayName','Data');
    hold on
    tfeHandle.plot(modelResponseStruct,'NewWindow',false,'Color',[.5 .5 .5],'DisplayName','Fit');
    hold off
    durationArray(ss)=paramsFit.paramMainMatrix(3);
end

clear tfeHandle

end % function