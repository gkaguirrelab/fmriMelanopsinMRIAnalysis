function fmriMelanopsinMRIAnalysis_makeAllCRFPackets(inputParams)
% fmriMelanopsinMRIAnalysis_makeAllCRFPackets(inputParams)
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
whichDataSets = {'RodControlPhotopic' 'RodControlScotopic' 'MelCRF' 'LMSCRF' 'SplatterControlCRF' 'RodControl'};
for dd = 1:length(whichDataSets)
    whichDataSet = whichDataSets{dd};
    switch whichDataSet
        case 'SplatterControlCRF'
            subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
            sessionIDs = {'051016' '042916' '050616' '050916'};
            boldIds = {[1:12] [1:11] [1:12] [1:12]};
            finalPacketCellArrayIdx = {[1] [2] [3] [4]};
        case 'LMSCRF'
            subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1'};
            sessionIDs = {'060816' '060116' '060616' '062816'};
            boldIds = {[1:9] [1:9] [1:10] [1:9]};
            finalPacketCellArrayIdx = {[1] [2] [3] [4]};
        case 'MelCRF'
            subjIDs = {'HERO_asb1' 'HERO_aso1' 'HERO_gka1' 'HERO_mxs1' 'HERO_mxs1'};
            sessionIDs = {'060716' '053116' '060216' '060916' '061016_Mel'};
            boldIds = {[1:9] [1:9] [1:9] [1:5] [1:4]};
            finalPacketCellArrayIdx = {[1] [2] [3] [4 5]};
        case 'RodControlScotopic'
            subjIDs = {'HERO_asb1' 'HERO_gka1' 'HERO_mxs1'};
            sessionIDs = {'101916' '101916' '101916'};
            boldIds = {[1:6] [1:6] [1:6]};
            finalPacketCellArrayIdx = {[1] [2] [3]};
        case 'RodControlPhotopic'
            subjIDs = {'HERO_asb1' 'HERO_gka1' 'HERO_mxs1'};
            sessionIDs = {'101916' '102416' '102416'};
            boldIds = {[7 9:12] [1:6] [1:6]}; % Note that for asb1, the 8th run was the wrong protocol. Dealing this by skipping it here and creating a dummy .mat response fil.e
            finalPacketCellArrayIdx = {[1] [2] [3]};
    end
    packetCellArrayTag = ['MelanopsinMR_' whichDataSet];
    packetCellArray = [];
    packetSaveDir = '/data/jag/MELA/MelanopsinMR/packets';
    if ~exist(packetSaveDir);
        mkdir(packetSaveDir);
    end;
    
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
        c = 1;
        for bb = boldIds{ss}
            params.stimulusFile = fullfile(matDir, matFiles{bb});
            params.responseFile = fullfile(params.sessionDir, boldDirs{bb}, 'wdrf.tf.nii.gz');
            params.anatRefRun = fullfile(params.sessionDir, boldDirs{1});

            %%
            fprintf('* <strong>Prepare anatomical template</strong>...');
            eccFile             = fullfile(params.anatRefRun, 'mh.ecc.func.vol.nii.gz');
            areasFile           = fullfile(params.anatRefRun, 'mh.areas.func.vol.nii.gz');
            eccData             = load_nifti(eccFile);
            areaData            = load_nifti(areasFile);
            DO_ECC = true;
            eccRange = [5 25];
            if DO_ECC
                ROI_V1              = find(abs(areaData.vol)==1 & ...
                    eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
                ROI_V2V3            = find((abs(areaData.vol)==2 | abs(areaData.vol)==3) & ...
                    eccData.vol>eccRange(1) & eccData.vol<eccRange(2));
            else
                ROI_V1              = find(abs(areaData.vol)==1);
                ROI_V2V3            = find((abs(areaData.vol)==2 | abs(areaData.vol)==3));
            end
            maskvol = ROI_V1;
            fprintf('\tDONE.\n');
            
            fprintf('* <strong>Loading response file</strong>...');
            resp = load_nifti(params.responseFile);
            TR = resp.pixdim(5)/1000;
            runDur = size(resp.vol,4);
            params.respTimeBase = (0:TR:(runDur*TR)-TR)*1000;
            fprintf('\tDONE.\n');
            % Flatten the volume
            [respvol, volDims] = fmriMelanopsinMRIAnalysis_flattenVolume(resp);

            % Assemble the average response
            params.respValues = mean(respvol(maskvol, :));
            
            %% Get the HRF
            params.hrfFile = fullfile(params.sessionDir,'HRF','V1.mat');
            
            %% Get the stimulus values
            [params.stimValues, params.stimTimeBase, params.stimMetaData] = fmriMelanopsinMRIAnalysis_makeStimStruct(params);
            
            % Mean center the stimuli
            for ii = 1:size(params.stimValues, 1)
                params.stimValues(ii, :) = params.stimValues(ii, :) - mean(params.stimValues(ii, :));
            end
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
            packetCellArray{ss, c} = thePacket;
            c = c+1;
        end
    end
    
    % Merge sessions
    NSessionsMerged = length(finalPacketCellArrayIdx);
    for mm = 1:NSessionsMerged
        mergeIdx = finalPacketCellArrayIdx{mm};
        mergedPacket = {packetCellArray{mergeIdx, :}};
        mergedPacket = mergedPacket(~cellfun('isempty', mergedPacket));
        for nn = 1:length(mergedPacket)
        finalPacketCellArrays{mm, nn} = mergedPacket{nn};
        end
    end
    packetCellArray = finalPacketCellArrays;
    packetCellArrayHash = DataHash(packetCellArray);
    packetCacheFileName = fullfile(packetSaveDir, [packetCellArrayTag '_' packetCellArrayHash '.mat']);
    save(packetCacheFileName,'packetCellArray','-v7.3');
    fprintf(['Saved the packetCellArray with hash ID ' packetCellArrayHash '\n']);
end