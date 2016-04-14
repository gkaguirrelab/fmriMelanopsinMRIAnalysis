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
for ii = 1:NMeasurements
    contrast(:, ii) = (T_receptors*(modSpd(:, ii) - bgSpd(:, ii))) ./ (T_receptors*bgSpd(:, ii));
end

%% Calculate the post-receptoral contrasts
markerSizeIndPoint = 3;
markerSizeGrpAvg = 5;
xOffset = 0.1;
theLabels = {'L+M', 'L-M', 'S'};
theRGB = [189 189 189 ; 49 163 84 ; 117 107 177 ; 43 140 190]/255;
postReceptoralContrasts = [1 1 0 0 ; 1 -1 0 0 ; 0 0 1 0]' \ contrast;

subplot(1, 3, 1);
ii = 2;
plot([-0.05 0.05], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
plot([0 0], [-0.05 0.05], '-', 'Color', [0.75 0.75 0.75]);
plot(contrast(1, :), contrast(2, :), 'ok', 'MarkerFaceColor', theRGB(ii, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'MarkerSize', markerSizeIndPoint);
xlabel('\DeltaL');
ylabel('\DeltaM');
box off; set(gca, 'TickDir', 'out');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);

set(gca, 'XTick', [-0.04:0.02:0.04]);
set(gca, 'YTick', [-0.04:0.02:0.04]);
title('MaxMel validation');
pbaspect([1 1 1]);

% Plot post-receptoral contrasts
subplot(1, 3, 2);
plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
for ii = 1:3
    plot((rand(1, NMeasurements)-0.5)/10+ii-xOffset, postReceptoralContrasts(ii, :), 'o', ...
        'MarkerFaceColor', theRGB(ii, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'MarkerSize', markerSizeIndPoint); hold on;
    errorbar(ii+xOffset, mean(postReceptoralContrasts(ii, :)), std(postReceptoralContrasts(ii, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);
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
ii = 4;
plot([0 4], [0 0], '-', 'Color', [0.75 0.75 0.75]); hold on;
plot((rand(1, NMeasurements)-0.5)/10+1-xOffset, contrast(ii, :), 'o', ...
    'MarkerFaceColor', theRGB(ii, :), 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', markerSizeIndPoint);
errorbar(1+xOffset, mean(contrast(ii, :)), std(contrast(ii, :)), 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', markerSizeGrpAvg);
set(gca, 'XTick', 1); set(gca, 'XTickLabels', 'Melanopsin');
set(gca, 'YTick', [4:.1:4.6]);
xlabel('Sensor');
ylabel('Contrast');



box off; set(gca, 'TickDir', 'out');
xlim([0 2]);
ylim([4 4.6]);
title({'MaxMel validation' 'Mean\pm1SD'});
pbaspect([1 1 1]);

set(gcf, 'PaperPosition', [0 0 9 3]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [9 3]); %Set the paper to have width 15 and height 6.
saveas(gcf, 'MaxMel_ValidationContrast.png', 'png');
close(gcf);