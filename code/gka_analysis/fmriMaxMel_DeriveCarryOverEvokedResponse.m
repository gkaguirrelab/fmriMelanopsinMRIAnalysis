function [grandMean, figHandle] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, deduFitData, kernelStructCellArray)
% function [responseMatrix] = fmriMaxMel_DeriveCarryOverEvokedResponse(packetFile, kernelFile)
%

verbosity='none';

% Construct the model object
tfeIAMPHandle = tfeIAMP('verbosity',verbosity);
tfeDEDUHandle = tfeDEDU('verbosity',verbosity);

% Loop across subjects and  calculate a subjectScaler to adjust other response amplitudes
% based upon HRF amplitude
for ss=1:length(kernelStructCellArray)
    kernelStruct=kernelStructCellArray{ss};
    subjectScaler(ss)=max(kernelStruct.values);
end
subjectScaler=subjectScaler ./ mean(subjectScaler);

% Loads into memory the variable packetCellArray
load(packetFile);

% Get the dimensions of the data
nSubjects=size(packetCellArray,1);
nRuns=size(packetCellArray,2);

% Check the number of stimuli in the first packet.
% Assume that the attention event is the last stimulusType
nStimuli=length(unique(packetCellArray{1,1}.stimulus.metaData.stimTypes));

% Create a carry-over matrix that will hold results from each subject
acrossSubMeans=zeros(nSubjects,nStimuli,nStimuli);
acrossSubSEMs=zeros(nSubjects,nStimuli,nStimuli);

% Prepare a figure
figHandle=figure();

for ss=1:nSubjects
    
    acrossRunMatrix=nan(nRuns,nStimuli,nStimuli);
    
    for rr=1:nRuns
        
        carryOverVals=zeros(nStimuli,nStimuli);
        carryOverCounts=zeros(nStimuli,nStimuli);
        
        thePacket=packetCellArray{ss,rr};
        
        if rr==1
            subjectMetaData{ss}=thePacket.metaData;
        end
        
        if ~isempty(thePacket)
            % Convert response.values to % change units
            signal=thePacket.response.values;
            signal=(signal-nanmean(signal))/nanmean(signal);
            thePacket.response.values=signal;
            
            % identify the number of stimulus instances in this packet
            stimTypes=thePacket.stimulus.metaData.stimTypes;
            defaultParamsInfo.nInstances=length(stimTypes);
            
            % Convert the stimulus instances to impulses
            thePacket.stimulus = makeImpulseStimStruct( thePacket.stimulus );
            
            % Prepare the HRF kernel for this subject
            kernelStruct = kernelStructCellArray{ss};
            kernelStruct.values = kernelStruct.values - kernelStruct.values(1);
            kernelStruct = normalizeKernelAmplitude( kernelStruct );
            
            % Now loop through the stimulus instances and replace the
            % stimulus model with the DEDU HRF fit
            for ii=1:length(stimTypes)
                thisStim=stimTypes(ii);
                stimulusStruct=thePacket.stimulus;
                stimulusStruct.values=stimulusStruct.values(ii,:);
                if thisStim==nStimuli % The stimulus is the attention trial
                    durationInSecs=0.001;
                else
                    durationInSecs=deduFitData{ss,thisStim}.meanDuration;
                end
                params = tfeDEDUHandle.defaultParams('defaultParamsInfo', defaultParamsInfo);
                params.paramMainMatrix=[1 durationInSecs];
                modelResponseStruct = tfeDEDUHandle.computeResponse(params,stimulusStruct,kernelStruct);
                thePacket.stimulus.values(ii,:)=modelResponseStruct.values(1,:);
            end % loop over stimulus types
            
            % Fit the signal with the IAMP model, obtaining a beta value
            % for each trial
            [paramsFit,fVal,modelResponseStruct] = ...
                tfeIAMPHandle.fitResponse(thePacket,...
                'defaultParamsInfo', defaultParamsInfo,...
                'errorType','1-r2',...
                'searchMethod','linearRegression');
            
            % sort the values into the carry-over matrix
            for jj=1:length(stimTypes)
                currentStimulus=stimTypes(jj);
                if jj==1
                    priorStimulus=stimTypes(end);
                else
                    priorStimulus=stimTypes(jj-1);
                end
                % Add the fit values into the response matrix, adjusting
                % for the subjectScaler
                carryOverVals(priorStimulus,currentStimulus)= ...
                    carryOverVals(priorStimulus,currentStimulus)+ ...
                    paramsFit.paramMainMatrix(jj)/subjectScaler(ss);
                carryOverCounts(priorStimulus,currentStimulus) = ...
                    carryOverCounts(priorStimulus,currentStimulus) +1;
            end % runt through stimTypes
            acrossRunMatrix(rr,:,:)=carryOverVals./carryOverCounts;
        end % check for not empty packet
    end % loop over runs
    
    acrossSubMeans(ss,:,:)=squeeze(nanmean(acrossRunMatrix));
    acrossSubSEMs(ss,:,:)=squeeze(nanstd(acrossRunMatrix))./sqrt(nRuns-squeeze(sum(isnan(acrossRunMatrix))));
    
    % Dump the mean response to the biggest stimulus from the start and end
    % of the scan session
%     outLine=['Subject ' num2str(ss) ' -  run 1-2: '];
%     outLine=[outLine num2str(100*nanmean(nanmean(nanmean(acrossRunMatrix(1:2,1:nStimuli-1,nStimuli-1)))))];
%     outLine=[outLine '  7-8: '];
%     outLine=[outLine num2str(100*nanmean(nanmean(nanmean(acrossRunMatrix(7:8,1:nStimuli-1,nStimuli-1)))))];
%     fprintf([outLine '\n']);

    % Calculate the linear effect of current and prior stimulus
    for ii=1:nStimuli-1
        X1(ii,1:nStimuli-1)=ii;
        X2(1:nStimuli-1,ii)=ii;
    end
    X1=X1-mean(mean(X1));
    X2=X2-mean(mean(X2));
    X1=X1/max(max(X1));
    X2=X2/max(max(X2));
    data=squeeze(acrossSubMeans(ss,1:nStimuli-1,1:nStimuli-1));
    [b,~,stats]=glmfit([X1(:), X2(:)],data(:));
    b=b*100;
    outLine=['Subject ' num2str(ss) ' - '];
    outLine=[outLine 'current stim fx: ' num2str(b(3)) ' (' num2str(stats.p(3)) '); ' ];
    outLine=[outLine 'prior stim fx: ' num2str(b(2)) ' (' num2str(stats.p(2)) ') \n' ];
    fprintf(outLine);

    if nStimuli==6
      stimLabels={'25','50','100','200','400'};
    end
    if nStimuli==5
      stimLabels={[char(188) 'x'], [char(189) 'x'],'1x','2x'}; 
    end
    subplotHandle=subplot(2,nSubjects+1,ss);
    hold on
    for ii=1:nStimuli-1
        lineColor=[1-(ii/nStimuli) 1-(ii/nStimuli) 1-(ii/nStimuli)];
        fmriMaxMel_PlotCRF( subplotHandle, 1:1:nStimuli-1, acrossSubMeans(ss,1:nStimuli-1,ii)*100, acrossSubSEMs(ss,1:nStimuli-1,ii)*100, ...
            'xTickLabels',stimLabels,...
            'xlim',[0 7],...
            'lineColor',lineColor,...
            'markerColor',lineColor,...
            'errorColor',[.75 .75 .75],...
            'xLabel','prior trial contrast',...
            'plotTitle',['subject ' num2str(ss)]);
        scaledIdx=(ii-mean(1:1:(nStimuli-1)))/((nStimuli-1)-mean(1:1:(nStimuli-1)));
        plot([1 nStimuli-1],[b(1)+b(3)*scaledIdx+b(2)*(-1) b(1)+b(3)*scaledIdx+b(2)*(1)],'-r')
    end
    
    subplotHandle=subplot(2,nSubjects+1,ss+nSubjects+1);
    k=squeeze(acrossSubMeans(ss,1:nStimuli-1,1:nStimuli-1))*100;
    image(k,'CDataMapping','scaled')
    colormap(autumn)
    caxis([-0.5,1]);
    pbaspect([1 1 1]);
    xlabel('current stim');
    ylabel('prior stim')
    xticklabels(stimLabels);
    yticklabels(stimLabels);
end % loop over subjects

grandMean=squeeze(nanmean(acrossSubMeans));
grandSEM=squeeze(nanstd(acrossSubMeans))/sqrt(nSubjects);

    % Calculate the linear effect of current and prior stimulus
    for ii=1:nStimuli-1
        X1(ii,1:nStimuli-1)=ii;
        X2(1:nStimuli-1,ii)=ii;
    end
    X1=X1-mean(mean(X1));
    X2=X2-mean(mean(X2));
    X1=X1/max(max(X1));
    X2=X2/max(max(X2));
    data=squeeze(grandMean(1:nStimuli-1,1:nStimuli-1));
    [b,~,stats]=glmfit([X1(:), X2(:)],data(:));
    b=b*100;
    outLine=['Grand mean - '];
    outLine=[outLine 'current stim fx: ' num2str(b(3)) ' (' num2str(stats.p(3)) '); ' ];
    outLine=[outLine 'prior stim fx: ' num2str(b(2)) ' (' num2str(stats.p(2)) ') \n' ];
    fprintf(outLine);

    if nStimuli==6
      stimLabels={'25','50','100','200','400'};
    end
    if nStimuli==5
      stimLabels={[char(188) 'x'], [char(189) 'x'],'1x','2x'}; 
    end
    subplotHandle=subplot(2,nSubjects+1,nSubjects+1);
    hold on
    for ii=1:nStimuli-1
        lineColor=[1-(ii/nStimuli) 1-(ii/nStimuli) 1-(ii/nStimuli)];
        fmriMaxMel_PlotCRF( subplotHandle, 1:1:nStimuli-1, grandMean(1:nStimuli-1,ii)*100, grandSEM(1:nStimuli-1,ii)*100, ...
            'xTickLabels',stimLabels,...
            'xlim',[0 7],...
            'lineColor',lineColor,...
            'markerColor',lineColor,...
            'errorColor',[.75 .75 .75],...
            'xLabel','prior trial contrast',...
            'plotTitle','Across subject mean');
        scaledIdx=(ii-mean(1:1:(nStimuli-1)))/((nStimuli-1)-mean(1:1:(nStimuli-1)));
        plot([1 nStimuli-1],[b(1)+b(3)*scaledIdx+b(2)*(-1) b(1)+b(3)*scaledIdx+b(2)*(1)],'-r')
    end
    
    subplotHandle=subplot(2,nSubjects+1,(nSubjects+1)*2);
    k=squeeze(grandMean(1:nStimuli-1,1:nStimuli-1))*100;
    image(k,'CDataMapping','scaled')
    colormap(autumn)
    caxis([-0.5,1]);
    pbaspect([1 1 1]);
    xlabel('current stim');
    ylabel('prior stim')
    xticklabels(stimLabels);
    yticklabels(stimLabels);


end % function