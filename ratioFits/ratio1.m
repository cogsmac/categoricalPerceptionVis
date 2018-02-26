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
%           1)
%           2) ratio1StimulusVals.m


%% 1) set stimlus values

% intialize psych toolbox
% get environment info
% Here we call some default settings for setting up Psychtoolbox

% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,[0 0 640 480]);

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
flipSecs = 1;
waitframes = round(flipSecs / ifi);

% hard coding first example for development
%[firstRectangle, secondRectangle] = ratio1StimulusVals(ratioArrayOpts(1), {'position', 1}, [screenXpixels, screenYpixels]);

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

% initialize psychometric search for each of the ratioArrayOpts.
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
tGuess = 1; tGuessSD = 4; % from demo. [TO DO] come up with actual values.
for i = 1:length(ratioArrayOpts)
    qu(i) = QuestCreate(tGuess,tGuessSD,pThreshold,beta,delta,gamma);
    qu(i).normalizePdf=1;
end

% staircase settings
%% 2) stimulus presentation

% set up trial 
ratioArrayIdx = randi([1 10],1,1); % which ratio difference (how different is each bar)?



% [TO DO] use ratio array values to inform the stimulus presentation

% Draw the rect to the screen
Screen('FillRect', windowPtr, [255 100 0], [50 100 150 600]);
Screen('FillRect', windowPtr, [255 100 0], [400 100 500 600]);
vbl  = Screen('Flip', windowPtr);



%% 3) get response
trialAcc = NaN; % set to 1 if they're right; 0 if they're wrong. Leave NaN for missed response.

commandwindow; % bring command window up front in case something funky happens/avoid writing to script.

%touch = 1;
%{
while touch==1
    [touch, secs, keycode] = KbCheck;
    % Sleep one millisecond after each check, so we don't
    % overload the system in Rush or Priority > 0
    WaitSecs(0.001);
end
%}
touch = 0;
i=0;
while ~touch
    % Sleep one millisecond after each check, so we don't
    % overload the system in Rush or Priority > 0
    WaitSecs(0.001);
    [touch, secs, keycode] = KbCheck;
    recordedAnswer = KbName(keycode);
    %{
    if i==50 % I don't know why this works but it does. [TODO] fix this.
        fprintf('\n');
        i=0;
    end
    i=i+1;
    %}
end
clc; % clear command window, removing any typed characters


% determine accuracy. Hardcoded for development.
correctAnswer = 'f';


if strcmpi(correctAnswer, recordedAnswer)
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

%% 5) check thresholds

% temporal threshold

% accuracy threshold

% escape if time is up or accuracy is as good as it can be

%% 6) save final experiment level data


%% end

% exit

pause(2) %
% Clear the screen.
sca;

