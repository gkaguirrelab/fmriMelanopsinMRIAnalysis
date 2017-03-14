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
for s = 1:length(theSubjects)
    theDir = fullfile(basePath, theSubjects{s}, theExptDates{s}, 'StimulusFiles', ...
        'Cache-MelanopsinDirectedSuperMaxMel', 'BoxARandomizedLongCableCStubby1_ND00', ...
        '23-Mar-2016_12_31_27', 'validation');
    theFiles = dir(theDir); theFiles(1:2) = [];
    % Load all the files
    for f = 1:length(theFiles)
        valPath = fullfile(theDir, theFiles(f).name, valFileName);
        tmp = load(valPath);
        bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
        modSpd(:, c) = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;
        T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
        c = c+1;
    end
end

% Calculate contrast for each of the measurement pairs
NMeasurements = size(modSpd, 2);
for jj = 1:NMeasurements
    contrast(:, jj) = (T_receptors*(modSpd(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
end

%% Calculate contrast for each of the measurement pairs
theConeStruct1.Lshift = 0;
theConeStruct1.Mshift = 0;
theConeStruct1.Sshift = 0;
theConeStruct1.Melshift = 0;
theConeStruct1.fieldSizeDegrees = 64;
theConeStruct1.observerAgeInYears = 32;
theConeStruct1.pupilDiameterMm = 8;
theConeStruct1.fractionBleached = [];
theConeStruct1.oxygenationFraction = [];
theConeStruct1.vesselThickness =[];
photoreceptorClasses = {'LConeTabulatedAbsorbance' 'MConeTabulatedAbsorbance' 'SConeTabulatedAbsorbance' 'Melanopsin'};

lambdaMaxRangeL = [-4 4]; % (2 nm = 1SD)
lambdaMaxRangeM = [-3 3]; % (1.5 nm = 1SD)
lambdaMaxRangeS = [-3 3]; % (1.3 nm = 1SD)
ageRange = [-12 14]; %±14 yrs (7 yrs = 1SD)

% Obtain all contrasts and convert to 'postreceptoral' contrast
allContrasts = [contrastSplatter{:}];
postReceptoralContrasts = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]' \ allContrasts;
max(abs(postReceptoralContrasts), [], 2)

%    0.0488
%    0.0396
%    0.1824


%% Calculate the post-receptoral contrasts
maxMelContrastsFig = figure;
markerSizeIndPoint = 3;
markerSizeGrpAvg = 5;
xOffset = 0.1;
theLabels = {'L+M+S', 'L-M', 'S'};
theRGB = [189 189 189 ; 49 163 84 ; 117 107 177 ; 43 140 190]/255;


for aa = 1:length(ageRange)
    for ll = 1:length(lambdaMaxRangeL)
        for mm = 1:length(lambdaMaxRangeM)
            for ss = 1:length(lambdaMaxRangeS)   
                contrast = contrastSplatter{aa, ll, mm, ss};
                postReceptoralContrasts = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]' \ contrast;
                subplot(1, 3, 1);
                jj = 2;
                plot([-0.09 0.09], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
                plot([0 0], [-0.09 0.09], '-', 'Color', [0.75 0.75 0.75]);
                plot(contrast(1, :), contrast(2, :), 'ok', 'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
                    'MarkerSize', markerSizeIndPoint);
                xlabel('\DeltaL');
                ylabel('\DeltaM');
                box off; set(gca, 'TickDir', 'out');
                xlim([-0.09 0.09]);
                ylim([-0.09 0.09]);
                
                set(gca, 'XTick', [-0.08:0.04:0.08]);
                set(gca, 'YTick', [-0.08:0.04:0.08]);
                title('\DeltaL vs \DeltaM');
                pbaspect([1 1 1]);
                
                % Plot post-receptoral contrasts
                subplot(1, 3, 2);
                plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
                for jj = 1:3
                    plot((rand(1, NMeasurements)-0.5)/10+jj-xOffset, postReceptoralContrasts(jj, :), 'o', ...
                        'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
                        'MarkerSize', markerSizeIndPoint); hold on;
                end
                set(gca, 'XTick', 1:3); set(gca, 'XTickLabels', theLabels);
                set(gca, 'YTick', [-0.30:0.10:0.30]);
                xlabel('Sensor');
                ylabel('Contrast');
                
                box off; set(gca, 'TickDir', 'out');
                xlim([0 4]);
                ylim([-0.30 0.30]);
                title({'MaxMel validation'});
                pbaspect([1 1 1]);
                
                % Plot Mel
                subplot(1, 3, 3);
                jj = 4;
                plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
                plot((rand(1, NMeasurements)-0.5)/10+1-xOffset, contrast(jj, :), 'o', ...
                    'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
                    'MarkerSize', markerSizeIndPoint);
                set(gca, 'XTick', 1); set(gca, 'XTickLabels', 'Melanopsin');
                set(gca, 'YTick', [4:.1:4.8]);
                xlabel('Sensor');
                ylabel('Contrast');
                
                box off; set(gca, 'TickDir', 'out');
                xlim([0 2]);
                ylim([4 4.8]);
                pbaspect([1 1 1]);
                
            end
        end
    end
end
set(maxMelContrastsFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(maxMelContrastsFig, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(maxMelContrastsFig, fullfile(outDir, 'MaxMel_ValidationContrastSimulation.png'), 'png');
close(maxMelContrastsFig);


%% Plot in the spectral domain
maxMelSpectralFig = figure;
wls = SToWls([380 2 201]);
subplot(1, 2, 1);
shadedErrorBar(wls, mean(bgSpd, 2), 2*std(bgSpd, [], 2)); hold on;
shadedErrorBar(wls, mean(modSpd, 2), 2*std(modSpd, [], 2), '-r'); hold on;
pbaspect([1 1 1]);
xlabel('Wavelength [nm]');
ylabel('Radiance [W m-2 sr-2 nm-1]');
title({'Stimulus spd' 'Mean\pm2SD'});
xlim([380 780]);
ylim([0 0.04]);

subplot(1, 2, 2);
shadedErrorBar(wls, mean(modSpd-bgSpd, 2), 2* std(modSpd-bgSpd, [], 2)); hold on;
%plot(wls, modSpd-bgSpd, '-k'); hold on;
pbaspect([1 1 1]);
xlabel('Wavelength [nm]');
ylabel('\DeltaRadiance [W m-2 sr-2 nm-1]');
title({'Difference spd' 'Mean\pm2SD'});
xlim([380 780]);
ylim([-0.02 0.02]);

set(maxMelSpectralFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(maxMelSpectralFig, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(maxMelSpectralFig, fullfile(outDir, 'MaxMel_Spectra.png'), 'png');
close(maxMelSpectralFig);

%%
photopicLuminanceCdM2 = T_xyz(2,:)*bgSpd;
for jj = 1:NMeasurements
chromaticityXY(:, jj) = (T_xyz(1:2,:)*bgSpd(:, jj))./sum(T_xyz*bgSpd(:, jj));
end
fprintf('\n');
fprintf('\t * <strong>Mean±1SD luminance</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(photopicLuminanceCdM2), std(photopicLuminanceCdM2));
fprintf('\t * <strong>Mean±1SD x chromaticity</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(chromaticityXY(1, :)), std(chromaticityXY(1, :)));
fprintf('\t * <strong>Mean±1SD y chromaticity</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(chromaticityXY(2, :)), std(chromaticityXY(2, :)));

%% Calculate the post-receptoral contrasts
maxMelContrastsFig = figure;
markerSizeIndPoint = 3;
markerSizeGrpAvg = 5;
xOffset = 0.1;
theLabels = {'L+M+S', 'L-M', 'S'};
theRGB = [189 189 189 ; 49 163 84 ; 117 107 177 ; 43 140 190]/255;
postReceptoralContrasts = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]' \ contrast;

subplot(1, 3, 1);
jj = 2;
plot([-0.05 0.05], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
plot([0 0], [-0.05 0.05], '-', 'Color', [0.75 0.75 0.75]);
plot(contrast(1, :), contrast(2, :), 'ok', 'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint);
xlabel('\DeltaL');
ylabel('\DeltaM');
box off; set(gca, 'TickDir', 'out');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);

set(gca, 'XTick', [-0.04:0.02:0.04]);
set(gca, 'YTick', [-0.04:0.02:0.04]);
title('\DeltaL vs \DeltaM');
pbaspect([1 1 1]);

% Plot post-receptoral contrasts
subplot(1, 3, 2);
plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
for jj = 1:3
    plot((rand(1, NMeasurements)-0.5)/10+jj-xOffset, postReceptoralContrasts(jj, :), 'o', ...
        'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'MarkerSize', markerSizeIndPoint); hold on;
    errorbar(jj+xOffset, mean(postReceptoralContrasts(jj, :)), std(postReceptoralContrasts(jj, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);
end
set(gca, 'XTick', 1:3); set(gca, 'XTickLabels', theLabels);
set(gca, 'YTick', [-0.10:0.05:0.10]);
xlabel('Sensor');
ylabel('Contrast');

box off; set(gca, 'TickDir', 'out');
xlim([0 4]);
ylim([-0.12 0.12]);
title({'MaxMel validation' 'Mean\pm1SD'});
pbaspect([1 1 1]);

% Plot Mel
subplot(1, 3, 3);
jj = 4;
plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
plot((rand(1, NMeasurements)-0.5)/10+1-xOffset, contrast(jj, :), 'o', ...
    'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint);
errorbar(1+xOffset, mean(contrast(jj, :)), std(contrast(jj, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);
set(gca, 'XTick', 1); set(gca, 'XTickLabels', 'Melanopsin');
set(gca, 'YTick', [4:.1:4.6]);
xlabel('Sensor');
ylabel('Contrast');

box off; set(gca, 'TickDir', 'out');
xlim([0 2]);
ylim([4 4.6]);
title({'Mean\pm1SD'});
pbaspect([1 1 1]);

set(maxMelContrastsFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(maxMelContrastsFig, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(maxMelContrastsFig, fullfile(outDir, 'MaxMel_ValidationContrast.png'), 'png');
close(maxMelContrastsFig);

%%

%% Script to estimate splatter in melanopsin MR experiments
[~, userID] = system('whoami');
userID = strtrim(userID);
basePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMR400PctLMS'];

theSubjects = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
theExptDates = {'040716' '033016' '040116' '040816'};
valFileName = 'Cache-LMSDirectedSuperMaxLMS-BoxARandomizedLongCableCStubby1_ND00-SpotCheck.mat';

% Iterate over the subjects
c = 1;
for s = 1:length(theSubjects)
    theDir = fullfile(basePath, theSubjects{s}, theExptDates{s}, 'StimulusFiles', ...
        'Cache-LMSDirectedSuperMaxLMS', 'BoxARandomizedLongCableCStubby1_ND00', ...
        '23-Mar-2016_12_31_27', 'validation');
    theFiles = dir(theDir); theFiles(1:2) = [];
    % Load all the files
    for f = 1:length(theFiles)
        valPath = fullfile(theDir, theFiles(f).name, valFileName);
        tmp = load(valPath);
        bgSpd(:, c) = tmp.cals{end}.modulationBGMeas.meas.pr650.spectrum;
        modSpd(:, c) = tmp.cals{end}.modulationMaxMeas.meas.pr650.spectrum;
        T_receptors = tmp.cals{end}.describe.cache.data(32).describe.T_receptors;
        c = c+1;
    end
end

% Calculate contrast for each of the measurement pairs
NMeasurements = size(modSpd, 2);
for jj = 1:NMeasurements
    contrast(:, jj) = (T_receptors*(modSpd(:, jj) - bgSpd(:, jj))) ./ (T_receptors*bgSpd(:, jj));
end

%%
photopicLuminanceCdM2 = T_xyz(2,:)*bgSpd;
for jj = 1:NMeasurements
chromaticityXY(:, jj) = (T_xyz(1:2,:)*bgSpd(:, jj))./sum(T_xyz*bgSpd(:, jj));
end
fprintf('\n');
fprintf('\t * <strong>Mean±1SD luminance</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(photopicLuminanceCdM2), std(photopicLuminanceCdM2));
fprintf('\t * <strong>Mean±1SD x chromaticity</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(chromaticityXY(1, :)), std(chromaticityXY(1, :)));
fprintf('\t * <strong>Mean±1SD y chromaticity</strong> [cd/m2]: <strong>%.2f</strong> ± %.3f\n', mean(chromaticityXY(2, :)), std(chromaticityXY(2, :)));

%% Plot in the spectral domain
maxLMSSpectralFig = figure;
wls = SToWls([380 2 201]);
subplot(1, 2, 1);
shadedErrorBar(wls, mean(bgSpd, 2), 2*std(bgSpd, [], 2)); hold on;
shadedErrorBar(wls, mean(modSpd, 2), 2*std(modSpd, [], 2), '-r'); hold on;
pbaspect([1 1 1]);
xlabel('Wavelength [nm]');
ylabel('Radiance [W m-2 sr-2 nm-1]');
title({'Stimulus spd' 'Mean\pm2SD'});
xlim([380 780]);
ylim([0 0.04]);

subplot(1, 2, 2);
shadedErrorBar(wls, mean(modSpd-bgSpd, 2), 2* std(modSpd-bgSpd, [], 2)); hold on;
%plot(wls, modSpd-bgSpd, '-k'); hold on;
pbaspect([1 1 1]);
xlabel('Wavelength [nm]');
ylabel('\DeltaRadiance [W m-2 sr-2 nm-1]');
title({'Difference spd' 'Mean\pm2SD'});
xlim([380 780]);
ylim([-0.04 0.04]);

set(maxLMSSpectralFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(maxLMSSpectralFig, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(maxLMSSpectralFig, fullfile(outDir, 'MaxLMS_Spectra.png'), 'png');
close(maxLMSSpectralFig);

%% Calculate the post-receptoral contrasts
maxLMSContrastsFig = figure;
markerSizeIndPoint = 3;
markerSizeGrpAvg = 5;
xOffset = 0.1;
theLabels = {'L+M+S', 'L-M'};
theRGB = [189 189 189 ; 49 163 84 ; 117 107 177 ; 43 140 190]/255;
postReceptoralContrasts = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]' \ contrast;
axLims = [3.5 4.4];

subplot(1, 3, 1);
jj = 2;
hold on;
plot([axLims], [axLims], '--k');
plot(contrast(1, :), contrast(2, :), 'ok', 'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint);
xlabel('\DeltaL');
ylabel('\DeltaM');
box off; set(gca, 'TickDir', 'out');
xlim([axLims]);
ylim([axLims]);
title('\DeltaL vs \DeltaM');
pbaspect([1 1 1]);

subplot(1, 3, 2);
jj = 3;
hold on;
plot([axLims], [axLims], '--k');
plot(postReceptoralContrasts(1, :), postReceptoralContrasts(3, :), 'ok', 'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint);
xlabel('\Delta[L+M]');
ylabel('\DeltaS');
box off; set(gca, 'TickDir', 'out');
xlim([axLims]);
ylim([axLims]);
title({'MaxLMS validation' '\DeltaS vs. \Delta[L+M]'});
pbaspect([1 1 1]);

% Plot post-receptoral contrasts
subplot(1, 3, 3);
plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
jj = 2; % L-M
plot((rand(1, NMeasurements)-0.5)/10+1-xOffset, postReceptoralContrasts(jj, :), 'o', ...
    'MarkerFaceColor', theRGB(jj, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint); hold on;
errorbar(1+xOffset, mean(postReceptoralContrasts(jj, :)), std(postReceptoralContrasts(jj, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);

% Mel
plot((rand(1, NMeasurements)-0.5)/10+2-xOffset, contrast (4, :), 'o', ...
    'MarkerFaceColor', theRGB(3, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint); hold on;
errorbar(2+xOffset, mean(contrast(4, :)), std(contrast(4, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);

set(gca, 'XTick', 1:2); set(gca, 'XTickLabels', {  'L-M', 'Mel'});
set(gca, 'YTick', [-0.15:0.05:0.15]);
xlabel('Sensor');
ylabel('Contrast');

box off; set(gca, 'TickDir', 'out');
xlim([0 3]);
ylim([-0.15 0.15]);
title({'Mean\pm1SD'});
pbaspect([1 1 1]);

set(maxLMSContrastsFig, 'PaperPosition', [0 0 8 3]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [8 3]); %Set the paper to have width 15 and height 6.
saveas(maxLMSContrastsFig, fullfile(outDir, 'MaxLMS_ValidationContrast.png'), 'png');
close(maxLMSContrastsFig);