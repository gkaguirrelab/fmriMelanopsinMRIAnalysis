function eventTimes = fmriMelanopsinMRIAnalysis_getAttentionEvents(params)
% eventTimes = fmriMelanopsinMRIAnalysis_makeStimStruct(params)
%
%  Makes a stimulus structure.
%
% 9/27/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (subjHRF.m)

% Get the attention events
attentionTaskNames  = {'MirrorsOffMaxLMS','MirrorsOffMaxMel','MirrorsOffSplatterControl'};
stimulus.metaData           = load(params.stimulusFile);
ct = 0;
attEvents = [];
for j = 1:size(stimulus.metaData.params.responseStruct.events,2)
    % Get the attention events
    if sum(strcmp(stimulus.metaData.params.responseStruct.events(j).describe.direction,attentionTaskNames))
        ct = ct + 1;
        % Get the stimulus window
        attEvents(ct) = stimulus.metaData.params.responseStruct.events(j).tTrialStart - ...
            stimulus.metaData.params.responseStruct.tBlockStart + ...
            stimulus.metaData.params.thePhaseOffsetSec(stimulus.metaData.params.thePhaseIndices(j));
    end
end
eventTimes                  = round(attEvents*1000); % attention events (msec)