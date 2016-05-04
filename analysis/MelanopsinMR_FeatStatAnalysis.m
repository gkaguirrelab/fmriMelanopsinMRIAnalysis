function MelanopsinMR_FeatStatAnalysis (results_dir, data_dir, subj_name,session_date,condition, numRuns, funcs, SUBJECTS_DIR)

% 2nd step for MelanopsinMR data processing. Follows:
% MelanopsinMR_Preprocessing. Preceeds: MelanopsinMR_PostFeatStatAnalysis.
% Produces a LOG file.
%
% Global Input arguments:
% 
% results_dir :  general path where all results for this project are saved. Specific
% subfolders are created during each step. Note that intermediate results
% are saved in specific paths within the data_dir.
% 
% data_dir : path to the data directory. Raw data and
% intermediate results are store in
% <data_dir>/<subject_name>/<session_date>/ (session_dir)
% 
% SUBJECTS_DIR : path tho the Freesurfer subjects directory.
% 
% 
% subj_name : name of the current subject
% 
% runNums : list of number of runs in current session
% 
% Local input arguments:
% where possible, local input arguments are hard coded according to
% pre-registration documents.
%
%%%%%%%%%
% Usage:
% 
% results_dir =  '/some/path/ideally/on/dropbox/' ;
% data_dir = '/data/jag/MELA/'; %Upenn cluster default path
% subj_name = 'HERO_xxx1';
% session_date = 'mmddyy';
% condition = 'MelPulses_400pct';
% runNums =  12 ;
% funcs = { ...
% 'wdrf.tf' ...
% 's5.wdrf.tf' ...
% };
% SUBJECTS_DIR
% MelanopsinMR_FeatStatAnalysis (results_dir, data_dir, SUBJECTS_DIR, subj_name,session_date,numRuns)
%
%%%%%%%%%
%% Initialize analysis
if ~exist('SUBJECTS_DIR','var')
    SUBJECTS_DIR = getenv('SUBJECTS_DIR');
end 
session_dir = fullfile(data_dir, subj_name,session_date);
output_dir = fullfile( results_dir, condition, subj_name, session_date);
if ~exist (output_dir, 'dir')
    mkdir (output_dir);
end
if ~exist (fullfile(output_dir, 'LOGS'),'dir')
    mkdir (fullfile(output_dir, 'LOGS'));
end
formatOut = 'mmddyy_HH.MM.SS';
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
funcs
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
outFilePerformance = fullfile(outDirPerformance, 'performance.csv');
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
            EVs = listdir(fullfile(outDir,stimuli_dirs{j},'*.txt'),'files');
            FIR_first_level_feat(outFile,funcVol,anatVol,EVs,condition)
        end
end
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

%% Create a script to submit all FEAT stat files
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Creating "Submit_FEAT_stat" script ~~~~~~~~~~~~~~~~~~~\n');

create_submit_first_level_feat (session_dir,subj_name,numRuns);

fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');

fprintf ('\n~~~~~~~~~~~~~~~~~~~ You can now submit FEAT stat using the script submit_first_level_feat.sh ~~~~~~~~~~~~~~~~~~~\n');

% %% Submit FEAT stat script
% fprintf ('\n~~~~~~~~~~~~~~~~~~~ Submitting FEAT stats ~~~~~~~~~~~~~~~~~~~\n');
% 
% %%%%% TEST IF THIS WORKS
% system('sh submit_first_level_feat.sh')  %must be on chead to run this!
% 
% fprintf ('\n~~~~~~~~~~~~~~~~~~~ Done! ~~~~~~~~~~~~~~~~~~~\n');
fprintf ('\n~~~~~~~~~~~~~~~~~~~ Wait for FEATstat to end, then move to step 3: MelanopsinMR_PostFeatStatAnalysis. ~~~~~~~~~~~~~~~~~~~\n');

