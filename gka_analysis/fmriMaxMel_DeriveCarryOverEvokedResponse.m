function [meanResponseMatrix, plotHandle] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, kernelFile)
% function [responseMatrix] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, kernelFile)
%

verbosity='none';

% Construct the model object
tfeHandle = tfeIAMP('verbosity',verbosity);

% Set some parameters for the evoked response derivation
msecsToModel=14000;
numFourierComponents=14;
TRmsecs=800;

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
acrossSubMatrix=zeros(nStimuli,nStimuli,nSubjects);

for ss=1:nSubjects

    theResponseMatrix=zeros(nStimuli,nStimuli);
    theCountMatrix=zeros(nStimuli,nStimuli);

    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
                
        if rr==1
            subjectMetaData{ss}=thePacket.metaData;
        end
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % grab the subject hrf and prepare it as a kernel
            hrfKernelStruct=kernelStructCellArray{ss};
            check = diff(thePacket.response.timebase);
            responseDeltaT = check(1);
            nSamples = ceil((hrfKernelStruct.timebase(end)-hrfKernelStruct.timebase(1))/responseDeltaT);
            newKernelTimebase = hrfKernelStruct.timebase(1):responseDeltaT:(hrfKernelStruct.timebase(1)+nSamples*responseDeltaT);
            hrfKernelStruct = tfeHandle.resampleTimebase(hrfKernelStruct,newKernelTimebase);
            thePacket.kernel=prepareHRFKernel(hrfKernelStruct);
            
            % downsample the stimulus values to 100 ms deltaT to speed things up
            totalResponseDuration=TRmsecs * ...
                length(thePacket.response.values);
            newStimulusTimebase=linspace(0,totalResponseDuration-100,totalResponseDuration/100);
            thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newStimulusTimebase);
                        
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
        
    acrossSubMatrix(:,:,ss)=theResponseMatrix./theCountMatrix;
    
end % loop over subjects

meanResponseMatrix=nanmean(acrossSubMatrix,3);
semResponseMatrix=nanstd(acrossSubMatrix,1,3)/sqrt(nSubjects);

plotHandle=figure();
set(gcf, 'PaperSize', [8.5 11]);
imagesc(meanResponseMatrix);

end % function