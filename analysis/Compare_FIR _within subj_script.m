output_dir ='/Users/giulia/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/MelanopsinMR/FIR_comparisons';

subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
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
for ss = 1:length(subjNames)
    subjName = subjNames{ss};
    for hh = 1:length(hemis)
        hemi = hemis{hh};
        
        for jj = 1:length(ROIs)
            ROI = ROIs{jj};
            dataMEL = { ...
                ['/data/jag/MELA/HERO_asb1/032416/FIR_figures/' hemi '_' ROI '_' 'MaxMelPulse_FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_aso1/032516/FIR_figures/' hemi '_' ROI '_' 'MaxMelPulse_FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_gka1/033116/FIR_figures/' hemi '_' ROI '_' 'MaxMelPulse_FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_mxs1/040616/FIR_figures/HERO_mxs1_MaxMelPulse_' hemi '_' ROI '_' 'FIR_raw.fig'] ...
                };
            dataLMS = { ...
                ['/data/jag/MELA/HERO_asb1/040716/FIR_figures/HERO_asb1_MaxLMSPulse_' hemi '_' ROI '_' 'FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_aso1/033016/FIR_figures/' hemi '_' ROI '_' 'MaxLMSPulse_FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_gka1/040116/FIR_figures/' hemi '_' ROI '_' 'MaxLMSPulse_FIR_raw.fig'] ...
                ['/data/jag/MELA/HERO_mxs1/040816/FIR_figures/HERO_mxs1_MaxLMSPulse_' hemi '_' ROI '_' 'FIR_raw.fig'] ...
                };
            
            dataFiles = {...
                dataMEL{ss} ...
                dataLMS{ss} ...
                };
            
            dataExt = 'fig' ;
            legendTexts = { ...
                '400% Melanopsin Pulse' ...
                '400% LMS Pulse' ...
                };
            titleText = [subjName ' FIR comparison ' hemi ' ' ROI];
            saveName = [subjName '_FIR_comparison_' hemi '_' ROI] ;
            
            FIR_multiplot (output_dir,dataFiles, dataExt, legendTexts, titleText, saveName)
        end
    end
end