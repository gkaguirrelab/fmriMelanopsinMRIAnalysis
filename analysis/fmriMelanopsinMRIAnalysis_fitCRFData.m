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
whichDataSets = {'SplatterControlCRF' 'LMSCRF' 'MelCRF'};
for dd = 1:length(whichDataSets)
    whichDataSet = whichDataSets{dd};
    switch whichDataSet
        case 'SplatterControlCRF'
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
    packetCellArrayTag = ['MelanopsinMR_' whichDataSet '_threshsig'];
    packetSaveDir = '/data/jag/MELA/MelanopsinMR/packets';
    if ~exist(packetSaveDir);
        mkdir(packetSaveDir);
    end;
    maskName = 'avg_varexp_thresh.nii.gz';
    
    for ss = 1:length(subjIDs);
        stimType = []; fitAmplitude = [];
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
        for bb = 1:length(boldDirs)
            params.stimulusFile = fullfile(matDir, matFiles{bb});
            params.responseFile = fullfile(params.sessionDir, boldDirs{bb}, 'wdrf.tf.nii.gz');
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
            stimType(bb, :) = params.stimMetaData.stimTypes;
            
            defaultParamsInfo.nInstances = size(params.stimValues, 1);
            
            %% Make the packet
            params.packetType = 'bold';
            thePacket = makePacket(params);
            
            % Prep the HRF
            thePacket.kernel = prepareHRFKernel(thePacket.kernel);
            
            %% Fit packet
            FIT = false;
            if FIT
                [paramsFit, fVal, modelResponseStruct] = ...
                    temporalFit.fitResponse(thePacket, ...
                    'defaultParamsInfo', defaultParamsInfo, ...
                    'paramLockMatrix', paramLockMatrix, ...
                    'searchMethod','linearRegression');
                fitAmplitude(b, :) = paramsFit.paramMainMatrix;
            end
            packetCellArray{ss, bb} = thePacket;
        end
    end
    packetCellArrayHash = DataHash(packetCellArray);
    packetCacheFileName = fullfile(outDir, [packetCellArrayTag '_' packetCellArrayHash '.mat']);
    save(packetCacheFileName,'packetCellArray','-v7.3');
    fprintf(['Saved the packetCellArray with hash ID ' packetCellArrayHash '\n']);
end
keyboard

% subplot(1, 3, 3)
% plot(log10([0.25 0.50 1 1.95]), mean(fitAmplitudesMean{1}(:, 1:4)), '-sk', 'MarkerFaceColor', 'k');
% pbaspect([1 1 1]); set(gca, 'TickDir', 'out');
% xlabel('log contrast'); ylabel('Percent signal change');
% set(gca, 'XTick', log10([0.25 0.50 1 1.95]), 'XTickLabel', 100*([0.25 0.50 1 1.95]))
% ylim([-0.1 2]);
% title('Splatter control');
% 
% subplot(1, 3, 2)
% plot(log10([0.25 0.5 1 2 4]), mean(fitAmplitudesMean{2}(:, 1:5)), '-sk', 'MarkerFaceColor', 'k');
% pbaspect([1 1 1]); set(gca, 'TickDir', 'out');
% xlabel('log contrast'); ylabel('Percent signal change');
% set(gca, 'XTick', log10([0.25 0.50 1 2 4]), 'XTickLabel', 100*([0.25 0.50 1 2 4]))
% ylim([-0.1 2]);
% title('LMS')
% 
% subplot(1, 3, 1)
% plot(log10([0.25 0.5 1 2 4]), mean(fitAmplitudesMean{3}(:, 1:5)), '-sk', 'MarkerFaceColor', 'k');
% pbaspect([1 1 1]); set(gca, 'TickDir', 'out');
% xlabel('log contrast'); ylabel('Percent signal change');
% set(gca, 'XTick', log10([0.25 0.50 1 2 4]), 'XTickLabel', 100*([0.25 0.50 1 2 4]))
% ylim([-0.1 2]);
% title('Mel')