function HRFOptimDemo
% HRFOptimDemo
%
% This program shows some demo for fitting an HRF using constrained
% optimization

% Define some parameters
len = 13;
TR = 1;

x0 = [6 16 1 1 1/6]; % These are our starting values. Standard HRF parameters
vlb = [4 12 0 0 1/9]; % Lower bounds, note that I'm pegging the beta parameters at positions 3 and 4
vub = [8 20 10 10 1/2]; % Upper bounds, note that I'm pegging the beta parameters at positions 3 and 4

% Some example data.
t0 = 0:1:13;

% Make some data
SYNTHETIC_DATA = false
if SYNTHETIC_DATA
    [data, t1] = GetDoubleGammaHRF(x0,TR,len);
    data = data+normrnd(0, 0.05, size(data)); % Add Gaussian noise
else
    data = [-0.0139...
        0.0041...
        0.0533...
        0.2125...
        0.3279...
        0.3265...
        0.2456...
        0.0973...
        0.0074...
        -0.0560...
        -0.0618...
        -0.0433...
        -0.0150...
        -0.0245]
end

% Set up the optimization
options = optimset('fmincon');
options = optimset(options,'Diagnostics','on','Display','off',...
    'LargeScale','on','Algorithm','sqp', 'MaxFunEvals', 100000, ...
    'TolFun', 1e-10, 'TolCon', 1e-10, 'TolX', 1e-10);

% Run the optimization
GLOBAL_SEARCH = true;
if GLOBAL_SEARCH
    problem = createOptimProblem(...
        'fmincon','objective',...
        @(p) CalculateHRFError(p,data,TR,len), ...
        'x0',x0,'lb',vlb,'ub',vub);
    gs = GlobalSearch('Display','iter','TolFun',0.001,'TolX',0.001);
    [p,fval] = run(gs,problem);
else
    p = fmincon(@(p) CalculateHRFError(p,data,TR,len),x0,[],[],[],[],vlb,vub,[],options)
end
% Evaluate the best fitting parameters
[model, t1] = GetDoubleGammaHRF(p,0.1,len);

% Plot this
plot(t0, data, 'ok', 'MarkerFaceColor', 'k'); hold on;
plot(t1, model, '-r');
xlim([-1 15]);

function [hrf, t] = GetDoubleGammaHRF(p,TR,len)
% Unpack the parameters
tp(1) = p(1);
tp(2) = p(2);
beta(1) = p(3);
beta(2) = p(4);
rt = p(5);

% Create HRF
dx = TR:TR:len;
t = [0 dx];
A = [0 gampdf(dx,tp(1),beta(1))];
B = [0 gampdf(dx,tp(2),beta(2))];
hrf = A/max(A) - rt*B/max(B);
%hrf = hrf'/sum(hrf); % Do not normalize

function e = CalculateHRFError(x,data,TR,len)
% Get the model prediction
model = GetDoubleGammaHRF(x,TR,len);

% Calculate the squared error
e = sum((model-data).^2);