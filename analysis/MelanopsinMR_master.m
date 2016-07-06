%% Melanopsin MR Masterscript - DRAFT

% This master script illustrates the complete processing pipeline for
% MelanopsinMR datasets. 
% In order to parallelize and speed up the analysis it is suggested to used
% the "single scripts" strategy that will run the same pipeline separately
% session by session.

% 6/2/2016  gf     Written and commented.


%% inputs
% global paths
results_dir =  '/data/jag/MELA/MelanopsinMR/Results';
data_dir = '/data/jag/MELA/MelanopsinMR'; %Upenn cluster default path
SUBJECTS_DIR = '/data/jag/MELA/freesurfer_subjects'; %Upenn cluster default path

% subjects, sessions, conditions (here, we just have one subject as
% an example)
subject_name = 'HERO_asb1_MaxMel';
subj_name = 'HERO_asb1';
session_date = '060716';
condition = 'MaxMelCRF';
numOfRuns =  9 ;

% this variables are specific for the current session
reconall = 0;  % reconall flag for current session (used in preprocessing)

funcs = { ...   %Change only if FEAT fsf file outputs in a folder which is not the default one. (used in FEAT stat and post FEAT stat)
    'wdrf.tf' ...
    's5.wdrf.tf' ...
    };

proj_template = true; % Change only if proj_template was already done for the current run (used in post FEAT stat)
proj_copes = true; % Change only if proj_copes was already done for the current run (used in post FEAT stat)



%% for every subject and session:

%% Define standard paths and variables for results and logs.
SUBJECTS_DIR = getenv('SUBJECTS_DIR'); %freesurfer subjects dir

session_dir = fullfile(data_dir, subj_name,session_date);

output_dir = fullfile( results_dir, condition, subj_name, session_date);
if ~exist (output_dir, 'dir')
    mkdir (output_dir);
end
if ~exist (fullfile(output_dir, 'LOGS'),'dir')
    mkdir (fullfile(output_dir, 'LOGS'));
end
formatOut = 'mmddyy_HH.MM.SS';

%%                 %%%%%% PREPROCESSING %%%%%%%
%% inizialize log file
timestamp = datestr((datetime('now')), formatOut);
diary (fullfile(output_dir, 'LOGS', [subj_name '_' condition '_Preprocessing_' timestamp '_LOG.txt']));
diary ('on')
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Preprocessing for %s , %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
results_dir
data_dir
SUBJECTS_DIR
subject_name
subj_name
session_date
condition
numRuns

%% create preprocessing scripts
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Creating preprocessing scripts ~~~~~~~~~~~~~~~~~~~\n');
outDir = fullfile(session_dir,'shell_scripts', subj_name);
if ~exist(outDir,'dir')
    mkdir(outDir);
end
logDir = fullfile(data_dir, 'LOGS');
if ~exist(logDir,'dir')
    mkdir(logDir);
end
fprintf ('\nParameters: \n');  %the parameters are left explicit (i.e. no ;) to appear in the log file.
job_name = [subj_name '_' session_date]
slicetiming = 1
reconall  % reconall is defined for each run at the beginnning of the master script. The other parameters should not be changed.
B0 = 0
filtType = 'high'
lowHz = 0.01
highHz = 0.10
physio = 1
motion = 1
task = 0
localWM = 1
anat = 1
amem = 20
fmem = 50

create_preprocessing_scripts(session_dir,subject_name,outDir, ...
    logDir,job_name,numRuns,reconall,slicetiming,B0,filtType, ...
    lowHz,highHz,physio,motion,task,localWM,anat,amem,fmem)
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

fprintf (['\n~~~~~~~~~~~~~~~~~~~ You can now start preprocessing using the script submit_' job_name '_all.sh ~~~~~~~~~~~~~~~~~~~\n']);
% stop writing in the logfile
diary ('off')

%% Run preprocessing scripts

% from terminal, run "sh submit_<job_name>_all.sh and wait for it to
% complete.



%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of preprocessing

%%                 %%%%%% FEAT STAT %%%%%%%
%% inizialize log file
timestamp = datestr((datetime('now')), formatOut);
diary (fullfile(output_dir, 'LOGS', [subj_name '_' condition '_FEATStatAnalyis_' timestamp '_LOG.txt']));
diary ('on')
fprintf ('\n~~~~~~~~~~~~~~~~~~~ FEATstat analysis for %s , %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
results_dir
data_dir
subj_name
session_date
condition
numRuns
funcs  %funcs are defined at the beginning of the master script. Change only if FEAT fsf file outputs in a folder which is not the default one.
SUBJECTS_DIR

%% Generate regressors for FEAT analysis
fprintf ('\n ~~~~~~~~~~~~~~~~~~~ Generating regressors for FEAT analysis ~~~~~~~~~~~~~~~~~~~\n');

%set up the directiories and the protocols
matDir = fullfile (session_dir, 'MatFiles');
outDir = fullfile (session_dir, 'Stimuli');
if ~isdir(outDir)
    mkdir(outDir);
end
outDirPerformance = fullfile (results_dir, 'Performance');
if ~isdir(outDirPerformance)
    mkdir(outDirPerformance);
end
protocolName = 'MelanopsinMRMaxMel';
wrapAround = 0;
matFiles = listdir (matDir, 'files');


%generate the regressors
for mm = 1:length(matFiles)
    matFile = fullfile(matDir,matFiles{mm});
    ol_regressors(matFile,outDir,protocolName,wrapAround)
end
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Regressors generated! ~~~~~~~~~~~~~~~~~~~\n');
%% Get the performance
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Evaluating performance ~~~~~~~~~~~~~~~~~~~\n');
for mm = 1:length(matFiles)
    matFile = fullfile(matDir,matFiles{mm});
    [hits(mm) hTotal(mm) falseAlarms(mm) fTotal(mm)] = check_performance(matFile, protocolName);
end

%% Write the performance out
outFilePerformance = fullfile(outDirPerformance, [subj_name '_' condition '_performance.csv']);
fid = fopen(outFilePerformance, 'w');
fprintf(fid, 'Hits,N,False alarms,N\n');
fclose(fid);
dlmwrite(outFilePerformance, [hits' hTotal' falseAlarms' fTotal'], '-append');
fid = fopen(outFilePerformance, 'a');
fprintf(fid, 'Total\n');
fclose(fid);
dlmwrite(outFilePerformance, [sum(hits) sum(hTotal) sum(falseAlarms) sum(fTotal)], '-append');
fid = fopen(outFilePerformance, 'a');
fprintf(fid, 'Percentages\n');
fprintf(fid, '%.3f,,%.3f,', 100*(sum(hits)/sum(hTotal)), 100*(sum(falseAlarms)/sum(fTotal)));
fclose(fid);
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

%% Create feat stat files
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Creating FEATstat fsf files ~~~~~~~~~~~~~~~~~~~\n');
FSF_dir = fullfile(session_dir,'first_level_stat');
if ~isdir(FSF_dir)
    mkdir(FSF_dir);
end
d = find_bold(session_dir);
for ff = 1:length(funcs)
    funcName = funcs{ff};
    for j = 1:numRuns
        clear EVs
        % Name the output .fsf file
        if strcmp(funcName,'s5.wdrf.tf'); % 5mm smoothing
            outFile = fullfile(FSF_dir,sprintf('Run_%02d_5mm.fsf',j));
        elseif strcmp(funcName,'wdrf.tf'); % raw (no smoothing)
            outFile = fullfile(FSF_dir,sprintf('Run_%02d_raw.fsf',j));
        else
            error('funcName not recognized');
        end
        % Name the functional and anatomical files for FSL's FEAT
        funcVol = fullfile(session_dir,d{j},[funcName '.nii.gz']);
        anatVol = fullfile(session_dir,'MPRAGE','001','MPRAGE_brain.nii.gz');
        stimuli_dirs = listdir(outDir,'dirs');
        if strcmp(condition,'SplatterControl')
            EVtypes = {...
                '25Pct' ...
                '50Pct' ...
                '100Pct' ...
                '195Pct' ...
                '0Pct' ...
                };
            EVstmp = listdir(fullfile(outDir,stimuli_dirs{j},'*.txt'),'files');
            ct = 1;
            for tt=1:length(EVtypes)
                EVtype = EVtypes{tt};
                for ii=1:length(EVstmp)
                    tmp = strfind(EVstmp{ii},['_' EVtype '_']);
                    if ~isempty(tmp)
                        EVs{ct} = fullfile(outDir,stimuli_dirs{j},EVstmp{ii});
                        ct = ct+1;
                    end
                end
            end
            FIR_first_level_feat(outFile,funcVol,anatVol,EVs,condition)
        else
            EVstmp = listdir(fullfile(outDir,stimuli_dirs{j},'*.txt'),'files');
            for ii =1:length(EVstmp)
                EVs{ii} = fullfile(outDir,stimuli_dirs{j},EVstmp{ii});
            end
            FIR_first_level_feat(outFile,funcVol,anatVol,EVs,condition)
        end
    end
end
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

%% Create a script to submit all FEAT stat files
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Creating "Submit_FEAT_stat" script ~~~~~~~~~~~~~~~~~~~\n');

create_submit_first_level_feat (session_dir,subj_name,numRuns);

fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

fprintf ('\n~~~~~~~~~~~~~~~~~~~ You can now submit FEAT stat using the script submit_first_level_feat.sh ~~~~~~~~~~~~~~~~~~~\n');

% stop writing in the log file
diary ('off')

%% Run FEAT stat scripts

% from terminal, run submit_first_level_feat.sh and wait for all the FEAT jobs to
% complete.


%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of FEAT stat


%%                 %%%%%% POST FEAT STAT %%%%%%%
%% inizialize log file
timestamp = datestr((datetime('now')), formatOut);
diary (fullfile(output_dir, 'LOGS', [subj_name '_' condition '_PostFEATAnalyis_' timestamp '_LOG.txt']));
diary ('on')
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Post FEAT analysis for %s , %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime
results_dir
data_dir
SUBJECTS_DIR
subject_name
subj_name
session_date
condition
runNums = 1:numOfRuns
funcs
proj_template
proj_copes

%% Extract Chisquare and p-values using Fisher's method, save out statistical maps in output_dir.
fprintf ('\n ~~~~~~~~~~~~~~~~~~~ Starting Fishers analysis ~~~~~~~~~~~~~~~~~~~\n');
% local inputs
Fisher_thresh = 0.05  % hardcoded according to preregistration document
% convert F values to p values
func = funcs{2};
convert_F_to_p(session_dir,subject_name,runNums,func,Fisher_thresh,SUBJECTS_DIR)
% Do the Fisher's combined probability test
func = funcs{2};
fisher_combined_prob_test(output_dir,session_dir,subject_name, subj_name, condition,runNums,func,Fisher_thresh, true, SUBJECTS_DIR);

fprintf ('\n~~~~~~~~~~~~~~~~~~~ Fishers analysis complete! ~~~~~~~~~~~~~~~~~~~\n');

%% FIR Analysis: Project template to subject
% Requires that the subject has been registered using:
% mri_cvs_register --mov <subject_name> --template cvs_avg35_inMNI152

if proj_template %needs to be done just one time
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projecting template to subject space... ~~~~~~~~~~~~~~~~~~~ \n');
    % Project Visual Cortex anatomical template to subject space
    project_template(session_dir,subject_name);
    % Project LGN anatomical template to subject space
    make_LGN_ROI(session_dir,subject_name)
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projection to subject space complete! ~~~~~~~~~~~~~~~~~~~ \n');
end

%% FIR Analysis: project the copes, get the means, save figures and csv files

% project copes

if proj_copes %needs to be run just one time
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Projecting copes... ~~~~~~~~~~~~~~~~~~~\n');
    for ff = 1:length(funcs)
        func = funcs{ff};
        projectCopes2anat(session_dir,subject_name,runNums,func)
    end
    fprintf ('\n~~~~~~~~~~~~~~~~~~~ Cope projection complete! ~~~~~~~~~~~~~~~~~~~\n');
end
switch condition
    case 'MelPulses_400pct'
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
        funcs = funcs (1);
        
        % Get means, plot them and save them as a csv file for stimulus
        fprintf ('\n~~~~~~~~~~~~~~~~~~~ Calculating, plotting and saving FIR means... ~~~~~~~~~~~~~~~~~~~\n');
        FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, condition)
        
        % for attention task
        currentCondition = [condition '_AttentionTask'];
        startingCope = length(copeNames)+1 ;
        FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, currentCondition, startingCope),
        
    case 'LMSPulses_400pct'
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
        funcs = funcs (1);
        
        % Get means, plot them and save them as a csv file for stimulus
        fprintf ('\n~~~~~~~~~~~~~~~~~~~ Calculating, plotting and saving FIR means... ~~~~~~~~~~~~~~~~~~~\n');
        FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, condition)
        
        % for attention task
        currentCondition = [condition '_AttentionTask'];
        startingCope = length(copeNames)+1 ;
        FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, currentCondition, startingCope);
        
        
    case 'SplatterControl'
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
        controls = {...
            '25pct'...
            '50pct'...
            '100pct'...
            '195pct'...
            'AttentionTask'...
            };
        
        funcs = funcs (1);
        
        % Get means, plot them and save them as a csv file for stimulus
        fprintf ('\n~~~~~~~~~~~~~~~~~~~ Calculating, plotting and saving FIR means... ~~~~~~~~~~~~~~~~~~~\n');
        startingCope =  1;
        for ss = 1:length(controls)
            currentCondition = [condition '_' controls{ss}];
            FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, currentCondition, startingCope),
            startingCope = (length(copeNames)*ss)+1 ;
        end
        
    case {'MaxMelCRF', 'MaxLMSCRF'}
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
        controls = {...
            '25pct'...
            '50pct'...
            '100pct'...
            '200pct'...
            '400pct'...
            'AttentionTask'...
            };
        
        funcs = funcs (1);
        
        % Get means, plot them and save them as a csv file for stimulus
        fprintf ('\n~~~~~~~~~~~~~~~~~~~ Calculating, plotting and saving FIR means... ~~~~~~~~~~~~~~~~~~~\n');
        startingCope =  1;
        for ss = 1:length(controls)
            currentCondition = [condition '_' controls{ss}];
            FIR_assemble(session_dir, subject_name, subj_name, output_dir, copeNames, runNums, hemis, ROIs, funcs, currentCondition, startingCope),
            startingCope = (length(copeNames)*ss)+1 ;
        end
end

fprintf ('\n~~~~~~~~~~~~~~~~~~~ Post FEAT Analysis complete for %s, %s, %s ~~~~~~~~~~~~~~~~~~~\n', subj_name, session_date, condition);
time = datetime

% stop writing in the log file
diary ('off')




%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of POST FEAT stat

%% Move the relevant results to dropbox

