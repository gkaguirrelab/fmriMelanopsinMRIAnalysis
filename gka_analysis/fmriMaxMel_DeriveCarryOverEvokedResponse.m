function [responseMatrix] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, kernelFile)
% function [responseStructCellArray, plotHandleBySubject, plotHandleByStimulus] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, subjectScaler)
%

verbosity='none';

% Construct the model object
tfeHandle = tfeIAMP('verbosity',verbosity);

% Set some parameters for the evoked response derivation
msecsToModel=14000;
numFourierComponents=14;

% Loads into memory the variable packetCellArray and kernelStructCellArray
load(packetFile);
load(kernelFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
% Assume that the attention event is the last stimulusType
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

% Create a carry-over matrix that will hold results from each subject
theResponseMatrix=nan(nStimuli,nStimuli,nRuns*2);
theCountMatrix=zeros(nStimuli,nStimuli);

for ss=1:nSubjects
    
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        
        rr
        
        if rr==1
            subjectMetaData{ss}=thePacket.metaData;
        end
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % add the kernel
            thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
            
            % identify the number of stimulus instances in this packet
            stimTypes=thePacket.stimulus.metaData.stimTypes;
            defaultParamsInfo.nInstances=length(stimTypes);
            
            % Fit the signal with the IAMP model, obtaining a beta value
            % for each trial
            [paramsFit,fVal,modelResponseStruct] = ...
                tfeHandle.fitResponse(thePacket,...
                'defaultParamsInfo', defaultParamsInfo);
            
            % sort the values into the carry-over matrix            
            for jj=1:length(stimTypes)
                currentStimulus=stimTypes(jj);
                if jj==1
                    priorStimulus=stimTypes(end);
                else
                    priorStimulus=stimTypes(jj-1);
                end
                theResponseMatrix(priorStimulus,currentStimulus)= ...
                    theResponseMatrix(priorStimulus,currentStimulus)+ ...
                    paramsFit.paramMainMatrix(jj);
                theCountMatrix(priorStimulus,currentStimulus) = ...
                    theCountMatrix(priorStimulus,currentStimulus) +1;
            end % runt through stimTypes
                        
        end % check for not empty packet
    end % loop over runs
    
    badCells=find(theCountMatrix==0);
    if ~isempty(badCells)
        error('There is a bad cell with no values in this carry over matrix');
    end
    
    theResponseMatrix=theResponseMatrix./theCountMatrix;
    
end % loop over subjects



end % function