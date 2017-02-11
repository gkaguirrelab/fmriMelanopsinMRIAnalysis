nTrials = 25;
nAttentionTaskTrials = 3;
nTrialsWithAttentionTask = nTrials+nAttentionTaskTrials;

seq_orig = [3,2,4,0,3,1,1,0,4,4,2,0,0,2,2,3,4,1,3,0,1,2,1,4,3];

seq1 = mod(seq_orig, 5)+1;
seq2 = mod(seq_orig+1, 5)+1;
seq3 = mod(seq_orig+2, 5)+1;
seq4 = mod(seq_orig+3, 5)+1;

phaseInd = repmat([1 2 3], 1, 10);
phaseInd = phaseInd(1:28);
phaseSeq1 = Shuffle(phaseInd);
phaseSeq2 = Shuffle(phaseInd);
phaseSeq3 = Shuffle(phaseInd);
phaseSeq4 = Shuffle(phaseInd);

%% Sequence 1
theSeq = 1;

theFrequencyIndices = ones(1, nTrialsWithAttentionTask);
trialDuration = 16*ones(1, nTrialsWithAttentionTask);
idx1 = 1:attnTask(1)-1;
idx2 = attnTask(1)+1:attnTask(2)-1;
idx3 = attnTask(2)+1:attnTask(3)-1;
idx4 = attnTask(3)+1:nTrialsWithAttentionTask;
switch theSeq
    case 1
        theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq1;
        thePhaseIndices = phaseSeq4;
    case 2
        theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq2;
        thePhaseIndices = phaseSeq4;
    case 3
        theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq3;
        thePhaseIndices = phaseSeq4;
    case 4
        theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq4;
        thePhaseIndices = phaseSeq4;
end
attnTask = randperm(nTrialsWithAttentionTask); attnTask = sort(attnTask(1:nAttentionTaskTrials));
theDirections = ones(1, nTrialsWithAttentionTask);
theDirections(attnTask) = 2;
theContrastRelMaxIndices = ones(1, nTrialsWithAttentionTask);

idx1 = 1:attnTask(1)-1;
idx2 = attnTask(1)+1:attnTask(2)-1;
idx3 = attnTask(2)+1:attnTask(3)-1;
idx4 = attnTask(3)+1:nTrialsWithAttentionTask;
theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq4;

fprintf('theFrequencyIndices:d:[');
for ii = 1:nTrialsWithAttentionTask
    fprintf('%g ', theFrequencyIndices(ii));
end
fprintf(']:Sequence of indices into frequency\n');
fprintf('thePhaseIndices:d:[');
for ii = 1:nTrialsWithAttentionTask
    fprintf('%g ', thePhaseIndices(ii));
end
fprintf(']:Sequence of indices into phase\n');
fprintf('theDirections:d:[');
for ii = 1:nTrialsWithAttentionTask
    fprintf('%g ', theDirections(ii));
end
fprintf(']:Sequence of indices into direction\n');
fprintf('theContrastRelMaxIndices:d:[');
for ii = 1:nTrialsWithAttentionTask
    fprintf('%g ', theContrastRelMaxIndices(ii));
end
fprintf(']:Sequence of indices into contrast scalar\n');
fprintf('trialDuration:d:d:[');
for ii = 1:nTrialsWithAttentionTask
    fprintf('%g ', trialDuration(ii));
end
fprintf(']:Trial durations\n');