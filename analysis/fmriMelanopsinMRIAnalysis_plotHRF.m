function fmriMelanopsinMRIAnalysis_plotHRF(inputParams)
% fmriMelanopsinMRIAnalysis_plotHRF(inputParams)
%
% Function to plot HRFs for each subject.
%
% 9/26/2016     ms      Homogenized comments and function documentation.

% Define the ROIs
ROIs = {'V1'};

% Iterate over the subjects
subList = listdir(fullfile(inputParams.dataDir,'HERO_*'),'dirs');
for ss = 1:length(subList) % Iterate over subjects
    % Figure out how many sessions we have
    sessList = listdir(fullfile(inputParams.dataDir,subList{ss}),'dirs');
    
    % The HRF folder is the same in every session. We just pick the first one.
    sessionDir = fullfile(inputParams.dataDir,subList{ss},sessList{1});
    hrfDir = fullfile(sessionDir,'HRF');
    for rr = 1:length(ROIs) % Iterate over ROIs
        roiType = ROIs{rr};
        
        % Load the .MAT file with the HRF
        load(fullfile(hrfDir,[roiType '.mat']));
        
        % Open a new figure
        fig = figure('units','normalized','position',[0 0 1 1]);
        
        % Added the error bar
        shadedErrorBar([],HRF.mean, HRF.sem);
        
        % Add informativbe information to the plot
        title (['Mean\pmSEM - ' subList{ss} ' ' ROIs{rr}],'Interpreter','none')
        xlabel('Time [msec]');
        ylabel('Amplitude [% signal change]');
        str = ['Total runs = ',num2str(HRF.numRuns)];
        text(2000, -0.1, str)
        ylims = [-0.3 1.4];
        ylim(ylims);
        xlims = [0, 17000];
        xlim(xlims);
        adjustPlot(fig);
        
        % Save and close the figure
        saveName = ['HRF_mean_' subList{ss} '_' ROIs{rr}];
        saveDir = fullfile(inputParams.resultsDir, 'HRF_mean');
        if ~exist (saveDir, 'dir')
            mkdir (saveDir);
        end
        saveas(fig, fullfile(saveDir, saveName), 'png');
        close(fig);
    end % Subhects
end % ROIS
