%% MelanopsinMR master script - v.2

% Dataset and project description goes here


%% Dataset variables
% global paths
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path
if ~exist (results_dir, 'dir')
    mkdir (results_dir);
end
% Used to find the subjects
subjectIdentifier = 'HERO_*';
% freesurfer subject names
subject_names = { ...
    'HERO_asb1_MaxMel' ...
    'HERO_aso1_MaxMel' ...
    'HERO_gka1_3T' ...
    'HERO_mxs1_MaxMel' ...
    };

%% Analysis variables
% session types (or conditions)
conditions = {...
    'MelPulses400pct' ...
    'LMSPulses400pct' ...
    'SplatterControlCRF' ...
    'MelPulsesCRF' ...
    'LMSPulsesCRF' ...
    };
% hemispheres
hemis = {...
    'mh'...
    'lh'...
    'rh'...
    };
% ROIs
ROIs = {...
    'V1' ...
    'V2andV3'...
    'LGN'...
    };
% controls
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
% directions
directions = { ...
    'Mel'
    'LMS'
    'AttentionTask'
    };

%% Setting up LOG File
% This section will set up a log file in which all the following steps will
% be recorded as single entries, with their own timestamps, using Matlab's
% "diary" function. This log file appends any new instance at the end. To
% get a "clean" log, delete any previously existing log files and run the
% script from start to end once.
% Note that some functions called in the script (e.g.
% create_preprocessing_scripts) will create their own log files.

% Define log directory
logDir = fullfile(data_dir, 'LOGS'); % folder for preprocessing logs (required by MRklar).
if ~exist(logDir,'dir')
    mkdir(logDir);
end
% set logfile path and name
diaryfile = fullfile(results_dir, 'MasterScriptLOG.txt');
% set timestamp format
formatOut = 'mmddyy_HH.MM.SS';

%% Preprocessing variables
slicetiming = 0 ;
reconall = 0 ; % change to 1 if the dataset was already run thorugh freesurfer reconall
refvol = 1 ;
filtType = 'high' ;
lowHz = 0.01 ;
highHz = 0.10 ;
physio = 1;
motion = 1;
task = 0;
localWM = 1;
anat = 1;
amem = 20;
fmem = 50;
% NOTE: will will get the number of runs for each session counting the bold runs
% within the session folder


%% END OF PROCESSING VARIABLES. DO NOT MODIFY THE SCRIPT FROM HERE ON %%


%% Getting the dataset ready for the analysis
% This section assumes that the analysis starts on the fMRI dataset as it is
% backed up on the DVDs; for every session, the following files and folders should be present:
% 1. DICOMS/  (containing sorted or unsorted .dcm files)
% 2. PulseOx/
% 3. Protocols/
% 4. MatFiles/
% 5. README.md

% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Getting the dataset ready for the analysis - %s ~~~~~~~\n\n', timestamp);
tic;

% Before proceeding with the analysis, we make sure that every session
% contains the appropriate DICOM files.

% Firstly, we sort the DICOM files into Series folders:
subjDirs = listdir(fullfile(data_dir,subjectIdentifier),'dirs');
for ss = 1:length(subjDirs)
    subDir = fullfile(data_dir,subjDirs{ss});
    sessDirs = listdir(fullfile(subDir),'dirs');
    for jj = 1:length(sessDirs)
        fprintf('Sorting DICOMs for subject %s session %s\n',subjDirs{ss},sessDirs{jj});
        dicom_sort(fullfile(subDir,sessDirs{jj},'DICOMS'));
        % We acquired a single T1 series from each subject, during the MelPulses400
        % session (i.e. each subject's first session). For each subject, we copy
        % the MPRAGE DICOM series from the Mel400 session in the other sessions DICOM
        % folders.
        if jj ~= 1
            copyfile(fullfile(subDir,sessDirs{1},'DICOMS','*T1w_MPR'), ...
                fullfile(subDir,sessDirs{jj},'DICOMS'));
        end
    end
end
fprintf ('All DICOMS are sorted.\n');

% In each session folder, we MANUALLY DELETE the incomplete DICOM series
% that resulted from acquisition errors during the session, as per
% information on the README.md file.
fprintf ('\n>>>> MANUALLY DELETE incomplete DICOM series from each session folder, as per information on the README.md file <<<<<\n\n' )

% stop logging
diary ('off')

%% Preprocessing
% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Preprocessing - %s ~~~~~~~\n\n', timestamp);
tic;

% Display variables for preprocessing (for logging purposes)
fprintf ('\nGeneral parameters for MRklar preprocessing: \n');
display(slicetiming)
display(reconall)
display(refvol)
display(filtType)
display(lowHz)
display(highHz)
display(physio)
display(motion)
display(task)
display(localWM)
display(anat)
display(amem)
display(fmem)
display(logDir)



subjDirs = listdir(fullfile(data_dir,subjectIdentifier),'dirs');
for ss = 1:length(subjDirs)
    subject_name = subjDirs{ss};
    subDir = fullfile(data_dir,subjDirs{ss});
    sessDirs = listdir(fullfile(subDir),'dirs');
    for kk = 1:length(sessDirs) % we copy into all the sessions following the first one
        session_name = sessDirs{kk};
        session_dir  = fullfile(subDir,session_name);
        % Count how many bold runs are in each session.  We do this
        % now to avoid to feed the number of bold runs for each
        % session as a preprocessing variable beforehand.
        fprintf ('Counting BOLD runs for subject %s, session %s \n',...
            subject_name, session_dir);
        b = find_bold(fullfile(session_dir,'DICOMS'));
        numRuns = length(b);
        fprintf ('>> %d BOLD runs found.\n', numRuns)
        % Create preprocessing scripts for this session
        job_name = [subject_name '_' session_name];
        outDir = fullfile(session_dir,'shell_scripts');
        if ~exist(outDir,'dir')
            mkdir(outDir);
        end
        
        fprintf ('Creating preprocessing scripts for subject %s, session %s \n', subject_name, session_name);
        create_preprocessing_scripts(session_dir,subject_name,outDir, ...
            logDir,job_name,numRuns,reconall,slicetiming,refvol,filtType, ...
            lowHz,highHz,physio,motion,task,localWM,anat,amem,fmem)
        fprintf ('>> Done\n\n');
        % Launch preprocessing scripts using a system command
        fprintf ('Launching preprocessing script for subject %s, session %s \n', subject_name, session_name);
        system(sprintf('sh %s/submit_%s_all.sh', outDir,job_name));
        fprintf ('>> Done\n\n');
    end
end
fprintf ('\n\nAll preprocessing script have been submitted. Wait for them to complete before moving on with this script\n')
toc

%stop logging
diary ('off')

%% Project template
% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Project template - %s ~~~~~~~\n\n', timestamp);
tic;

subjDirs = listdir(fullfile(data_dir,subjectIdentifier),'dirs');
for ss = 1:length(subjDirs)
    subject_name = subject_names{ss};
    subDir = fullfile(data_dir,subjDirs{ss});
    sessDirs = listdir(fullfile(subDir),'dirs');
    for kk = 1:length(sessDirs)
        session_dir = fullfile(subDir,sessDirs{kk});
        project_template(session_dir,subject_name); % for Visual Cortex ROIs
        make_LGN_ROI(session_dir,subject_name); % for LGN ROI
    end
end

fprintf ('\n\nProject template completed for all runs.\n')
toc

%stop logging
diary ('off')

%% Make HRF
% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Make HRF for every subject - %s ~~~~~~~\n\n', timestamp);
tic;

subList = listdir(fullfile(data_dir,'HERO_*'),'dirs');
for ss = 1:length(subList)
    params.subjDir = fullfile(data_dir,subList{ss});
    subjHRF(params);
end

fprintf ('\n\nAll subjHRF have been made. \n')
toc

%stop logging
diary ('off')

%% Create and submit jobs to make packets
% start logging
diary(diaryfile)
diary ('on')
timestamp = datestr((datetime('now')), formatOut);
fprintf ('\n\n~~~~~~~ Create and submit make packets jobs - %s ~~~~~~~\n\n', timestamp);
tic;

mem = 52;
func = 'wdrf.tf';
subList = listdir(fullfile(data_dir,'HERO_*'),'dirs');
for ss = 1:length(subList)
    sessList = listdir(fullfile(data_dir,subList{ss}),'dirs');
    for jj = 1:length(sessList)
        for rr = 1%:length(ROIs)
            if strcmp(ROIs{rr}, 'V2andV3')
                roiType = 'V2V3';
            else
                roiType = ROIs{rr};
            end
            sessionDir = fullfile(data_dir,subList{ss},sessList{jj});
            outDir = fullfile(sessionDir,'shell_scripts');
            packetType = 'bold';
            saveFlag = 1;
            % Create 'makePackets' script
            fname1 = fullfile(outDir,['makePackets_' roiType '.sh']);
            fid1 = fopen(fname1,'w');
            fprintf(fid1,'#!/bin/bash\n');
            fprintf(fid1,['sessionDir=' sessionDir '\n']);
            fprintf(fid1,['packetType=' packetType '\n']);
            fprintf(fid1,['roiType=' roiType '\n\n']);
            fprintf(fid1,['func=' func '\n\n']);
            fprintf(fid1,['saveFlag=' saveFlag '\n\n']);
            matlab_string = '"makePackets(''$sessionDir'',''$packetType'',''$roiType'',''$func'',''$saveFlag'');"';
            fprintf(fid1,['matlab -nodisplay -nosplash -r ' matlab_string]);
            fclose(fid1);
            % Create submit script
            fname2 = fullfile(outDir,['submit_makePackets_' roiType '.sh']);
            fid2 = fopen(fname2,'w');
            fprintf(fid2,['qsub -l h_vmem=' num2str(mem) ...
                '.2G,s_vmem=' num2str(mem) 'G -e ' logDir ' -o ' logDir ' ' ...
                fullfile(outDir,['makePackets_' roiType '.sh'])]);
            fclose(fid2);
            % Launch preprocessing scripts using a system command
            fprintf ('Launching makePacket script for subject %s, session %s, ROI %s \n', subList{ss},sessList{jj},ROIs{rr});
            system(sprintf('sh %s/submit_makePackets_%s.sh', outDir,roiType));
            fprintf ('>> Done\n\n');
        end
    end
end

fprintf ('\n\nAll makePackets script have been submitted. Wait for them to complete before moving on with the next cell\n')
toc

%stop logging
diary ('off')

%% Plot and save HRF mean and SEM for every subject 

subList = listdir(fullfile(data_dir,'HERO_*'),'dirs');
for ss = 1:length(subList)
    sessList = listdir(fullfile(data_dir,subList{ss}),'dirs');
    sessionDir = fullfile(data_dir,subList{ss},sessList{1}); % the HRF folder is the same in every session. We just pick the first one.
    hrfDir = fullfile(sessionDir,'HRF');
    for rr = 1%:length(ROIs)
        roiType = ROIs{rr};
        load(fullfile(hrfDir,[roiType '.mat']));
        fig = figure('units','normalized','position',[0 0 1 1]);
        shadedErrorBar([],HRF.mean, HRF.sem);
        title (['Mean' char(177) 'SEM - ' subList{ss} ' ' ROIs{rr}],'Interpreter','none')
        xlabel('Time [msec]');
        ylabel('Amplitude [% signal change]');
        str = ['Total runs = ',num2str(HRF.numRuns)];
        text(2000, -0.1, str)
        ylims = [-0.3 1.4];
        ylim(ylims);
        xlims = [0, 17000];
        xlim(xlims);
        adjustPlot(fig);
        saveName = ['HRF_,mean_' subList{ss} '_' ROIs{rr}];
        saveDir = fullfile(results_dir, 'HRF_mean');
        if ~exist (saveDir, 'dir')
            mkdir (saveDir);
        end
        saveas(fig, fullfile(saveDir, saveName), 'pdf');
        close(fig);
    end
end

    
      
