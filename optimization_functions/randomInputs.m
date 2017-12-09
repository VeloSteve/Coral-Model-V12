function [possible, nextIndex, good] = randomInputs(result, best, possible, steps, fromBest)
    good = false;
    % Start in the middle if there's no previous best (and if we're using
    % the starting point).
    if isnan(best(1))
        startIndex = ceil(steps/2);
    else
        startIndex = best;
    end
    nextIndex = ones(1,4);
    
    % Try up to 50 times (but no more than half the possible combinations)
    % for an untested combination.  If there's not one
    % the space is probably well covered already.
    randSize = 1; % Was 2 - use 1 to just search  nearest neighbors.
    maxTry = min(min(50, prod(steps)/2), 2*power(randSize*2+1, sum(steps>1)));
    for tries = 1:maxTry
        for i = 1:4
            if steps(i) ~= 1
                if fromBest
                    % Offset by -randSize to randSize (hoping at least one is not zero)
                    del = unidrnd(randSize*2 + 1) - randSize - 1;  % function returns between 1 and the argument
                    nextIndex(i) = min(steps(i), max(1, startIndex(i) + del));
                else
                    nextIndex(i) = unidrnd(steps(i));
                end
            else
                nextIndex(i) = 1;
            end
        end
        if isnan(result(nextIndex(1), nextIndex(2), nextIndex(3), nextIndex(4)))
            possible = setOptimizationInputs(nextIndex, possible, steps);
            good = true;
            fprintf('Random search to %d %d %d %d\n', nextIndex);
            return;
        end
        if mod(tries, 10) == 0
            fprintf('%d misses so far, looking for a random neighbor\n',tries);
        end
    end
    % Failed to find an available direction to test.
    fprintf('No new values to test found in %d tries.\n', tries);
    % possible goes back unchanged, but good=false is the real result.
    %inputSet = ones(1,4);

end

