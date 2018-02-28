%  This saves data to a text file. Minimizes chances of data loss over
%  saving at the end of the experiment.
%
function saveTrialData_barGraphType(subID, ...  participantID
    stimType, ...  comparisonTask
    trialIterator, ... trialID
    sameOrDiffTrial, ... sameOrDiffTrial
    recordedAnswer, ... letterResponse
    trialAcc, ... accuracy
    ratioArrayIdx, ... % whichRatio
    questObject, ... % for the SA (staircase analysis) variables
    presentedRatio... % presentedRatio; stimulus value in ratio space
    ) 

%
%  Author: Caitlyn McColeman
%  Date Created: Feb 28 2018
%  Last Edit:
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For:
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
%                                                  ratioArrayOpts to determine reference values
%      % formatting text file %
varNames_BA = {'participantID', 'comparisonTask', 'trialID', 'sameOrDiffTrial', 'letterResponse', 'accuracy', 'whichRatio'};
varTypes_BA = ['     %s \t           %s \t          %u \t          %s \t           %s \t           %u \t         %u \t  '];
dataIn_BA   = { num2str(subID)     stimType     trialIterator  sameOrDiffTrial  recordedAnswer    trialAcc   ratioArrayIdx};
%
%
%       [TO DO - rt variables and onset timing]
%
%
%       % STAIRCASE ANALYSIS VARIABLES % save only for "different" trials
qu = questObject; 
%              testedRatio, decimal; qu.(ratioArrayIdx).referenceRatio
%       ratioPresentations, integer; qu.(ratioArrayIdx).trialCount
%        abstractIntensity, decimal; qu.(ratioArrayIdx).intensity(qu.(ratioArrayIdx).trialCount)
%   `       presentedRatio, decimal; [TODO calculated in experiment file and offered as input to this function]
%       estimatedThreshold, decimal; qu.(ratioArrayIdx).xThreshold
%                 response, logical; qu.(ratioArrayIdx).response
%            quantileOrder, decimal; qu.(ratioArrayIdx).quantileOrder
%
%      % formatting text file %
varNames_SA = {          'testedRatio',             'nRatioPresentations',                          'abstractIntensity',                      'presentedRatio',        'estimatedThreshold',                     'response',                    'quantileOrder'    };
varTypes_SA = [             '%1.6f \t                       %d \t                                          %3.6f \t                                 %s \t                     %3.6f \t                             %u \t                          %1.6f \t'        ];
dataIn_SA   = {qu.(ratioArrayIdx).referenceRatio qu.(ratioArrayIdx).trialCount  qu.(ratioArrayIdx).intensity(qu.(ratioArrayIdx).trialCount)  mat2str(presentedRatio)  qu.(ratioArrayIdx).xThreshold   qu.(ratioArrayIdx).response  qu.(ratioArrayIdx).quantileOrder};
%
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
%  OUTPUT: [Insert Outputs of this script]
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments:


% Open/create a script named after this subject; spec. permission to append
fID = fopen([ num2str(subID) 'trialLvl.tsv'], 'a');
fprintf(fID, [varTypes_BA varTypes_SA '\r\n'], [dataIn_BA{:} dataIn_SA{:}]); % save data
fclose(fID); % close the file connection 


