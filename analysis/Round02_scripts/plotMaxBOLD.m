% plot max BOLD response

%% define variables
dropbox_dir = '/Users/giulia/Desktop/TEST' %'/Users/giulia/Dropbox-Aguirre-Brainard-Lab/MELA_analysis/MelanopsinMR/FIR_comparisons';
data_dir = '/data/jag/MELA/MelanopsinMR/Results';
subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...   % needs to couple more than one session for MEL
    };

sessionsMEL = { ...
    '060716' ...
    '053116' ...
    '060216' ...
    '060916' ...
    };
sessionsLMS = { ...
    '060816' ...
    '060116' ...
    '060616' ...
    '062816' ...   % this session will be discarded and rerun.
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
%%
for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for  cc = 1: length(controls)
                control = controls{cc};
                % load data file
                dataMEL = fullfile (data_dir, 'MaxMelCRF', subjName, sessionsMEL{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxMelCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                dataLMS = fullfile (data_dir, 'MaxLMSCRF', subjName, sessionsLMS{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxLMSCRF_' control '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                errorMEL = fullfile (data_dir, 'MaxMelCRF', subjName, sessionsMEL{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxMelCRF_' control '_' hemi '_' ROI '_wdrf.tf_SEM.csv']);
                errorLMS = fullfile (data_dir, 'MaxLMSCRF', subjName, sessionsLMS{ss}, 'CSV_datafiles', [subjNames{ss} '_MaxLMSCRF_' control '_' hemi '_' ROI '_wdrf.tf_SEM.csv']);
                
                % take out max and corresponding error
                ptsMEL = csvread(dataMEL);
                [maxMEL(cc),maxMELidx(cc)] = max(ptsMEL);
                ptserrorMEL = csvread(errorMEL);
                maxerrorMEL(cc) = ptserrorMEL(maxMELidx(cc));
                
                ptsLMS = csvread(dataLMS);
                [maxLMS(cc),maxLMSidx(cc)] = max(ptsLMS);
                ptserrorLMS = csvread(errorLMS);
                maxerrorLMS(cc) = ptserrorLMS(maxLMSidx(cc));
            end
            
            % make the plots
            output_dir = fullfile (dropbox_dir, 'CRF_MaxBOLDresponse', subjNames{ss} );
            
            figure('units','normalized','position',[0 0 1 1]);
            hold on
            titleText = [subjName ' MaxBoldResponse ' hemi ' ' ROI];
            legendTexts = { ...
                'MaxMelCRF' ...
                'MaxLMSCRF'...
                'Attention task MelCRF' ...
                'Attention task LMSCRF'...
                };
            
            xTick = 1:6;
            xLabels = controls;
            x = 1:6;
            offset = 0.1;
              
            e1 = errorbar(x(1:5), maxMEL(1:5), maxerrorMEL(1:5), '-k');
            e2 = errorbar(x(1:5) + offset, maxLMS(1:5), maxerrorLMS(1:5), '-k');
            e3 = errorbar(x(6), maxMEL(6), maxerrorMEL(6), '-k');
            e4 = errorbar(x(6) + offset, maxLMS(6), maxerrorLMS(6), '-k');
            
            set(get(get(e1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(e2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(e3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(e4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
            plot( x(1:5), maxMEL(1:5), 's', 'LineStyle', 'none', 'Color', 'k', 'MarkerFaceColor', 'b');
            plot( x(1:5) + offset, maxLMS(1:5), 's', 'LineStyle', 'none', 'Color', 'k', 'MarkerFaceColor', 'r');
            plot( x(6), maxMEL(6), 'o', 'LineStyle', 'none', 'Color', 'k', 'MarkerFaceColor', 'b');
            plot( x(6) + offset, maxLMS(6), 'o', 'LineStyle', 'none', 'Color', 'k', 'MarkerFaceColor', 'r');
            
            
            legend (legendTexts, 'Interpreter','none');
            
            ax = gca;
            set(ax,'XTick',xTick);
            set(ax,'XTickLabel',xLabels);
            xlabel('Contrast [pct]');
            ylabel('Max Bold Response [pct signal change]');
            ylim([-0.2 1.4]);
            xlim([0 7]);
            set(gca, 'TickDir', 'out'); box off;
            pbaspect([1 1 1])
            title (titleText,'Interpreter','none')
            
            set(gcf, 'PaperPosition', [0 0 7 7]);
            set(gcf, 'PaperSize', [7 7]);
            
            saveName = [subjName '_CRFMaxBOLDresponse_' hemi '_' ROI] ;
            if ~exist (output_dir,'dir')
                mkdir (output_dir);
            end
            saveas(gcf, fullfile(output_dir, saveName), 'pdf');
            close all;
            
        end
    end
end