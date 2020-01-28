% getPropTest selects the correct psw2 column based on a bleaching target
% and (ideally) any model change which could affect bleaching prior to 2010.
% These factors include
% Evolution on/off
% RCP scenario
% Symbiont shuffling assumptions
%
% A previous version of this used switch statements, but the number of possible
% cases is growing large enough that this is unwieldy.
function [propTest] = getPropTest(E, OA, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget)
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
    propCases(120, 8) = 0;
    
    % Programming note: consider storing the required index in an 8-dimensional
    % array, allowing it to be accessed directly without the index logic at the
    % bottom of this function.  Note that most of the dimensions would be of
    % length 2, and rarely more than 4, so that the size would not be excessive.
    
    % Values are E, OA, RCP, superMode, advantage, growth penalty, start, bleachTarget
    propCases(2, :) = [0, 0, 26, 9, 0, 0, 1861, 3]; % RCP 2.6, E=0, OA=0
    propCases(3, :) = [0, 0, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=0, OA=0
    propCases(4, :) = [0, 0, 60, 9, 0, 0, 1861, 3]; % RCP 6, E=0, OA=0
    propCases(5, :) = [0, 0, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=0, OA=0
    propCases(6, :) = [1, 0, 26, 9, 0, 0, 1861, 3]; % RCP 2.6, E=1, OA=0
    propCases(7, :) = [1, 0, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=1, OA=0
    propCases(8, :) = [1, 0, 60, 9, 0, 0, 1861, 3]; % RCP 6, E=1, OA=0
    propCases(9, :) = [1, 0, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=1, OA=0
    propCases(10, :) = [1, 1, 26, 9, 0, 0, 1861, 3]; % RCP 2.6, E=1, OA=1
    propCases(11, :) = [1, 1, 45, 9, 0, 0, 1861, 3]; % RCP 4.5, E=1, OA=1
    propCases(12, :) = [1, 1, 60, 9, 0, 0, 1861, 3]; % RCP 6, E=1, OA=1
    propCases(13, :) = [1, 1, 85, 9, 0, 0, 1861, 3]; % RCP 8.5, E=1, OA=1
    propCases(14, :) = [0, 0, 26, 9, 0, 0, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(15, :) = [0, 0, 45, 9, 0, 0, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(16, :) = [0, 0, 60, 9, 0, 0, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(17, :) = [0, 0, 85, 9, 0, 0, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(18, :) = [1, 0, 26, 9, 0, 0, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(19, :) = [1, 0, 45, 9, 0, 0, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(20, :) = [1, 0, 60, 9, 0, 0, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(21, :) = [1, 0, 85, 9, 0, 0, 1861, 5]; % RCP 8.5, E=1, OA=0
    propCases(22, :) = [1, 1, 26, 9, 0, 0, 1861, 5]; % RCP 2.6, E=1, OA=1
    propCases(23, :) = [1, 1, 45, 9, 0, 0, 1861, 5]; % RCP 4.5, E=1, OA=1
    propCases(24, :) = [1, 1, 60, 9, 0, 0, 1861, 5]; % RCP 6, E=1, OA=1
    propCases(25, :) = [1, 1, 85, 9, 0, 0, 1861, 5]; % RCP 8.5, E=1, OA=1
    propCases(26, :) = [0, 0, 26, 9, 1, 0.25, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(27, :) = [0, 0, 45, 9, 1, 0.25, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(28, :) = [0, 0, 60, 9, 1, 0.25, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(29, :) = [0, 0, 85, 9, 1, 0.25, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(30, :) = [0, 0, 26, 9, 0.5, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(31, :) = [0, 0, 45, 9, 0.5, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(32, :) = [0, 0, 60, 9, 0.5, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(33, :) = [0, 0, 85, 9, 0.5, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(34, :) = [1, 0, 26, 9, 0.5, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(35, :) = [1, 0, 45, 9, 0.5, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(36, :) = [1, 0, 60, 9, 0.5, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(37, :) = [1, 0, 85, 9, 0.5, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0
    propCases(38, :) = [0, 0, 26, 9, 1, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(39, :) = [0, 0, 45, 9, 1, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(40, :) = [0, 0, 60, 9, 1, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(41, :) = [0, 0, 85, 9, 1, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(42, :) = [1, 0, 26, 9, 1, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(43, :) = [1, 0, 45, 9, 1, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(44, :) = [1, 0, 60, 9, 1, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(45, :) = [1, 0, 85, 9, 1, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0
    propCases(46, :) = [0, 0, 26, 9, 1.5, 0.5, 1861, 5]; % RCP 2.6, E=0, OA=0
    propCases(47, :) = [0, 0, 45, 9, 1.5, 0.5, 1861, 5]; % RCP 4.5, E=0, OA=0
    propCases(48, :) = [0, 0, 60, 9, 1.5, 0.5, 1861, 5]; % RCP 6, E=0, OA=0
    propCases(49, :) = [0, 0, 85, 9, 1.5, 0.5, 1861, 5]; % RCP 8.5, E=0, OA=0
    propCases(50, :) = [1, 0, 26, 9, 1.5, 0.5, 1861, 5]; % RCP 2.6, E=1, OA=0
    propCases(51, :) = [1, 0, 45, 9, 1.5, 0.5, 1861, 5]; % RCP 4.5, E=1, OA=0
    propCases(52, :) = [1, 0, 60, 9, 1.5, 0.5, 1861, 5]; % RCP 6, E=1, OA=0
    propCases(53, :) = [1, 0, 85, 9, 1.5, 0.5, 1861, 5]; % RCP 8.5, E=1, OA=0
    propCases(54, :) = [0, 0, 26, 9, 0, 0, 1861, 10]; % RCP 2.6, E=0, OA=0
    propCases(55, :) = [0, 0, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=0, OA=0
    propCases(56, :) = [0, 0, 60, 9, 0, 0, 1861, 10]; % RCP 6, E=0, OA=0
    propCases(57, :) = [0, 0, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=0, OA=0
    propCases(58, :) = [1, 0, 26, 9, 0, 0, 1861, 10]; % RCP 2.6, E=1, OA=0
    propCases(59, :) = [1, 0, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=1, OA=0
    propCases(60, :) = [1, 0, 60, 9, 0, 0, 1861, 10]; % RCP 6, E=1, OA=0
    propCases(61, :) = [1, 0, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=1, OA=0
    propCases(62, :) = [1, 1, 26, 9, 0, 0, 1861, 10]; % RCP 2.6, E=1, OA=1
    propCases(63, :) = [1, 1, 45, 9, 0, 0, 1861, 10]; % RCP 4.5, E=1, OA=1
    propCases(64, :) = [1, 1, 60, 9, 0, 0, 1861, 10]; % RCP 6, E=1, OA=1
    propCases(65, :) = [1, 1, 85, 9, 0, 0, 1861, 10]; % RCP 8.5, E=1, OA=1

    % Computed separately and so not sorted with those above.
    propCases(66, :) = [0, 0, 26, 9, 1, 0.5, 1861, 3]; % RCP 2.6, E=0, OA=0
    propCases(67, :) = [0, 0, 45, 9, 1, 0.5, 1861, 3]; % RCP 4.5, E=0, OA=0
    propCases(68, :) = [0, 0, 60, 9, 1, 0.5, 1861, 3]; % RCP 6, E=0, OA=0
    propCases(69, :) = [0, 0, 85, 9, 1, 0.5, 1861, 3]; % RCP 8.5, E=0, OA=0
    propCases(70, :) = [1, 0, 26, 9, 1, 0.5, 1861, 3]; % RCP 2.6, E=1, OA=0
    propCases(71, :) = [1, 0, 45, 9, 1, 0.5, 1861, 3]; % RCP 4.5, E=1, OA=0
    propCases(72, :) = [1, 0, 60, 9, 1, 0.5, 1861, 3]; % RCP 6, E=1, OA=0
    propCases(73, :) = [1, 0, 85, 9, 1, 0.5, 1861, 3]; % RCP 8.5, E=1, OA=0
    propCases(74, :) = [0, 0, 26, 9, 1, 0.5, 1861, 10]; % RCP 2.6, E=0, OA=0
    propCases(75, :) = [0, 0, 45, 9, 1, 0.5, 1861, 10]; % RCP 4.5, E=0, OA=0
    propCases(76, :) = [0, 0, 60, 9, 1, 0.5, 1861, 10]; % RCP 6, E=0, OA=0
    propCases(77, :) = [0, 0, 85, 9, 1, 0.5, 1861, 10]; % RCP 8.5, E=0, OA=0
    propCases(78, :) = [1, 0, 26, 9, 1, 0.5, 1861, 10]; % RCP 2.6, E=1, OA=0
    propCases(79, :) = [1, 0, 45, 9, 1, 0.5, 1861, 10]; % RCP 4.5, E=1, OA=0
    propCases(80, :) = [1, 0, 60, 9, 1, 0.5, 1861, 10]; % RCP 6, E=1, OA=0
    propCases(81, :) = [1, 0, 85, 9, 1, 0.5, 1861, 10]; % RCP 8.5, E=1, OA=0




    % Below are the averaged cases.  This lines are hand-built by taking the 1st
    % line above and every 4th line thereafter, and replacing the RCP value with
    % zero.  The they are numbered consecutively from 70 to match what is done
    % in PropConstantCalcsForOptimizer. This will cause the average "s" to be selected.
    % Values are E, OA, RCP, superMode=0, advantage, growth penalty, start, bleachTarget
    propCases(100, :) = [0, 0, 0, 9, 0, 0, 1861, 3]; % E=0, OA=0   
    propCases(101, :) = [1, 0, 0, 9, 0, 0, 1861, 3]; % E=1, OA=0
    propCases(102, :) = [1, 1, 0, 9, 0, 0, 1861, 3]; % E=1, OA=1  
    propCases(103, :) = [0, 0, 0, 9, 0, 0, 1861, 5]; % E=0, OA=0    
    propCases(104, :) = [1, 0, 0, 9, 0, 0, 1861, 5]; % E=1, OA=0   
    propCases(105, :) = [1, 1, 0, 9, 0, 0, 1861, 5]; % E=1, OA=1   
    propCases(106, :) = [0, 0, 0, 9, 1, 0.25, 1861, 5]; % E=0, OA=0   
    propCases(107, :) = [0, 0, 0, 9, 0.5, 0.5, 1861, 5]; % E=0, OA=0    
    propCases(108, :) = [1, 0, 0, 9, 0.5, 0.5, 1861, 5]; % E=1, OA=0    
    propCases(109, :) = [0, 0, 0, 9, 1, 0.5, 1861, 5]; % E=0, OA=0   
    propCases(110, :) = [1, 0, 0, 9, 1, 0.5, 1861, 5]; % E=1, OA=0   
    propCases(111, :) = [0, 0, 0, 9, 1.5, 0.5, 1861, 5]; % E=0, OA=0    
    propCases(112, :) = [1, 0, 0, 9, 1.5, 0.5, 1861, 5]; % E=1, OA=0    
    propCases(113, :) = [0, 0, 0, 9, 0, 0, 1861, 10]; % E=0, OA=0    
    propCases(114, :) = [1, 0, 0, 9, 0, 0, 1861, 10]; % E=1, OA=0    
    propCases(115, :) = [1, 1, 0, 9, 0, 0, 1861, 10]; % E=1, OA=1
    
    % This batch is averaged the same way as the 100-115, but not sorted
    % in with the rest.
    propCases(116, :) = [0, 0, 0, 9, 1, 0.5, 1861, 3]; % E=0, OA=0
    propCases(117, :) = [1, 0, 0, 9, 1, 0.5, 1861, 3]; % E=1, OA=0
    propCases(118, :) = [0, 0, 0, 9, 1, 0.5, 1861, 10]; % E=0, OA=0
    propCases(119, :) = [1, 0, 0, 9, 1, 0.5, 1861, 10]; % E=1, OA=0
   


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
    ooo = propCases(:, 2) == OA;
    rrr = propCases(:, 3) == rcpNum;
    sss = propCases(:, 4) == superMode;
    aaa = propCases(:, 5) == advantage;
    ggg = propCases(:, 6) == superGrowthPenalty;
    yyy = propCases(:, 7) == startYear;
    bbb = propCases(:, 8) == bleachTarget;
    % If there is zero advantage or mode is zero, we don't care about
    % growth penalty or start year.
    if superMode == 0 || advantage == 0.0
        propTest = find(eee & ooo & rrr & sss & aaa & bbb);
    else
        propTest = find(eee & rrr & sss & aaa & ggg & yyy & bbb);
    end
    if size(propTest) > 1
        error('propTest is not uniquely specified by E = %d, OA = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, OA, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    elseif isempty(propTest) | size(propTest) == 0 | propTest == 0
            error('propTest is not defined for E = %d, OA = %d, RCP = %s, superMode = %d, advantage = %d, superGrowthPenalty = %d, startYear = %d, bleachTarget = %d', ...
            E, OA, RCP, superMode, advantage, superGrowthPenalty, startYear, bleachTarget);
    end
    return;
end
