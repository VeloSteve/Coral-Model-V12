%% Try to find an optimal equation for the proportionality constant by varying
% up to 4 input variables and trying to maximize a "goodness" score based on
% reef survival and other factors.
%
% Note that this is just a crude stepwise search, with some attempt to search
% near the best values.  I wrote it when new to MATLAB, and before realizing
% how many runs this might take.  Something smarter like MATLAB's fminsearch
% would be worth a try.
%%
optTimerStart = tic;

% Supporting functions are here:
addpath(strcat(pwd, '\optimization_functions'));
% Algorithm options
keepOldResults = false;  % Use results across multiple runs - only valid if model parameters and step sizes don't change.
checkEquals = true;  % When more than one "equal best" is found, check all neighbors.
% Discrete steps for each parameter.  Set to one for constants.
maxSteps = 19; % 7, 13, 19 are useful multiples
boxStart = true;  % Use specified starting points, typically at each corner of the parameter space.  If false, include just one point in the center.
maxRuns = 100;  % Stop after this many runs, if no other stopping condition is reached.
randomStart = 0;  % Number of random looks before starting an organized search.
maxRandomEnd = 26; % Points to check around a possible final point, in case there is a better value on a diagonal. Bug: must be at least 1.
useHoldDirection = true; % Keep going the same way when when a linear search finds a new best.
equalBestTol = 0.05; % Default 0.05 If a new value is this close, treat it as an equal best for checking.

RCP = 'rcp85'; %  MUST MATCH THE MODEL FOR CORRECT SST INPUT!

%% NOTE
% to continue building the plottable result array after a MATLAB restart:
% Do this MANUALLY before the run, otherwise new results won't be
% accumulated:
% load('optResults_1_19_19_19', 'cumResult');
% result = cumResult;
% Note: cumResult may be redundant in the current code.  Consider using
% just "result".
%
%%
% Target values - most values are set up to target zero or a fixed value.
% This is variable:
targetBleaching = 5.0;
%% Possible values for constants in this equation:
% max(0.3,min(1.3,( mean(exp(0.063.*SSThist))./var(exp(0.063.*SSThist)) ).^0.5/11
% where the 0.063 is considered fixed and the other values are known below as
% 0.3 - pMin - the lowest result possible
% 1.3 - pMax - the largest result possible
% 0.5 - exponent
% 11  - div  - the divisor

%% WARNING: pMin is now used to initialize bleachFrac, which determines how sensitive the reefs are to bleaching.
%  the variable names are NOT updated except where they will affect the
%  execution of the main program.

% Try a new way of choosing 4 or fewer variables to optimize from a larger
% set.
% Warning: add variables, but don't renumber, as they are pulled out by
% number before calling the solver.
option{1} = {'bleachFrac', 0.22, 0.225};  % Not normally used.
option{2} = {'pMin', 0.36, 0.36};
option{3} = {'pMax', 1.5, 1.5};
option{4} = {'exponent', 0.46, 0.46}; % Variable "y" in the draft paper.
option{5} = {'div', 7.03, 7.23 };     % Variable "s" in the draft paper.


options = [2, 3, 4, 5]; % Which variables may vary. Okay to include some with steps=1
    A = intersect(options, [1 6:14]);
    assert(isempty(A), 'With pswOnly true, only related parameters are allowed.');

% Steps to actually use for each (1 to hold constant)
steps = [1, 1, maxSteps, maxSteps];

% After this, each option will contain name, min, max, range, and a default
% current value which is equal to min.
for i = 1:length(option)
    option{i}{4} = option{i}{3} - option{i}{2};
    option{i}{5} = option{i}{2};
end

% The variables to optimize - the optimizer doesn't need to know what they
% are, but the correct variables must be set before calling the coral
% model.
possible = {option{options(1)}, option{options(2)}, option{options(3)}, option{options(4)}};

%% Strategy:
% 1) Start by testing some selected points - the center of the parameter
%    space and all the corners.
% 2) Test some random points - in a large parameter space this can find a
%    good starting point faster than linear stepping, and it also has the
%    chance of escaping a local minimum picked up by step 1.
% 3) From the best input point so far:
%   a) Pick one variable and check the next untested value above and below,
%   or skip if the array limits are reached.
%   b) Calulated results are kept, so if we find an already-tested value
%   significantly worse than the best, also skip that direction.
%   c) Any time a new best is found, update and start back from 3.
%   d) Repeat until all 4 variables have been tested.
%   e) Stop when all 8 directions are skipped.
% 4) By now the maxiumum should be near, but since the above search
%    never looks "diagonally", try some random nearby points which have not
%    already been tested to see if any are better.  If an improvement is
%    found, start back at 3 again.
% 5) If maxRuns is exceeded stop even if the above isn't complete.


% Use old results for more speed - for testing only.  This will give
% bad results if model parameters other than psw2 change.
if keepOldResults
    if exist('cumResult', 'var')
        % TODO - check that dimension in cumResult match steps.
        % Load old results so we don't waste time checking old points.
        result = cumResult;
    elseif ~exist('result', 'var')
        result = NaN(steps(1), steps(2), steps(3), steps(4));
    end
else
    % The safe way: start fresh every time:
    clear cumResult;
    clear result;
    result = NaN(steps(1), steps(2), steps(3), steps(4));
end

bestYet = 1000000000;
bestIndex = NaN(1,4);
% There is a problem when a parameter is locally unimportant so that more
% than one point matches the current best value.  A new best may be
% adjacent to one of the points but not to all of them.  It is necessary to
% keep track of all the "equal bests" and check all of their neighbors.  The
% list can be cleared if a new best is found.
equalBests = {};  % All "equally best" coordinates.

clear nextInputs;  % Clears a persistent variable in the function.

disp('Starting optimization runs');
nextVar = 4;    % Search direction - it doesn't matter which is first.
up = false;
runs = 0;

% Build a "box" which hits all the corners of the parameter space, in case
% there's something special there which would make a good starting point.

boxIndex = {};
boxValue = {};
% Manually assign boxes - this assumes the 2nd variable doesn't vary, but
% these points should not be essential to the result anyway.

boxIndex{1} = ceil(steps/2);  % A point right in the center.

% Set ranges for building box indexes.
if boxStart
    boxRange = {};
    for variableI = 1:4
        st = steps(variableI);
        if st == 1
            boxRange{end+1} = [1];
        else
            boxRange{end+1} = [1 ceil(st/2) st];
        end
    end
    % Build the box
    for b4 = boxRange{4}
        for b3 = boxRange{3}
            for b2 = boxRange{2}
                for b1 = boxRange{1}
                    boxIndex{end+1} = [b1 b2 b3 b4];
                end
            end
        end
    end
else
    boxIndex{1} = [ceil(steps(1)/2) ceil(steps(2)/2) ceil(steps(3)/2) ceil(steps(4)/2)]; 
end
% Optionally add extra box entries, typically an informed guess at the
% best value:
%boxIndex{end+1} = [1 16 14 14]; % Example hardwire - watch indexes.
% Careful - overwriting center point above!
%boxIndex{1} = [18 1 8 6]; % Example hardwire - watch indexes.

% Sets of input values based on the indexes.
for boxI = length(boxIndex):-1:1
    boxValue{boxI} = setOptimizationInputs(boxIndex{boxI}, possible, steps);
end

skips = 0;  % count consecutive times an axis and direction must be skipped
maxSkips = 8;
randomEnd = 0;    % random attempts around the best value found by stepping
% Lists of test case summary information for review after each run.
bestList = {};
badList = {}; % not actually bad, just no improvement.
while runs < maxRuns && skips <= maxSkips && randomEnd < maxRandomEnd
    % This big if-else just hold the different was of selecting the next
    % test case.  No coral calculations are done here.
    if ~isempty(boxIndex)
        useIV = true;
        possible = boxValue{end};
        inputIndex = boxIndex{end};
        boxValue(end) = [];
        boxIndex(end) = [];
        good = true;
        stepType = 'Box';
    elseif randomStart > 0
        % Search truly randomly in hopes of a good starting point for the other phases.
        [possible, inputIndex, good] = randomInputs(result, bestIndex, possible, steps, false);
        randomStart = randomStart - 1;
        stepType = 'Full Random';
    elseif skips < maxSkips
        % Search in an organized way along each parameter index
        [possible, inputIndex, good] = nextInputs(result, bestIndex, possible, nextVar, steps, up);
        randomEnd = 0;
        stepType = 'Linear';
    elseif checkEquals && (length(equalBests) > 1)
        % If we've exhausted the point in use (bestIndex) but there are
        % others, move on to those before falling through to the last
        % random checks.
        fprintf('======= equal best code, %d left.\n', length(equalBests));
        skips = 0;
        equalBests(1) = [];  % Must use smooth parens on left, square brackets on right.
        bestIndex = equalBests{1};
        [possible, inputIndex, good] = nextInputs(result, bestIndex, possible, nextVar, steps, up);
        randomEnd = 0;
        stepType = 'Linear Next';
    else
        % Search randomly  around the best known result to capture changes not
        % seen by changing one variable at a time.
        [possible, inputIndex, good] = randomInputs(result, bestIndex, possible, steps, true);
        randomEnd = randomEnd + 1;
        stepType = 'Near Random';
    end
    % possible has been updated, but code below expects to find values in
    % the option array.  Copy the 4 which are in use in possible.
    for i = 1:4
        option{options(i)} = possible{i};
    end

    holdDirection = false;
    if ~good
        skips = skips + 1;
        disp('Skip.');
    else
        if randomEnd == 0
            skips = 0;
        end
        runs = runs + 1;
        %
        % Always active
        propInputValues = [option{2}{5}, option{3}{5}, option{4}{5}, option{5}{5}];
        thisRCP = RCP;
        propConstantCalcsForOptimizer
        assert(strcmp(thisRCP, RCP), 'RCP set for prop calculations %s must not be overwritten by PCCFO setting %s!', thisRCP, RCP);

        multiPlot.active = false;
        try
            [Bleaching_85_10_By_Event, E] = aCoralModel
        catch ME
            if (strcmp(ME.message,'ExcessiveBleaching'))
                Bleaching_85_10_By_Event = 1000.0; % arbitrary large value
            else
                disp('Unexpected error type:');
                disp(ME.identifier);
                rethrow(ME)
            end
        end
        assert(strcmp(thisRCP, RCP), 'RCP set for prop calculations %s must match model setting %s!', thisRCP, RCP);
        %  Original version, using mostly older parameters:
        %[goodness, pg1950, bleach] = goodnessValue(targetBleaching, psw2_new, percentGone, Mort_stats, C_seed, mEvents, reefsThisRun, AvgMortFreq_85_10_SD);
        % Use latest bleaching and mortality values
        [goodness, bleach] = goodnessValue(targetBleaching, psw2_new(:, 1), ...
            Bleaching_85_10_By_Event);
        result(inputIndex(1), inputIndex(2), inputIndex(3), inputIndex(4)) = goodness;
        if goodness < bestYet
            bestIndex = inputIndex;
            if equalBestTol >= abs(goodness - bestYet)
                % Keep old bests as still worth checking, just add the new
                % one.
                equalBests(end+1) = {inputIndex};
            else
                if length(equalBests) > 1
                    disp('======= resetting equal bests ======');
                end
                equalBests = {inputIndex};
            end
            bestYet = goodness;
            beep();
            fprintf('New best of %f at %d, %d, %d, %d \n', bestYet, inputIndex);
            %fprintf('At key reefs: %d %f; %d %f; %d %f; %d %f; %d %f\n', keyReefs(1), psw2_new(keyReefs(1)),  keyReefs(2), psw2_new(keyReefs(2)), keyReefs(3), psw2_new(keyReefs(3)), keyReefs(4), psw2_new(keyReefs(4)), keyReefs(5), psw2_new(keyReefs(5)));
            bestList{end+1} = sprintf('aBest = %f at values %f, %f, %f, and indexes %d %d %d %d  pg = %f, randomEnd = %d \n  psw2 stats: min/mean/max = %d %d %d, variance = %d %s Ko = %f, Mo = %f, VI = %f, Bleach = %f\n', ...
                bestYet, propInputValues, inputIndex, randomEnd, ...
                min(psw2_new(:, 1)), mean(psw2_new(:, 1)), max(psw2_new(:, 1)), var(psw2_new(:, 1)), ...
                stepType, psw2_new(793, 1), psw2_new(144, 1), psw2_new(420, 1), bleach);

            bestList'
            skips = 0;
            randomEnd = 0; 
            if strcmp(stepType, 'Linear') || strcmp(stepType, 'Linear Next')
                holdDirection = true;
            end
            % See progress
            if ~exist('cumResult', 'var')
                cumResult = result;
            else
                cumResult = max(cumResult, result);
            end
            %OptimizationPlot
        else
            %if goodness == bestYet
            if equalBestTol >= abs(goodness - bestYet)
                fprintf('Adding equal best. Now %d .\n', 1+length(equalBests));
                equalBests(end+1) = {inputIndex};
                bestList{end+1} = sprintf('cBest = %f at values %f, %f, %f, and indexes %d %d %d %d  pg = %f, randomEnd = %d \n  psw2 stats: min/mean/max = %d %d %d, variance = %d %s Ko = %f, Mo = %f, VI = %f, Bleach = %f\n', ...
                    bestYet, propInputValues, inputIndex, randomEnd, ...
                    min(psw2_new(:, 1)), mean(psw2_new(:, 1)), max(psw2_new(:, 1)), var(psw2_new(:, 1)), ...
                    stepType, psw2_new(793, 1), psw2_new(144, 1), psw2_new(420, 1), bleach);

            end
            fprintf('No improvement at %d, %d, %d, %d  randomEnd = %d run = %d, bestYet = %f\n', inputIndex, randomEnd, runs, bestYet);
            badList{end+1} = sprintf('Bad  = %f at values %f, %f, %f, %f and indexes %d %d %d %d randomEnd = %d %s\n', ...
                goodness, propInputValues, inputIndex, randomEnd, stepType);

            if ~mod(runs, 10)
                % See progress
                if ~exist('cumResult', 'var')
                    cumResult = result;
                else
                    cumResult = max(cumResult, result);
                end
                %OptimizationPlot
            end
        end
    end
    if ~holdDirection && useHoldDirection
        % Cycle though directions for future loops.  This doesn't apply to all
        % parts of the testing, but it doesn't hurt.
        % Don't cycle if a new best was found during a linear search.
        if ~up
            nextVar = 1+mod(nextVar, 4);
            % If steps is 1 for this variable, move on.
            while steps(nextVar) == 1
                nextVar = 1+mod(nextVar, 4);
            end
        end
        up = ~up;
    end
end
bestList = bestList';
badList = badList';

fprintf('===== Re-run of best case found so lat/lon array is visible =====\n');
multiPlot.active = true;
inputIndex = bestIndex;
possible = setOptimizationInputs(inputIndex, possible, steps);
for i = 1:4
    option{options(i)} = possible{i};
end
propInputValues = [option{2}{5}, option{3}{5}, option{4}{5}, option{5}{5}];
propConstantCalcsForOptimizer

[Bleaching_85_10_By_Event, E] = aCoralModel

fprintf('%s\n', bestList{end});
fprintf('Done in %d runs with skips = %d.\n', runs, skips);
fprintf('Best indexes %d %d %d %d\n', bestIndex);
fprintf('Done with optimization.\n');
load handel.mat;
sound(y);

if ~exist('cumResult', 'var')
    cumResult = result;
else
    cumResult = max(cumResult, result);
end

showBests(cumResult, possible, steps);
optElapsed = toc(optTimerStart);
fprintf('Optimization finished in %7.1f seconds.\n', optElapsed);
fprintf('at %s\n', datestr(now));
psw2Plot(propInputValues, E, RCP, Reefs_latlon(:,2), psw2_new(:,1));

%% A scatter plot of variance values versus latitude.
function psw2Plot(p, E, RCP,X1, Y1)
%CREATEFIGURE(X1, Y1)
%  X1:  scatter x
%  Y1:  scatter y

%  Auto-generated by MATLAB on 17-Jan-2017 12:18:35

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create scatter
scatter(X1,Y1);

% Create xlabel
xlabel({'Latitude'});

% Create title
t = sprintf('psw inputs: %8.4f %8.4f %8.4f %8.4f for %s and E = %d', p, RCP, E);
%title({strcat('psw2 for ', ' ', RCP, ' E= ', num2str(E))});
title(t);

% Create ylabel
ylabel({'Proportionality Constant'});
end
