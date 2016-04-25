nTrials = 16;
nAttentionTaskTrials = 3;
nTrialsWithAttentionTask = nTrials+nAttentionTaskTrials;

seq_orig = [0,3,3,2,3,1,1,0,2,2,1,3,0,0,1,2];

seq1 = mod(seq_orig, 4)+1;
seq2 = mod(seq_orig+1, 4)+1;
seq3 = mod(seq_orig+2, 4)+1;
seq4 = mod(seq_orig+3, 4)+1;

phaseInd = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 1 2 3 1];
phaseSeq1 = Shuffle(phaseInd);
phaseSeq2 = Shuffle(phaseInd);
phaseSeq3 = Shuffle(phaseInd);
phaseSeq4 = Shuffle(phaseInd);

%% Sequence 1
theFrequencyIndices = ones(1, nTrialsWithAttentionTask);
trialDuration = 16*ones(1, nTrialsWithAttentionTask);
thePhaseIndices = phaseSeq4;
attnTask = randperm(nTrialsWithAttentionTask); attnTask = sort(attnTask(1:nAttentionTaskTrials));
theDirections = ones(1, nTrialsWithAttentionTask);
theDirections(attnTask) = 2;
theContrastRelMaxIndices = ones(1, nTrialsWithAttentionTask);

idx1 = 1:attnTask(1)-1;
idx2 = attnTask(1)+1:attnTask(2)-1;
idx3 = attnTask(2)+1:attnTask(3)-1;
idx4 = attnTask(3)+1:nTrialsWithAttentionTask;
theContrastRelMaxIndices([idx1 idx2 idx3 idx4]) = seq4;

fprintf('theFrequencyIndices:[');
for ii = 1:nTrialsWithAttentionTask
   fprintf('%g ', theFrequencyIndices(ii));
end
fprintf(']:Sequence of indices into frequency\n');
fprintf('thePhaseIndices:[');
for ii = 1:nTrialsWithAttentionTask
   fprintf('%g ', thePhaseIndices(ii));
end
fprintf(']:Sequence of indices into phase\n');
fprintf('theDirections:[');
for ii = 1:nTrialsWithAttentionTask
   fprintf('%g ', theDirections(ii));
end
fprintf(']:Sequence of indices into direction\n');
fprintf('theContrastRelMaxIndices:[');
for ii = 1:nTrialsWithAttentionTask
   fprintf('%g ', theContrastRelMaxIndices(ii));
end
fprintf(']:Sequence of indices into contrast scalar\n');
fprintf('trialDuration:[');
for ii = 1:nTrialsWithAttentionTask
   fprintf('%g ', trialDuration(ii));
end
fprintf(']:Trial durations\n');