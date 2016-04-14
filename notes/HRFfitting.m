function HRFfitting (session_dir,dropbox_dir)

% Define some parameters
% len = 13;
% TR = 1;
%
% x0 = [6 16 1 1 1/6]; % These are our starting values. Standard HRF parameters
% vlb = [4 12 0 0 1/9]; % Lower bounds, note that I'm pegging the beta parameters at positions 3 and 4
% vub = [8 20 10 10 1/2]; % Upper bounds, note that I'm pegging the beta parameters at positions 3 and 4
%
% t0 = 0:1:13;

figures = dir(fullfile(session_dir, 'FIR_figures'));

for ii= 3:length(figures)
    fig = figures(ii).name;
    
    % get datapoints
    H = open (fullfile(session_dir, 'FIR_figures', fig));
    D=get(gca,'Children');
    YData=get(D,'YData');
    y = YData(1);
    Data = transpose(y{:});
    close (H);
    
    %do the fitting
    pX0 = [6 10 1/6]; % These are our starting values. Standard HRF parameters
    plb = [1 5 0]; % Lower bounds
    pub = [10 20 1]; % Upper bounds
    
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
    
    
    
    %save this
    if ~exist (fullfile(session_dir, 'HRF_figures'),'dir')
        mkdir (session_dir, 'HRF_figures');
    end
    if ~exist (fullfile(dropbox_dir, 'HRF_figures'),'dir')
        mkdir (dropbox_dir, 'HRF_figures');
    end
    savefig(fullfile(session_dir, 'HRF_figures', fig)); %save .fig on cluster
    savefigs('pdf', fullfile(dropbox_dir,'HRF_figures', fig)); %save .pdf on dropbox
    close all;
    
end
end
