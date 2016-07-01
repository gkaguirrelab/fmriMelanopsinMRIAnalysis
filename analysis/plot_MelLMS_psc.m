% Plot the percent signal change to Melanopsin and LMS directed stimuli 
%   using:
%
%   bins of eccentricity
%   'plotVisual'
%
%   Written by Andrew S Bock Jul 2016

%% set up variables
projDir = '/data/jag/MELA/MelanopsinMR';
condNames = {'lmsMAX' 'melMAX'};
copeNums = 1:14; % FIR covariates (0-13 seconds)
subjNames = {...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1'...
    };
lmsMAX = {...
    '040716' ...
    '033016' ...
    '040116' ...
    '040816' ...
    };
melMAX = {...
    '032416' ...
    '032516' ...
    '033116' ...
    '040616' ...
    };
featDir = 'wdrf.tf.feat';
ROI = 'V1';
eccBins = [0 1 2.5 5 10 20 33 55 90];
%% Convert copes to percent signal change (only need to do this once)
for ss = 1:length(subjNames)
    for cc = 1:length(condNames)
        switch condNames{cc}
            case 'lmsMAX'
                sessionDir = fullfile(projDir,subjNames{ss},lmsMAX{ss});
            case 'melMAX'
                sessionDir = fullfile(projDir,subjNames{ss},melMAX{ss});
        end
        b = find_bold(sessionDir);
        featDirs = cell(1,length(b));
        for i = 1:length(b)
            featDirs{i} = fullfile(sessionDir,b{i},featDir);
        end
        meanpsc = nan(length(copeNums),256,256,256);
        pscCope = nan(length(featDirs),256,256,256);
        progBar = ProgressBar(length(copeNums),'Calculating percent signal change...');
        for j = copeNums
            for i = 1:length(featDirs)
                % mean functional volume in anatomical space
                meanout = fullfile(featDirs{i},'mean_func.anat.nii.gz');
                mtmp = load_nifti(meanout);
                % copes in anatomical space
                copeout = fullfile(featDirs{i},'stats',['cope' num2str(copeNums(j)) '.anat.nii.gz']);
                % Calculate percent signal change (using copes)
                ctmp = load_nifti(copeout);
                psctmp = (ctmp.vol./mtmp.vol)*100; % convert to percent signal change
                psctmp(psctmp==inf | psctmp==-inf) = nan; % set inf/-inf to nan
                ctmp.vol = psctmp;
                save_nifti(ctmp,fullfile(featDirs{i},'stats',...
                    ['cope' num2str(copeNums(j)) '.anat.psc.nii.gz']));
            end
            progBar(j);
        end
    end
end
%% Calculate copes to percent signal change
pscData = cell(length(subjNames),2,3);
progBar = ProgressBar(length(subjNames)*2,'Calculating percent signal change...');
ct = 0;
for ss = 1:length(subjNames)
    for cc = 1:length(condNames)
        ct = ct + 1;
        % Set session directory based on condition
        switch condNames{cc}
            case 'lmsMAX'
                sessionDir = fullfile(projDir,subjNames{ss},lmsMAX{ss});
            case 'melMAX'
                sessionDir = fullfile(projDir,subjNames{ss},melMAX{ss});
        end
        % Get bold runs
        b = find_bold(sessionDir);
        featDirs = cell(1,length(b));
        for i = 1:length(b)
            featDirs{i} = fullfile(sessionDir,b{i},featDir);
        end
        % Get retinotopy volumes
        ecc = load_nifti(fullfile(sessionDir,'anat_templates','mh.ecc.anat.vol.nii.gz'));
        pol = load_nifti(fullfile(sessionDir,'anat_templates','mh.pol.anat.vol.nii.gz'));
        areas = load_nifti(fullfile(sessionDir,'anat_templates','mh.areas.anat.vol.nii.gz'));
        % Get voxel indices for ROI
        switch ROI
            case 'V1'
                roiInd = abs(areas.vol) == 1; % V1
        end
        % Get the mean percent signal change across runs
        meanpsc = nan(length(featDirs),sum(roiInd(:)));
        for i = 1:length(featDirs)
            pscCope = nan(length(copeNums),sum(roiInd(:)));
            for j = copeNums
                tmp = load_nifti(fullfile(featDirs{i},'stats',...
                    ['cope' num2str(copeNums(j)) '.anat.psc.nii.gz']));
                pscCope(j,:) = tmp.vol(roiInd);
            end
            % Get the largest amplitude response (+ or -)
            [~,tmp] = nanmax(abs(pscCope),[],1);
            tmpMax = nan(size(tmp));
            for k = 1:length(tmp)
                tmpMax(k) = pscCope(tmp(k),k);
            end
            meanpsc(i,:) = tmpMax;
        end
        pscData{ss,cc,1} = squeeze(nanmean(meanpsc))';
        pscData{ss,cc,2} = ecc.vol(roiInd);
        pscData{ss,cc,3} = pol.vol(roiInd);
        progBar(ct);
    end
end
% Save the data
save(fullfile(projDir,'pscData.mat'),'pscData');
%% Bin data
clear LMS MEL
binNames = cell(1,length(eccBins)-1);
for i = 1:length(eccBins)-1
    binNames{i} = [num2str(eccBins(i)) '-' num2str(eccBins(i+1))];
    tmp = nan(length(subjNames),length(condNames));
    for ss = 1:length(subjNames)
        for cc = 1:length(condNames)
            binInd = pscData{ss,cc,2} > eccBins(i) & pscData{ss,cc,2} <= eccBins(i+1);
            tmp(ss,cc) = mean(pscData{ss,cc,1}(binInd));
        end
    end
    LMS.mean(i) = mean(tmp(:,1));
    LMS.SEM(i) = std(tmp(:,1)) / sqrt(length(tmp(:,2)));
    MEL.mean(i) = mean(tmp(:,2));
    MEL.SEM(i) = std(tmp(:,2)) / sqrt(length(tmp(:,2)));
end
%% Plot binned data
fullFigure;
% LMS
subplot(1,2,1);
errorbar(LMS.mean,LMS.SEM);
axis square
set(gca,'XTick',1:length(eccBins)-1);
set(gca,'XTickLabel',binNames,'FontSize',15);
xlabel('Eccentricity bins','FontSize',20);
ylabel('Percent signal change','FontSize',20);
ylim([-0.5 1.5])
title('LMS pulse: mean +/- SEM','FontSize',30);
% MEL
subplot(1,2,2);
errorbar(MEL.mean,LMS.SEM);
axis square
set(gca,'XTick',1:length(eccBins)-1);
set(gca,'XTickLabel',binNames,'FontSize',15);
xlabel('Eccentricity bins','FontSize',20);
ylabel('Percent signal change','FontSize',20);
ylim([-0.5 1.5])
title('MEL pulse: mean +/- SEM','FontSize',30);
savefigs('pdf',fullfile(projDir,'LMS_MEL_psc'));
%% Deprecated below


















%% Plot using plotVisual
for ss = 1:length(subjNames)
    for cc = 1:length(condNames)
        roiInd = 1:length(pscData{ss,cc,1});
        allImages(ss,cc).outImage = plotVisual(pscData{ss,cc,1},pscData{ss,cc,2},pscData{ss,cc,3},roiInd);
    end
end
%% Pull out the LMS and Mel data
for i = 1:length(subjNames)
    LMS(i,:,:) = allImages(i,1).outImage;
    MEL(i,:,:) = allImages(i,2).outImage;
end
%% Get the mean
meanLMS = squeeze(mean(LMS));
meanMEL = squeeze(mean(MEL));
matSize = size(meanLMS);
plotDists = nan(size(meanLMS));
axLim = 90;
for i = 1:matSize(1) % row (y)
    for j = 1:matSize(2) % columns (x)
        plotDists(i,j) = sqrt( (i-(matSize(1)+1)/2)^2 + (j-(matSize(2)+1)/2)^2 );
    end
end
eccDists = 10.^(plotDists * log10(axLim)/( (matSize(1)/2) ));
% log scale
logDists = log10(eccDists);
%% Plot mean image
fullFigure;
subplot(1,1,1);%hold on;
axis off;
% bak = outImage;
%pImage = cdf('normal',outImage);
% threshImage = pImage;
% threshImage(threshImage>0.05) = nan;
% finalImage = log10(threshImage);
%finalImage = log10(pImage);
pcolor(meanMEL);
shading flat;
colormap(viridis);
axis off
axis square
colorbar('EastOutside');
%% Plot using plotVisual
clear inVol
for ss = 1:length(subjNames)
    for cc = 1:length(condNames)
        switch condNames{cc}
            case 'lmsMAX'
                sessionDir = fullfile(projDir,subjNames{ss},lmsMAX{ss});
            case 'melMAX'
                sessionDir = fullfile(projDir,subjNames{ss},melMAX{ss});
        end
        b = find_bold(sessionDir);
        featDirs = cell(1,length(b));
        for i = 1:length(b)
            featDirs{i} = fullfile(sessionDir,b{i},featDir);
        end
        meanpsc = nan(length(featDirs),256,256,256);
        progBar = ProgressBar(length(featDirs),'Calculating percent signal change...');
        for i = 1:length(featDirs)
            pscCope = nan(length(copeNums),256,256,256);
            for j = copeNums
                tmp = load_nifti(fullfile(featDirs{i},'stats',...
                    ['cope' num2str(copeNums(j)) '.anat.psc.nii.gz']));
                pscCope(j,:,:,:) = tmp.vol;
            end
            % Get the largest amplitude response (+ or -)
            dims = size(pscCope);
            tmpCope = reshape(pscCope,dims(1),dims(2)*dims(3)*dims(4));
            [~,tmp] = nanmax(abs(tmpCope),[],1);
            tmpMax = nan(dims(2),dims(3),dims(4));
            for k = 1:length(tmp)
                tmpMax(k) = tmpCope(tmp(k),k);
            end
            meanpsc(i,:,:,:) = tmpMax;
            progBar(i);
        end
        inVol = squeeze(nanmean(meanpsc));
        % Get retinotopy volumes
        eccVol = fullfile(sessionDir,'anat_templates','mh.ecc.anat.vol.nii.gz');
        polVol = fullfile(sessionDir,'anat_templates','mh.pol.anat.vol.nii.gz');
        % Get voxel indices for ROI
        tmp = load_nifti(fullfile(sessionDir,'anat_templates','mh.areas.anat.vol.nii.gz'));
        roiInd = abs(tmp.vol) == 1; % V1
        [allImages(ss,cc).outImage] = plotVisual(inVol,eccVol,polVol,roiInd);
    end
end