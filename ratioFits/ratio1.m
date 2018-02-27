%  This is the master function for the psychophysical experiment wherein
%  participants compare the value of two pairs of graphed values. It is a
%  simple same/different task.
%
%  Author: Caitlyn McColeman
%  Date Created: Feburary 26 2018
%  Last Edit:
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: [Insert Name of Project]
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: [Insert Function Inputs here (if any)]
%
%  OUTPUT: [Insert Outputs of this script]
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
%           2) ratio1StimulusVals.m


%% 1) set stimlus values

% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
kbPointer = keyboardIndices(end);
KbName('UnifyKeyNames');

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, [.75 .75 .75], [1 1 900 500]);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);

% get some details about the presentation size
positionOptions = positionRef([screenXpixels, screenYpixels]);

% Figure out which keyboard to listen to
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
kbPointer = keyboardIndices(end);
% Unify keycode to keyname mapping across operating systems:
KbName('UnifyKeyNames');

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% Retreive the maximum priority number and set max priority
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);

% Here we use to a waitframes number greater then 1 to flip at a rate not
% equal to the monitors refreash rate. For this example, once per second,
% to the nearest frame
flipSecs = .75;
waitframes = round(flipSecs / ifi); % for the presentation of the two stimuli

% hard coded for development
ratioArrayOpts = [
    .50, 1;
    .55, 1;
    .60, 1;
    .45, 1;
    .40, 1;
    1, .50;
    1, .55;
    1, .60;
    1, .45;
    1, .40]; %one staircase for each of these

% which are we comparing to? (What doesn't change in psychophysical
% function trials)?
isReferenceBar = ratioArrayOpts == 1;

% staircase settings
randJitter = rand(length(ratioArrayOpts),2)/100; % very little bit of noise. Essentially impossible to start.
randJitter(isReferenceBar==1)=0;
presentedRatio = ratioArrayOpts+randJitter; % will update with multiple trials

% what type of stimulus are we doing the same/different task with?
stimType = 'barGraphType';

% preparing logging variables
sameOrDiffTitle = {'same', 'different'};
sameOrDiffResp  = {'f'   , 'j'};

%% Start experiment loop

try
    endExp = 0; % escape condition
    
    %% 2) stimulus presentation
    while ~endExp
        
        % fixation cross [TODO: formatting]
        vbl = Screen('Flip', windowPtr);
        
        % set up trial [TODO: make sure each variable here is logged]
        ratioArrayIdx = randi([1 10],1,1); % which ratio difference (how different is each bar)?
        
        position = randi([1 9], 1, 2); %  first stimulus is presented in position1
        
        sameOrDiffRand  = randperm(2);
        sameOrDiffTrial = sameOrDiffTitle{sameOrDiffRand(1)};
        sameOrDiffCorr  = sameOrDiffResp{sameOrDiffRand(1)};
        
        presentationOrder = randperm(2); % which are we changing? 1 indicates the given ratio value; 2 indicates the one changing in response to threshold
        
        if strcmpi(stimType,'barGraphType') % could be 'barGraphType' or 'singleBar' for
            
            % TODO: add a "same" control condition
            
            % the thresholded, comparison; one will always be 1, one will
            % be some proportion
            bar1Val = presentedRatio(ratioArrayIdx,1); % first bar, redundantly save data
            bar2Val = presentedRatio(ratioArrayIdx,2); % second bar
            
            % get the rectangle data
            refRect=barGraphType(ratioArrayOpts(ratioArrayIdx,:), position(1), [screenXpixels, screenYpixels]);
            if strcmpi('same', sameOrDiffTitle)
                stimRect = refRect;
            else
                stimRect = barGraphType(presentedRatio(ratioArrayIdx,:), position(2), [screenXpixels, screenYpixels]);
            end
            
            %{
            % call function to get stimulus size, position, properties of
            % the changing, thresholded stimlus
            [stimRect1, stimRect2] = ratio1StimulusVals(presentedRatio(ratioArrayIdx,:), {'position', position(1)}, [screenXpixels, screenYpixels]);
            %}
            % call function to get stimulus size, position, properties of
            % the reference stimulus
            
            
        end
        
        % present the first item
        if presentationOrder(1) == 2
            % first stimulus is the manipulated, psychophysical one
            Screen('FillRect', windowPtr, [100 100 100], stimRect);
        else
            % first stimulus is the reference one
            Screen('FillRect', windowPtr, [100 100 100], refRect);
        end
        
        % push to screen. note vbl is stimulus one onset time and marks removal of fixation cross.
        % fixation cross is on screen 1/4 the duration of the stimuli.
        vbl = Screen('Flip', windowPtr, vbl + (waitframes/4 - 0.5) * ifi);
        
        % present the second item
        if presentationOrder(2) == 2
            % second stimulus is the manipulated, psychophysical one
            Screen('FillRect', windowPtr, [100 100 100], stimRect);
        else
            % second stimulus is the reference one
            Screen('FillRect', windowPtr, [100 100 100], refRect);
        end
        
        % ... wait for waitframes to pass and flip the second stimulus
        WaitSecs(.5) % TODO use a proper timing method via Peter Scafe PTB demo
        vbl2 = Screen('Flip', windowPtr);
        
        % ... wait for waitframes to pass and flip the response prompt
        responsePrompt([screenXpixels, screenYpixels], windowPtr)
        WaitSecs(.5)
        vbl3 = Screen('Flip', windowPtr);
        
        %% 3) get response
        trialAcc = NaN; % set to 1 if they're right; 0 if they're wrong. Leave NaN for missed response.
        
        touch = 0;
        
        commandwindow
        while ~touch
            % Sleep one millisecond after each check, so we don't
            % overload the system in Rush or Priority > 0
            WaitSecs(0.001);
            [touch, secs, keycode,timingChk] = KbCheck(kbPointer);
            recordedAnswer = KbName(keycode);
            beep % for dev [TODO] remove beep
        end
        clc; % clear command window, removing any typed characters
        
        
        if strcmpi(sameOrDiffCorr, recordedAnswer)
            trialAcc = 1;
        else
            trialAcc = 0;
        end
        
        % [TODO] some visual confirmation of response
        
        %% 4) adjust staircase
        
        % [TODO] at this point we'll have determined which ratioArrayOpts we're on.
        % This is presently hardcoded for development.
        ratioArrayIdx = 1; % points to the staircase that we're fitting
        
        tTest=QuestQuantile(qu(ratioArrayIdx));
        % Update the pdf
        qu(ratioArrayIdx)=QuestUpdate(qu(ratioArrayIdx),tTest,trialAcc); % Add the new datum (actual test intensity and observer response) to the database.
        
        % output of the QuestUpdate to inform the stimulus presentation.
        presentedRatio(ratioArrayIdx, ~isReferenceBar(ratioArrayIdx))=qu(ratioArrayIdx).intensity(qu(ratioArrayIdx).trialCount);
        
        %% 5) check thresholds
        
        % temporal threshold
        
        % accuracy threshold
        
        % escape if time is up or accuracy is as good as it can be
        
        %% 6) save final experiment level data
        
        endExp = 1;
        %% end
    end
    
    % exit
catch %#ok<*CTCH> In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.  Importantly, it closes the onscreen windowPtr if it's open.
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end

