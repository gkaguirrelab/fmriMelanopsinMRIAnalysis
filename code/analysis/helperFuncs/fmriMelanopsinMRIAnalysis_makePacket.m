function packet = fmriMelanopsinMRIAnalysis_makePacket(params)

%   Outputs a 'packet' structure with stimulus, response, metaData, and
%   (optionally) HRF information
%
%   Usage:
%   packet = makePacket(params)
%
%   params structure:
%   params.packetType       - 'bold' or 'pupil'
%   params.sessionDir       - session directory, full path
%   params.stimulusFile     - full path to stimulus file
%   params.stimValues       - 1 x N vector of stimulus values
%   params.stimTimeBase     - 1 x N vector of stimulus times (msec)
%   params.stimMetaData     - Any stimulus meta data
%   params.responseFile     - full path to response file
%   params.respValues       - 1 x N vector of response values
%   params.respTimeBase     - 1 x N vector of response times (msec)
%
%   If strcmp(params.packetType,'bold')
%
%   params.hrfFile          - full path to HRF file
%
%   Output fields in packets:
%
%   stimulus.values         - M x N matrix modeling M stimulus events
%   stimulus.timebase       - 1 x N vector of stimulus times (msec)
%   stimulus.metaData       - structure with info about the stimulus
%
%   response.values         - 1 x N vector of response values
%   response.timebase       - 1 x N vector of response times (msec)
%   response.metaData       - structure with info about the response
%
%   metaData.projectName    - project name (e.g. 'MelanopsinMR');
%   metaData.subjectName    - subject name (e.g. 'HERO_asb1');
%   metaData.sessionDate    - session date (e.g. '041416');
%   metaData.stimulusFile   - fullfile(sessionDir,'MatFiles',matFiles{i});
%   metaData.responseFile   - fullfile(sessionDir,boldDirs{i},[func '.nii.gz']);
%
%   If packetType == 'bold', also outputs:
%
%   kernel.values           - 1 x N vector of response values
%   kernel.timebase         - 1 x N vector of response times (msec)
%   kernel.metaData         - structure with info about the HRF
%
%   Otherwise, the fields in kernel are the empty matrix ([]).
%
%   Written by Andrew S Bock Aug 2016

%% Metadata
[subjectStr,sessionDate]            = fileparts(params.sessionDir);
[projectStr,subjectName]            = fileparts(subjectStr);
[~,projectName]                     = fileparts(projectStr);
metaData.projectName                = projectName;
metaData.subjectName                = subjectName;
metaData.sessionDate                = sessionDate;
metaData.stimulusFile               = params.stimulusFile;
metaData.responseFile               = params.responseFile;
%% Stimulus
stimulus.values                     = params.stimValues;
stimulus.timebase                   = params.stimTimeBase;
stimulus.metaData.filename          = params.stimulusFile;
stimulus.metaData                   = params.stimMetaData;
%% Response
response.values                     = params.respValues;
response.timebase                   = params.respTimeBase;
response.metaData.filename          = params.responseFile;
%% Kernel
switch params.packetType
    case 'bold'
        % HRF (if applicable)
        tmp                         = load(params.hrfFile);
        kernel.values               = tmp.HRF.mean;
        kernel.timebase             = 0:length(kernel.values)-1;
        kernel.metaData             = tmp.HRF.metaData;
    otherwise
        kernel.values               = [];
        kernel.timebase             = [];
        kernel.metaData             = [];
end
%% Save the packets
packet.stimulus                     = stimulus;
packet.response                     = response;
packet.metaData                     = metaData;
packet.kernel                       = kernel;