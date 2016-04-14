%% Housekeeping
clearvars;

%% Discover the user so that the path can be set up correctly.
[~, userID] = system('whoami');
userID = strtrim(userID);

%% List all the .mat files
matFiles = {...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-01.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-02.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-03.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-04.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-05.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-06.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-07.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-08.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-09.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-10.mat'] ...
    ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/MelanopsinMRMaxMel/HERO_asb1/032416/MatFiles/HERO_asb1-MelanopsinMRMaxMel-11.mat'] ...
    };

%% Set up the output directories
outDir = '/data/jag/MELA/HERO_asb1/032416/Stimuli';
outDirPerformance = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/MelanopsinMR/MelPulses_400%/HERO_asb1/032416'];
if ~isdir(outDirPerformance)
    mkdir(outDirPerformance);
end
protocolName = 'MelanopsinMRMaxMel';
wrapAround = 0;

%% Generate the regressors
for mm = 1:length(matFiles)
    matFile = matFiles{mm};
    ol_regressors(matFile,outDir,protocolName,wrapAround)
end

%% Also get the performance
for mm = 1:length(matFiles)
    matFile = matFiles{mm};
    [hits(mm) hTotal(mm) falseAlarms(mm) fTotal(mm)] = check_performance(matFile, protocolName);
end

%% Write the performance out
outFilePerformance = fullfile(outDirPerformance, 'performance.csv');
fid = fopen(outFilePerformance, 'w');
fprintf(fid, 'Hits,N,False alarms,N\n');
fclose(fid);
dlmwrite(outFilePerformance, [hits' hTotal' falseAlarms' fTotal'], '-append');
fid = fopen(outFilePerformance, 'a');
fprintf(fid, 'Total\n');
fclose(fid);
dlmwrite(outFilePerformance, [sum(hits) sum(hTotal) sum(falseAlarms) sum(fTotal)], '-append');
fid = fopen(outFilePerformance, 'a');
fprintf(fid, 'Percentages\n');
fprintf(fid, '%.3f,,%.3f,', 100*(sum(hits)/sum(hTotal)), 100*(sum(falseAlarms)/sum(fTotal)));
fclose(fid);    