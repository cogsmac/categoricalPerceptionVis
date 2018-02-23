%  Thinking about categorical perception and a study for it more
%  systematically; consider how we want the potential stimuli to differ and
%  the ranges covered in the data display.
%
%  Author: Caitlyn McColeman
%  Date Created: Feb 22 2018
%  Last Edit: [Last Time of Edit]
%
%  Visual Thining Lab, Northwestern University
%  Originally Created For: categorical perception pilot
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:
%
%  OUTPUT: a quick plot looking at the ranges covered
%
%  Additional Scripts Used: [Insert all scripts called on]
%
%  Additional Comments: For project scoping only.
%       assumes...
%       - that the smallest difference we care about is 1/16
%

% ratios of interest:
% [1/2 1/4 1/8 1/16]
denominatorArray = [2, 4, 8, 16];


counter = 0;
for i = denominatorArray
    counter= counter+1;
    subtractionArray(counter) = 1/i;
end

% note that we also want to consider the whole range stometimes too (i.e.
% 1)
fullSet = [1 subtractionArray 0];

% these values will cover the span of options ranging 0 to 1; will not
% offer options WITHIN quadrant though
basicCategoryStim = nchoosek(fullSet,2);
basicCategoryStim = [basicCategoryStim; 1-basicCategoryStim];

% get within hemi-set
lowerWithinStim  = nchoosek(subtractionArray,2);% .5 and all the categorical values below
upperWithinStim  = 1-lowerWithinStim; % .5 and all the categorical values above

% concatenate stimulus values for the CATEGORY trials
categoryTrialsVals = [basicCategoryStim; lowerWithinStim; upperWithinStim];

% off category set
%rng(007) % set seed [so it's "random" as far as my expectations are, but we can get teh same stim set]
startRandSet = rand(round(length(categoryTrialsVals)/length(subtractionArray)),1); % generate set of random numbers

% take the less-than-full-range set and use that to set the second value of
% the startRandSet. The idea is that we'll be able to compare the ranges
% between the two sets (random, category) but the initialized locations
% will be random.
nonCategoryTrialsVals2 = []; % intialize storage
nonCategoryTrialsVals1 = [];
for i = [.75 subtractionArray]
    
    % repeat starting vector so that we have an initial value
    nonCategoryTrialsVals1 = [nonCategoryTrialsVals1; startRandSet];
    
    % subtract
    nonCategoryTrialsVals2 = [nonCategoryTrialsVals2; startRandSet - i];
    
    
    % repeat starting vector so that we have an initial value
    nonCategoryTrialsVals1 = [nonCategoryTrialsVals1; startRandSet];
    
    % and add ranges to mirror
    nonCategoryTrialsVals2 = [nonCategoryTrialsVals2; startRandSet + i];
end

nonCategoryTrialsVals = [nonCategoryTrialsVals1 nonCategoryTrialsVals2];

% filter out impossible values (<0 or >1)
nonCategoryTrialsVals(nonCategoryTrialsVals(:,2)<0,:)=[];
nonCategoryTrialsVals(nonCategoryTrialsVals(:,2)>1,:)=[];

%{
for i = 1:length(startRandSet)
    secondVal = Inf;
   
    % three conditions for inclusion: positive, less than 1, and more than
    % 1/16 different than the first value
    
    %{
    ~((secondVal - startRandSet(i) > 0) && ...
            (startRandSet(i) - secondVal < 1) &&...
            (abs(startRandSet(i) - secondVal) >= 1/16) && ...
            isfinite(secondVal))
    %}
    
    while (abs(startRandSet(i) - secondVal) >= 1/16) && ...
            ~isfinite(secondVal)
        
        secondVal = rand;
    end
    
    startRandSet(i,2)=secondVal;
end
%}
%% visualize

% check the ranges
   categoryTrRange = categoryTrialsVals(:,1)   - categoryTrialsVals(:,2);
nonCategoryTrRange = nonCategoryTrialsVals(:,1)- nonCategoryTrialsVals(:,2);

figure
subplot(1,2,1)
hist(categoryTrRange, 20)
subplot(1,2,2)
hist(nonCategoryTrRange, 20)


% make sure the random values look random
figure; hist(startRandSet); title('random values')

% category trials
categoryTrialsVals = sort(categoryTrialsVals, 'desc');
figure;
subplot(1,2,1) % categorical values
for i = 1:length(categoryTrialsVals)
    line(categoryTrialsVals(i,:), [i i]);
end
title('on category boundaries')
% off-category trials 
nonCategoryTrialsVals = sort(nonCategoryTrialsVals, 'desc');
subplot(1,2,2) % categorical values
for i = 1:length(nonCategoryTrialsVals)
    line(nonCategoryTrialsVals(i,:), [i i]);
end
title('off category boundaries')