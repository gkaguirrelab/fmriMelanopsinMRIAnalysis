function [startTimesSorted, stimValuesSorted, attnStartTimes] = SortContrasts(dataDir,subj_name,session)

% SortContrasts
%
% Takes in 3-column format files for all contrasts and orders them
% chronologically. 
% Uses the ordering information to bin entries for 400% 3-columns file in
% the following categories:
% - 400f400
% - 400f200or100
% - 400f050or025
% Three new 3 column files are saved out.
%

% Usage
% =====



% July 2016 - written and commented GF. Derived from Ben Chin's orderStartTimes.m

%% locate stimuli folder

% Define path to folder for one sunject on one date
dirPathStim = fullfile (dataDir, subj_name, session, 'Stimuli');
       
%% Load & Plot Stimulus Step Functions

% Load all contents of Stimulus Directory
stimDirContents = dir(dirPathStim) ;

% Number of Stimulus Folders
numberOfFolders = length(stimDirContents) ;

% Initialize Cell containing all Stimulus folder names
folderNameCell = {} ;

% Loop over numebr of Stimulus folders & create cell with their names
for i = 1:numberOfFolders
   miniFolderName = stimDirContents(i).name ;
   if length(miniFolderName)>4 & strcmp(miniFolderName(1:4),'HERO') ;
       folderNameCell{length(folderNameCell)+1} = miniFolderName ;
   end
end

% Store Stimulus Order A & B
stimValuesSorted_A = [] ;
stimValuesSorted_B = [] ;

startTimesSorted = repmat(-1,[length(folderNameCell) 50]);
stimValuesSorted = repmat(-1,[length(folderNameCell) 50]);
attnStartTimes = repmat(-1,[length(folderNameCell) 50]);

for i = 1:length(folderNameCell)
   % Look in each run's folder
   currentDirPath = [dirPathStim char(folderNameCell(i))] ; 
   % Get all their contents
   runFiles = dir(currentDirPath) ;

   % Initialize Matrices for storing start Times & Stimulus values
   startTimes = [] ;
   stimValues = [] ;

   for j = 1:length(runFiles)
       % LOOK AT EACH FILE
       curFile = runFiles(j).name;

       % We are interested in Hz_all files
       if length(curFile)>10 && strcmp(curFile(length(curFile)-9:length(curFile)),'valid.txt')
          % Extract Temporal Frequency of Stimulus from file name
          stimFile = load([currentDirPath '/' curFile]) ; 
          freqValueTxt = curFile(length(curFile)-11:length(curFile)-10) ;

          % Number (0,2,4,8,16,32,64)-- can be 2-digit or 1-digit
          if str2num(freqValueTxt)
              freqValueNum = str2num(freqValueTxt) ;
          else
              freqValueNum = str2num(freqValueTxt(2)) ;            
          end

          % Grab all values in first column (Starting times)
          curTimeValue = stimFile(:,1) ;
          % Collect all start times and corresponding Stimulus values
          startTimes(length(startTimes)+1:length(startTimes)+length(curTimeValue)) = curTimeValue ;
          stimValues(length(stimValues)+1:length(stimValues)+length(curTimeValue)) = freqValueNum ;         
          
          % If the file contains Attention Task data
%        elseif length(curFile)>20 & strcmp(curFile(length(curFile)-16:length(curFile)),'attentionTask.txt')
%            % load attention file
%            attnFile = load([currentDirPath '/' curFile]) ;
%            
%            attnTimeValuesPreStore = [] ;
%            
%            % collect attention task start times
%            attnTimeValuesPreStore(length(attnTimeValuesPreStore)+1:length(attnTimeValuesPreStore)+length(attnFile(:,1))) = attnFile(:,1)';
%            
%            attnTimeValuesPreStore = sort(attnTimeValuesPreStore);
        end
       
   end
      
   % Sort the Big Vector of Start Times
   [startTimesSortedBeforeStore, stmsInd] = sort(startTimes) ;
   startTimesSorted(i,1:length(startTimesSortedBeforeStore)) = startTimesSortedBeforeStore;
   % Sort Corresponding Stimulus values
   stimValuesSorted(i,1:length(stimValues)) = stimValues(stmsInd) ;
   % store attention start times
%    attnStartTimes(i,1:length(attnTimeValuesPreStore)) = attnTimeValuesPreStore;
end

gribble = 1;