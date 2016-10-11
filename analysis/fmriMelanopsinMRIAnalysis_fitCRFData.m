function fmriMelanopsinMRIAnalysis_fitCRFData(inputParams)
% fmriMelanopsinMRIAnalysis_fitCRFData(inputParams)
%
% Fits the 400% data
%
% 10/1/2016 ms Wrote it.

%% Copy over the params
params = inputParams;

%% Set up the fitting object
% Set up a @tfe object to do convolution
temporalFit = tfeIAMP('verbosity','none');
params0 = temporalFit.defaultParams();
paramLockMatrix = [];

%% Iterate over the subjects
whichDataSet = 'LMSCRF';
switch whichDataSet
    case 'Splatter'
        subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
        sessionIDs = {'051016' '042916' '050616' '050916'};
        sessionRef = {'032416' '032516' '033116' '040616'};
    case 'LMSCRF'
        subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
        sessionIDs = {'060816' '060116' '060616' '062816'};
        sessionRef = {'032416' '032516' '033116' '040616'};
    case 'MelCRF'
        subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1' 'HERO_mxs1'};
        sessionIDs = {'060716' '053116' '060216' '060916' '061016_Mel'};
        sessionRef = {'032416' '032516' '033116' '040616' '040616'};
end

maskName = 'avg_varexp_thresh.nii.gz';

for ss = 1:length(subjIDs);
    subjID = subjIDs{ss}; sessionID = sessionIDs{ss};
    params.sessionDir = fullfile(params.dataDir, subjID, sessionID);
    params.outDir = fullfile(params.sessionDir, 'stats');
    if ~isdir(params.outDir);
        mkdir(params.outDir);
    end;
    boldDirs = find_bold(params.sessionDir);
    matDir = fullfile(params.sessionDir,'MatFiles');
    matFiles = listdir(matDir,'files');
    
    % Iterate over BOLD dirs
    for b = 1:length(boldDirs)
        params.stimulusFile = fullfile(matDir, matFiles{b});
        params.responseFile = fullfile(params.sessionDir, boldDirs{b}, 'wdrf.tf.nii.gz');
        params.anatRefRun = fullfile(params.sessionDir, boldDirs{1});
        params.maskFile = fullfile(params.dataDir, subjID, sessionRef{ss}, 'stats', maskName);
        
        fprintf('* <strong>Loading response file</strong>...');
        resp = load_nifti(params.responseFile);
        TR = resp.pixdim(5)/1000;
        runDur = size(resp.vol,4);
        params.respTimeBase = (0:TR:(runDur*TR)-TR)*1000;
        fprintf('\tDONE.\n');
        % Flatten the volume
        [respvol, volDims] = fmriMelanopsinMRIAnalysis_flattenVolume(resp);
        
        fprintf('* <strong>Loading mask file</strong>...');
        maskfile = load_nifti(params.maskFile);
        fprintf('\tDONE.\n');
        % Flatten the mask
        maskvol = fmriMelanopsinMRIAnalysis_flattenVolume(maskfile);
        
        % Assemble the average response
        params.respValues = mean(respvol(find(maskvol), :));
        
        % Convert to epSC
        params.respValues = convert_to_psc(params.respValues);
        
        %% Get the HRF
        params.hrfFile = fullfile(params.sessionDir,'HRF','V1.mat');
        
        %% Get the stimulus values
        [params.stimValues, params.stimTimeBase, params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);
        
        % Mean center the stimuli
        for ii = 1:size(params.stimValues, 1)
            params.stimValues(ii, :) = params.stimValues(ii, :) - mean(params.stimValues(ii, :));
        end
        stimType(b, :) = params.stimMetaData.stimTypes;
        
        defaultParamsInfo.nInstances = size(params.stimValues, 1);
        
        %% Make the packet
        params.packetType = 'bold';
        thePacket = makePacket(params);
        
        % Prep the HRF
        thePacket.kernel = prepareHRFKernel(thePacket.kernel);
        
        %% Fit packet
        [paramsFit, fVal, modelResponseStruct] = ...
            temporalFit.fitResponse(thePacket, ...
            'defaultParamsInfo', defaultParamsInfo, ...
            'paramLockMatrix', paramLockMatrix, ...
            'searchMethod','linearRegression');
        fitAmplitude(b, :) = paramsFit.paramMainMatrix;
    end
    
    % Iterate over stimulus type
    stimTypeFlat = stimType(:);
    fitAmplitudeFlat = fitAmplitude(:);
    for ii = 1:5
        fitAmplitudesMean(ss, ii) = mean(fitAmplitudeFlat(find(stimTypeFlat == ii )));
        fitAmplitudesSEM(ss, ii) = std(fitAmplitudeFlat(find(stimTypeFlat == ii ))) / sqrt(length(fitAmplitudeFlat(find(stimTypeFlat == ii ))));
    end
end

keyboard