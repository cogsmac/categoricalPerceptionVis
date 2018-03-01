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
%                                                  ratioArrayOpts to determine reference value
%
%
%       [TO DO - rt variables and onset timing]
%
%
%       % STAIRCASE ANALYSIS VARIABLES % save only for "different" trials
%              testedRatio, decimal; qu.referenceRatio
%       ratioPresentations, integer; qu.trialCount
%        abstractIntensity, decimal; qu.intensity(qu.trialCount)
%   `       presentedRatio, decimal; [TODO calculated in experiment file and offered as input to this function]
%       estimatedThreshold, decimal; qu.xThreshold
%                 response, logical; qu.response
%            quantileOrder, decimal; qu.quantileOrder
%
%      % formatting text file %



% basic analysis
varNames_BA = {'participantID', 'comparisonTask', 'trialID', 'sameOrDiffTrial', 'letterResponse', 'accuracy', 'whichRatio'};
varTypes_BA = ['     %s\t           %s\t             %u\t           %s\t             %s\t           %d\t         %d\t  '];
dataIn_BA   = { num2str(subID)     stimType     trialIterator  sameOrDiffTrial  recordedAnswer    trialAcc   ratioArrayIdx};



% staircase analysis
varNames_SA   = { 'testedRatio',       'nRatioPresentations',     'abstractIntensity',       'presentedRatio',          'estimatedThreshold',          'response',          'quantileOrder'};
if strcmpi(sameOrDiffTrial, 'different')
    qu = questObject;
    dataIn_SA ={mat2str(qu.referenceRatio)    qu.trialCount        qu.intensity(qu.trialCount)  mat2str(presentedRatio)    qu.xThreshold     qu.response(qu.trialCount)   qu.quantileOrder  };
else % qu object will not be updated on 'same' trials. Just save some blank values to hold place
    dataIn_SA ={mat2str(presentedRatio)          NaN                         NaN                mat2str(presentedRatio)            NaN                     trialAcc             NaN     };
end
varTypes_SA   = [    '%s\t                  %d\t                     %3.6f\t                    %s\t                       %3.6f\t                     %u\t                    %1.6f '  ];


if ~(exist([num2str(subID) 'trialLvl.txt'])==2)
    fID = fopen([ num2str(subID) 'trialLvl.txt'], 'a+'); % open file
    
    % all the variable names are strings; save as such
    varTypes_names = repmat('%s\t ', 1, length(varNames_BA)+length(varNames_SA));
    
    namesIn = {varNames_BA{:} varNames_SA{:}};
    
    % push to file
    fprintf(fID, [varTypes_names '\n'], namesIn{:}); % save data
    
    % close connection to file
    fclose(fID)
end


% Open/create a file named after this subject; spec. permission to append
fID = fopen([ num2str(subID) 'trialLvl.txt'], 'a+');

dataIn = {dataIn_BA{:} dataIn_SA{:}};
fprintf(fID, [varTypes_BA varTypes_SA  '\n'], dataIn{:}); % save data
fclose(fID); % close the file connection

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




