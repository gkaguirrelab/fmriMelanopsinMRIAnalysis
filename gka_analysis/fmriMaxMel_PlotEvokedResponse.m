function [ ] = fmriMaxMel_PlotEvokedResponse( plotHandle, timebase, meanResponse, errorResponse, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Parse vargin for options passed here
p = inputParser;
p.addRequired('plotHandle',@ishandle);
p.addRequired('timebase',@isnumeric);
p.addRequired('meanResponse',@isnumeric);
p.addRequired('errorResponse',@isnumeric);
p.addParameter('lineColor',[1 1 1],@isnumeric);
p.addParameter('plotTitle','title here',@ischar);
p.addParameter('ylim',[-0.5 2],@isnumeric);
p.parse(plotHandle, timebase, meanResponse, errorResponse, varargin{:});

% Detect and store current hold state
currentHoldState = ishold;

% Plot the primary function
plot(plotHandle, timebase/1000,meanResponse,'Color',p.Results.lineColor);
hold(plotHandle,'on');

% Plot error bounds if this was passed
if ~isempty(errorResponse)
    plot(plotHandle,timebase/1000,meanResponse+errorResponse,'Color',[0.5 0.5 0.5]);
    plot(plotHandle,timebase/1000,meanResponse-errorResponse,'Color',[0.5 0.5 0.5]);
end

% Clean up the labels and axes
ylim(plotHandle,p.Results.ylim);
xlim(plotHandle,[0 14]);
title(plotHandle,p.Results.plotTitle,'Interpreter', 'none');
pbaspect(plotHandle,[1 1 1])
xlabel(plotHandle,'Time [secs]'); ylabel(plotHandle,'% BOLD change');
set(plotHandle,'Xtick',0:2:14)
set(plotHandle,'FontSize',6);
box(plotHandle,'off');

% Restore the initial hold state
if currentHoldState
    hold(plotHandle,'on');
end

end % function

