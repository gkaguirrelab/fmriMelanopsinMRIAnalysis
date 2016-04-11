%% Set defaults
useFakeData = 0;

%% Set data
if useFakeData
    [hrf] = doubleGammaHrf;
    for i = 1:length(hrf)
        Data(i) = hrf(i) + hrf(i)*(rand(1)/2); % add noise
    end
else
    realData = [-0.0139;0.0041;0.0533;0.2125;0.3279;0.3265;0.2456;0.0973;...
        0.0074;-0.0560;-0.0618;-0.0433;-0.0150;-0.0245];
    %Data = zeros(33,1);
    Data = zeros(size(realData));
    Data(1:length(realData)) = realData;
end

pX0 = [6 10 1/6]; % These are our starting values. Standard HRF parameters
plb = [1 1 0]; % Lower bounds
pub = [10 20 1]; % Upper bounds

problem = createOptimProblem(...
    'fmincon','objective',...
    @(p) findHRF(p,Data),'x0',pX0,'lb',plb,'ub',pub);
gs = GlobalSearch('Display','iter');
[optp,fval] = run(gs,problem);
newhrf = doubleGammaHrf(1,[optp(1) optp(1)+optp(2)],[1 1],optp(3));

dataL = length(Data);
x = 1:dataL;
figure;plot(x,Data,'.b',x,newhrf(x),'r');
axis square;