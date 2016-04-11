session_dir = '/Users/giulia/Desktop/MelanopsinMR_figures/gka1_033116/';
fig = dir(fullfile(session_dir, 'FIR_figures', 'mh_V1_MaxMelPulse_FIR_raw.fig'));




%do the fitting
pX0 = [6 10 1/6]; % These are our starting values. Standard HRF parameters
plb = [3 1 0]; % Lower bounds
pub = [10 20 1/3]; % Upper bounds

problem = createOptimProblem(...
    'fmincon','objective',...
    @(p) findHRF(p,Data),'x0',pX0,'lb',plb,'ub',pub);
gs = GlobalSearch('Display','iter');
[optp,fval] = run(gs,problem);
newhrf = doubleGammaHrf(1,[optp(1) optp(1)+optp(2)],[1 1],optp(3));

%plot this
    dataL = length(Data);
    x = 1:dataL;
    figure('units','normalized','position',[0 0 1 1]);
    plot(x,Data,'ok', 'MarkerFaceColor', 'k');hold on;
    plot(x,newhrf(x),'r');
    axis square;
    xlabel('Time in seconds','FontSize',20);
    ylabel('Percent Signal Change','FontSize',20);
    xlim([0 14]);