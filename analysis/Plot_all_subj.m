 %% for each subject  
figs = { ...
    '/data/jag/MELA/HERO_asb1/032416/FIR_figures/mh_V1_MaxMelPulse_FIR_raw.fig' ...
    '/data/jag/MELA/HERO_aso1/032516/FIR_figures/mh_V1_MaxMelPulse_FIR_raw.fig' ...
    '/data/jag/MELA/HERO_gka1/033116/FIR_figures/mh_V1_MaxMelPulse_FIR_raw.fig' ...
    '/data/jag/MELA/HERO_mxs1/040616/FIR_figures/HERO_mxs1_MaxMelPulse_mh_V1_FIR_raw.fig' ...
    };
subjNames = { ...
    'HERO_asb1' ...
    'HERO_aso1' ...
    'HERO_gka1' ...
    'HERO_mxs1' ...
    };

dropbox_dir ='/Users/giulia/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/MelanopsinMR/MelPulses_400%/All_subjects';    


 %% get means
for ff = 1:length(figs)
% get datapoints
    H = open (figs{ff});
    D=get(gca,'Children');
    YData=get(D,'YData');
    y(ff) = YData(1);
    close (H);
end

%% plot all in same figure
figure('units','normalized','position',[0 0 1 1]);
hold on
xlabel('Time in seconds');
ylabel('Percent Signal Change');
title ('All subjects MaxMel_mh_V1','Interpreter','none')
xlims = [-1 15];
ylims = [-0.3 1];
xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
xLabels = xTick;
h = plot([xlims(1) xlims(end)],[0 0],'k');
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
xlim(xlims); ylim(ylims);
ax = gca;
set(ax,'XTick',xTick);
set(ax,'XTickLabel',xLabels);
for pp = 1:length(figs)
    dataP = y(pp);
    dataP = transpose (dataP{:});
    dataL = length(dataP);
    x = 0:1:dataL-1;
    plot(x,dataP,'o-');
    axis square;
    legendInfo{pp} = (subjNames{pp}); 
end
legend (legendInfo, 'Interpreter','none');

%save

set(gcf, 'PaperPosition', [0 0 7 7]);
set(gcf, 'PaperSize', [7 7]);
saveas(gcf, fullfile(dropbox_dir, 'HEROES_MaxMel_mh_V1'), 'pdf'); %save .pdf on dropbox
close all;


%% calculate mean
s1 = y{1};
s2 = y{2};
s3 = y{3};
s4 = y{4};
M = [s1 ; s2 ; s3 ; s4];
meanSubj = mean (M);
stdSubj = std (M);

figure('units','normalized','position',[0 0 1 1]);
hold on
% TextBox = uicontrol('style','text')
% set(TextBox,'String','Point by point mean across 4 subjects with standard deviation')
xlabel('Time in seconds');
ylabel('Percent Signal Change');
title ('Mean across all subjects MaxMel_mh_V1','Interpreter','none')
xlims = [-1 15];
ylims = [-0.3 1];
xTick = [0 1 2 3 4 5 6 7 8 9 10 11 12 13];
xLabels = xTick;
h = plot([xlims(1) xlims(end)],[0 0],'k');
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
xlim(xlims); ylim(ylims);
ax = gca;
set(ax,'XTick',xTick);
set(ax,'XTickLabel',xLabels);
errorbar(x,meanSubj,stdSubj, 'k');hold on;
plot(x, meanSubj,'.r','MarkerSize',16);


%save

set(gcf, 'PaperPosition', [0 0 7 7]);
set(gcf, 'PaperSize', [7 7]);
saveas(gcf, fullfile(dropbox_dir, 'MEAN_MaxMel_mh_V1'), 'pdf'); %save .pdf on dropbox
close all;