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
% subject names
subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

% freesurfer subject names
subject_names = { ...
    'HERO_asb1_MaxMel' ...
    'HERO_aso1_MaxMel' ...
    'HERO_gka1_3T' ...
    'HERO_mxs1_MaxMel' ...
    };

% 400pct MaxMel sessions
sessionsMEL400 = { ...
    {'032416' ''} ...
    {'032516' ''} ...
    {'033116' ''} ...
    {'040616' ''} ...
    };

% 400pct MaxLMS sessions
sessionsLMS400 = { ...
    {'040716' ''} ...
    {'033016' ''} ...
    {'040116' ''} ...
    {'040816' ''} ...
    };

% Splatter Control CRF
sessionsSplatterCRF = { ...
    {'051016' ''}  ...
    {'042916' ''} ...
    {'050616' ''} ...
    {'050916' ''} ...
    };

% Mel Pulses CRF
sessionsMELCRF = { ...
    {'060716' ''} ...
    {'053116' ''} ...
    {'060216' ''} ...
    {'060916' '061016_Mel'} ...  %%%% for HERO_mxs1 this condition was acquired in 2 different sessions
    };

% LMS Pulses CRF
sessionsLMSCRF = { ...
    {'060816' ''} ...
    {'060116' ''} ...
    {'060616' ''} ...
    {'062816' ''} ...
    };

% all sessions
allSessions = { sessionsMEL400 ...
        sessionsLMS400 ...
        sessionsSplatterCRF ...
        sessionsMELCRF ...
        sessionsLMSCRF ...
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
logDir = fullfile(data_dir, 'LOGS'); % folder for preprocessing logs (required by MRklar).
if ~exist(logDir,'dir')
    mkdir(logDir);
end
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
for ss = 1:length(subjNames)
    sprintf ('Sorting DICOMs for subject %s \n', subjNames{ss});
    for kk = 1:length(allSessions)
        sessions = allSessions{kk}{ss};
        for mm = 1:length(sessions)
            if ~isempty(sessions{mm})
                dicom_sort (fullfile(data_dir, subjNames{ss}, sessions{mm}, 'DICOMS'));
            end
        end
    end
end
fprintf ('All DICOMS are sorted.\n');

% In each session folder, we MANUALLY DELETE the incomplete DICOM series
% that resulted from acquisition errors during the session, as per
% information on the README.md file.
fprintf ('\n>>>> MANUALLY DELETE incomplete DICOM series from each session folder, as per information on the README.md file <<<<<\n\n' )


% We acquired a single T1 series from each subject, during the MelPulses400
% session (i.e. each subject's first session). For each subject, we copy
% the MPRAGE DICOM series from the Mel400 session in the other sessions DICOM
% folders.
for ss = 1:length(subjNames)
    fprintf ('Copying MPRAGE DICOM files for subject %s \n', subjNames{ss});
    for kk = 1:length(allSessions) % we copy into all the sessions following the first one
        sessions = allSessions{kk}{ss};
        for mm = 1:length(sessions)
            if ~isempty(sessions{mm}) & ~strcmp(sessions{mm},sessionsMEL400{ss}{1})
                copyfile(fullfile(data_dir, subjNames{ss}, sessionsMEL400{ss}{1}, 'DICOMS','*T1w_MPR'), ...
                    fullfile(data_dir, subjNames{ss}, sessions{mm}, 'DICOMS'));
            end
        end
    end
end
fprintf ('All MPRAGE folders copied.\n');
fprintf ('\n\nThe dataset is now ready for the analysis.\n')
toc

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

for ss = 1:length(subjNames)
    subject_name = subject_names{ss};
    for kk = 1:length(allSessions) % we copy into all the sessions following the first one
        sessions = allSessions{kk}{ss};
        for mm = 1:length(sessions)
            if ~isempty(sessions{mm})
                session_dir  = fullfile(data_dir, subjNames{ss}, sessions{mm});
                % Count how many bold runs are in each session.  We do this
                % now to avoid to feed the number of bold runs for each
                % session as a preprocessing variable beforehand.
                fprintf ('Counting BOLD runs for subject %s, session %s \n',...
                    subjNames{ss}, sessions{mm});
                b = find_bold(fullfile(session_dir,'DICOMS'));
                numRuns = length(b);
                fprintf ('>> %d BOLD runs found.\n', numRuns)
                % Create preprocessing scripts for this session
                job_name = [subjNames{ss} '_' sessions{mm}];
                outDir = fullfile(session_dir,'shell_scripts');
                if ~exist(outDir,'dir')
                    mkdir(outDir);
                end
                
                fprintf ('Creating preprocessing scripts for subject %s, session %s \n', subjNames{ss}, sessions{mm});
                create_preprocessing_scripts(session_dir,subject_name,outDir, ...
                    logDir,job_name,numRuns,reconall,slicetiming,refvol,filtType, ...
                    lowHz,highHz,physio,motion,task,localWM,anat,amem,fmem)
                fprintf ('>> Done\n\n');
                % Launch preprocessing scripts using a system command
                fprintf ('Launching preprocessing script for subject %s, session %s \n', subjNames{ss}, sessions{mm});
                system(sprintf('sh %s/submit_%s_all.sh', outDir,job_name));
                fprintf ('>> Done\n\n');
            end
        end
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

for ss = 1:length(subjNames)
    for kk = 1:length(allSessions)
        sessions = allSessions{kk}{ss};
        for mm = 1:length(sessions)
            if ~isempty(sessions{mm})
                project_template (fullfile(data_dir, subjNames{ss}, sessions{mm}),subject_names{ss});
            end
        end
    end
end

fprintf ('\n\nProject template completed for all runs.\n')
toc

%stop logging
diary ('off')
%% Create jobs to make packets
mem = 42;
packetType = 'V1';
func = 'wdrf.tf';
subList = listdir(fullfile(data_dir,'HERO_*'),'dirs');
for i = 1:length(subList)
    sessList = listdir(fullfile(data_dir,subList{i}),'dirs');
    for j = 1:length(sessList)
        sessionDir = fullfile(data_dir,subList{i},sessList{j});
        outDir = fullfile(sessionDir,'shell_scripts');
        % Create 'makePackets' script
        fname = fullfile(outDir,'makePackets_V1.sh');
        fid = fopen(fname,'w');
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,['sessionDir=' sessionDir '\n']);
        fprintf(fid,['packetType=' packetType '\n']);
        fprintf(fid,['func=' func '\n\n']);
        matlab_string = '"makePackets(''$sessionDir'',''$packetType'',''$func'');"';
        fprintf(fid,['matlab -nodisplay -nosplash -r ' matlab_string]);
        fclose(fid);
        % Create submit script
        fname = fullfile(outDir,'submit_makePackets_V1.sh');
        fid = fopen(fname,'w');
        fprintf(fid,['qsub -l h_vmem=' num2str(mem) ...
            '.2G,s_vmem=' num2str(mem) 'G -e ' logDir ' -o ' logDir ' ' ...
            fullfile(outDir,'makePackets_V1.sh')]);
        fclose(fid);
    end
end
%% Extract packets for each session for V1
% % start logging
% diary(diaryfile)
% diary ('on')
% timestamp = datestr((datetime('now')), formatOut);
% fprintf ('\n\n~~~~~~~ Make Packets - %s ~~~~~~~\n\n', timestamp);
% tic;
% 
% %extract packets
% for ss = 1:length(subjNames)
%     for kk = 1:length(allSessions)
%         sessions = allSessions{kk}{ss};
%         for mm = 1:length(sessions)
%             if ~isempty(sessions{mm})
%                 for rr = 1:length(ROIs)
%                     if strcmp(ROIs{rr}, 'V2andV3')
%                         packetType = 'V2V3';
%                     else
%                         packetType = ROIs{rr};
%                     end
%                     fprintf('\n Saving %s packets for for subject %s, session %s ... ', ROIs{rr}, subjNames{ss}, sessions{mm});
%                     [packets] = makePackets(fullfile(data_dir, subjNames{ss}, sessions{mm}),packetType);
%                     fprintf ('done.\n')
%                     clear packets
%                 end
%             end
%         end
%     end
% end
% fprintf ('\n\nMake Packets completed for all runs.\n')
% toc

%stop logging
diary ('off')