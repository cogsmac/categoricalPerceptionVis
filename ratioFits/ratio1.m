%  This is the master function for the psychophysical experiment wherein
%  participants compare the value of two pairs of graphed values. It is a
%  simple same/different task. The value of the stimulus presented for
%  "different" trials differs based upon user performance. This is a
%  staircasing design set up to figure out if there are different
%  perceptual thresholds for different ratio values. 
%
%  There are two major conditions in this early version: the 'barGraphType'
%  where the ratios are always relative to a bar that represents the value
%  of 1. 
%
%  The second condition is mostly a control. Instead of using a ratio, it's
%  just a single bar. The bars are the same that are used in the
%  'barGraphType' tasks, but there is NO reference bar, so functionally
%  participants aren't seeing a ratio. Consider this condition,
%  'barOnlyType', the control for the experiment.
%
function ratio1(subID)
%
%  Author: Caitlyn McColeman
%  Date Created: Feburary 26 2018
%  Last Edit: March 4 2018
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: ratio1
%
%  INPUT: subID, integer; the identifer for this participant
%
%  OUTPUT: saves .mat & .txt files to current directory. The .txt file is a
%            tab delimited file, with one row per trial. It should be
%            sufficient more most anaylses. In the event that additional
%            information is required, though, the .mat file from each trial
%            is saved too so everything that was a variable in
%            that trial is available if need be. 
%
%  Additional Comments:
%       Broadly, the workflow is
%           1) set stimulus values
%           2) present stimuli
%           3) record accuracy
%           4) adjust staircase
%           5) terminate upon meeting threshold/timing out
%           6) save data
%
%  Additional Scripts Used:
%           1) Quest package (distributed via psychtoolbox) TODO: add
%                   citations
%           2) ratio1StimulusVals.m, positionRef.m, barGraphType.m
%           3) saveTrialData_barGraphType.m
%           4) Quest package 
%           5) NA
%           6) saveTrialData_barGraphType.m


%% 1) set stimlus values

% Clear the workspace and the screen
sca;
close all;

debugMode = 0; % toggle to 1 for development

if debugMode
    subID = 1; %#ok<UNRCH> % the debug subject ID will overwrite input to avoid errors
end

% Basic experiment parameters
nMinutes = 22; % maximum duration
trialPerBlock = 100;

experimentOpenTime = tic; testIfTimeUp = 0;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% keyboard information
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;  %#ok<*ASGLU>
kbPointer = keyboardIndices(end);  %#ok<*NASGU>
KbName('UnifyKeyNames');

% Get the screen numbers
screens = Screen('Screens');
Screen('Preference', 'SkipSyncTests', 1)

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
lightGrey = [.75 .75 .75];

% Open an on screen window
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, lightGrey);%, [1 1 1200 750]);
Screen('Resolution', windowPtr);
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);

% get some details about the presentation size
positionOptions = positionRef([screenXpixels, screenYpixels]);

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% Retreive the maximum priority number and set max priority
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);

% Using Scarfe's waitframe method to improve timing accuracy
flipSecs = .75;
waitframes = round(flipSecs / ifi);

HideCursor() % get rid of mouse cursor 

% which ratios are we testing?
ratioArrayOpts = [ % comments indicate values that will be used in exp 2 if warrented
    .50, 1;
    %.55, 1;
    .60, 1;
    %.45, 1;
    .40, 1;
    1, .50;
    % 1, .55;
    1, .60;
    % 1, .45;
    1, .40]; %one staircase for each of these; n = 6 for 20 mins exp

% which are we comparing to? (What doesn't change in psychophysical
% function trials)?
isReferenceBar = ratioArrayOpts == 1;

presentedRatio = ratioArrayOpts; % initialize

% what type of stimulus are we doing the same/different task with?
possibleStimTypes = {'barGraphType', 'barOnlyType'}; condChooser = randperm(2);
stimType = possibleStimTypes{condChooser(1)};

% preparing logging variables
sameOrDiffTitle = {'same', 'different'};
sameOrDiffResp  = {'f'   , 'j'};

% allow only task-relevant responses
allowedResponses = [KbName(sameOrDiffResp{1}) KbName(sameOrDiffResp{2})];
ret = RestrictKeysForKbCheck([allowedResponses 44]); % also 44 for spacebar

% set-up intial psychometric values for Quest
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
guessThreshold = log(.1);
guessSD = 3;

% one fit for each ratio match
qu=table;
for i = 1:length(ratioArrayOpts)
    qu.(i)=QuestCreate(guessThreshold,guessSD,pThreshold,beta,delta,gamma);
    qu.(i).normalizePdf=1;
    qu.(i).referenceRatio = ratioArrayOpts(i,:);
end

%% Start experiment loop

try
    endExp = 0; % escape condition
    trialIterator = 0; % count how many trials we've done
    %% 2) stimulus presentation
    while ~endExp && (testIfTimeUp < 60*nMinutes)
        
        % clear screen
        Screen('FillRect', windowPtr, lightGrey);
        trialIterator = trialIterator + 1;
        
        trialOnset = Screen('Flip', windowPtr);
        
        % add fixation cross
        fixationCross = '+';
        % Horizontally and vertically centered:
        [nx, ny, bbox] = DrawFormattedText(windowPtr, fixationCross, 'center', 'center', 0);
        
        
        % Flip to the screen (wait just three frames)
        fixationOnset = Screen('Flip', windowPtr, trialOnset + 3 * ifi);
        
        WaitSecs(.020)
        % set up trial 
        ratioArrayIdx = randi([1 length(ratioArrayOpts)],1,1); % which ratio difference (how different is each bar)?
        
        position = randi([1 9], 1, 2); %  first stimulus is presented in position(1). 9 possible positions
        
        sameOrDiffRand  = randperm(2);
        sameOrDiffTrial = sameOrDiffTitle{sameOrDiffRand(1)};
        sameOrDiffCorr  = sameOrDiffResp{sameOrDiffRand(1)};
        
        presentationOrder = randperm(2); % which are we changing? 1 indicates the given ratio value; 2 indicates the one changing in response to threshold
        Screen('FillRect', windowPtr, lightGrey);
        % get the rectangle data
        [refRect, refHeights]=barGraphType(ratioArrayOpts(ratioArrayIdx,:), position(1), [screenXpixels, screenYpixels], stimType, isReferenceBar(ratioArrayIdx,:));
        
        if strcmpi('same', sameOrDiffTrial)
            % the thresholded, comparison; one will always be 1, one will
            % be some proportion
            bar1Val = ratioArrayOpts(ratioArrayIdx,1); % first bar, redundantly save data
            bar2Val = ratioArrayOpts(ratioArrayIdx,2); % second bar
            
            % get the same rectangle stimuli as refRect, but different x positions
            [stimRect, stimHeights]=barGraphType(ratioArrayOpts(ratioArrayIdx,:), position(1), [screenXpixels, screenYpixels], stimType, isReferenceBar(ratioArrayIdx,:));
            
        else
            % get the suggested values from quest object (tTest is log intensity)
            tTest=QuestQuantile(qu.(ratioArrayIdx));
            tTest=min(-log(.999),max(log(0.001),tTest)); % constrain to ratio values
            
            % convert log value from tTest to linear value for
            % presentedRatio; add the exp(tTest) to the reference ratio
            presentedRatio(ratioArrayIdx, ~isReferenceBar(ratioArrayIdx,:)) = ...
                ratioArrayOpts(ratioArrayIdx, ~isReferenceBar(ratioArrayIdx,:)) + exp(tTest);
            
            % the thresholded, comparison; one will always be 1, one will
            % be some proportion
            bar1Val = presentedRatio(ratioArrayIdx,1); % first bar, redundantly save data
            bar2Val = presentedRatio(ratioArrayIdx,2); % second bar
            [stimRect, rectHeights]= barGraphType(presentedRatio(ratioArrayIdx,:), position(1), [screenXpixels, screenYpixels], stimType, isReferenceBar(ratioArrayIdx,:));
        end
        
        if debugMode
            display([bar1Val bar2Val]) %#ok<UNRCH>
            [nx, ny, bbox] = DrawFormattedText(windowPtr, num2str(trialIterator), 'center', 'center', 0);
            
        end
        
        % present the first item
        if presentationOrder(1) == 2
            % first stimulus is the manipulated, psychophysical one
            Screen('FillRect', windowPtr, lightGrey/2, stimRect);
        else
            % first stimulus is the reference one
            Screen('FillRect', windowPtr, lightGrey/2, refRect);
        end
        
        % push to screen. note vbl is stimulus one onset time and marks removal of fixation cross.
        stimulus1Onset = Screen('Flip', windowPtr, fixationOnset + (waitframes - 0.5) * ifi);
        
        % blank between stimuli
        Screen('FillRect', windowPtr, lightGrey);
        stimulus1Offset = Screen('Flip', windowPtr, stimulus1Onset + (waitframes - 0.5) * ifi);
        
        if debugMode
            display(refHeights) %#ok<UNRCH>
        end
        % present the second item
        if presentationOrder(2) == 2
            % second stimulus is the manipulated, psychophysical one
            Screen('FillRect', windowPtr, lightGrey/2, stimRect);
        else
            % second stimulus is the reference one
            Screen('FillRect', windowPtr, lightGrey/2, refRect);
        end
        
        if debugMode
            sameOrDiffCorr %#ok<UNRCH>
        end
        
        % ... wait for waitframes to pass and flip the second stimulus
        stimulus2Onset = Screen('Flip', windowPtr, stimulus1Offset + (waitframes/4 - 0.5) * ifi);
        Screen('FillRect', windowPtr, lightGrey);
        % ... wait for waitframes to pass and flip the response prompt
        responsePrompt([screenXpixels, screenYpixels], windowPtr)
        
        %% 3) get response
        trialAcc = NaN; % set to 1 if they're right; 0 if they're wrong. Leave NaN for missed response.
        touch = 0;
        
        commandwindow; % record key presses outside of experiment in command line so code doesn't get messy
        
        promptOnset = Screen('Flip', windowPtr, stimulus2Onset + (waitframes - 0.5) * ifi);
        responseOnset = tic; % should the same as prompOnset; coding for safe redundancy/checking
        while ~touch
            % Sleep one millisecond after each check, so we don't
            % overload the system in Rush or Priority > 0
            WaitSecs(0.001);
            [touch, secs, keycode,timingChk] = KbCheck(kbPointer);
            recordedAnswer = KbName(keycode);
        end
        responseTime = toc(responseOnset);
        
        if strcmpi(sameOrDiffCorr, recordedAnswer)
            trialAcc = 1;
            
            % Color the screen
            Screen('FillRect', windowPtr, [0 255 0]);
            
        else
            trialAcc = 0;
            
            Screen('FillRect', windowPtr, [255 0 0]);
        end
        
        % feedback is a flash 1/8 the duration of stimulus presentation
        feedbackOnset = Screen('Flip', windowPtr, secs + (waitframes/8 - 0.5) * ifi);
        
        currentRatio = presentedRatio(ratioArrayIdx,:);
        %% 4) adjust staircase
        if strcmpi('different', sameOrDiffTrial)
            
            % Update the pdf
            qu.(ratioArrayIdx)=QuestUpdate(qu.(ratioArrayIdx),tTest,trialAcc); % Add the new datum (actual test intensity and observer response) to the database.
            
        end
        %% 5) check thresholds
        
        % temporal threshold
        testIfTimeUp=toc(experimentOpenTime);
        testIfTimeUp < nMinutes; %#ok<VUNUS>
        
        % escape if time is up or accuracy is as good as it can be
        Screen('FillRect', windowPtr, lightGrey);
        trialEnd = Screen('Flip', windowPtr, feedbackOnset + (waitframes/8 - 0.5) * ifi);
        
        % save data at trial lvl
        saveTrialData_barGraphType(subID, stimType, trialIterator, sameOrDiffTrial, recordedAnswer, trialAcc, ratioArrayOpts, ratioArrayIdx, qu.(ratioArrayIdx), currentRatio, stimRect, refRect, presentationOrder)
        
        % for piloting, save whole .mat file
        save(['sub' num2str(subID) 'trial' num2str(trialIterator) '.mat'])
        
        % check if it's time for a block break
        if trialIterator>0 && mod(trialIterator, trialPerBlock)==0
            
            remainingTime = round(nMinutes - testIfTimeUp/60);
            % take a break
            blockText([screenXpixels, screenYpixels], windowPtr, kbPointer, remainingTime)
            
        end
        
    end
    %% 6) save final experiment level data
    exitText([screenXpixels, screenYpixels], windowPtr)
    WaitSecs(20)
    sca;
    
catch %#ok<*CTCH> In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.  Importantly, it closes the onscreen windowPtr if it's open.
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end

