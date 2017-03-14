function [plotHandles] = fmriMaxMel_PlotCRF( plotHandle, xValues, meanResponse, errorResponse, varargin)
%
% Plot a CRF

p = inputParser;
p.addRequired('plotHandle',@(x)(isempty(x) | sum(ishandle(x))));
p.addRequired('xValues',@isnumeric);
p.addRequired('meanResponse',@isnumeric);
p.addRequired('errorResponse',@isnumeric);
p.addParameter('lineColor',[.25 .25 .25],@isnumeric);
p.addParameter('markerColor',[0 0 0],@isnumeric);
p.addParameter('markerSize',3,@isnumeric);
p.addParameter('errorColor',[0.5 0.5 0.5],@isnumeric);
p.addParameter('lineWidth',0.5,@isnumeric);
p.addParameter('plotTitle','title here',@ischar);
p.addParameter('xLabel','contrast',@ischar);
p.addParameter('xTickLabels',cellstr(num2str(xValues')),@iscell);
p.addParameter('ylim',[-0.5 1],@isnumeric);
p.addParameter('xlim',[0 length(xValues)+1],@isnumeric);
p.addParameter('xAxisAspect',1,@isnumeric);
p.addParameter('yAxisAspect',1,@isnumeric);
p.addParameter('dataOnly',false,@islogical);
p.addParameter('plotSymbol','o',@ischar);
p.addParameter('secondAxis',false,@islogical);

p.parse(plotHandle, xValues, meanResponse, errorResponse, varargin{:});

% Create an empty figure if a handle was not supplied
if isempty(plotHandle)
    figure();
    plotHandle=subplot(1,1,1);
end

% Detect and store current hold state
initialHoldState = ishold;
hold(plotHandle,'on');

% Plot the data and the error bars
if ~isempty(errorResponse)
  errbar(xValues,meanResponse,errorResponse,'Color',p.Results.errorColor,'lineWidth',1)
end
plot(plotHandle,xValues,meanResponse,'Color',p.Results.lineColor,'LineWidth',p.Results.lineWidth,'Marker',p.Results.plotSymbol,'MarkerSize',p.Results.markerSize,'MarkerFaceColor',p.Results.markerColor,'MarkerEdgeColor','none');

% Clean up the labels and axes
ylim(plotHandle,p.Results.ylim);
xlim(plotHandle,p.Results.xlim);
title(plotHandle,p.Results.plotTitle,'Interpreter', 'none');
pbaspect(plotHandle,[p.Results.xAxisAspect p.Results.yAxisAspect 1])
ylabel(plotHandle,'% BOLD change');
set(plotHandle,'FontSize',8);
box(plotHandle,'off');

if p.Results.secondAxis
    plot(plotHandle,xValues,xValues*0-0.25,'-k');
    for xx=1:length(xValues)
        plot(plotHandle,[xValues(xx),xValues(xx)],[-0.25,-0.30],'-k');
        text(plotHandle,xValues(xx),-0.35,p.Results.xTickLabels{xx},'FontSize',6,'HorizontalAlignment','center');
    end
    text(plotHandle,mean(xValues),-0.45,p.Results.xLabel,'FontSize',6,'HorizontalAlignment','center');
else
xlabel(plotHandle,p.Results.xLabel); 
set(plotHandle,'Xtick',1:1:length(meanResponse));
xticklabels(plotHandle,p.Results.xTickLabels);
end

% hline=refline(a,0,0);
% set(hline,'Color','k','LineStyle','--');

% Clear all chart junk if requested
if p.Results.dataOnly
    set(plotHandle, 'visible', 'off')
end

% Restore the initial hold state
if initialHoldState
    hold(plotHandle,'on');
else
    hold(plotHandle,'off');
end


end % function
