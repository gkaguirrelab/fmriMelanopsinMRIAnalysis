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

valFileName = 'Cache-MelanopsinDirectedSuperMaxMel-BoxARandomizedLongCableBStubby1_ND00-SpotCheck.mat';

% Iterate over the subjects
c = 1;
%theDir = fullfile('/Users/mspits/Downloads/CacheTest/', ...
%    'Cache-MelanopsinDirectedSuperMaxMel', 'BoxDRandomizedLongCableAEyePiece2_ND07', ...
%    '14-Jun-2016_12_04_00', 'validation');
theDir = fullfile('/Users/mspits/Downloads/CacheTest/', ...
    'Cache-MelanopsinDirectedSuperMaxMel', 'BoxARandomizedLongCableBStubby1_ND00', ...
    '29-May-2016_14_48_42', 'validation');


%29-May-2016_14_48_42
theFiles = dir(theDir); theFiles(1:3) = [];
% Load all the files
for f = 1:length(theFiles)
    valPath = fullfile(theDir, theFiles(f).name, valFileName);
    tmp = load(valPath);
    bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
    modSpd(:, c) = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;
    T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
    c = c+1;
end

% Calculate contrast for each of the measurement pairs
NMeasurements = size(modSpd, 2);
for jj = 1:NMeasurements
    contrast(:, jj) = (T_receptors*(modSpd(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
end

%%
theFig = figure;
maxLims = [3.5 4.5];
subplot(1, 3, 1);
plot([0 0], maxLims, '--k'); hold on;
plot(contrast(1, :), contrast(4, :)', 'sk', 'MarkerFaceColor', 'r')
xlabel('L'); ylabel('Mel');
title('L vs. Mel.');
pbaspect([1 1 1]);
xlim([-0.02 0.02]);
ylim([3.4 3.6]);
xlim([-0.02 0.02]);
ylim(maxLims);

%
subplot(1, 3, 2);
plot([0 0], maxLims, '--k'); hold on;
plot(contrast(2, :), contrast(4, :)', 'sk', 'MarkerFaceColor', 'g')
xlabel('M'); ylabel('Mel');
title('M vs. Mel.');
pbaspect([1 1 1]);
xlim([-0.04 0.04]);
ylim([3.4 3.6]);
xlim([-0.04 0.04]);
ylim(maxLims);

%
subplot(1, 3, 3);
plot([0 0], maxLims, '--k'); hold on;
plot(contrast(3, :), contrast(4, :)', 'sk', 'MarkerFaceColor', 'b')
xlabel('S'); ylabel('Mel');
title('S vs. Mel.');
pbaspect([1 1 1]);
xlim([-0.1 0.1]);
ylim([3.4 3.6]);
xlim([-0.1 0.1]);
ylim(maxLims);

adjustPlot(theFig);

set(theFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(theFig, '~/Desktop/MaxMel-BoxARandomizedLongCableBStubby1_ND00.png', 'png');
close(theFig);


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
maxLims = [3.5 4.5];
[~, userID] = system('whoami');
userID = strtrim(userID);

valFileName = 'Cache-LMSDirectedSuperMaxLMS-BoxARandomizedLongCableBStubby1_ND00-SpotCheck.mat';

% Iterate over the subjects
c = 1;
%theDir = fullfile('/Users/mspits/Downloads/CacheTest/', ...
%    'Cache-LMSDirectedSuperMaxLMS', 'BoxDRandomizedLongCableAEyePiece2_ND07', ...
%    '14-Jun-2016_12_04_00', 'validation');
theDir = fullfile('/Users/mspits/Downloads/CacheTest/', ...
    'Cache-LMSDirectedSuperMaxLMS', 'BoxARandomizedLongCableBStubby1_ND00', ...
    '29-May-2016_14_48_42', 'validation');

theFiles = dir(theDir); theFiles(1:3) = [];
% Load all the files
for f = 1:length(theFiles)
    valPath = fullfile(theDir, theFiles(f).name, valFileName);
    tmp = load(valPath);
    bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
    modSpd(:, c) = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;
    T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
    c = c+1;
end

% Calculate contrast for each of the measurement pairs
NMeasurements = size(modSpd, 2);
for jj = 1:NMeasurements
    contrast(:, jj) = (T_receptors*(modSpd(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
end

%%
theFig = figure;
subplot(1, 3, 1);
plot(maxLims, maxLims, '--k'); hold on;
plot(contrast(1, :), contrast(2, :)', 'sk', 'MarkerFaceColor', 'r')
xlabel('L'); ylabel('M');
title('L vs. M.');
pbaspect([1 1 1]);
xlim(maxLims);
ylim(maxLims);

%
subplot(1, 3, 2);
plot(maxLims, maxLims, '--k'); hold on;
plot(contrast(2, :), contrast(3, :)', 'sk', 'MarkerFaceColor', 'g')
xlabel('M'); ylabel('S');
title('M vs. S.');
pbaspect([1 1 1]);
xlim(maxLims);
ylim(maxLims);

%
subplot(1, 3, 3);
plot(maxLims, maxLims, '--k'); hold on;
plot(contrast(1, :), contrast(3, :)', 'sk', 'MarkerFaceColor', 'b')
xlabel('L'); ylabel('S');
title('L vs. S.');
pbaspect([1 1 1]);
xlim(maxLims);
ylim(maxLims);

adjustPlot(theFig);

set(theFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [7 3]); %Set the paper to have width 15 and height 6.
saveas(theFig, '~/Desktop/MaxLMS-BoxARandomizedLongCableBStubby1_ND00.png', 'png');
close(theFig);