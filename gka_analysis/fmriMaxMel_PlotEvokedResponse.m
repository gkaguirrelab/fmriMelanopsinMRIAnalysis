function [ ] = fmriMaxMel_PlorEvokedResponse( plotHandle, timebase, meanResponse, errorResponse, lineColor, plotTitle)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

currentHoldState = ishold;

    plot(plotHandle, timebase/1000,meanResponse,'Color',lineColor);
    hold(plotHandle,'on');
    
    if ~isempty(errorResponse)
    plot(plotHandle,timebase/1000,meanResponse+errorResponse,'Color',[0.5 0.5 0.5]);
    plot(plotHandle,timebase/1000,meanResponse-errorResponse,'Color',[0.5 0.5 0.5]);
    end
    ylim(plotHandle,[-0.5 2]);
    xlim(plotHandle,[0 14]);
    title(plotHandle,plotTitle,'Interpreter', 'none'); 
    pbaspect(plotHandle,[1 1 1])
    xlabel(plotHandle,'Time [secs]'); ylabel(plotHandle,'% BOLD change');
    set(plotHandle,'Xtick',0:2:14)
    set(plotHandle,'FontSize',6);
    box(plotHandle,'off');

    if currentHoldState 
hold(plotHandle,'on');
    end
end

