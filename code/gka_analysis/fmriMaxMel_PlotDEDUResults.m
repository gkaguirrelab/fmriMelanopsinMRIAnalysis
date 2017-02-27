function [plotHandles] = fmriMaxMel_PlotDEDUResults( meanAmplitudes, meanDurations, semAmplitudes, semDurations, xValFVals)
%
% Plot the results of the DEDU model

fitThresh=-1;

maxSEMDuration=max(semDurations(:));
symbolBySubject={'o','s','^','p'};
contrastLevels=[12.5,25,50,100,200,400,800];
contrastLabels={'','25','50','100','200','400',''};
splatterLabels={'','','',[char(188) 'x'], [char(189) 'x'],'1x','2x'};
nContrastsByDirection=[5,5,4]; % the number of contrast levels for each direction

%% Plot a contrast response amplitude plot

plotHandles{1}=figure;

% Set up the labels and axes

% axis for splatter
b=axes('Position',[.1 .1 .8 1e-12]);
set(b,'Units','normalized');
set(b,'Color','none');

% axis for contrast
a=axes('Position',[.1 .1 .8 .7]);
set(a,'Units','normalized');

% set limits and labels
set(a,'xlim',[min(log10(contrastLevels)) max(log10(contrastLevels))]);
set(b,'xlim',[min(log10(contrastLevels)) max(log10(contrastLevels))]);
xlabel(a,'contrast')
xlabel(b,'splatter')
title(a,'Amplitude x Contrast','Interpreter', 'none');

xticks(a,log10(contrastLevels));
xticks(b,log10(contrastLevels));
xticklabels(a,contrastLabels);
xticklabels(b,splatterLabels);
ylabel(a,'% BOLD change [subject scaled]');
box(a,'off');
pbaspect(a,[1 1 1])

hline=refline(a,0,0);
set(hline,'Color','k','LineStyle','--');

hold on
for dd=1:3
    for ss=1:4
        amps=meanAmplitudes(dd,:,ss);
        semAmps=semAmplitudes(dd,:,ss);
        switch dd
            case 1
                faceColor=[.8,.8,.8];
        plot(a,log10(contrastLevels(2:length(amps)+1)),amps,symbolBySubject{ss},...
            'MarkerSize', 15,...
            'MarkerEdgeColor', [0.5, 0.5, 0.5], ...
            'MarkerFaceColor', faceColor);
            case 2
                faceColor=[0.4,0.4,1];
        plot(a,log10(contrastLevels(2:length(amps)+1)),amps,symbolBySubject{ss},...
            'MarkerSize', 15,...
            'MarkerEdgeColor', [0.5, 0.5, 0.5], ...
            'MarkerFaceColor', faceColor);
            case 3
                faceColor=[1,0.4,0.4];
        plot(a,log10(contrastLevels(2:length(amps)+1)*4),amps,symbolBySubject{ss},...
            'MarkerSize', 10,...
            'MarkerEdgeColor', [0.5, 0.5, 0.5], ...
            'MarkerFaceColor', faceColor);
        end
    end
end

for dd=1:3
    medianAmps=median(squeeze(meanAmplitudes(dd,:,:)),2);
            switch dd
            case 1
                xvals=log10(contrastLevels(2:length(amps)+1));
                yvals=medianAmps;
cs = spline(xvals,[0 yvals' 0]);
                xxvals=min(xvals):0.01:max(xvals);
plot(a,xxvals,ppval(cs,xxvals),'-k');
            case 2
                xvals=log10(contrastLevels(2:length(amps)+1));
                yvals=medianAmps;
cs = spline(xvals,yvals);
                xxvals=min(xvals):0.01:max(xvals);
plot(a,xxvals,ppval(cs,xxvals),'-b');
            case 3
                xvals=log10(contrastLevels(2:length(amps)+1)*4);
                yvals=medianAmps;
cs = spline(xvals,[0 yvals' 0]);
                xxvals=min(xvals):0.01:max(xvals);
plot(a,xxvals,ppval(cs,xxvals),'-r');
            end
end



%% Plot duration vs. amplitude in the DEDU model

plotHandles{2}=figure;
hold on
for dd=1:3
    subplot(1,3,dd);
    hold on
    % Clean up the labels and axes
    pbaspect([1 1 1])
xlabel('Duration [secs]'); ylabel('% BOLD change [subject scaled]');
ylim([-.25 1]);
xlim([-1 8]);
box('off');
    for ss=1:4
        nContrasts=nContrastsByDirection(dd);
        for cc=1:nContrasts
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
                    case 3
                        faceColor=[1,0.4,0.4];
                end
                MarkerSize=ceil(5*(1.01-semDur/maxSEMDuration));
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
            end % if there are points to plot
        end % loop over contrasts
    end % loop over subjects
    % Add an ellipses
    pointsIdx=find(xValFVals(dd,:,:)>=fitThresh);
    durs=meanDurations(dd,:,:);
    amps=meanAmplitudes(dd,:,:);
    confellipse2([durs(pointsIdx) amps(pointsIdx) ],0.5,faceColor);

end % loop over directions



end % function


function hh = confellipse2(xy,conf,lineColor)
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
h = line(exy(:,1),exy(:,2),'Clipping','off','Color',lineColor);
if nargout > 0
    hh = h;
end

end % ellipse function
