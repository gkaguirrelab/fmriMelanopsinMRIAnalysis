session_dir = '/data/jag/MELA/HERO_asb1/040716';
subject_name = 'HERO_asb1_MaxMel';
outDir = fullfile('/data','jag','MELA','preprocessing_scripts', subject_name);
if ~exist(outDir,'dir')
    mkdir(outDir);
end
logDir = '/data/jag/MELA/LOGS'; % make sure this exists!
job_name = 'HERO_asb1_040716'; % Name for this job/session (may not match subject_name)
numRuns = 10; % number of bold runs
reconall = 0; % 0 if already run through Freesurfer
slicetiming = 1; % correct slice timings
B0 = 0;
filtType = 'high';
lowHz = 0.01;
highHz = 0.10;
physio = 1;
motion = 1;
task = 0;
localWM = 1;
anat = 1;
amem = 20;
fmem = 50;

create_preprocessing_scripts(session_dir,subject_name,outDir,logDir,job_name,...
    numRuns,reconall,slicetiming,B0,filtType,lowHz,highHz,physio,motion,task,...
    localWM,anat,amem,fmem)