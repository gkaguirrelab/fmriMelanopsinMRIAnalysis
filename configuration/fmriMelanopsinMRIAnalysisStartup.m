%% Startup script for use with the Toolbox Toolbox.
%
% Here is a sample startup.m for works with the ToolboxToolbox.  You
% should copy this file to your system outside of the ToolboxToolbox
% folder.  You should rename this file to "startup.m".  You should edit
% Your startup.m with the correct toolboxToolboxDir, and any Matlab
% preferences you wish to change for your local machine.
%
% 2016 benjamin.heasly@gmail.com

%% Where is the Toolbox Toolbox installed?

% a reasonable default, or pick your own
userFolder = '/home/mspitschan/matlab';
toolboxToolboxDir = fullfile(userFolder, 'ToolboxToolbox');


%% Set up the path.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('full');
catch err
    warning('Error setting Toolbox Toolbox path during startup: %s', err.message);
end

cd(originalDir);


%% Put /usr/local/bin on path so we can see things installed by Homebrew.
if ismac()
    setenv('PATH', ['/usr/local/bin:' getenv('PATH')]);
end


%% Matlab preferences that control ToolboxToolbox.

% uncomment any or all of these that you wish to change

% % default location for JSON configuration
configPath = '~/toolbox_config.json';
setpref('ToolboxToolbox', 'configPath', configPath);

% % default folder to contain regular the toolboxes
toolboxRoot = '/home/mspitschan/matlab';
setpref('ToolboxToolbox', 'toolboxRoot', toolboxRoot);

% % default folder to contain shared, pre-installed toolboxes
toolboxCommonRoot = '/srv/toolboxes';
setpref('ToolboxToolbox', 'toolboxCommonRoot', toolboxCommonRoot);

% % default folder for hooks that set up local config for each toolbox
localHookFolder = '/home/mspitschan/matlab/localToolboxHooks';
setpref('ToolboxToolbox', 'localHookFolder', localHookFolder);

% % location of ToolboxHub or other toolbox registry
registry = tbDefaultRegistry();
setpref('ToolboxToolbox', 'registry', registry);

% % system command used to check whether the Internet is reachable
if ispc()
    checkInternetCommand = 'ping -n 1 www.google.com';
else
    checkInternetCommand = 'ping -c 1 www.google.com';
end
setpref('ToolboxToolbox', 'checkInternetCommand', checkInternetCommand);

tbUse('MelanopsinMR_BOLDAnalysisConfig');
