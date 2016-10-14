function fmriMelanopsinMRIAnalysis_projectAnatTemplatesToFunc(inputParams)
% fmriMelanopsinMRIAnalysis_projectAnatTemplatesToFunc(inputParams)
%
% Project templates for each subject
%
% 10/14/2016     ms      Homogenized comments and function documentation.

% Set up the data Dir

%% HERO_asb1
subjDir = fullfile(inputParams.dataDir, 'MelanopsinMR', 'HERO_asb1');
sessDirs = {'032416' '040716' '051016' '060716' '060816'};
for ss = 1:length(sessDirs)
    sessionDir      = fullfile(fullfile(subjDir, sessDirs{ss}));
    b               = find_bold(sessionDir);
    %% Project templates to functional space
    params.sessionDir = sessionDir;
    for i = 1:length(b)
        params.runNum = i;
        projectTemplate2Func(params)
    end
end

%% HERO_aso1
subjDir = fullfile(inputParams.dataDir, 'MelanopsinMR', 'HERO_aso1');
sessDirs = {'032516' '033016' '042916' '053116' '060116'};
for ss = 1:length(sessDirs)
    sessionDir      = fullfile(fullfile(subjDir, sessDirs{ss}));
    b               = find_bold(sessionDir);
    %% Project templates to functional space
    params.sessionDir = sessionDir;
    for i = 1:length(b)
        params.runNum = i;
        projectTemplate2Func(params)
    end
end

%% HERO_gka1
subjDir = fullfile(inputParams.dataDir, 'MelanopsinMR', 'HERO_gka1');
sessDirs = {'033116' '040116' '050616' '060216' '060616'};
for ss = 1:length(sessDirs)
    sessionDir      = fullfile(fullfile(subjDir, sessDirs{ss}));
    b               = find_bold(sessionDir);
    %% Project templates to functional space
    params.sessionDir = sessionDir;
    for i = 1:length(b)
        params.runNum = i;
        projectTemplate2Func(params)
    end
end

%% HERO_mxs1
subjDir = fullfile(inputParams.dataDir, 'MelanopsinMR', 'HERO_mxs1');
sessDirs = {'040616' '040816' '050916' '060916' '061016_Mel' '062816'};
for ss = 1:length(sessDirs)
    sessionDir      = fullfile(fullfile(subjDir, sessDirs{ss}));
    b               = find_bold(sessionDir);
    %% Project templates to functional space
    params.sessionDir = sessionDir;
    for i = 1:length(b)
        params.runNum = i;
        projectTemplate2Func(params)
    end
end