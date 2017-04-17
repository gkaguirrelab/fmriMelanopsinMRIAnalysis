function fmriMelanopsinMRIAnalysis_runFEATanalysis (params)

%% HERO_asb1 - 032416 - MaxMel400%
params.subjectName = 'HERO_asb1';
params.sessionDir = fullfile(params.dataDir, 'HERO_asb1/032416');
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns = 11; % Number of BOLD runs
params.sessType = '_MEL400_';

FEATwrapper (params)

%% HERO_asb1 - 040716 - MaxLMS400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_asb1/040716');
params.subjectName      = 'HERO_asb1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 10; % Number of BOLD runs
params.sessType = '_LMS400_';

FEATwrapper (params)

%% HERO_aso1 - 032516 - MaxMel400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_aso1/032516');
params.subjectName      = 'HERO_aso1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 11; % Number of BOLD runs
params.sessType = '_MEL400_';

FEATwrapper (params)

%% HERO_aso1 - 033016 - MaxLMS400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_aso1/033016');
params.subjectName      = 'HERO_aso1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 12; % Number of BOLD runs
params.sessType = '_LMS400_';

FEATwrapper (params)
%% HERO_gka1 - 033116 - MaxMel400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_gka1/033116');
params.subjectName      = 'HERO_gka1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 12; % Number of BOLD runs
params.sessType = '_MEL400_';

FEATwrapper (params)

%% HERO_gka1 - 040116 - MaxLMS400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_gka1/040116');
params.subjectName      = 'HERO_gka1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 12; % Number of BOLD runs
params.sessType = '_LMS400_';

FEATwrapper (params)

%% HERO_mxs1 - 040616 - MaxMel400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_mxs1/040616');
params.subjectName      = 'HERO_mxs1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 12; % Number of BOLD runs
params.sessType = '_MEL400_';

FEATwrapper (params)

%% HERO_mxs1 - 040816 - MaxLMS400%
params.sessionDir       = fullfile(params.dataDir, 'HERO_mxs1/040816');
params.subjectName      = 'HERO_mxs1';
params.FEATDir = fullfile(params.sessionDir, 'FEATstimuli');
params.numRuns          = 12; % Number of BOLD runs
params.sessType = '_LMS400_';

FEATwrapper (params)

end


%% the following wrapper is only used in the main function above
function FEATwrapper (params)
% create fsf files
d = find_bold(params.sessionDir);
funcName = 's5.wdrf.tf';
for j = 1:params.numRuns
    clear EVs
    
    % Name the output .fsf file
    outFile = fullfile(params.FEATDir,sprintf('Run_%02d_5mm.fsf',j));
    
    % Name the functional and anatomical files for FSL's FEAT
    funcVol = fullfile(params.sessionDir,d{j},[funcName '.nii.gz']);
    anatVol = fullfile(params.sessionDir,'MPRAGE','001','MPRAGE_brain.nii.gz');
    
    stim = sprintf('run%02d_stimulus', j);
    at = sprintf('run%02d_attentionTask', j);
    EVs = { ...
        fullfile(params.FEATDir, [params.subjectName params.sessType  stim]) ...
        fullfile(params.FEATDir, [params.subjectName params.sessType  at]) ...
        };
    
    % make fsf files
    fmriMelanopsinMRIAnalysis_makeSinBasisFEATfiles(outFile,funcVol,anatVol,EVs)
end

% create a "submit all script
fname = fullfile(params.FEATDir , [params.subjectName 'submit_first_level_feat.sh']);
fid = fopen(fname,'w');
fprintf(fid,'#!/bin/bash\n');
for rr = 1:params.numRuns
 fprintf(fid, ['feat ' params.FEATDir '/Run_%02d_5mm.fsf\n'],rr);
end
end
