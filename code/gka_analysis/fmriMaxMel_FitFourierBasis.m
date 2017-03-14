function [eventResponseStruct, fVal, modelResponseStruct] = fmriMaxMel_FitFourierBasis( thePacket, stimIndex, msecsToModel, numFourierComponents )
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

% Create the Fourier covariate model for all stimuli
nStimuli=length(unique(thePacket.stimulus.metaData.stimTypes));

stimulusEventPacket=thePacket;
stimulusEventPacket.stimulus.values=[];
stimulusEventPacket.stimulus.metaData=[];
stimulusEventPacket.kernel=[];

for ss=1:nStimuli
    % Create an eventTimesArray that has the time of onset for this stim type
    eventIdx=find(thePacket.stimulus.metaData.stimTypes==ss);
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
    
    % build the stimulusEventPacket for fitting
    if ss==1
        stimulusEventPacket.stimulus.values=stimulusStruct.values;
        stimulusEventPacket.stimulus.metaData.stimTypes=repmat(ss,1,numFourierComponents);
    else
        stimulusEventPacket.stimulus.values = ...
            [stimulusEventPacket.stimulus.values; stimulusStruct.values];
        stimulusEventPacket.stimulus.metaData.stimTypes = ...
            [stimulusEventPacket.stimulus.metaData.stimTypes,repmat(ss,1,numFourierComponents)];
    end
end % loop over stimulus types

% set up the default properties of the fit
paramLockMatrix = []; % unused
defaultParamsInfo.nInstances = size(stimulusEventPacket.stimulus.values,1);

% Derive the Fourier set fit
[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(stimulusEventPacket,...
    'defaultParamsInfo', defaultParamsInfo, ...
    'paramLockMatrix',paramLockMatrix, ...
    'searchMethod','linearRegression',...
    'errorType','1-r2');

% Recover the modeled response and place into a kernel struct.
eventResponseStruct.timebase=fourierSetStructure.timebase;

% Multiply the amplitude values of the parameter fit by the elements of the
% Fourier Set
idxToSample=find(stimulusEventPacket.stimulus.metaData.stimTypes==stimIndex);
eventResponseStruct.values=(fourierSetStructure.values'*paramsFit.paramMainMatrix(idxToSample))';

% close the temporalFit object
clear temporalFit

end % function
