output_dir = '/Users/giulia/Desktop/TEST'
csv_dir = '/Users/giulia/Desktop/TEST/CSV_datafiles'

combinations = { ...
    'Mel_LMS_CTRL195' ...
    'CTRL_V1_MH' ...
    'MELAT_LMSAT_CTRLAT' ...
    };
conditions = {...
    'MelPulses_400pct' ...
    'MelPulses_400pct_AttentionTask' ...
    'LMSPulses_400pct' ...
    'LMSPulses_400pct_AttentionTask' ...
    'SplatterControl_195pct' ...
    'SplatterControl_100pct' ...
    'SplatterControl_50pct' ...
    'SplatterControl_25pct' ...
    'SplatterControl_AttentionTask' ...
    };

%% plot Mel_LMS_CTRL195

%get files
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
for hh = 1:length(hemis)
    hemi = hemis{hh};
    for jj = 1:length(ROIs)
        ROI = ROIs{jj};

        
        dataMEL = fullfile (csv_dir, ['Mean_across_subjects_' 'MelPulses_400pct_' hemi '_' ROI '_mean.csv']);
        dataLMS = fullfile (csv_dir, ['Mean_across_subjects_' 'LMSPulses_400pct_' hemi '_' ROI '_mean.csv']);
        dataCTRL = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_195pct_' hemi '_' ROI '_mean.csv']);
        
        dataFiles = {...
            dataMEL ...
            dataLMS ...
            dataCTRL
            };
        
        errorMEL = fullfile (csv_dir, ['Mean_across_subjects_' 'MelPulses_400pct_' hemi '_' ROI '_sem.csv']);
        errorLMS = fullfile (csv_dir, ['Mean_across_subjects_' 'LMSPulses_400pct_' hemi '_' ROI '_sem.csv']);
        errorCTRL = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_195pct_' hemi '_' ROI '_sem.csv']);
        
        errorFiles = {...
            errorMEL ...
            errorLMS ...
            errorCTRL
            };
        
        dataExt = 'csv' ;
        legendTexts = { ...
            '400% Melanopsin Pulse' ...
            '400% LMS Pulse' ...
            '195% SplatterControl'
            };
        titleText = ['Mean_across_subjects - Mel LMS Control ' hemi ' ' ROI];
        saveName = ['Mean_across_subjects_MEL_LMS_CTRL_195_' hemi '_' ROI] ;
        
        FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
        
        
        % plot with errorbars
                % set axes
        figure('units','normalized','position',[0 0 1 1]);
        hold on
        xlabel('Time in seconds');
        ylabel('Percent Signal Change');
        title (titleText,'Interpreter','none')
        xlims = [-1 15];
        ylims = [-0.5 1.2];
        xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
        xLabels = xTick;
        h = plot([xlims(1) xlims(end)],[0 0],'k');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        xlim(xlims); ylim(ylims);
        ax = gca;
        set(ax,'XTick',xTick);
        set(ax,'XTickLabel',xLabels);
        x = 0:1:13;
        offsets = 0:(0.2/(length(dataFiles)-1)):0.2;
        legendTexts = { ...
            ['400% Melanopsin Pulse ' char(177) ' SEM'] ...
            ['400% LMS Pulse ' char(177) ' SEM'] ...
            ['195% SplatterControl ' char(177) ' SEM']
            };
            
        for ff = 1:length(dataFiles)
            y(:,ff) = csvread(dataFiles{ff});
            dataP = y(:,ff);
            e(:,ff) = csvread(errorFiles{ff});
            errorP = e(:,ff);
            errorbar(x+offsets(ff),dataP,errorP); hold on
            legendInfo{ff} = (legendTexts{ff});
        end
        legend (legendInfo, 'Interpreter','none');
        set(gcf, 'PaperPosition', [0 0 7 7]);
set(gcf, 'PaperSize', [7 7]);
saveName = ['Mean_across_subjects_MEL_LMS_CTRL_195_ERROR_' hemi '_' ROI] ;
saveas(gcf, fullfile(output_dir, saveName), 'pdf'); 
close all;

    end
end


%% plot CTRL_V1_MH

%get files
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
for hh = 1:length(hemis)
    hemi = hemis{hh};
    for jj = 1:length(ROIs)
        ROI = ROIs{jj};

        
        data195 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_195pct_' hemi '_' ROI '_mean.csv']);
        data100 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_100pct_' hemi '_' ROI '_mean.csv']);
        data50 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_50pct_' hemi '_' ROI '_mean.csv']);
        data25 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_25pct_' hemi '_' ROI '_mean.csv']);
        
        dataFiles = {...
            data195 ...
            data100 ...
            data50 ...
            data25 ...
            };
        
        error195 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_195pct_' hemi '_' ROI '_sem.csv']);
        error100 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_100pct_' hemi '_' ROI '_sem.csv']);
        error50 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_50pct_' hemi '_' ROI '_sem.csv']);
        error25 = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_25pct_' hemi '_' ROI '_sem.csv']);
        
        errorFiles = {...
            error195 ...
            error100 ...
            error50 ...
            error25 ...
            };
        dataExt = 'csv' ;
        legendTexts = { ...
            '195% SplatterControl' ...
            '100% SplatterControl' ...
            '50% SplatterControl' ...
            '25% SplatterControl' ...
            };
        titleText = ['Mean_across_subjects - Splatter Control ' hemi ' ' ROI];
        saveName = ['Mean_across_subjects_SplatterControl_' hemi '_' ROI] ;
        
        FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
        
        
        % plot with errorbars
                % set axes
        figure('units','normalized','position',[0 0 1 1]);
        hold on
        xlabel('Time in seconds');
        ylabel('Percent Signal Change');
        title (titleText,'Interpreter','none')
        xlims = [-1 15];
        ylims = [-0.5 1.2];
        xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
        xLabels = xTick;
        h = plot([xlims(1) xlims(end)],[0 0],'k');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        xlim(xlims); ylim(ylims);
        ax = gca;
        set(ax,'XTick',xTick);
        set(ax,'XTickLabel',xLabels);
        x = 0:1:13;
        offsets = 0:(0.2/(length(dataFiles)-1)):0.2;
        legendTexts = { ...
            ['195% SplatterControl ' char(177) ' SEM'] ...
            ['100% SplatterControl ' char(177) ' SEM'] ...
            ['50% SplatterControl ' char(177) ' SEM'] ...
            ['25% SplatterControl ' char(177) ' SEM'] ...
            };
        for ff = 1:length(dataFiles)
            y(:,ff) = csvread(dataFiles{ff});
            dataP = y(:,ff);
            e(:,ff) = csvread(errorFiles{ff});
            errorP = e(:,ff);
            errorbar(x+offsets(ff),dataP,errorP); hold on
            legendInfo{ff} = (legendTexts{ff});
        end
        legend (legendInfo, 'Interpreter','none');
        set(gcf, 'PaperPosition', [0 0 7 7]);
set(gcf, 'PaperSize', [7 7]);
saveName = ['Mean_across_subjects_SplatterControl_ERROR_' hemi '_' ROI] ;
saveas(gcf, fullfile(output_dir, saveName), 'pdf'); 
close all;

    end
end

%% plot ATTENTION TASKS
%get files
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
for hh = 1:length(hemis)
    hemi = hemis{hh};
    for jj = 1:length(ROIs)
        ROI = ROIs{jj};

        
        dataMEL = fullfile (csv_dir, ['Mean_across_subjects_' 'MelPulses_400pct_AttentionTask_' hemi '_' ROI '_mean.csv']);
        dataLMS = fullfile (csv_dir, ['Mean_across_subjects_' 'LMSPulses_400pct_AttentionTask_' hemi '_' ROI '_mean.csv']);
        dataCTRL = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_AttentionTask_' hemi '_' ROI '_mean.csv']);
        
        dataFiles = {...
            dataMEL ...
            dataLMS ...
            dataCTRL
            };
        
        errorMEL = fullfile (csv_dir, ['Mean_across_subjects_' 'MelPulses_400pct_AttentionTask_' hemi '_' ROI '_sem.csv']);
        errorLMS = fullfile (csv_dir, ['Mean_across_subjects_' 'LMSPulses_400pct_AttentionTask_' hemi '_' ROI '_sem.csv']);
        errorCTRL = fullfile (csv_dir, ['Mean_across_subjects_' 'SplatterControl_AttentionTask_' hemi '_' ROI '_sem.csv']);
        
        errorFiles = {...
            errorMEL ...
            errorLMS ...
            errorCTRL
            };
        
        dataExt = 'csv' ;
        legendTexts = { ...
            '400% Melanopsin Pulse Attention Task' ...
            '400% LMS Pulse Attention Task' ...
            'SplatterControl Attention Task'
            };
        titleText = ['Mean_across_subjects - Attention Tasks ' hemi ' ' ROI];
        saveName = ['Mean_across_subjects_AttentionTasks_' hemi '_' ROI] ;
        
        FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
        
        
        % plot with errorbars
                % set axes
        figure('units','normalized','position',[0 0 1 1]);
        hold on
        xlabel('Time in seconds');
        ylabel('Percent Signal Change');
        title (titleText,'Interpreter','none')
        xlims = [-1 15];
        ylims = [-0.5 1.2];
        xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
        xLabels = xTick;
        h = plot([xlims(1) xlims(end)],[0 0],'k');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        xlim(xlims); ylim(ylims);
        ax = gca;
        set(ax,'XTick',xTick);
        set(ax,'XTickLabel',xLabels);
        x = 0:1:13;
        offsets = 0:(0.2/(length(dataFiles)-1)):0.2;
        legendTexts = { ...
            ['400% Melanopsin Pulse Attention Task ' char(177) ' SEM'] ...
            ['400% LMS Pulse Attention Task ' char(177) ' SEM'] ...
            ['SplatterControl Attention Task ' char(177) ' SEM']
            };
            
        for ff = 1:length(dataFiles)
            y(:,ff) = csvread(dataFiles{ff});
            dataP = y(:,ff);
            e(:,ff) = csvread(errorFiles{ff});
            errorP = e(:,ff);
            errorbar(x+offsets(ff),dataP,errorP); hold on
            legendInfo{ff} = (legendTexts{ff});
        end
        legend (legendInfo, 'Interpreter','none');
        set(gcf, 'PaperPosition', [0 0 7 7]);
set(gcf, 'PaperSize', [7 7]);
saveName = ['Mean_across_subjects_AttentionTasks_ERROR_' hemi '_' ROI] ;
saveas(gcf, fullfile(output_dir, saveName), 'pdf'); 
close all;

    end
end

