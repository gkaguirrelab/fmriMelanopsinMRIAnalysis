%% MelanopsinMR_BOLDAnalysisConfig
%
% Declare the toolboxes we need for the IBIOColorDetect project and
% write them into a JSON file.  This will let us use the ToolboxToolbox to
% deliver unto us the perfect runtime environment for this project.
%
% 2016 benjamin.heasly@gmail.com

% Clear
clear;

%% Declare some toolboxes we want.
config = [ ...
    tbToolboxRecord( ...
    'name', 'MRklar', ...
    'type', 'git', ...
    'url', 'https://github.com/gkaguirrelab/MRklar.git'), ...
	tbToolboxRecord( ...
    'name', 'MRlyze', ...
    'type', 'git', ...
    'url', 'https://github.com/gkaguirrelab/MRlyze.git'), ...
    tbToolboxRecord( ...
    'name', 'mriTemporalFitting', ...
    'type', 'git', ...
    'url', 'https://github.com/gkaguirrelab/mriTemporalFitting.git')];

%% Write the config to a JSON file.
configPath = 'MelanopsinMR_BOLDAnalysisConfig.json';
tbWriteConfig(config, 'configPath', configPath);