function [ ] = fmriMaxMel_PlotDEDUResults( meanAmplitudes, meanDurations, semAmplitudes, semDurations)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure
hold on
plotSymbols={'o','o'};
maxSEMDuration=max(semDurations(:));
plotBaseColor=[[1 0 0];[0 0 1]];

for cc=1:5
    for ss=1:4
        lmsAmp=meanAmplitudes(1,cc,ss);
        melAmp=meanAmplitudes(2,cc,ss);
        lmsDur=meanDurations(1,cc,ss);
        melDur=meanDurations(2,cc,ss);
plot([melDur,lmsDur],[melAmp,lmsAmp],'-k');
    end
end
for dd=1:2
for ss=1:4
    amps=meanAmplitudes(dd,:,ss);
    durs=meanDurations(dd,:,ss);
    semDurs=semDurations(dd,:,ss);
    semAmps=semAmplitudes(dd,:,ss);
    errorbar(durs,amps,semAmps,'o',...
        'MarkerEdgeColor', 'none', ...
'MarkerFaceColor', plotBaseColor(dd,:));
    errorbar(durs,amps,semDurs,'horizontal','o',...
        'MarkerEdgeColor', 'none', ...
'MarkerFaceColor', plotBaseColor(dd,:));
end
end
end % function

