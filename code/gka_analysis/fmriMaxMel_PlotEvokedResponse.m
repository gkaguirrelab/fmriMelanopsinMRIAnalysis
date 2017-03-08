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
p.addParameter('lineWidth',0.5,@isnumeric);
p.addParameter('plotTitle','title here',@ischar);
p.addParameter('ylim',[-0.5 2],@isnumeric);
p.addParameter('xTick',2,@isnumeric);
p.addParameter('xAxisAspect',1,@isnumeric);
p.addParameter('xUnits','Time [secs]',@ischar);
p.addParameter('yAxisAspect',1,@isnumeric);
p.addParameter('dataOnly',false,@islogical);
p.parse(plotHandle, timebase, meanResponse, errorResponse, varargin{:});

% Detect and store current hold state
currentHoldState = ishold;

% Set the timeDivisor
switch p.Results.xUnits
    case 'Time [msecs]'
        timeDivisor=1;
    case 'Time [secs]'
        timeDivisor=1000;
    case 'Time [mins]'
        timeDivisor=1000*60;
    case 'Time [hours]'
        timeDivisor=1000*60*60;
    otherwise
        error('That is not an xUnits that I know');
end

% Plot the primary function
plot(plotHandle, timebase/timeDivisor,meanResponse,'Color',p.Results.lineColor,'LineWidth',p.Results.lineWidth);
hold(plotHandle,'on');

% Plot error bounds if this was passed
if ~isempty(errorResponse)
   errorLineColor=(([1 1 1]-p.Results.lineColor)*.5)+p.Results.lineColor;
   plot(plotHandle,timebase/timeDivisor,meanResponse+errorResponse,'Color',errorLineColor);
   plot(plotHandle,timebase/timeDivisor,meanResponse-errorResponse,'Color',errorLineColor);
end

% Calculate deltaT so we can know what the limit of our axes should be
check = diff(timebase);
deltaT = check(1);
maxTime=(max(timebase)+deltaT)/timeDivisor;

% Clean up the labels and axes
ylim(plotHandle,p.Results.ylim);
xlim(plotHandle,[0 maxTime]);
title(plotHandle,p.Results.plotTitle,'Interpreter', 'none');
pbaspect(plotHandle,[p.Results.xAxisAspect p.Results.yAxisAspect 1])
xlabel(plotHandle,p.Results.xUnits); ylabel(plotHandle,'% BOLD change');
set(plotHandle,'Xtick',0:p.Results.xTick:maxTime)
set(plotHandle,'FontSize',6);
box(plotHandle,'off');

% Clear all chart junk if requested
if p.Results.dataOnly
    set(plotHandle, 'visible', 'off')
end

% Restore the initial hold state
if currentHoldState
    hold(plotHandle,'on');
end

end % function

