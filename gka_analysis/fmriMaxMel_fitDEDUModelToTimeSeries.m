function [xValFitStructure, plotHandle] = fmriMaxMel_fitDEDUModelToTimeSeries(packetFile, kernelFile)
%

verbosity='full';

TRmsecs=800;

% Announce our intentions
if strcmp(verbosity,'full')
    fprintf('>> Conducting sequential model fits to the data\n');
end

% Loads into memory the variable packetCellArray and kernelStructCellArray
load(packetFile); % loads the variable packetCellArray
load(kernelFile); % loads the variable kernelStructCellArray

%% Prepare the packetCellArray for fitting
% Loop through the packets and
%  - prepare the HRF kernel
%  - downsample the stimulus array for speed
%  - build an array to identify the stimulus type in each packet

if strcmp(verbosity,'full')
    fprintf('\t Preparing the kernel and stimulus vectors\n');
end

% Construct the model object to be used for resampling and fitting
tfeHandle = tfeDEDU('verbosity','none');

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

for ss=1:nSubjects
    
    % Grab the average hrf and prepare it as a kernel
    % Assume the deltaT of the response timebase is the same
    % across packets for this subject
    theHRFKernelStruct=kernelStructCellArray{ss};
    check = diff(packetCellArray{ss,1}.response.timebase);
    responseDeltaT = check(1);
    nSamples = ceil((theHRFKernelStruct.timebase(end)-theHRFKernelStruct.timebase(1))/responseDeltaT);
    newKernelTimebase = theHRFKernelStruct.timebase(1):responseDeltaT:(theHRFKernelStruct.timebase(1)+nSamples*responseDeltaT);
    theHRFKernelStruct = tfeHandle.resampleTimebase(theHRFKernelStruct,newKernelTimebase);
    theHRFKernelStruct = prepareHRFKernel(theHRFKernelStruct);
    
    for rr=1:nRuns
        thePacket=packetCellArray{ss,rr};
        if ~isempty(thePacket)
            
            % Place the kernel struct in the packet
            thePacket.kernel = theHRFKernelStruct;
            
            % downsample the stimulus values to 100 ms deltaT to speed things up
            totalResponseDuration=TRmsecs * ...
                length(thePacket.response.values);
            newStimulusTimebase=linspace(0,totalResponseDuration-100,totalResponseDuration/100);
            thePacket.stimulus=tfeHandle.resampleTimebase(thePacket.stimulus,newStimulusTimebase);
            
            % convert the response.values to percent change
            signal=thePacket.response.values;
            timeSeriesMean=mean(signal);
            signal=(signal-timeSeriesMean)./timeSeriesMean*100;
            thePacket.response.values=signal;
            
            % put the modified packet back into the cell arrray
            packetCellArray{ss,rr}=thePacket;
            
        end % the packet is not empty
    end % loop over runs
end % loop over subjects


%% Obtain cross-validated variance explained for the DEDU model

if strcmp(verbosity,'full')
    fprintf('\t Obtain cross-validated variance explained for the DEDU model\n');
    plotHandle=figure();
end

for ss=1:nSubjects
        
        % Identify the set of packets for this subject
        subPacketCellArray=packetCellArray(ss,:);

        % Remove any empty packets
        goodPacketIdx=find(~cellfun(@isempty,subPacketCellArray));
        subPacketCellArray=subPacketCellArray(goodPacketIdx);        
        
        % Conduct the cross validation
        [ xValFitStructure, averageResponseStruct, modelResponseStruct ] = crossValidateFits( subPacketCellArray, tfeHandle, ...
            'partitionMethod','loo', ...
            'maxPartitions',20, ...
            'aggregateMethod', 'mean',...
            'verbosity', 'none',...
            'errorType', '1-r2', ...
            'DiffMinChange', 0.001,...
            'verbosity','full');
        
        xValFitStructureCellArray_DEDU{ss}=xValFitStructure;
        
        % Plot the fit to the data
        if strcmp(verbosity,'full')
            subplot(nSubjects,1,ss);
            plot(averageResponseStruct.timebase,averageResponseStruct.values)
            hold on
            plot(modelResponseStruct.timebase,modelResponseStruct.values)
            title(modDirections(ii))
            xlabel('time [msecs]');
            ylabel('response [%]'); set(gca,'FontSize',15); colorbar;
            hold off
        end
        
        % Report the train and test fvals
        if strcmp(verbosity,'minimal')
            fprintf('\t\t\t R-squared train: %g , test: %g \n', 1-mean(xValFitStructure.trainfVals), 1-mean(xValFitStructure.testfVals));
        end
        
end % loop over subjects
delete(tfeHandle);


end % function