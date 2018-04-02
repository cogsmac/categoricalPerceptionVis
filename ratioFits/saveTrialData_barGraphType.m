%  This saves data to a text file. Minimizes chances of data loss over
%  saving at the end of the experiment.
%
function saveTrialData_barGraphType(...
    ... % basic analysis variables
    subID, ...  participantID
    stimType, ...  comparisonTask
    trialIterator, ... trialID
    sameOrDiffTrial, ... sameOrDiffTrial
    recordedAnswer, ... letterResponse
    trialAcc, ... accuracy
    ratioArrayOpts, ... on "same" trials, ratioArrayOpts(ratioArrayIdx) is the presented value
    ... % timing
    experimentStart, ...
    fixationOnset, ...
    stimulus1Onset, ...
    ISIOnset, ...
    stimulus2Onset, ...
    promptOnset, ...
    responseTime, ...
    feedbackOnset, ...
    timeFromStart, ...
    trialEnd, ...
    ... % reproducibility
    ratioArrayIdx, ... % whichRatio
    questObject, ... % for the SA (staircase analysis) variables
    presentedRatio,... % presentedRatio; stimulus value in ratio space
    stimRect, ... % [x1 y1 x2 y2]; the rectangle values for the manipulated stim
    refRect,... % [x1 y1 x2 y2]; the rectangle values for the reference stim
    presentationOrder, ...
    whoAmIFile)

%
%  Author: Caitlyn McColeman
%  Date Created: Feb 28 2018
%  Last Edit:  March 20 2018
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: ratio1
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:
%
%       % BASIC ANALYSIS VARIABLES %
%
%       participantID, string; subID             - new trial. who dis?
%      comparisonTask, string; stimType          - what task are they doing?
%            trialID, integer; trialIterator     - what trial number
%    sameOrDiffTrial,  string; sameOrDiffTrial   - match/non-match
%     letterResponse,  string; recordedAnswer    - the actual button pressed
%           accuracy, logical; trialAcc          - correct/incorrect response
%         whichRatio, integer; ratioArrayIdx     - a way to index into
%                                                  ratioArrayOpts to determine reference value
%
%       % TIMING ANALYSIS VARIABLES %
%
%      experimentStart, float; experimentOpenTime - when did this all kick off? [uint64, computer time]
%        fixationOnset, float; fixationOnset      - start of fixation
%       stimulus1Onset, float; stimulus1Onset     - start of stimulus
%                                                   presentation (first item)
%             ISIOnset, float; stimulus2Offset    - the start of the blank
%                                                   between stimulus 1 and 2
%       stimulus2Onset, float; stimulus2Onset     - start of stimulus
%                                                   presentation (second item)
%          promptOnset, float; responsePromptOn   - start of self-paced
%                                                   response phase
%         responseTime, float; responseTime       - time to say "same" or
%                                                   "different"
%        feedbackOnset, float; feedbackOnset      - start of red/green
%                                                   flash
%        timeFromStart, float; testIfTimeUp       - "toc" from "tic" on
%                                                   experimentStart
%             trialEnd, float; trialEnd           - vbl from last screen
%                                                   flip
%
%       % STAIRCASE ANALYSIS VARIABLES % save only for "different" trials
%
%              testedRatio, decimal; qu.referenceRatio
%       ratioPresentations, integer; qu.trialCount
%        abstractIntensity, decimal; qu.intensity(qu.trialCount)
%   `       presentedRatio, decimal; [TODO calculated in experiment file and offered as input to this function]
%       estimatedThreshold, decimal; qu.xThreshold
%                 response, logical; qu.response
%            quantileOrder, decimal; qu.quantileOrder
%
%       % DETAIL METHOD VARIABLES % for debugging and re-drawing stimuli as
%                                   needed
%
%         stimRectLeft, string; mat2str(stimRect(:,1))
%        stimRectRight, string; mat2str(stimRect(:,2))
%          refRectLeft, string; mat2str(refRect(:,1))
%         refRectRight, string; mat2str(refRect(:,2))
%    presentationOrder, string; mat2str(presentationOrder)

if strcmpi(whoAmIFile, 'ratio2.m')
    directionOfChange = presentedRatio(1,3);
else
    directionOfChange = 1;
end

% basic analysis
varNames_BA = {'participantID', 'comparisonTask', 'trialID', 'sameOrDiffTrial', 'letterResponse', 'accuracy', 'whichRatio'};
varTypes_BA = ['     %s\t           %s\t             %u\t           %s\t             %s\t           %d\t         %d\t  '];
dataIn_BA   = { num2str(subID)     stimType     trialIterator  sameOrDiffTrial  recordedAnswer    trialAcc   ratioArrayIdx};

% timing analysis
varNames_Time = {'experimentStart', 'fixationOnset','stimulus1Onset','ISIOnset','stimulus2Onset', 'promptOnset','responseTime', 'feedbackOnset', 'timeFromStart', 'trialEnd'};
varTypes_Time = ['  %15.1f\t'          '%15.1f\t'       '%15.1f\t'   '%15.1f\t'   '%15.1f\t'        '%15.1f\t'     '%15.1f\t'      '%15.1f\t'       '%15.1f\t'    '%15.1f\t'];
  dataIn_Time = { experimentStart  fixationOnset     stimulus1Onset   ISIOnset stimulus2Onset   promptOnset   responseTime    feedbackOnset    timeFromStart    trialEnd };

% staircase analysis
varNames_SA   = { 'testedRatio',       'nRatioPresentations',     'abstractIntensity',       'presentedRatioL', 'presentedRatioR',       'estimatedThreshold', 'estThresholdSD',    'response',          'quantileOrder',        'TTest', 'UpdateDirection'};
if strcmpi(sameOrDiffTrial, 'different')
    qu = questObject;
    tTest = QuestQuantile(qu);
      
      estThreshold = QuestMean(qu);
    estThresholdSD = QuestSd(qu);
    
    dataIn_SA ={mat2str(qu.referenceRatio)        qu.trialCount    qu.intensity(qu.trialCount)  presentedRatio(1) presentedRatio(2)         estThreshold   estThresholdSD   qu.response(qu.trialCount)   qu.quantileOrder       tTest  directionOfChange};
else % qu object will not be updated on 'same' trials. Just save some blank values to hold place
    dataIn_SA ={mat2str(ratioArrayOpts(ratioArrayIdx,:)) NaN            NaN     ratioArrayOpts(ratioArrayIdx,1) ratioArrayOpts(ratioArrayIdx,2)   NaN           NaN                trialAcc                   NaN                NaN          NaN       };
end
varTypes_SA   = [    '%s\t                            %d\t              %3.6f\t                    %3.6f\t          %3.6f\t                    %3.6f\t          %3.6f\t             %u\t                      %1.6f\t            %1.6f\t      %d\t     '  ];

% reproducible trial DEtails
varNames_DE   = { 'StimLeftBarLeft', 'StimLeftBarTop', 'StimLeftBarRight', 'StimLeftBarBottom', 'StimRightBarTop', 'StimRightBarLeft', 'StimRightBarBottom', 'StimRightBarRight', 'refStimOrder'} ;
  dataIn_DE   = {                                                               stimRect(:,1)'                                                                    stimRect(:,2)'   mat2str(presentationOrder)};
varTypes_DE   = [    ' %4.4f\t             %4.4f\t             %4.4f\t          %4.4f\t             %4.4f\t             %4.4f\t             %4.4f\t                 %4.4f\t         %s'  ];

%
%       % DETAIL METHOD VARIABLES %
%
%         stimRectLeft, string; mat2str(stimRect(:,1))
%        stimRectRight, string; mat2str(stimRect(:,2))
%          refRectLeft, string; mat2str(refRect(:,1))
%         refRectRight, string; mat2str(refRect(:,2))
%    presentationOrder, string; mat2str(presentationOrder)
%
%
%  OUTPUT: Saves a .txt file; tab delimited to the data directory
%
%  Additional Scripts Used: 
%
%  Additional Comments:
%       - extended March 16 with whoAmIFile to mark the name of the
%       experiment wrapper that calls this data saving function. This will
%       break the function for ratio1.m.


% Create header row
if ~(exist(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'])==2)
    fID = fopen(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'], 'a+'); % open file
    
    % all the variable names are strings; save as such
    varTypes_names = repmat('%s\t ', 1, length(varNames_BA)+length(varNames_Time)+length(varNames_SA)+length(varNames_DE));
    
    namesIn = {varNames_BA{:} varNames_Time{:} varNames_SA{:} varNames_DE{:}};
    
    % push to file
    fprintf(fID, [varTypes_names '\n'], namesIn{:}); % save data
    
    % close connection to file
    fclose(fID)
end


% Open/create a file named after this subject; spec. permission to append
fID = fopen(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'], 'a+');

dataIn = {dataIn_BA{:} dataIn_Time{:} dataIn_SA{:} dataIn_DE{:}};
fprintf(fID, [varTypes_BA varTypes_Time varTypes_SA varTypes_DE '\n'], dataIn{:}); % save data
fclose(fID); % close the file connection


