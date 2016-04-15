% this script was used to overwrite standard FSL registration before doing
% FEAT High level analysis.

% this script needs MRlicht
session_dir = '/data/jag/MELA/HERO_gka1/031516';
subject_name =  'HERO_gka1_3T';
runNums= 1:9;
featName = 'FIR_raw';
%% Make sure FEAT First Level Analysis has been done on all runs


%% Overwrite FEAT registration

overwrite_feat_reg(session_dir,subject_name,runNums,featName)
