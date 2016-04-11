function plot_FIR(means,SEMs,ROI,condName,hemi,func,subj_name,xlims,ylims,xTick,xLabels)

% Plots FIR
%
%   Usage:
%   plot_FIR(means,SEMs,ROI,condName,hemi,func,xlims,ylims,xTick,xLabels)
%
%   Based on plot_TTF, Written by Andrew S Bock Sep 2015
%   
%% set defaults
if ~exist('condName','var')
    CondName = '';
end
if ~exist('hemi','var')
    hemi = '';
end
if ~exist('func','var')
    func = '';
end
if ~exist('ROI','var')
    ROI = 'LGN';
end
if ~exist('subj_name','var')
    subj_name = '';
end
if ~exist('xlims','var')
    xlims = [-1 15];
end
if ~exist('ylims','var')
    ylims = [-0.5 1];
end
if ~exist('xTick','var')
    xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
end
if ~exist('xLabels','var')
    xLabels = xTick;
end

%% PLOT FIR WITH ERROR BARS
% MEANS = cell2mat(means);
% SEMS = cell2mat(sems);
x = 0:1:(length(means)-1);

figure('units','normalized','position',[0 0 1 1]);
plot([xlims(1) xlims(end)],[0 0],'k'); hold on;
errorbar(x,means,SEMs, 'k');hold on;
plot(x, means,'.r','MarkerSize',16);
title({subj_name; [hemi ' ' ROI ' ' condName ' ' func]},'Interpreter','none')
xlabel('Time [sec]');
ylabel('Amplitude [% signal change]');
xlim(xlims); ylim(ylims);
ax = gca;

set(ax,'XTick',xTick);
set(ax,'XTickLabel',xLabels);
pbaspect([1 1 1]);
set(gca, 'TickDir', 'out'); 
box off;
