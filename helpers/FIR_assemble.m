function FIR_assemble(session_dir, subject_name, subj_name, dropbox_dir, SUBJECTS_DIR, copeNames, hemis, ROIs, funcs, funcNames, Conditions, Runs)
% FIR_assemble(session_dir, subject_name, subj_name, dropbox_dir, SUBJECTS_DIR, copeNames, hemis, ROIs, funcs, funcNames, Conditions, Runs)

for hh = 1:length(hemis)
    hemi = hemis{hh};
    %LGN variables
    in_vol = fullfile('~/data/' , [hemi '.LGN.prob.nii.gz']);
    out_vol =  fullfile(session_dir, [hemi '.LGN.prob.nii.gz']);
    ref_vol = fullfile (SUBJECTS_DIR , subject_name, '/mri/T1.mgz');

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
            case 'V1'
                ROIind = find(abs(areas.vol)==1 & (ecc.vol>5 & ecc.vol<=30));
        end        
        
        %% Get means
        for ff = 1:length(funcs)
            func = funcs{ff};
            funcName = funcNames{ff};
            for i = 1:length(Conditions)
                condName = Conditions{i};
                runNums = Runs{i};
                %[means{i},sems{i}] = psc_cope(session_dir,subject_name,runNums,func,ROIind, copeNames);
                [means{i},sems{i}] = psc_cope_get_means(session_dir,subject_name,runNums,func,ROIind, copeNames);
                FIR_plot(means{i},sems{i},ROI,condName,subj_name,hemi,funcName);
                if ~exist (fullfile(session_dir, 'FIR_figures'),'dir')
                    mkdir (session_dir, 'FIR_figures');
                end
                if ~exist (fullfile(dropbox_dir, 'FIR_figures'),'dir')
                    mkdir (dropbox_dir, 'FIR_figures');
                end
                savefig(fullfile(session_dir, 'FIR_figures', [hemi '_' ROI '_' condName '_' func '.fig'])); %save .fig on cluster
                set(gcf, 'PaperPosition', [0 0 4 4]);
                set(gcf, 'PaperSize', [4 4]);
                saveas(gcf, fullfile(dropbox_dir,'FIR_figures', [hemi '_' ROI '_' condName '_' func]), 'pdf');%save .pdf on dropbox
                close all;
            end
        end
    end
end