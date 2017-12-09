function [possible, nextIndex, good] = nextInputs(result, best, possible, nextVar, steps, up)
    persistent lastIndex;
    earlyExit = true;  % Try bailing if an existing worse value is found in the search direction.
    worseBy = 1.05; % 5 percent worse is enough to bail. (later 20%)
    %inputSet = zeros(1, 4);
    nextIndex = zeros(1, 4);
    good = false;
    % On the first call we pick the middle point and return.
    if isempty(best) && isempty(lastIndex)
        disp('WARNING - this code is assumed dead.  How did this happen?');
        lastIndex = ceil(steps/2);
        %lastIndex = [1 1 13 10];
        nextIndex = lastIndex;
        inputSet = setInputs(lastIndex, possible, steps);
        good = true;
        return;
    end
    if ~isempty(best) && ~isnan(best(1))
        lastIndex = best;
    end
    % On later calls search for a new test point along the given index
    % nextVar and return.
    % If we get this far, we should be working relative to an existing
    % value.
    old = result(lastIndex(1), lastIndex(2), lastIndex(3), lastIndex(4));
    assert(~isnan(old) && old >= 0, 'Starting from an untested point!');
    nextIndex = lastIndex;
    found = false;
    if up
        found = false;
        while ~found && nextIndex(nextVar) < steps(nextVar)
            nextIndex(nextVar) = nextIndex(nextVar) + 1;
            tryHere = result(nextIndex(1), nextIndex(2), nextIndex(3), nextIndex(4));
            if isnan(tryHere)
                lastIndex = nextIndex;
                possible = setOptimizationInputs(nextIndex, possible, steps);
                good = true;
                fprintf('Up   search to %d %d %d %d\n', nextIndex);
                return;
            elseif earlyExit && tryHere > old * worseBy
                fprintf('Early exit up (%d).\n', nextVar);
                return;
            end
        end
        % No options in the up direction.  Return with no result.
        return;
    else
        while ~found && nextIndex(nextVar) > 1
            nextIndex(nextVar) = nextIndex(nextVar) - 1;
            tryHere = result(nextIndex(1), nextIndex(2), nextIndex(3), nextIndex(4));
            if isnan(tryHere)
                lastIndex = nextIndex;
                possible = setOptimizationInputs(nextIndex, possible, steps);
                good = true;
                fprintf('Down search to %d %d %d %d\n', nextIndex);
                return;
            elseif earlyExit && tryHere > old * worseBy
                fprintf('Early exit down (%d).\n', nextVar);
                return;
            end
        end
        % No options in the up direction.  Return with no result.
        return;
    end
end
