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
    propCases = NaN(41, 7);
    
    % Values are E, RCP, superMode, advantage, growth penalty, start, bleachTarget
    
    %propCases(2, :) = [0, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=0, OA=0
    %propCases(3, :) = [0, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=0, OA=0
    %propCases(4, :) = [1, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=1, OA=0
    %propCases(5, :) = [1, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=1, OA=0
    propCases(6, :) = [1, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=1, OA=1
    propCases(7, :) = [1, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=1, OA=1
    
    propCases(8, :) = [0, 26, 9, 0, 0, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(9, :) = [0, 45, 9, 0, 0, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(10, :) = [0, 60, 9, 0, 0, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(11, :) = [0, 85, 9, 0, 0, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(12, :) = [1, 26, 9, 0, 0, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(13, :) = [1, 45, 9, 0, 0, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(14, :) = [1, 60, 9, 0, 0, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(15, :) = [1, 85, 9, 0, 0, 1861, 5]; % RCP 8.5, E=1, OA=0
    
    propCases(16, :) = [0, 26, 9, 1, 0.25, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(17, :) = [0, 45, 9, 1, 0.25, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(18, :) = [0, 60, 9, 1, 0.25, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(19, :) = [0, 85, 9, 1, 0.25, 1861, 5]; % RCP 8.5, E=0, OA=0
    
    propCases(20, :) = [0, 26, 9, 1, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(21, :) = [0, 45, 9, 1, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(22, :) = [0, 60, 9, 1, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(23, :) = [0, 85, 9, 1, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(24, :) = [1, 26, 9, 1, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(25, :) = [1, 45, 9, 1, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(26, :) = [1, 60, 9, 1, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(27, :) = [1, 85, 9, 1, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0
    
    propCases(28, :) = [0, 26, 9, 1.5, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(29, :) = [0, 45, 9, 1.5, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(30, :) = [0, 60, 9, 1.5, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(31, :) = [0, 85, 9, 1.5, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(32, :) = [1, 26, 9, 1.5, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(33, :) = [1, 45, 9, 1.5, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(34, :) = [1, 60, 9, 1.5, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(35, :) = [1, 85, 9, 1.5, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0
    
    %propCases(36, :) = [0, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=0, OA=0
    %propCases(37, :) = [0, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=0, OA=0
    %propCases(38, :) = [1, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=1, OA=0
    %propCases(39, :) = [1, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=1, OA=0
    propCases(40, :) = [1, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=1, OA=1
    propCases(41, :) = [1, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=1, OA=1
    
    % Build special cases where a single value is returned for all cases
    % which differ only in RCP value.
    % All are for a target bleaching value of 5.  OA = 0 unless specified.
    propCases(50, :) = [0, 0, 9, 0, 0, 1861, 5]; % E=0, no advantage
    propCases(51, :) = [1, 0, 9, 0, 0, 1861, 5]; % E=1, no advantage
    propCases(52, :) = [0, 0, 9, 1, 0.25, 1861, 5]; % E=0, 1.0 advantage, penalty 0.25
    propCases(53, :) = [0, 0, 9, 1, 0.5, 1861, 5]; % E=0, 1.0 advantage, penalty 0.5   
    propCases(54, :) = [1, 0, 9, 1, 0.5, 1861, 5]; % E=1, 1.0 advantage, penalty 0.5
    propCases(55, :) = [0, 0, 9, 1.5, 0.5, 1861, 5]; % E=0, 1.5 advantage, penalty 0.5
    propCases(56, :) = [1, 0, 9, 1.5, 0.5, 1861, 5]; % E=1, 1.5 advantage, penalty 0.5
    propCases(57, :) = [0, 0, 9, 0.5, 0.5, 1861, 5]; % E=0, 0.5 advantage, penalty 0.5
    propCases(58, :) = [1, 0, 9, 0.5, 0.5, 1861, 5]; % E=1, 0.5 advantage, penalty 0.5

    % Symbiont advantage of 0.5 C in these cases:
    propCases(60, :) = [0, 26, 9, 0.5, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(61, :) = [0, 45, 9, 0.5, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(62, :) = [0, 60, 9, 0.5, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(63, :) = [0, 85, 9, 0.5, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(64, :) = [1, 26, 9, 0.5, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(65, :) = [1, 45, 9, 0.5, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(66, :) = [1, 60, 9, 0.5, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(67, :) = [1, 85, 9, 0.5, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0







    %% Now select the matching case (if any) based on input parameters
    % (E, RCP, superMode, advantage, start, bleachTarget)
    % Before doing the logic, make some adjustments to the inputs.
    % Make RCP an integer.
    if RCP == "average"
        rcpNum = 0;
    else
        rcpNum = str2num(replace(RCP, 'rcp', ''));
    end
    % If nothing happens before 2010, the symbiont options can all be zero.
    % startYear is a vector, one per reef.  If there are diverse values, this
    % will require a new "s" for each case.  If there is just one, we can use
    % it as a single value.
    if (max(startYear) == min(startYear)) || min(startYear) > 2010
        startYear = startYear(1);
    else
        error("There is currently no support for interventions starting at a variety of years before 2011.");
    end
    
    % Collapse to equivalent cases.
    if advantage == 0
        superGrowthPenalty = 0;
    end
    if startYear > 2010
        advantage = 0;
        superGrowthPenalty = 0;
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
    % If there is zero advantage or mode is zero, we don't care about
    % growth penalty or start year.
    if superMode == 0 || advantage == 0.0
        propTest = find(eee & rrr & sss & aaa & bbb);
    else
        propTest = find(eee & rrr & sss & aaa & ggg & yyy & bbb);
    end
    if size(propTest) > 1
        error('propTest is not uniquely specified by E = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    elseif isempty(propTest) | size(propTest) == 0 | propTest == 0
            error('propTest is not defined for E = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    end
    return;
end
