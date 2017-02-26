function [plotHandles] = fmriMaxMel_PlotDEDUResults( meanAmplitudes, meanDurations, semAmplitudes, semDurations, xValFVals)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fitThresh=0.15;

maxSEMDuration=max(semDurations(:));
symbolBySubject={'o','s','^','p'};
contrastLevels=[25,50,100,200,400];

plotHandles{1}=figure;
hold on
for dd=1:2
    for ss=1:4
        amps=meanAmplitudes(dd,:,ss);
        semAmps=semAmplitudes(dd,:,ss);
        switch dd
            case 1
                faceColor=[.8,.8,.8];
            case 2
                faceColor=[0.4,0.4,1];
        end
        plot(log(contrastLevels),amps,symbolBySubject{ss},...
            'MarkerSize', 15,...
            'MarkerEdgeColor', [0.5, 0.5, 0.5], ...
            'MarkerFaceColor', faceColor);
    end
end

for dd=1:2
    medianAmps=median(squeeze(meanAmplitudes(dd,:,:)),2);
    switch dd
        case 1
            faceColor=[.8,.8,.8];
        case 2
            faceColor=[0.4,0.4,1];
    end
    plot(log(contrastLevels),medianAmps,'-k');
end

% Clean up the labels and axes
title('Amplitude x Contrast','Interpreter', 'none');
pbaspect([1 1 1])
xlabel('log contrast'); ylabel('% BOLD change [subject scaled]');
box('off');


figure
hold on
for dd=1:2
    for ss=1:4
        for cc=1:5
            if xValFVals(dd,cc,ss)>=fitThresh
                amp=meanAmplitudes(dd,cc,ss);
                dur=meanDurations(dd,cc,ss);
                semDur=semDurations(dd,cc,ss);
                semAmp=semAmplitudes(dd,cc,ss);
                fade=semDur/maxSEMDuration;
                switch dd
                    case 1
                        faceColor=[0.8,0.8,0.8];
                    case 2
                        faceColor=[0.4,0.4,1];
                end
                MarkerSize=ceil(15*(1.01-semDur/maxSEMDuration));
                errorbar(dur,amp,semAmp,'-.k',...
                    'MarkerSize', MarkerSize,...
                    'MarkerEdgeColor', [0.5 0.5 0.5], ...
                    'MarkerFaceColor', 'none');
                errorbar(dur,amp,semDur,'-.k','horizontal',...
                    'MarkerSize', MarkerSize,...
                    'MarkerEdgeColor', [0.5 0.5 0.5], ...
                    'MarkerFaceColor', 'none');
                plot(dur,amp,symbolBySubject{ss},...
                    'MarkerSize', MarkerSize,...
                    'MarkerEdgeColor', [0.5 0.5 0.5], ...
                    'MarkerFaceColor', faceColor);
            end
        end
    end
end

% Clean up the labels and axes
title('Duration x Amplitude','Interpreter', 'none');
pbaspect([1 1 1])
xlabel('Duration [secs]'); ylabel('% BOLD change [subject scaled]');
box('off');


% Build a classifier
% 
% fVals=xValFVals(1,:,:);
%     amps=meanAmplitudes(1,:,:);
%     durs=meanDurations(1,:,:);
%     idx=find(fVals>=fitThresh);    
%     lmsData=[durs(idx),amps(idx)];
%     lmsWeights=fVals(idx);
%     lmsLabels=cell(length(idx),1);
%     lmsLabels(:)=cellstr('lms');
% fVals=xValFVals(2,:,:);
%     amps=meanAmplitudes(2,:,:);
%     durs=meanDurations(2,:,:);
%     idx=find(fVals>=fitThresh);
%     melData=[durs(idx),amps(idx)];
%     melWeights=fVals(idx);
%     melLabels=cell(length(idx),1);
%     melLabels(:)=cellstr('mel');
%     
%     labels=[lmsLabels;melLabels];
%     data=[lmsData;melData];
%     data=array2table(data);
%     data=[data,labels];
%     data.Properties.VariableNames{1}='dur';
%     data.Properties.VariableNames{2}='amp';
%     data.Properties.VariableNames{3}='direction';
% 
%     
%     weights=[lmsWeights;melWeights];
%     MdlLinear = fitcdiscr(data,'direction','PredictorNames',{'dur','amp'},'ClassNames',{'lms','mel'},'Weights',weights);
% K = MdlLinear.Coeffs(1,2).Const;
% L = MdlLinear.Coeffs(1,2).Linear;
% f = @(x) (K + L(1)*x) / (-1* L(2));
% fplot(f,[1 4]);

pointsIdx=find(xValFVals(1,:,:)>=fitThresh);
durs=meanDurations(1,:,:);
amps=meanAmplitudes(1,:,:);
confellipse2([durs(pointsIdx) amps(pointsIdx) ],0.5);

pointsIdx=find(xValFVals(2,:,:)>=fitThresh);
durs=meanDurations(2,:,:);
amps=meanAmplitudes(2,:,:);
confellipse2([durs(pointsIdx) amps(pointsIdx) ],0.5);

end % function

function b = Theil_Sen_Regress(x,y)

N=length(x);

Comb = combnk(1:N,2);

theil=diff(y(Comb),1,2)./diff(x(Comb),1,2);
b=median(theil);

end

function hh = confellipse2(xy,conf)
%CONFELLIPSE2 Draws a confidence ellipse.
% CONFELLIPSE2(XY,CONF) draws a confidence ellipse on the current axes
% which is calculated from the n-by-2 matrix XY and encloses the
% fraction CONF (e.g., 0.95 for a 95% confidence ellipse).
% H = CONFELLIPSE2(...) returns a handle to the line.

% written by Douglas M. Schwarz
% schwarz@kodak.com
% last modified: 12 June 1998

n = size(xy,1);
mxy = mean(xy);

numPts = 181; % The number of points in the ellipse.
th = linspace(0,2*pi,numPts)';


p = 2; % Dimensionality of the data, 2-D in this case.

k = finv(conf,p,n-p)*p*(n-1)/(n-p);
% Comment out line above and uncomment line below to use ftest toolbox.
% k = fdistinv(p,n-p,1-conf)*p*(n-1)/(n-p);

[pc,score,lat] = princomp(xy);
% Comment out line above and uncomment 3 lines below to use ftest toolbox.
% xyp = (xy - repmat(mxy,n,1))/sqrt(n - 1);
% [u,lat,pc] = svd(xyp,0);
% lat = diag(lat).^2;

ab = diag(sqrt(k*lat));
exy = [cos(th),sin(th)]*ab*pc' + repmat(mxy,numPts,1);

% Add ellipse to current plot
h = line(exy(:,1),exy(:,2),'Clipping','off');
if nargout > 0
    hh = h;
end

end % ellipse function
