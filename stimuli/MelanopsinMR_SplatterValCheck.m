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
basePath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-MaxMelPostreceptoralSplatterControl/BoxARandomizedLongCableCStubby1_ND00/18-Apr-2016_10_23_32/validation';

valFileName = 'Cache-MaxMelPostreceptoralSplatterControl-BoxARandomizedLongCableCStubby1_ND00-SpotCheck.mat';

% Iterate over the subjects
c = 1;
fprintf('* Loading files from ...\n');
    theDir = basePath;
    theFiles = dir(theDir); theFiles(1:2) = [];
    % Load all the files
    for f = 1:length(theFiles)
        valPath = fullfile(theDir, theFiles(f).name, valFileName);
        tmp = load(valPath);
        bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
        spd025Pct(:, c) = tmp.cals{end}.modulationAllMeas(:, 2).meas.pr650.spectrum;
        spd050Pct(:, c) = tmp.cals{end}.modulationAllMeas(:, 3).meas.pr650.spectrum;
        spd100Pct(:, c) = tmp.cals{end}.modulationAllMeas(:, 4).meas.pr650.spectrum;
        spd195Pct(:, c) = tmp.cals{end}.modulationAllMeas(:, 5).meas.pr650.spectrum;
        date{c} = theFiles(f).name;
        T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
        c = c+1;
    end

% Calculate contrast for each of the measurement pairs
NMeasurements = 5;
for jj = 1:NMeasurements
    contrast025(:, jj) = (T_receptors*(spd025Pct(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
    contrast050(:, jj) = (T_receptors*(spd050Pct(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
    contrast100(:, jj) = (T_receptors*(spd100Pct(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
    contrast195(:, jj) = (T_receptors*(spd195Pct(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
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
