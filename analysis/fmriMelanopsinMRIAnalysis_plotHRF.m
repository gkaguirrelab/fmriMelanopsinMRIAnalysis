function fmriMelanopsinMRIAnalysis_plotHRF(inputParams)

ROIs = {'V1'};
close all;

subList = listdir(fullfile(inputParams.dataDir,'HERO_*'),'dirs');
for ss = 1:length(subList)
    sessList = listdir(fullfile(inputParams.dataDir,subList{ss}),'dirs');
    sessionDir = fullfile(inputParams.dataDir,subList{ss},sessList{1}); % the HRF folder is the same in every session. We just pick the first one.
    hrfDir = fullfile(sessionDir,'HRF');
    for rr = 1:length(ROIs)
        roiType = ROIs{rr};
        load(fullfile(hrfDir,[roiType '.mat']));
        fig = figure('units','normalized','position',[0 0 1 1]);
        shadedErrorBar([],HRF.mean, HRF.sem);
        title (['Mean' char(177) 'SEM - ' subList{ss} ' ' ROIs{rr}],'Interpreter','none')
        xlabel('Time [msec]');
        ylabel('Amplitude [% signal change]');
        str = ['Total runs = ',num2str(HRF.numRuns)];
        text(2000, -0.1, str)
        ylims = [-0.3 1.4];
        ylim(ylims);
        xlims = [0, 17000];
        xlim(xlims);
        adjustPlot(fig);
        saveName = ['HRF_mean_' subList{ss} '_' ROIs{rr}];
        saveDir = fullfile(inputParams.resultsDir, 'HRF_mean');
        if ~exist (saveDir, 'dir')
            mkdir (saveDir);
        end
        saveas(fig, fullfile(saveDir, saveName), 'png');
        close(fig);
    end
end