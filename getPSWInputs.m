% Get the parameters used to compute psw2 for each reef.  A unique set must
% exist for any combination of parameters which affects historical coral growth
% or bleaching.
%
% Previous versions used switch statements or long lists of array initialization
% code, but that was unreliable.  Now we read an array which include the case
% parameters as well as the 4 values which determine psw2.
% Consider
%  E   OA  RCP    Mode  Adv    Penalty Target pMin    pMax   y      s        obj      bleach   mort
%  1   0   rcp26  9     0.00   0.50    3.00   0.025   1.50   0.46   4.1094   1.2547   2.9990   0.3117
%
% The first 7 values are the parameters which define the case being run.
% The next 4 values are the inputs to psw2 calculations.
% The last 2 values are used during optimization as parts of the goal function.
%
% The dimension of the array are
% Index Values Description
% 1     2       E
% 2     2       OA
% 3     5       RCP (4 scenarios as rcpXX or mean)
% 4     10      superMode (symbiont modes 0-9, but often only 9
% 5     5       symbiont advantage, 0 to 2 in steps of 0.5
% 6     3       growth penalty, 0, 0.25, or 0.5
% 7     2       start symbiont modification in 1861 or 2100 (no change)
% 8     3       bleaching target, 3, 5, or 10
% 9     7       result values, pMin, pMax, y, s, objectiveFunction, bleachingResult, percentGone
%
% This yields a possible 126,000 values (for 18,000 cases), but most will be
% null.  This seems large, but is easily handled.  If it becomes more extreme,
% MATLAB's sparse array functions may prove useful.
function [pMin, pMax, y, s] = getPSWInputs(E, OA, RCP, superMode, advantage, ...
                                  superGrowthPenalty, startYear, bleachTarget)
    % Default is to run after optimization for a bleaching target of
    % 5% between 1985 and 2010.  The argument can ask for other values.
    if nargin < 7
        bleachTarget = 5;
    end
  

    %% Now select the matching case (if any) based on input parameters
    % (E, RCP, superMode, advantage, start, bleachTarget)
    % Before doing the logic, make some adjustments to the inputs.

    % If nothing happens before 2010, the symbiont options can all be zero.
    % startYear is a vector, one per reef.  If there are diverse values, this
    % will require a new "s" for each case.  If there is just one, we can use
    % it as a single value.
    if (max(startYear) == min(startYear)) || min(startYear) > 2010
        startYear = startYear(1);
    else
        error("There is currently no support for interventions starting at a variety of years before 2011.");
    end
    
    %% WARNING.  This block is a bit of a kludge since some parameters are
    % handled inconsistently when they theoretically don't matter.  This way of
    % forcing matches could change.
    %
    % When advantage is zero, intevention start date doesn't matter.  It gets
    % set to 2101 for other reasons, but we have optimized cases for 1861, so
    % use those.
    % Similarly, growth penalty is not applied with zero advantage, and so is
    % set to zero, but here the matching case is still labeled with a nonzero
    % value.
    if advantage == 0
        if startYear == 2101
            startYear = 1861;
        end
        if superGrowthPenalty == 0
            superGrowthPenalty = 0.5;
        end
    end
    
    
    %% Bring in the definition of supported cases from an external file to ensure
    % that we are in sync with AllNewPWS2.m
    % A typical line looks like
    %     fullAdvantage = [0, 0.5, 1.0, 1.5, 2.0];
    % and there are definitions for fullE, fullOA, fullRCP, fullSuperMode,
    % fullAdvantage, fullGrowthPenalty, fullStartYear, and fullBleachTarget.
    addpath('optimization_functions');
    DefineCaseOptions
    
    i1 = caseIndex(fullE, E, 'Evolution');
    i2 = caseIndex(fullOA, OA, 'Ocean Acidification');
    i3 = caseIndex(fullRCP, RCP, 'RCP');
    i4 = caseIndex(fullSuperMode, superMode, 'Super symbiont mode');
    i5 = caseIndex(fullAdvantage, advantage, 'Thermal advantage');
    i6 = caseIndex(fullGrowthPenalty, superGrowthPenalty, 'Growth penalty');
    i7 = caseIndex(fullStartYear, startYear, 'Start year for interventions');
    i8 = caseIndex(fullBleachTarget, bleachTarget, 'Target 1985-2010 bleaching');
    
    load('mat_files/Optimize_psw2_9D.mat', 'pswResults');
    pMin = pswResults(i1, i2, i3, i4, i5, i6, i7, i8, 1); 
    pMax = pswResults(i1, i2, i3, i4, i5, i6, i7, i8, 2); 
    y = pswResults(i1, i2, i3, i4, i5, i6, i7, i8, 3);
    s = pswResults(i1, i2, i3, i4, i5, i6, i7, i8, 4);
    
    % s is the value optimized for, so check that there is a valid value.  If
    % there is, assume the other 3 are correct.
    if isempty(s) || isnan(s) || (s == 0)
        error('Separately valid case options defined a case with no optimized psw2 available.');
    end

end

function [idx] = caseIndex(full, current, name) 
    idx = find(full == current);
    if isempty(idx)
        fprintf("No match for input value %s in case definitions for %s.\n", current, name);
        error("Stopping because of unsupported case options or missing optimized psw2 values.");
    end
end
