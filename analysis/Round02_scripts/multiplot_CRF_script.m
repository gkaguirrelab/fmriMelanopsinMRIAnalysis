dropbox_dir = '/Users/giulia/Desktop/TEST' %'/Users/giulia/Dropbox-Aguirre-Brainard-Lab/MELA_analysis/MelanopsinMR/FIR_comparisons';
data_dir = '/data/jag/MELA/MelanopsinMR/Results';
subjNames = { ...
%     'HERO_asb1' ...
%     'HERO_aso1' ...
%     'HERO_gka1' ...
    'HERO_mxs1' ...   % needs to couple more than one session for MEL
    };

sessionsMEL = { ...
%     '060716' ...
%     '053116' ...
%     '060216' ...
    '060916' ...
    };
sessionsLMS = { ...
%     '060816' ...
%     '060116' ...
%     '060616' ...
    '062816' ...   
    };
conditions = {...
    'MaxMelCRF' ...
    'MaxLMSCRF' ...
    };
controls = {...
            '25pct'...
            '50pct'...
            '100pct'...
            '200pct'...
            '400pct'...
            'AttentionTask'...
            };

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


%% plot all MEL and all LMS within subject
% no error bars
for ss = 1:length(subjNames)
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for kk = 1:length(conditions)
                condition = conditions{kk};
                if strcmp(condition,'MaxMelCRF')
                    sessions = sessionsMEL;
                else
                    sessions = sessionsLMS;
                end
                for cc = 1: length(controls)
                    control = controls{cc};
                    dataFiles{cc} = fullfile (data_dir,  condition, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                    dataExt = 'csv' ;
                    legendTexts = controls;
                    titleText = [ subjNames{ss} ' - ' condition ' - '  hemi ' '  ROI];
                    saveName = [subjNames{ss} '_' condition '_ALL_' hemi '_' ROI] ;
                    output_dir = fullfile (dropbox_dir, condition, subjNames{ss} );
                    if ~exist ('output_dir', 'dir')
                        mkdir ('output_dir')
                    end
                end
                FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
            end
        end
    end
end

% with errorbars


%% Compare MEL and LMS within subject
% single control, with errorbars
for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for  cc = 1: length(controls)
                control = controls{cc};
                dataMEL = fullfile (data_dir, 'MaxMelCRF', subjName, sessionsMEL{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxMelCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                dataLMS = fullfile (data_dir, 'MaxLMSCRF', subjName, sessionsLMS{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxLMSCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                
                errorMEL = fullfile (data_dir, 'MaxMelCRF', subjName, sessionsMEL{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxMelCRF_' control '_' hemi '_' ROI '_wdrf.tf_SEM.csv']);
                errorLMS = fullfile (data_dir, 'MaxLMSCRF', subjName, sessionsLMS{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxLMSCRF_' control '_' hemi '_' ROI '_wdrf.tf_SEM.csv']);
                
                dataFiles = {...
                    dataMEL ...
                    dataLMS ...
                    };
                
                errorFiles = {...
                    errorMEL ...
                    errorLMS ...
                    };
                titleText = [subjName ' CRF ' control ' ' hemi ' ' ROI];
                
                output_dir = fullfile (dropbox_dir, 'CRF_comparison', subjNames{ss} );
                
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
                    ['MaxMelCRF_' control] ...
                    ['MaxLMSCRF_' control] ...
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
                    
                    saveName = [subjName '_CRF_comparison_' control '_' hemi '_' ROI] ;
                    if ~exist (output_dir,'dir')
                        mkdir (output_dir);
                    end
                    saveas(gcf, fullfile(output_dir, saveName), 'pdf');
                    close all;
            end
        end
    end
end


% single controls, no errobars
for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for  cc = 1: length(controls)
                control = controls{cc};
                dataMEL = fullfile (data_dir, 'MaxMelCRF', subjName, sessionsMEL{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxMelCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                dataLMS = fullfile (data_dir, 'MaxLMSCRF', subjName, sessionsLMS{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxLMSCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                
                dataFiles = {...
                    dataMEL ...
                    dataLMS ...
                    };
                
                dataExt = 'csv' ;
                legendTexts = { ...
                    ['MaxMelCRF_' control] ...
                    ['MaxLMSCRF_' control] ...
                    };
                titleText = [subjName ' CRF ' control ' ' hemi ' ' ROI];
                saveName = [subjName '_CRF_comparison_' control '_' hemi '_' ROI] ;
                output_dir = fullfile (dropbox_dir, 'CRF_comparison_within_subj_noError', subjNames{ss} );
                FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
            end
        end
    end
end

%% Compare MEL across subjects
% single control, with errorbars

% all controls, no errobars



%% Compare LMS across subjects
% single control, with errorbars

% all controls, no errobars

