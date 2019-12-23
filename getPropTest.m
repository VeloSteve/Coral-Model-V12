% getPropTest selects the correct psw2 column based on a bleaching target
% and (ideally) any model change which could affect bleaching prior to 2010.
% These factors include
% Evolution on/off
% RCP scenario
% Symbiont shuffling assumptions
%
% A previous version of this used switch statements, but the number of possible
% cases is growing large enough that this is unwieldy.
function [propTest] = getPropTest(E, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget)
    % Default is to run after optimization for a bleaching target of
    % 5% between 1985 and 2010.  The argument can ask for other values.
    if nargin < 7
        bleachTarget = 5;
    end
    propTest = 0; % an undefined case - check at the end.
    % Enumerate all the cases we have values for, and then use the arguments to
    % pick the right one.
    
    % When start is > 2010 there is no effect, so let that match a date of zero.
    % Also, treat "control400" the same as "rcp26".
    % Values are E, RCP, superMode, advantage, start, bleachTarget
    propCases = NaN(64, 7);
    propCases(20, :) = [0, 26, 0, 0, 0, 0, 5];
    propCases(24, :) = [0, 45, 0, 0, 0, 0, 5];
    propCases(25, :) = [0, 60, 0, 0, 0, 0, 5];
    propCases(21, :) = [0, 85, 0, 0, 0, 0, 5];
    propCases(22, :) = [1, 26, 0, 0, 0, 0, 5];
    propCases(26, :) = [1, 45, 0, 0, 0, 0, 5];
    propCases(27, :) = [1, 60, 0, 0, 0, 0, 5];
    propCases(23, :) = [1, 85, 0, 0, 0, 0, 5];
    
    propCases(2, :) = [0, 26, 0, 0, 0, 0, 10];
    propCases(4, :) = [0, 45, 0, 0, 0, 0, 10];
    propCases(6, :) = [0, 60, 0, 0, 0, 0, 10];
    propCases(8, :) = [0, 85, 0, 0, 0, 0, 10];
    propCases(3, :) = [1, 26, 0, 0, 0, 0, 10];
    propCases(5, :) = [1, 45, 0, 0, 0, 0, 10];
    propCases(7, :) = [1, 60, 0, 0, 0, 0, 10];
    propCases(9, :) = [1, 85, 0, 0, 0, 0, 10];
    
    propCases(10, :) = [0, 26, 0, 0, 0, 0, 3];
    propCases(12, :) = [0, 45, 0, 0, 0, 0, 3];
    propCases(14, :) = [0, 60, 0, 0, 0, 0, 3];
    propCases(16, :) = [0, 85, 0, 0, 0, 0, 3];
    propCases(11, :) = [1, 26, 0, 0, 0, 0, 3];
    propCases(13, :) = [1, 45, 0, 0, 0, 0, 3];
    propCases(15, :) = [1, 60, 0, 0, 0, 0, 3];
    propCases(17, :) = [1, 85, 0, 0, 0, 0, 3];
    
    % Start including shuffling cases.  Note that the order of entry is
    % different here, but of course it doesn't matter.
    propCases(28, :) = [0, 26, 9, 1.0, 0.5, 1861, 5];  % RCP 2.6, E=0
    propCases(29, :) = [1, 26, 9, 1.0, 0.5, 1861, 5];  % RCP 2.6, E=1
    propCases(30, :) = [0, 45, 9, 1.0, 0.5, 1861, 5];  % RCP 4.5, E=0
    propCases(31, :) = [1, 45, 9, 1.0, 0.5, 1861, 5];  % RCP 4.5, E=1
    propCases(32, :) = [0, 60, 9, 1.0, 0.5, 1861, 5];  % RCP 6.0, E=0
    propCases(33, :) = [1, 60, 9, 1.0, 0.5, 1861, 5];  % RCP 6.0, E=1
    propCases(34, :) = [0, 85, 9, 1.0, 0.5, 1861, 5];  % RCP 8.5, E=0
    propCases(35, :) = [1, 85, 9, 1.0, 0.5, 1861, 5];  % RCP 8.5, E=1

    % Shuffling, but with advantage = 1.5C
    propCases(36, :) = [1, 26, 9, 1.5, 0.5, 1861, 5];  % RCP 8.5, E=1
    
    % And now with a shuffling growth penalty of 0.25, rather than 0.5.
    % This was previously not a variable.
    propCases(44, :) = [1, 26, 9, 1.5, 0.25, 1861, 5];  % RCP 8.5, E=1
    
    propCases(52, :) = [1, 26, 9, 1.0, 0.25, 1861, 5];  % RCP 8.5, E=1
    % Values: (E, RCP, superMode, superAdvantage, superGrowthPenalty, startYear, bleachTarget)
    
    %% Now select the matching case (if any) based on input parameters
    % (E, RCP, superMode, advantage, start, bleachTarget)
    % Before doing the logic, make some adjustments to the inputs.
    % Make RCP an integer.
    rcpNum = str2num(replace(RCP, 'rcp', ''));
    % If nothing happens before 2010, the symbiont options can all be zero.
    % startYear is a vector, one per reef.  If there are diverse values, this
    % will require a new "s" for each case.  If there is just one, we can use
    % it as a single value.
    if (max(startYear) == min(startYear)) || min(startYear) > 2010
        startYear = startYear(1);
    else
        error("There is currently no support for interventions starting at a variety of years before 2011.");
    end
    
    if (advantage == 0) || (startYear > 2010)
        superMode = 0;
        advantage = 0;
        startYear = 0;
    end
    % This could be done in one line of code, but this is easier for beginners.
    % With thousands of entries this could also be slow, but it's insignificant
    % with only dozens.
    eee = propCases(:, 1) == E;
    rrr = propCases(:, 2) == rcpNum;
    sss = propCases(:, 3) == superMode;
    aaa = propCases(:, 4) == advantage;
    ggg = propCases(:, 5) == superGrowthPenalty;
    yyy = propCases(:, 6) == startYear;
    bbb = propCases(:, 7) == bleachTarget;
    propTest = find(eee & rrr & sss & aaa & ggg & yyy & bbb);
    if size(propTest) > 1
        error('propTest is not uniquely specified by E = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    elseif size(propTest) == 0 | propTest == 0
            error('propTest is not defined for E = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    end
    return;
end
