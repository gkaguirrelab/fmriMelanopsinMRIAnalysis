function e = findHRF(p,obsData)

% Calculates the error between the predicted and observed HRF data
%
%   Usage:
%   e = findHRF(p,obsData)
%
%   p(1) = time to peak
%   p(2) = undershoot, in seconds AFTER peak (e.g. undershoot = p(1) + p(2))
%   p(2) = ratio of peak to undershoot
%
%   Example:
%   p = [6 10 1/6];
%
%   Written by Andrew S Bock Mar 2016

%% Set up params
TR = 1;
tp(1) = p(1);
tp(2) = p(1)+p(2);
beta(1) = 1;
beta(2) = 1;
rt = p(3);
%% Calc HRF
[hrf] = doubleGammaHrf(TR,tp,beta,rt);
dataL = length(obsData);
model = hrf(1:dataL);
e = sum((model-obsData).^2);