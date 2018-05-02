%  Building upon the psychophysics studies ratio1 and ratio2...
%  This is a similar idea, but instead of same/different task, participants
%  will adjust the stimulus to match what they saw previously.
%
%  There are four within-subjects conditions
%       a) the 'barGraphType' where the ratios are always relative to a bar
%          that represents the value of 1.
%       b) the 'stackedType' which is a stacked bar graph, plotting the
%          value relative to the value of 1 as a darker grey
%       c) the 'stackedAcross' bar graph which is the same as above but
%          varies in the horizontal extent
%       d) the 'barOnly' condition to act as a control and ensure the
%          effects are due to ratio judgements and not a consequence of the
%          number of pixels
%
function ratio4(subID)
%
%  Author: Caitlyn McColeman
%  Date Created: May 2 2018
%  Last Edit:
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: Deep Perception project series
%
%  INPUT: subID, integer; the identifer for this participant
%
%  OUTPUT: saves .mat & .txt files to the adjustment_data directory.
%            The .txt file is a tab delimited file, with one row per trial.
%            It should be sufficient more most anaylses. In the event that
%            more information is required, though, the .mat file from each
%            trial is saved too so everything that was a variable in
%            that trial is available if need be.
%
%  Additional Comments:
%       Broadly, the workflow is [TODO] update the steps highlighted by %%
%                                       to match these numbers
%           1) set stimulus values
%           2) present stimuli
%           3) allow adjustment/collect response
%           4) record response
%           6) save data
%
%  Additional Scripts Used: [TODO] update when the code's finished to
%                                  accurately reflect what this calls
%           1) Quest package (distributed via psychtoolbox) TODO: add
%                   citations
%           2) positionRef.m, barGraphType.m
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
nMinutes = 50; % maximum duration
trialPerBlock = 100;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% keyboard, mouse information
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;  %#ok<*ASGLU>
[mouseIndices, productNames, allInfo] = GetMouseIndices;

kbPointer = keyboardIndices(end);  %#ok<*NASGU>
mousePntr = mouseIndices(end);

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

experimentOpenTime = tic; testIfTimeUp = 0;

% Open an on screen window
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, lightGrey, [1 1 1200 750]);
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

% which ratios are we testing?
changingVal = .01:.01:.99; % finer resolution in adjustment study than in the psychophysics one because we aren't staircasing
constantVal = ones(length(changingVal),1);

ratioArrayOpts = [[changingVal' constantVal ]; % test value,      reference value,
    [constantVal changingVal' ]];% reference value, test value

% which are we comparing to?
isReferenceBar = ratioArrayOpts(:,1:2) == 1;

% permute the order of trials. We'll do this again after each block.
p = randperm(100,100);

% preparing logging variables
sameOrDiffTrial = 'adjust';

% allow only task-relevant responses [TODO] probably just want "enter" when
% they're done
% ret = RestrictKeysForKbCheck([32 44 40 37 77 88]); % spacebar, return and enter for OSx and PC. only tested on mac

% make sure we're in the right place in the directory so that stuff saves
% to the proper location
whereAmI  = mfilename('fullpath') ;
toLastDir = regexp(whereAmI, '.*\/', 'match') ;% get directory only (exclude file name)
toLastDir = toLastDir{1}; % extract string from cell
cd(toLastDir) % move to directory containing the file. Think of it as home base.

userBuffer = 40; %pixels; give a little extra room past the edges to improve usability

expCumulPts = 0; %initalize point earnings

% add reminder for interface. Occurs in position 5 -- center of screen.
instructionTxt = 'Press space to advance';

%% Start experiment loop

try
    
    endExp = 0; % escape condition
    trialIterator = 0; % count how many trials we've done
    
    
    % figure out the order of presentation
    blockOrderIdx = randperm(4,4);
    
    % what type of stimulus are we doing the same/different task with?
    possibleStimTypes = {'barGraphType', 'stackedType', 'barOnly', 'stackedAcross'};
    for b = blockOrderIdx
        % the type of graph for this block
        stimType = possibleStimTypes{b};
        
        %% 2) stimulus presentation
        while ~endExp && (testIfTimeUp < 60*nMinutes)
            
            % clear screen
            Screen('FillRect', windowPtr, lightGrey);
            trialIterator = trialIterator + 1;
            
            trialOnset = Screen('Flip', windowPtr);
            HideCursor() % get rid of mouse cursor
            
            % add fixation cross
            fixationCross = '+';
            % Horizontally and vertically centered:
            [nx, ny, bbox] = DrawFormattedText(windowPtr, fixationCross, 'center', 'center', 0);
            
            % Flip to the screen (wait just three frames)
            fixationOnset = Screen('Flip', windowPtr, trialOnset + 3 * ifi);
            
            WaitSecs(.020)
            % set up trial
            %ratioArrayIdx = randi([1 length(ratioArrayOpts)],1,1); % which ratio difference (how different is each bar)?
            if trialIterator <= length(p)
                ratioArrayIdx = p(trialIterator);
            else
                
                findRow = mod(trialIterator, length(p));
                ratioArrayIdx = p(trialIterator);
            end
            
            position = datasample([1:4, 6:9],2,'Replace',false); % save center (position 5) for reminder, "hit enter to advance"
            
            Screen('FillRect', windowPtr, lightGrey);
            
            % get the rectangle data
            [refRect, refHeights]  =barGraphType(ratioArrayOpts(ratioArrayIdx,:), position(1), [screenXpixels, screenYpixels], stimType, isReferenceBar(ratioArrayIdx,:));
            [stimRect, stimHeights]=barGraphType(ratioArrayOpts(ratioArrayIdx,:), position(2), [screenXpixels, screenYpixels], stimType, isReferenceBar(ratioArrayIdx,:));
            
            % make sure we don't draw a negative rectangle
            impossibleIdx = stimRect(4,:) <= stimRect(2,:);
            
            if sum(impossibleIdx) > 0
                stimRect(2, impossibleIdx) = stimRect(4,impossibleIdx) - 1;
            end
            
            if debugMode
                display([bar1Val bar2Val]) %#ok<UNRCH>
                [nx, ny, bbox] = DrawFormattedText(windowPtr, num2str(trialIterator), 'center', 'center', 0);
                
            end
            
            if ~strcmpi(stimType, 'stackedType')
                % present the first item
                Screen('FillRect', windowPtr, lightGrey/2, refRect);
            else % run seperate function to draw the stacked bar graphs
                
                % first stimulus, position(1) [todo make sure this saves like we expect it to]
                plotValueRect  =  stimRect(:, ~isReferenceBar(ratioArrayIdx,:));
                fullRangeRect2 =  stimRect(:,  isReferenceBar(ratioArrayIdx,:));
                
                % re-present reference rectangle
                referenceRect  =  refRect(:, ~isReferenceBar(ratioArrayIdx,:));
                fullRangeRect  =  refRect(:,  isReferenceBar(ratioArrayIdx,:));
                
                % first stimulus is the manipulated, psychophysical one
                drawStackedGraph(fullRangeRect2, plotValueRect, windowPtr, lightGrey/2)
            end
            
            % push to screen. note vbl is stimulus one onset time and marks removal of fixation cross.
            stimulus1Onset = Screen('Flip', windowPtr, fixationOnset + (waitframes - 0.5) * ifi);
            
            % blank between stimulus presentation and response
            Screen('FillRect', windowPtr, lightGrey);
            stimulus1Offset = Screen('Flip', windowPtr, stimulus1Onset + (waitframes - 0.5) * ifi);
            
            advancePressed = 0; % will turn to one when enter/return is pressed on keyboard
            
            % initialize values for while loop
            keycode =0; hasBeenAdjusted = 0;
            
            responseAdjustmentRec = [];
            commandwindow;
            
            % present the reference bar and allow response [TODO] record final cursor position
            ShowCursor('arrow')
            if ~strcmpi(stimType, 'stackedType') % this is the bar graph one
                % draw reference bar
                drawRect = stimRect(:, ~isReferenceBar(ratioArrayIdx,:));
                % draw response bar
                updatedRect = drawRect; updatedRect(2)=updatedRect(4)-1; % a one-pixel high rectangle to start
                Screen('FillRect', windowPtr, lightGrey/2, updatedRect);
            else % run seperate function to draw the stacked bar graphs
                
                updatedRect = fullRangeRect; updatedRect(2)=updatedRect(4)-1; % a one-pixel high rectangle to start
                % draw reference bar, response bar
                drawStackedGraph(fullRangeRect, updatedRect, windowPtr, lightGrey/2)
            end
            % start RT counter
            responseOnset = Screen('Flip', windowPtr, stimulus1Offset + waitframes/8 * ifi);
            
            %% 3) get response
            trialAcc = NaN; % set to 1 if they're right; 0 if they're wrong. Leave NaN for missed response.
            touch = 0;
            
            mouseSampler = 0;
            
            responseOnsetTic = tic; % should the same as prompOnset; coding for safe redundancy/checking
            while sum(keycode)==0 % present stimuli, and wait for the user to press enter to advance.
                
                [touch, secs, keycode, timingChk] = KbCheck(kbPointer);
                keyIn = KbName(keycode);
                
                [x,y,buttons,focus,valuators,valinfo] = GetMouse();
                
                if ~strcmpi(stimType, 'stackedType')
                    % draw the reference bar (ratio = 1)
                    Screen('FillRect', windowPtr, lightGrey/2, stimRect(:,isReferenceBar(ratioArrayIdx,:)));
                    % prep conditions to update the rectangle
                    inAdjustmentRegion = x>stimRect(1, ~isReferenceBar(ratioArrayIdx,:)) && x<stimRect(3, ~isReferenceBar(ratioArrayIdx,:));
                    
                else
                    drawStackedGraph(fullRangeRect, updatedRect, windowPtr, lightGrey/2)
                    inAdjustmentRegion = x>fullRangeRect(1) && x<fullRangeRect(3);
                end
                %Screen('Flip', windowPtr, stimulus1Offset + (waitframes - 0.5) * ifi) % show the reference bar
                
                weHaveSomethingToDraw = hasBeenAdjusted;
                buttonDown = sum(buttons)>0;
                
                % update the drawn rectangle/show a cross hair to indicate
                % that it can be adjusted
                [hasBeenAdjusted, updatedRect] = mouseAdjustment(inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, updatedRect, y, windowPtr, lightGrey);
                
                if hasBeenAdjusted
                    mouseSampler = mouseSampler + 1; % keep track of iterations
                    adjustOnset(mouseSampler) = Screen('Flip', windowPtr, stimulus1Offset + (waitframes - 0.5) * ifi);
                    % Horizontally and vertically centered:
                    [nx, ny, bbox] = DrawFormattedText(windowPtr, instructionTxt, 'center', 'center', 0);
                    
                    % record the value of the drawn rectangle this millisecond
                    responseAdjustmentRec = [responseAdjustmentRec updatedRect];
                end
                WaitSecs(0.001); % avoid overloading the system on checks, update keyboard and mouse status each millisecond
            end
            responseTime = toc(responseOnsetTic);
            
            Screen('FillRect', windowPtr, lightGrey);
            
            %% Feedback
            if ~strcmpi(stimType, 'stackedType')
                % draw the reference bar (ratio = 1)
                Screen('FillRect', windowPtr, lightGrey/2, stimRect(:,isReferenceBar(ratioArrayIdx,:)));
            end
            
            originalYVals= stimRect([2,4],~isReferenceBar(ratioArrayIdx,:));
            drawnYVals= updatedRect([2,4]);
            
            %errorPxScale = presented - drawn
            errorPxScale = (originalYVals(2)-originalYVals(1)) - (drawnYVals(2)-drawnYVals(1));
            
            % distance between drawn proportion and actually presented
            % proportion
            errorRatioScale = sum(errorPxScale/abs(diff(stimRect([1,3],isReferenceBar(ratioArrayIdx,:)))));
            
            pointsScaled = 25-round(abs(errorRatioScale*100),1);
            
            feedbackTxt = [ num2str(pointsScaled) ' points']; % best possible is 25 pts
            
            % total number of points from the start of the experiment
            expCumulPts = expCumulPts + pointsScaled;
            
            DrawFormattedText(windowPtr, feedbackTxt, 'center', 'center', 0);
            
            feedbackOnset = Screen('Flip', windowPtr, adjustOnset(end) + (waitframes/8 - 0.5) * ifi);
            %% 6) check thresholds
            
            % temporal threshold
            testIfTimeUp=toc(experimentOpenTime);
            testIfTimeUp < nMinutes; %#ok<VUNUS>
            
            % escape if time is up or accuracy is as good as it can be
            Screen('FillRect', windowPtr, lightGrey);
            trialEnd = Screen('Flip', windowPtr, feedbackOnset + (waitframes - 0.5) * ifi);
            
            % save data at trial lvl
            whoAmIFile = mfilename;
            
            % save whole .mat file so that we can dig into the adjustment
            % history
            save(['../' whoAmIFile '_data/' whoAmIFile 'sub' num2str(subID) 'trial' num2str(trialIterator) '.mat'])
            remainingTime = round(nMinutes - testIfTimeUp/60);
            
            % check if it's time for a block break
            if trialIterator>0 && mod(trialIterator, trialPerBlock)==0
                % take a break
                blockTextAdjustment([screenXpixels, screenYpixels], windowPtr, kbPointer, remainingTime, expCumulPts)
                
                % permutate the trial order again
                p = randperm(100,100);
            end
            
            saveTrialData_barGraphType(subID, stimType, trialIterator, sameOrDiffTrial, 'Y', errorRatioScale, ratioArrayOpts, experimentOpenTime, fixationOnset, stimulus1Onset, stimulus1Offset, responseOnset, adjustOnset(1), responseTime, feedbackOnset, remainingTime, trialEnd, ratioArrayIdx, [], ratioArrayOpts(ratioArrayIdx,:), stimRect, refRect, [NaN NaN], whoAmIFile)
            
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

