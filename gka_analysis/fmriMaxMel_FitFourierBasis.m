function [responseStruct] = fmriMaxMel_FitFourierBasis( thePacket, stimIndex, msecsToModel, numFourierComponents )
% function [kernelStructCellArray] = fmriMaxMel_FitFourierBasis( thePacket, msecsToModel, numFourierComponents )
%
% Fits a Fourier basis set to each event specified in thePacket,
% and returns a kernelStructCellArray that has an estimate of the average evoked
% response to each stimulus type.
%
% Arguments in:
%  - thePacket - the packet to be analyzed.
%  - stimIndex - which stimType to fit
%  - msecsToModel - the duration (in msecs) of the window over which the
%    Fourier basis set should model events.
%  - numFourierComponents - The number of Fourier components to have in the
%    model fit. This includes the zeroeth (DC) frequency component.
%
% Arguments out:
%  - kernelStruct - a structure that contains the timebase and values of
%    the mean evoked response estimated using the Fourier basis set.
%

% instantiate the model object that will be used for fitting
temporalFit = tfeIAMP('verbosity','none');

% Create an eventTimesArray that has the time of onset of each of this
% stimulus type
eventIdx=find(thePacket.stimulus.metaData.stimTypes==stimIndex);
eventTimesArray=zeros(1,length(eventIdx));
for ee=1:length(eventIdx)
    
    % Find the stimulus onsets so that we can adjust the model to it. We
    % do that by finding a [0 1] edge from a difference operator.
    stimulus=thePacket.stimulus.values(eventIdx(ee),:);
    tmp = diff(stimulus);
    tmp(tmp < 0) = 0;
    tmp(tmp > 0) = 1;
    
    % Check if the very first value is 1, in which case the stim onset is
    % at the initial value
    if tmp(1)==1
        eventTimesArray(ee) = thePacket.stimulus.timebase(1);
    else
        eventTimesArray(ee) = thePacket.stimulus.timebase(strfind(tmp, [0 1]));
    end
end % loop over instances of this stimulusType

% Create the stimulusStructure that contains the Fourier components
[stimulusStruct, fourierSetStructure] = ...
    makeFourierStimStruct( thePacket.stimulus.timebase, ...
    eventTimesArray, ...
    msecsToModel, numFourierComponents );

% build the attentionEventPacket for fitting
stimulusEventPacket.stimulus=stimulusStruct;
stimulusEventPacket.response.timebase=thePacket.response.timebase;
stimulusEventPacket.response.values=thePacket.response.values;
stimulusEventPacket.kernel=[];
stimulusEventPacket.metaData=[];

% set up the default properties of the fit
paramLockMatrix = []; % unused
defaultParamsInfo.nInstances = numFourierComponents;

% Derive the Fourier set fit
[paramsFit,~,~] = ...
    temporalFit.fitResponse(stimulusEventPacket,...
    'defaultParamsInfo', defaultParamsInfo, ...
    'paramLockMatrix',paramLockMatrix, ...
    'searchMethod','linearRegression');

% Recover the modeled response and place into a kernel struct.
responseStruct.timebase=fourierSetStructure.timebase;

% Multiply the amplitude values of the parameter fit by the elements of the
% Fourier Set
responseStruct.values=(fourierSetStructure.values'*paramsFit.paramMainMatrix)';

% Down-sample the kernelStruct to the resolution of the model
%modelResolution=msecsToModel/numFourierComponents;
%newTimebase=linspace(0,msecsToModel-modelResolution,msecsToModel/modelResolution);
%responseStruct=temporalFit.resampleTimebase(responseStruct,newTimebase);


% close the temporalFit object
clear temporalFit

end % function
