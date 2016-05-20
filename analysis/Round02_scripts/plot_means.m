%%
output_dir = '/Users/giulia/Desktop/TEST'%'/Users/giulia/Dropbox-Aguirre-Brainard-Lab/MELA_analysis/MelanopsinMR/FIR_comparisons';
data_dir = '/data/jag/MELA/MelanopsinMR';
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
subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };
sessionsMEL = { ...
    '032416' ...
    '032516' ...
    '033116' ...
    '040616' ...
    };
sessionsLMS = { ...
    '040716' ...
    '033016' ...
    '040116' ...
    '040816' ...
    };
sessionsCTRL = { ...
    '051016' ...
    '042916' ...
    '050616' ...
    '050916' ...
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


for cc = 1:length(conditions)
    condition = conditions{cc};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            for ss = 1:length(subjNames)
                switch condition
                    case'MelPulses_400pct'
                        sessions = sessionsMEL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yMEL(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yMEL(:,ss);
                        
                    case'MelPulses_400pct_AttentionTask'
                        sessions = sessionsMEL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yMELAT(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yMELAT(:,ss);
                    case 'LMSPulses_400pct'
                        sessions = sessionsLMS;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yLMS(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yLMS(:,ss);
                        
                    case 'LMSPulses_400pct_AttentionTask'
                        sessions = sessionsLMS;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yLMSAT(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yLMSAT(:,ss);
                        
                    case 'SplatterControl_195pct'
                        sessions = sessionsCTRL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yCTRL195(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yCTRL195(:,ss);
                        
                    case 'SplatterControl_100pct'
                        sessions = sessionsCTRL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yCTRL100(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yCTRL100(:,ss);
                        
                    case 'SplatterControl_50pct'
                        sessions = sessionsCTRL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yCTRL50(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yCTRL50(:,ss);
                        
                    case 'SplatterControl_25pct'
                        sessions = sessionsCTRL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yCTRL25(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yCTRL25(:,ss);
                        
                    case 'SplatterControl_AttentionTask'
                        sessions = sessionsCTRL;
                        dataFiles{ss} = fullfile (data_dir, subjNames{ss}, sessions{ss}, 'CSV_datafiles', [subjNames{ss} '_' condition '_' hemi '_' ROI '_wdrf.tf_mean.csv']);
                        yCTRLAT(:,ss) = csvread(dataFiles{ss});
                        dataP (:, ss)= yCTRLAT(:,ss);
                end
                meanP = mean(dataP,2);
                semP = std(dataP,0,2)/sqrt(size(dataP,1));
            end
            
            % plot and save
            subj_name = 'Mean_across_subjects';
            
            FIR_plot(meanP,semP,ROI,condition,hemi, subj_name);
            
            if ~exist (fullfile(output_dir, 'FIR_figures'),'dir')
                mkdir (output_dir, 'FIR_figures');
            end
            
            set(gcf, 'PaperPosition', [0 0 7 7]);
            set(gcf, 'PaperSize', [7 7]);
            saveas(gcf, fullfile(output_dir,'FIR_figures', [subj_name '_' condition '_' hemi '_' ROI '.pdf']), 'pdf');%save .pdf on dropbox
            close all;
            
            % save means
            
            if ~exist (fullfile(output_dir, 'CSV_datafiles'),'dir')
                mkdir (output_dir, 'CSV_datafiles');
            end
            fileNameM = [subj_name '_' condition '_' hemi '_' ROI '_' 'mean.csv'];
            fileNameS = [subj_name '_' condition '_' hemi '_' ROI  '_' 'sem.csv'];
            csvwrite ((fullfile(output_dir,'CSV_datafiles', fileNameM)), meanP);
            csvwrite ((fullfile(output_dir,'CSV_datafiles', fileNameS)), semP);
            clear meanP
            clear stdP
        end
        
    end
end




