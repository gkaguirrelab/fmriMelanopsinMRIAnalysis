function [meanDurations, semDurations, meanAmplitudes, semAmplitudes, plotHandles] = fmriMaxMel_fitDEDUModelToAvgResponse(meanEvokedResponsesCellArray, kernelStructCellArray)
%

verbosity='none';

stimulusDeltaT=1; % time resolution of the stimulus model, in msecs

% Construct the model object
tfeHandle = tfeDEDU('verbosity',verbosity);

% Get the dimensions of the data
nDirections=2; % just the LMS and Mel stimuli
nContrasts=5; % the number of contrast levels
nSubjects=size(kernelStructCellArray,2);

meanDurations=zeros(nDirections,nContrasts,nSubjects);
semDurations=zeros(nDirections,nContrasts,nSubjects);

for dd=1:nDirections
    fprintf(['Direction ' strtrim(num2str(dd)) '\n']);
    plotHandles{dd}=figure();
    for cc=1:nContrasts
        fprintf(['\tContrast ' strtrim(num2str(cc)) '\n']);
        for ss=1:nSubjects
            fprintf(['\t\tSubject ' strtrim(num2str(ss)) '\n']);
            subPlotHandle=subplot(nContrasts,nSubjects,ss+((cc-1)*nSubjects));
            clear thePacket
            
            % Build a packet with a mean response and an impulse stimulus
            thePacket.response = meanEvokedResponsesCellArray{dd}{ss,cc};
            thePacket.kernel = prepareHRFKernel(kernelStructCellArray{ss});
            check=diff(thePacket.response.timebase);
            responseDeltaT=check(1);
            totalDuration=max(thePacket.response.timebase)+responseDeltaT;
            thePacket.stimulus.timebase=0:stimulusDeltaT:totalDuration-stimulusDeltaT;
            thePacket.stimulus.values=thePacket.stimulus.timebase*0;
            thePacket.stimulus.values(1) = 1;
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
                [paramsFit,~,~] = ...
                    tfeHandle.fitResponse(thePacket,...
                    'defaultParamsInfo', defaultParamsInfo,...
                    'DiffMinChange',0.01);
                amplitudeArray(bb)=paramsFit.paramMainMatrix(1);
                durationArray(bb)=paramsFit.paramMainMatrix(2);
            end
            meanAmplitudes(dd,cc,ss)=mean(amplitudeArray);
            semAmplitudes(dd,cc,ss)=std(amplitudeArray);
            meanDurations(dd,cc,ss)=mean(durationArray);
            semDurations(dd,cc,ss)=std(durationArray);
            
%             % Add to the plot the ±SEM of the fits
%             whips=[ [1,1];[-1,-1];[1,-1];[-1,1]];
%             for rr=1:4
%                 paramsFit.paramMainMatrix(1)=meanAmplitudes(dd,cc,ss) + ...
%                     whips(rr,1)*semAmplitudes(dd,cc,ss);
%                 paramsFit.paramMainMatrix(2)=meanDurations(dd,cc,ss) + ...
%                     whips(rr,2)*semDurations(dd,cc,ss);
%                 modelResponseStruct = tfeHandle.computeResponse(paramsFit,thePacket.stimulus,thePacket.kernel);
%                 fmriMaxMel_PlotEvokedResponse( subPlotHandle, modelResponseStruct.timebase, modelResponseStruct.values, [], 'ylim', [-0.5 2], 'lineColor', [1 .8 .8], 'plotTitle', [thePacket.metaData.subjectName ' - stim ' strtrim(num2str(cc))]);
%                 responseRangeMatrix(rr,:)=modelResponseStruct.values;
%             end
            
            % Plot the mean response and mean fit
            [paramsFit,fVal,modelResponseStruct] = ...
                tfeHandle.fitResponse(thePacket,...
                'defaultParamsInfo', defaultParamsInfo,...
                'DiffMinChange',0.01,...
                'errorType','1-r2');
            fmriMaxMel_PlotEvokedResponse( subPlotHandle, thePacket.response.timebase, thePacket.response.values, [], 'ylim', [-0.5 2], 'lineColor', [0 0 0], 'plotTitle', [thePacket.metaData.subjectName ' - stim ' strtrim(num2str(cc))]);
            fmriMaxMel_PlotEvokedResponse( subPlotHandle, modelResponseStruct.timebase, modelResponseStruct.values, [], 'ylim', [-0.5 2], 'lineColor', [1 0 0], 'plotTitle', [thePacket.metaData.subjectName ' - stim ' strtrim(num2str(cc))]);
            text(2,1.5,['r2 = ' sprintf('%0.2f',1-fVal)],'FontSize',6)
            hold off
            
        end % subjects
    end % contrasts
end % directions

clear tfeHandle

end % function