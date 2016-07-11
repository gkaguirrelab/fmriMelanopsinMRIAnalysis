%% set saving path and variables
dropbox_dir = '/Users/giulia/Desktop/Results_Round2' %'/Users/giulia/Dropbox-Aguirre-Brainard-Lab/MELA_analysis/MelanopsinMR/FIR_comparisons';
data_dir = '/data/jag/MELA/MelanopsinMR/Results';

subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

conditions = {...
    'MelPulses_400pct' ...
    'LMSPulses_400pct' ...
    'SplatterControl' ...
    'MaxMelCRF' ...
    'MaxLMSCRF' ...
    };

conditionFolders = {...
    'MaxMel_400%' ...
    'MaxLMS_400%' ...
    'SplatterControl_CRF' ...
    'MaxMel_CRF' ...
    'MaxLMS_CRF' ...
    };

controlsSplatter = { ...
    '_25pct'...
    '_50pct'...
    '_100pct'...
    '_195pct'...
    '_AttentionTask'...
    };

controlsCRF = {...
    '_25pct'...
    '_50pct'...
    '_100pct'...
    '_200pct'...
    '_400pct'...
    '_AttentionTask'...
    };

directions = {...
    'Mel stimuli' ...
    'LMS stimuli' ...
    'Attention Tasks' ...
    };

hemis = {...
    'mh'...
    };
ROIs = {...
    'V1' ...
    'V2andV3'...
    };

%% Plot by session

for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for cc = 1:length(conditions)
                condition = conditions{cc};
                
                % set figure
                firFig = figure('units','normalized','position',[0 0 1 1]);
                hold on;
                xlabel('Time [sec]');
                ylabel('Signal change [%]');
                xlims = [-1 15];
                ylims = [-0.5 1.4];
                xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
                xLabels = xTick;
                h = plot([xlims(1) xlims(end)],[0 0],'k');
                set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                xlim(xlims); ylim(ylims);
                ax = gca;
                set(ax,'XTick',xTick);
                set(ax,'XTickLabel',xLabels);

                switch (condition)
                    case 'MelPulses_400pct'
                        controls = { ...
                            '' ...
                            '_AttentionTask' ...
                            };
                        conditionFolder =  'MaxMel_400%';
                      
                        
                        
                    case 'LMSPulses_400pct'
                        controls = { ...
                            '' ...
                            '_AttentionTask' ...
                            };
                        conditionFolder =  'MaxLMS_400%';
                        
                        
                    case 'SplatterControl'
                        controls = controlsSplatter;
                        conditionFolder =  'SplatterControl_CRF';
                        
                    case 'MaxMelCRF'
                        controls = controlsCRF;
                        conditionFolder = 'MaxMel_CRF';
                        
                    case 'MaxLMSCRF'
                        controls = controlsCRF;
                        conditionFolder = 'MaxLMS_CRF';
                        
                    otherwise
                        error ('No condition selected')
                end
                for kk = 1:length(controls)
                            control = controls{kk};
                            offsets = 0:(0.3/(length(controls)-1)):0.3;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolder, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(kk),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk) = plot(x+offsets(kk), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk} = ([condition control]);
                            hold on
                        end
                        legend (p,legendInfo, 'Interpreter','none');
                        title([subjName '_' condition '_' hemi '_' ROI],'Interpreter','none')
                        
                        % save it out
                        axesHandles = findobj(firFig, 'type', 'axes');
                        set(axesHandles, 'TickDir', 'out');
                        
                        % Make the axes square and turns the bounding box off
                        for ii = 1:length(axesHandles)
                            pbaspect(axesHandles(ii), [1 1 1]);
                            box(axesHandles(ii), 'off')
                        end
                        
                        % Sets the size of the figure to be [5 5], if there is only one subplot
                        if length(axesHandles) == 1
                            set(firFig, 'PaperPosition', [0 0 7 7]);
                            set(firFig, 'PaperSize', [7 7]);
                        end
                        saveas(firFig, fullfile (dropbox_dir, subjName, 'bySession', conditionFolder, [subjName '_' condition control '_' hemi '_' ROI]), 'pdf');
                        close all;
                        clear legendInfo
                        clear p
                        clear g

            end
        end
    end
end


%% plot by Direction
for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for dd = 1:length(directions)
                direction = directions{dd};
                % set figure
                firFig = figure('units','normalized','position',[0 0 1 1]);
                hold on;
                xlabel('Time [sec]');
                ylabel('Signal change [%]');
                xlims = [-1 15];
                ylims = [-0.5 1.4];
                xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
                xLabels = xTick;
                h = plot([xlims(1) xlims(end)],[0 0],'k');
                set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                xlim(xlims); ylim(ylims);
                ax = gca;
                set(ax,'XTick',xTick);
                set(ax,'XTickLabel',xLabels);
                switch (direction)
                    case 'Mel stimuli' 
                        condition = 'MelPulses_400pct';
                        controls1 = { ...
                            '' ...
                            };
                        for kk = 1:length(controls1)
                            control = controls1{kk};
                            offsets = 0;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolders{1}, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(kk),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk) = plot(x+offsets(kk), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk} = ([condition control]);
                            hold on
                        end
                        
                        condition = 'MaxMelCRF';
                        controls2 = controlsCRF(1:5);
                        for ll = 1:length(controls2) , 
                            control = controls2{ll};
                            offsets = 0:(0.3/(length(controls2))):0.3;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolders{4}, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(ll),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk+ll) = plot(x+offsets(ll+1), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk+ll} = ([condition control]);
                            hold on
                        end
                        legend (p,legendInfo, 'Interpreter','none');
                        title([subjName '_' direction '_' hemi '_' ROI],'Interpreter','none')
                        
                        % save it out
                        axesHandles = findobj(firFig, 'type', 'axes');
                        set(axesHandles, 'TickDir', 'out');
                        
                        % Make the axes square and turns the bounding box off
                        for ii = 1:length(axesHandles)
                            pbaspect(axesHandles(ii), [1 1 1]);
                            box(axesHandles(ii), 'off')
                        end
                        
                        % Sets the size of the figure to be [5 5], if there is only one subplot
                        if length(axesHandles) == 1
                            set(firFig, 'PaperPosition', [0 0 7 7]);
                            set(firFig, 'PaperSize', [7 7]);
                        end
                        saveas(firFig, fullfile (dropbox_dir, subjName, 'byDirection', 'Mel', [subjName '_' 'Mel' '_' hemi '_' ROI]), 'pdf');
                        close all;
                        clear legendInfo
                        clear p
                        clear g
                        clear controls1
                        clear controls2
                        clear kk
                        clear ll
                        
                        
                    case 'LMS stimuli'
                        condition = 'LMSPulses_400pct';
                        controls1 = { ...
                            '' ...
                            };
                        for kk = 1:length(controls1)
                            control = controls1{kk};
                            offsets = 0;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolders{2}, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(kk),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk) = plot(x+offsets(kk), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk} = ([condition control]);
                            hold on
                        end
                        
                        condition = 'MaxLMSCRF';
                        controls2 = controlsCRF(1:5);
                        for ll = 1:length(controls2)
                            control = controls2{ll};
                            offsets = 0:(0.3/(length(controls2))):0.3;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolders{5}, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(ll+1),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk+ll) = plot(x+offsets(ll), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk+ll} = ([condition control]);
                            hold on
                        end
                        legend (p,legendInfo, 'Interpreter','none');
                        title([subjName '_' direction '_' hemi '_' ROI],'Interpreter','none')
                        
                        % save it out
                        axesHandles = findobj(firFig, 'type', 'axes');
                        set(axesHandles, 'TickDir', 'out');
                        
                        % Make the axes square and turns the bounding box off
                        for ii = 1:length(axesHandles)
                            pbaspect(axesHandles(ii), [1 1 1]);
                            box(axesHandles(ii), 'off')
                        end
                        
                        % Sets the size of the figure to be [5 5], if there is only one subplot
                        if length(axesHandles) == 1
                            set(firFig, 'PaperPosition', [0 0 7 7]);
                            set(firFig, 'PaperSize', [7 7]);
                        end
                        saveas(firFig, fullfile (dropbox_dir, subjName, 'byDirection', 'LMS', [subjName '_' 'LMS' '_' hemi '_' ROI]), 'pdf');
                        close all;
                        clear legendInfo
                        clear p
                        clear g
                        clear controls1
                        clear controls2
                        
                    case 'Attention Tasks'
                        control = '_AttentionTask';
                        for kk = 1:length(conditions)
                            condition = conditions{kk};
                            
                            offsets = 0:(0.3/(length(conditions)-1)):0.3;
                            
                            load(fullfile (dropbox_dir, subjName, 'bySession', conditionFolders{kk}, [subjName '_' condition control '_' hemi '_' ROI]));
                            
                            x = 0:1:13;
                            g = errorbar(x+offsets(kk),M(:,2),M(:,3),'.','color', [0.5 0.5 0.5],'MarkerSize',14);% hold on;
                            set(get(get(g,'Annotation'),'LegendInformation'),'IconDisplayStyle','children');
                            p(kk) = plot(x+offsets(kk), M(:,2), '-','MarkerSize',10);
                            legendInfo{kk} = ([condition]);
                            hold on
                        end
                        
                        
                        legend (p,legendInfo, 'Interpreter','none');
                        title([subjName '_' direction '_' hemi '_' ROI],'Interpreter','none')
                        
                        % save it out
                        axesHandles = findobj(firFig, 'type', 'axes');
                        set(axesHandles, 'TickDir', 'out');
                        
                        % Make the axes square and turns the bounding box off
                        for ii = 1:length(axesHandles)
                            pbaspect(axesHandles(ii), [1 1 1]);
                            box(axesHandles(ii), 'off')
                        end
                        
                        % Sets the size of the figure to be [5 5], if there is only one subplot
                        if length(axesHandles) == 1
                            set(firFig, 'PaperPosition', [0 0 7 7]);
                            set(firFig, 'PaperSize', [7 7]);
                        end
                        saveas(firFig, fullfile (dropbox_dir, subjName, 'byDirection', 'AttentionTask', [subjName '_' 'AttentionTask' '_' hemi '_' ROI]), 'pdf');
                        close all;
                        clear legendInfo
                        clear p
                        clear g
                        clear control
                        
                end
            end
        end
    end
end










