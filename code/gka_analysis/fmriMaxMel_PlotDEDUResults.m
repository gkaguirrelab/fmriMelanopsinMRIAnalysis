function [ ] = fmriMaxMel_PlotDEDUResults( meanAmplitudes, meanDurations, semAmplitudes, semDurations)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

maxSEMDuration=max(semDurations(:));
symbolBySubject={'o','s','^','p'};
contrastLevels=[25,50,100,200,400];

figure
hold on
for dd=1:2
    for ss=1:4
        amps=meanAmplitudes(dd,:,ss);
        semAmps=semAmplitudes(dd,:,ss);
        switch dd
            case 1
                faceColor=[1,0,0];
            case 2
                faceColor=[0,0,1];
        end
        plot(log(contrastLevels),amps,symbolBySubject{ss},...
            'MarkerSize', 5,...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceColor', faceColor);
    end
end


figure
hold on
for dd=1:2
    for ss=1:4
        for cc=1:5
            amp=meanAmplitudes(dd,cc,ss);
            dur=meanDurations(dd,cc,ss);
            semDur=semDurations(dd,cc,ss);
            semAmp=semAmplitudes(dd,cc,ss);
            fade=semDur/maxSEMDuration;
            switch dd
                case 1
                    faceColor=[1,fade,fade];
                case 2
                    faceColor=[fade,fade,1];
            end
            MarkerSize=ceil(15*(1.01-semDur/maxSEMDuration));
            errorbar(dur,amp,semAmp,symbolBySubject{ss},...
                'MarkerSize', MarkerSize,...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceColor', faceColor);
            
        end
    end
end
end % function

