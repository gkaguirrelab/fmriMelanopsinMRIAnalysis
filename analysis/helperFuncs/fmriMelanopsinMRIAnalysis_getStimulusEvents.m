function eventTimes = fmriMelanopsinMRIAnalysis_getStimulusEvents(params, eventIdx)
% eventTimes = fmriMelanopsinMRIAnalysis_getStimulusEvents(params, eventIdx)
%
%  Makes a stimulus structure.
%
% 9/27/2016     ms      Homogenized comments and function documentation.
%                       Based on code from Andrew S. Bock (subjHRF.m)

% Get the attention events
stimulus.metaData           = load(params.stimulusFile);
ct = 0;
attEvents = [];
for j = 1:size(stimulus.metaData.params.responseStruct.events,2)
    % Get the attention events
    if stimulus.metaData.params.theDirections(j) == eventIdx
        ct = ct + 1;
        % Get the stimulus window
        attEvents(ct) = stimulus.metaData.params.responseStruct.events(j).tTrialStart - ...
            stimulus.metaData.params.responseStruct.tBlockStart + ...
            stimulus.metaData.params.thePhaseOffsetSec(stimulus.metaData.params.thePhaseIndices(j));
    end
end
eventTimes                  = round(attEvents*1000); % attention events (msec)