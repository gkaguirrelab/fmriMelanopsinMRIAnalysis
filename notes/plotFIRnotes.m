session_dir = '/data/jag/MELA/HERO_gka1/031516';
subject_name =  'HERO_gka1_3T';
dropbox_dir = '/Users/giulia/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/MelanopsinMRMaxMel/HERO_gka1/031516/FIR_figures';
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects';
copeNames = {...
        'Sec00' ...
        'Sec01' ...
        'Sec02' ...
        'Sec03' ...
        'Sec04' ...
        'Sec05' ...
        'Sec06' ...
        'Sec07' ...
        'Sec08' ...
        'Sec09' ...
        'Sec10' ...
        'Sec11' ...
        'Sec12' ...
        'Sec13' ...
        };
    hemis = {...
         'mh'...
         'lh'...
        'rh'...
        };
    ROIs = {...
    'LGN'...
%     'V1all'...
%     'V1low'...
%     'V1mid'...
%     'V1high'...
%     'V2andV3'...    
    };

funcs = {...
'FIR_raw' ...
'FIR_5mm'...
};
funcNames = {...
'FIR.raw' ...
'FIR.5mm'...
};



for hh = 1:length(hemis)
    hemi = hemis{hh};
%LGN variables
in_vol = fullfile('~/data/' , [hemi '.LGN.prob.nii.gz']);
out_vol =  fullfile(session_dir, [hemi '.LGN.prob.nii.gz']);
ref_vol = fullfile (SUBJECTS_DIR , subject_name, '/mri/T1.mgz');

%% Run the first-level analysis


%% Project the anatomical templates to subject space
% this session needs to run just for the first time

%project_template(session_dir,subject_name); % for visual cortex
apply_cvs_inverse(in_vol,out_vol,ref_vol,subject_name,SUBJECTS_DIR) %for LGN

%% 

for jj = 1:length(ROIs)
    ROI = ROIs{jj};
    % Get ROIind
    areas = load_nifti(fullfile(session_dir,[hemi '.areas.vol.nii.gz'])); % both hemis
    ecc = load_nifti(fullfile(session_dir,[hemi '.ecc.vol.nii.gz'])); % both hemis
    switch ROI
        case 'V1all'
            ROIind = find(abs(areas.vol)==1); % all of V1
        case 'V1low'
            ROIind = find(abs(areas.vol)==1 & ecc.vol<=5);
        case 'V1mid'
            ROIind = find(abs(areas.vol)==1 & (ecc.vol>5 & ecc.vol<=15));
        case 'V1high'
            ROIind = find(abs(areas.vol)==1 & (ecc.vol>15 & ecc.vol<=40));
        case 'V2andV3'
            ROIind = find(abs(areas.vol)==2 | abs(areas.vol)==3);
        case 'LGN'
            if strcmp(hemi,'mh')
                lgn_rh = load_nifti(fullfile(session_dir, 'rh.LGN.prob.nii.gz'));
                lgn_lh = load_nifti(fullfile(session_dir, 'lh.LGN.prob.nii.gz'));
                ROIind = find((lgn_rh.vol)>=25 | (lgn_lh.vol)>=25);
            else
                lgn = load_nifti(fullfile(session_dir, [hemi '.LGN.prob.nii.gz']));
                ROIind = find((lgn.vol)>=25);
            end
    end
    %% Define Conditions and runs
    Conditions = {'MaxMelPulse'};
    Runs = {[1, 2, 3, 4, 5, 6, 7, 8, 9]};
    
    
    %% Get means
    for ff = 1:length(funcs)
        func = funcs{ff};
        funcName = funcNames{ff};
        for i = 1:length(Conditions)
            condName = Conditions{i};
            runNums = Runs{i};
            [means{i},sems{i}] = psc_cope(session_dir,subject_name,runNums,func,ROIind, copeNames);
            plot_FIR(means{i},sems{i},ROI,condName,hemi,funcName);
            if ~exist (fullfile(session_dir, 'FIR_figures'),'dir')
                mkdir (session_dir, 'FIR_figures');
            end
            if ~exist (fullfile(dropbox_dir, 'FIR_figures'),'dir')
                mkdir (dropbox_dir, 'FIR_figures');
            end
            savefig(fullfile(session_dir, 'FIR_figures', [hemi '_' ROI '_' condName '_' func '.fig'])); %save .fig on cluster
            savefigs('pdf', fullfile(dropbox_dir,'FIR_figures', [hemi '_' ROI '_' condName '_' func])); %save .pdf on dropbox
            close all;
        end
    end
end
end