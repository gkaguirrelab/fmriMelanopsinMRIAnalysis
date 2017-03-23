function [plotHandle] = fmriMaxMel_makeDEDUDemoPlot(kernelStruct)
%

verbosity='none';

stimulusDeltaT=1; % time resolution of the stimulus model, in msecs
totalDuration=16000;

% Construct the model object
tfeHandle = tfeDEDU('verbosity',verbosity);

% Prepare the kernel for convolution
kernelStruct.values = kernelStruct.values - kernelStruct.values(1);
kernelStruct = normalizeKernelArea( kernelStruct );

stimulusStruct=kernelStruct;
stimulusStruct.values=stimulusStruct.values*0;
stimulusStruct.values(1)=1;

defaultParamsInfo.nInstances=1;

plotHandle=figure();

for duration = 1:6 % this is in seconds
for amplitude = 1:6 % proportion of 1 unit of response
    subplotHandle=subplot(6,6,(amplitude-1)*6+duration);

    % Get the default DEDU parameters and insert our model values
    params = tfeHandle.defaultParams('defaultParamsInfo', defaultParamsInfo);
    params.paramMainMatrix=[1/amplitude duration];
    modelResponseStruct = tfeHandle.computeResponse(params,stimulusStruct,kernelStruct);
    
            if duration==1 && amplitude==1
            dataOnly=false;
        else
            dataOnly=true;
        end
        fmriMaxMel_PlotEvokedResponse( subplotHandle, modelResponseStruct.timebase, modelResponseStruct.values, [], 'dataOnly', dataOnly, 'ylim', [-0.5 1], 'xAxisAspect', 1, 'yAxisAspect', 2, 'lineColor', [1 0 0]);

end
end

clear tfeHandle

end % function