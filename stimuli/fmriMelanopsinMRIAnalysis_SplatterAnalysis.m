%% Blank slate
clearvars; clc; close all;

% Define output dir
tmp = mfilename('fullpath');
tmp = fileparts(tmp);
outDir = fullfile(tmp, 'plots');
if ~isdir(outDir)
    mkdir(outDir);
end

%% Load CIE functions.   
load T_xyz1931
S = [380 2 201];
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

%% Script to estimate splatter in melanopsin MR experiments
[~, userID] = system('whoami');
userID = strtrim(userID);
basePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel'];

theSubjects = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
theExptDates = {'032416' '032516' '033116' '040616'};
valFileName = 'Cache-MelanopsinDirectedSuperMaxMel-BoxARandomizedLongCableCStubby1_ND00-SpotCheck.mat';

% Iterate over the subjects
c = 1;
fprintf('* Loading files from ...\n');
for s = 1:length(theSubjects)
    theDir = fullfile(basePath, theSubjects{s}, theExptDates{s}, 'StimulusFiles', ...
        'Cache-MelanopsinDirectedSuperMaxMel', 'BoxARandomizedLongCableCStubby1_ND00', ...
        '23-Mar-2016_12_31_27', 'validation');
    theFiles = dir(theDir); theFiles(1:2) = [];
    % Load all the files
    for f = 1:length(theFiles)
        valPath = fullfile(theDir, theFiles(f).name, valFileName);
        tmp = load(valPath);
        fprintf('\t>> Subject <strong>%s</strong> / <strong>%s</strong>\n', theSubjects{s}, theFiles(f).name);
        bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
        modSpd(:, c) = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;
        date{c} = theFiles(f).name;
        T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
        c = c+1;
    end
end

% Calculate contrast for each of the measurement pairs
NMeasurements = size(modSpd, 2);
for jj = 1:NMeasurements
    contrast(:, jj) = (T_receptors*(modSpd(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
end

%% Average contrast within each pre/post measurement set
startIdx = [1:5:40]; endIdx = [5:5:40];
for ii = 1:length(startIdx)
    avgContrastPerSess(:, ii) = mean(contrast(:, startIdx(ii):endIdx(ii)), 2);
end

%% Obtain all contrasts and convert to postreceptoral contrast
B_postreceptoral = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0];
postReceptoralContrasts = B_postreceptoral' \ avgContrastPerSess;
for ii = 1:3
[maxAbsolutePostreceptoral(ii, :), idx] = max(abs((postReceptoralContrasts(ii, :))), [], 2);
maxAbsolutePostreceptoralSign(ii, :) = sign(postReceptoralContrasts(ii, idx));
end
signedMaxAbsolutePostreceptoralContrast = maxAbsolutePostreceptoralSign.*maxAbsolutePostreceptoral;
fprintf('* Maximum absolute contrast (5 decimal points) on ...\n');
fprintf('\t LMS\t <strong>%.5f</strong>\n', signedMaxAbsolutePostreceptoralContrast(1, :));
fprintf('\t L-S\t <strong>%.5f</strong>\n', signedMaxAbsolutePostreceptoralContrast(2, :));
fprintf('\t S\t <strong>%.5f</strong>\n', signedMaxAbsolutePostreceptoralContrast(3, :));

% Save to file
splatterContrastOutCSV = fullfile(outDir, 'MaxMel_PostreceptoralSplatter.csv');
csvwrite(splatterContrastOutCSV, signedMaxAbsolutePostreceptoralContrast);