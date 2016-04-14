function [hits, hTotal, falseAlarms, fTotal] = check_performance(matFile, protocolName)
% check_performance(matFile, protocolName)
% Displays the hit rate and false alarm rate for an attention task created
%   using the OneLight, based on an input .mat file
%
%   Usage:
%   check_performance(matFile, protocolName)
%
%   Written by Andrew S Bock Mar 2016
% 4/8/16    ms   Updated.

%% Load the .mat file
load(matFile);
%% Iterate over the segments and count analyze accuracy
NSegments           = length(params.responseStruct.events);
attentionTaskFlag   = zeros(1,NSegments);
responseDetection   = zeros(1,NSegments);
hit                 = zeros(1,NSegments);
miss                = zeros(1,NSegments);
falseAlarm          = zeros(1,NSegments);
for i = 1:NSegments
    switch protocolName
        case {'MelanopsinMRMaxMel' 'MelanopsinMR'}
            % Attentional 'blinks'
            if ~isempty(strfind(params.responseStruct.events(i).describe.direction, 'MirrorsOff'))
                attentionTaskFlag(i) = 1;
            end
        case 'HCLV_Photo'
            % Attentional 'blinks'
            if params.responseStruct.events(i).attentionTask.segmentFlag
                attentionTaskFlag(i) = 1;
            end
    end
    
    % Subject key press responses
    if ~isempty(params.responseStruct.events(i).buffer) & any(~strcmp({params.responseStruct.events(i).buffer.charCode}, '='))
        responseDetection(i) = 1;
    end
    % Hits
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 1)
        hit(i) = 1;
    end
    % Misses
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 0)
        miss(i) = 1;
    end
    % False Alarms
    if (attentionTaskFlag(i) == 0) && (responseDetection(i) == 1)
        falseAlarm(i) = 1;
    end
end
hits = sum(hit);
hTotal = sum(attentionTaskFlag);
falseAlarms = sum(falseAlarm);
fTotal = (NSegments-sum(attentionTaskFlag));
%% Display performance
fprintf('*** Subject %s - hit rate: %.3f (%g/%g) / false alarm: %.3f (%g/%g)\n', ...
    exp.subject, hits/hTotal, hits, hTotal, ...
    falseAlarms/fTotal, falseAlarms, ...
    fTotal);