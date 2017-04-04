function [figHandle] = fmriMaxMel_makeFourierDemoPlot(packetFile)
%

temporalFit = tfeIAMP('verbosity','none');

% Set some parameters for the evoked response derivation
msecsToModel=16000;
numFourierComponents=16;

% Loads into memory the variable packetCellArray
load(packetFile);

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

% Prepare to plot the evoked and fit responses by subject
figHandle=figure();
set(gcf, 'PaperSize', [8.5 11]);
plotHandle=subplot(1,1,1);

% Pick one subject and one run to model
ss=4;
rr=4;

thePacket=packetCellArray{ss,rr};

% Create a stimulus matrix that is just impulses
stimulusStruct=thePacket.stimulus;
[ comboStimulusStruct ] = combineStimInstances( stimulusStruct );
[ impulseStimulusStruct ] = makeImpulseStimStruct( comboStimulusStruct );
modelStruct.timebase=stimulusStruct.timebase;
modelStruct.values=stimulusStruct.timebase*0;

if ~isempty(thePacket)
    % Convert response.values to % change units
    signal=thePacket.response.values;
    signal=(signal-nanmean(signal))/nanmean(signal);
    thePacket.response.values=signal;
    
    for ii=1:nStimuli
        [ eventResponseStruct, fVal, modelResponseStruct ] = ...
            fmriMaxMel_FitFourierBasis(thePacket, ii, ...
            msecsToModel, numFourierComponents);
        
        % Convolve the eventResponseStruct by the impulse stimulus
        subStimulusStruct=impulseStimulusStruct;
        subStimulusStruct.values=subStimulusStruct.values(ii,:);
        subModeledResponse=temporalFit.applyKernel(subStimulusStruct,eventResponseStruct);
        modelStruct.values=modelStruct.values+subModeledResponse.values;
    end
else
    error('Ya gotta give me a packet with something in it!');
end % check for not empty packet

% Plot the Fourier fits
fmriMaxMel_PlotEvokedResponse( plotHandle, modelStruct.timebase, modelStruct.values*100, [],...
    'ylim', [-3 3], 'lineColor', [1 0 0],'lineWidth',0.1,...
    'plotTitle', ['Fourier fits r2= ' strtrim(num2str(fVal)) ],...
    'xTick',1,'xAxisAspect',5, 'xUnits', 'Time [mins]')

hold on

% Plot the time-series data for this subject
fmriMaxMel_PlotEvokedResponse( plotHandle, thePacket.response.timebase, thePacket.response.values*100, [],...
    'ylim', [-3 3], 'lineColor', [.5 .5 .5],'lineWidth',0.1,...
    'marker','.','markerFaceColor',[0.5,0.5,0.5],...
    'xTick',1,'xAxisAspect',5, 'xUnits', 'Time [mins]')

% Add markers for the stimulus events
    for ii=1:nStimuli
fmriMaxMel_PlotEvokedResponse( plotHandle, comboStimulusStruct.timebase, comboStimulusStruct.values(ii,:)-3, [],...
    'ylim', [-3 3], 'lineColor', [ii/(nStimuli+1) ii/(nStimuli+1) 1],'lineWidth',0.5,...
    'xTick',1,'xAxisAspect',5, 'xUnits', 'Time [mins]')

    end
    hold off


end % function