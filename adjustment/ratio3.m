%  Building upon the psychophysics studies ratio1 and ratio2... 
%  This is a similar idea, but instead of same/different task, participants
%  will adjust the stimulus to match what they saw previously.
%
%  There are two major conditions.
%       a) the 'barGraphType' where the ratios are always relative to a bar 
%          that represents the value of 1. 
%       b) A new condition, one where the participants see a bar and it's
%          partially filled depending upon the ratio value
%
function ratio3(subID)
%
%  Author: Caitlyn McColeman
%  Date Created: March 23 2018
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

% which ratios are we testing?
changingVal = .01:.01:.99; % finer resolution in adjustment study than in the psychophysics one because we aren't staircasing
constantVal = ones(length(changingVal),1);

ratioArrayOpts = [[changingVal' constantVal ]; % test value,      reference value,  
                  [constantVal changingVal' ]];% reference value, test value

% which are we comparing to?
isReferenceBar = ratioArrayOpts(:,1:2) == 1;

presentedRatio = ratioArrayOpts; % initialize [TODO] Kill all presented ratio

% what type of stimulus are we doing the same/different task with?
possibleStimTypes = {'barGraphType', 'stackedType'}; 
      condChooser = randperm(length(possibleStimTypes));
         stimType = possibleStimTypes{condChooser(1)};

         
         stimType = 'barGraphType'
% preparing logging variables % this is where the structure departs [TODO]
sameOrDiffTitle = {'same', 'different'};
sameOrDiffResp  = {'f'   , 'j'};

% allow only task-relevant responses [TODO] probably just want "enter" when
% they're done
allowedResponses = [KbName(sameOrDiffResp{1}) KbName(sameOrDiffResp{2})];
ret = RestrictKeysForKbCheck([32 44 40 37 77 88]); % spacebar, return and enter for OSx and PC. only tested on mac

% make sure we're in the right place in the directory so that stuff saves
% to the proper location
whereAmI  = mfilename('fullpath') ;
toLastDir = regexp(whereAmI, '.*\/', 'match') ;% get directory only (exclude file name)
toLastDir = toLastDir{1}; % extract string from cell
cd(toLastDir) % move to directory containing the file. Think of it as home base.

userBuffer = 40; %pixels; give a little extra room past the edges to improve usability

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
        HideCursor() % get rid of mouse cursor 
        
        % add fixation cross
        fixationCross = '+';
        % Horizontally and vertically centered:
        [nx, ny, bbox] = DrawFormattedText(windowPtr, fixationCross, 'center', 'center', 0);
        
        % Flip to the screen (wait just three frames)
        fixationOnset = Screen('Flip', windowPtr, trialOnset + 3 * ifi);
        
        WaitSecs(.020)
        % set up trial 
        ratioArrayIdx = randi([1 length(ratioArrayOpts)],1,1); % which ratio difference (how different is each bar)?
        
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
            % first stimulus is the manipulated, psychophysical one
            Screen('FillRect', windowPtr, lightGrey/2, stimRect);
        else % run seperate function to draw the stacked bar graphs
            plotValueRect = stimRect(:, ~isReferenceBar(ratioArrayIdx,:));
            referenceRect =  refRect(:, ~isReferenceBar(ratioArrayIdx,:));
            fullRangeRect = stimRect(:,  isReferenceBar(ratioArrayIdx,:));
            % first stimulus is the manipulated, psychophysical one
            drawStackedGraph(fullRangeRect, plotValueRect, windowPtr, lightGrey/2)
        end
        
        % push to screen. note vbl is stimulus one onset time and marks removal of fixation cross.
        stimulus1Onset = Screen('Flip', windowPtr, fixationOnset + (waitframes - 0.5) * ifi);
        
        % blank between stimulus presentation and response
        Screen('FillRect', windowPtr, lightGrey);
        stimulus1Offset = Screen('Flip', windowPtr, stimulus1Onset + (waitframes - 0.5) * ifi);
        
        
        % ... wait for waitframes to pass and begin the response phase
        advancePressed = 0; % will turn to one when enter/return is pressed on keyboard
        
        % initialize values for while loop
        keycode =0; hasBeenAdjusted = 0;
        
        % present the reference bar and allow response [TODO] record final cursor position
        ShowCursor('arrow')
        if ~strcmpi(stimType, 'stackedType') % this is the bar graph one
            
            drawRect = stimRect(:, ~isReferenceBar(ratioArrayIdx,:));
            % start RT counter
            responseOnset = Screen('Flip', windowPtr, stimulus1Offset + waitframes/8 * ifi);
            commandwindow;
            while ~sum(keycode)>0
                % draw the reference bar (ratio = 1)
                Screen('FillRect', windowPtr, lightGrey/2, stimRect(:,isReferenceBar(ratioArrayIdx,:)));
                
                [x,y,buttons,focus,valuators,valinfo] = GetMouse();
                
                % prep conditions to update the rectangel
                    inAdjustmentRegion = x>stimRect(1, ~isReferenceBar(ratioArrayIdx,:)) && x<stimRect(3, ~isReferenceBar(ratioArrayIdx,:));
                 weHaveSomethingToDraw = hasBeenAdjusted;
                            buttonDown = sum(buttons)>0;
                        adjustableRect = drawRect;
                
                % update the drawn rectangle/show a cross hair to indicate
                % that it can be adjusted 
                % [TODO] clean this up in a separate function
                
                [hasBeenAdjusted, updatedRect] = mouseAdjustment(inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, adjustableRect, y, windowPtr, lightGrey);
               %{
                if x>stimRect(1, ~isReferenceBar(ratioArrayIdx,:)) && x<stimRect(3, ~isReferenceBar(ratioArrayIdx,:)) && sum(buttons)>0
                    hasBeenAdjusted = 1;
                    % update the adjusted rectangle
                    drawRect(2) = min(y, drawRect(4));
                    
                    ShowCursor('CrossHair')
                    Screen('FillRect', windowPtr, lightGrey/2, drawRect);
                
                elseif hasBeenAdjusted && x>stimRect(1, ~isReferenceBar(ratioArrayIdx,:)) && x<stimRect(3, ~isReferenceBar(ratioArrayIdx,:))
                    ShowCursor('CrossHair')
                    % keep the most recent adjusted rectangle on screen
                    Screen('FillRect', windowPtr, lightGrey/2, drawRect);
                
                elseif x>stimRect(1, ~isReferenceBar(ratioArrayIdx,:)) && x<stimRect(3, ~isReferenceBar(ratioArrayIdx,:))
                    % no current action, but in the region to make one. show cross
                    % hair
                    ShowCursor('CrossHair')
                    
                elseif hasBeenAdjusted
                    % no current action, outside of region to adjust
                    Screen('FillRect', windowPtr, lightGrey/2, drawRect);
                    ShowCursor('Arrow')
                else
                    % no action (current or past), not in the region to
                    % adjust 
                    ShowCursor('Arrow')
                end
                %}
                
                % add reminder for interface. Occurs in position 5 -- center of screen.
                instructionTxt = 'Press enter to advance';
                
                % Horizontally and vertically centered:
                [nx, ny, bbox] = DrawFormattedText(windowPtr, instructionTxt, 'center', 'center', 0);
                
                [touch, secs, keycode, timingChk] = KbCheck(kbPointer);
                keyIn = KbName(keycode);
                
                Screen('Flip', windowPtr, stimulus1Offset + waitframes/8 * ifi);
                WaitSecs(0.001); % avoid overloading the system on checks, update keyboard and mouse status each millisecond
                
            end
        else % run seperate function to draw the stacked bar graphs
                % draw reference bar
                drawStackedGraph(fullRangeRect, plotValueRect, windowPtr, lightGrey/2)
            % [TODO] while loop for mouse adjustment for the second
            % rectangle
                fullRangeRect = refRect(:,  isReferenceBar(ratioArrayIdx,:));
                % [TODO] second input here needs to be the rectangle corresponding to the user-drawn one.
                drawStackedGraph(fullRangeRect, referenceRect, windowPtr, lightGrey/2)

        end
        
        if debugMode
            sameOrDiffCorr %#ok<UNRCH>
        end
        
      
        Screen('FillRect', windowPtr, lightGrey);
        % ... wait for waitframes to pass and flip the response prompt
        responsePrompt([screenXpixels, screenYpixels], windowPtr)
        
        %% 3) get response
        trialAcc = NaN; % set to 1 if they're right; 0 if they're wrong. Leave NaN for missed response.
        touch = 0;
        
        commandwindow; % record key presses outside of experiment in command line so code doesn't get messy
        
        promptOnset = Screen('Flip', windowPtr, stimulus1Offset + (waitframes - 0.5) * ifi);
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
        whoAmIFile = mfilename;
        
        % for piloting, save whole .mat file
        save(['../ratioFits_data2/' whoAmIFile 'sub' num2str(subID) 'trial' num2str(trialIterator) '.mat'])
        remainingTime = round(nMinutes - testIfTimeUp/60);
        
        % check if it's time for a block break
        if trialIterator>0 && mod(trialIterator, trialPerBlock)==0
            % take a break
            blockText([screenXpixels, screenYpixels], windowPtr, kbPointer, remainingTime)
        end
        
        saveTrialData_barGraphType(subID, stimType, trialIterator, sameOrDiffTrial, recordedAnswer, trialAcc, ratioArrayOpts, experimentOpenTime, fixationOnset, stimulus1Onset, stimulus1Offset, stimulus2Onset, promptOnset, responseTime, feedbackOnset, remainingTime, trialEnd, ratioArrayIdx, qu.(ratioArrayIdx), currentRatio, stimRect, refRect, presentationOrder, whoAmIFile)
        
        
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

