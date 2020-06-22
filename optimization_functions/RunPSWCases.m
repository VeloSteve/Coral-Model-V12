%% Run the model repeatedly to find the "s" value giving the best match to the
%  bleaching target without too much reef death.
function [quality, parameters] = RunPSWCases(pd)
    wrapTimerStart = tic;

    bleachingTarget = pd.get('bleachingTarget');
    % Just using 2 to 9 for all would work, but this gives things a closer
    % start.
    if bleachingTarget <= 4
        useLowerS = 2;
        useUpperS = 5;
    elseif bleachingTarget >=6
        useLowerS = 5;
        useUpperS = 9;
    else
        useLowerS = 4;
        useUpperS = 6;
    end
    startSteps = 7;
    maxPasses = 10; % 14; % 14 may be overkill, but it gets the 4th decimal place.
    propInputValues = [0.025, 1.5, 0.46, NaN];
    
    
    % Run the model to evaluate the objective function and repeat as follows:
    % 1) Try startSteps points from useLowerS to useUpperS inclusive.
    % 2) Warn if either extreme is the minimum.
    % 3) Choose a new range including the minimum, the points on each side of
    %    it, and the second lowest point (which may already be included).
    % 4) Retain the values already computed and fill in all half steps between.
    % 5) Repeat steps 3 and 4 until a stopping condition is reached.  That
    %    condition is based on the objective function, bleaching level, step
    %    size, and a limit on the number of attempts.
    % 6) Warn if bleaching is far from target or objective function is large.
    % 7) Set quality and parameters values for return.
    pointsToRun = linspace(useLowerS, useUpperS, startSteps);
    clear resultList;
    idx = 1;
    for thisS = pointsToRun
        [goodness, bleaching, pg] = runOnce(propInputValues, thisS, pd, bleachingTarget);
        
        % For return, 
        % Values are pMin, pMax, y, s, objectiveFunction, bleachingResult, percentGone  
        resultList(idx, :) = [thisS goodness bleaching pg];
        idx = idx + 1;
    end
    
    %% Now we have the results of the first pass.  Find the minimum and its neighbors.
    summary = {};
    for passes = 1:maxPasses
        best = min(resultList(:, 2));
        minAt = find(resultList(:, 2) == best);  % possibly > 1 point, but usually 1
        assert(~isempty(minAt), 'No s matched the minimum.');
        % WARNING: do the next two checks more gracefully so work isn't lost.
        if passes < 3
            assert(min(minAt) > 1, 'Error: best result was at lower boundary.  Restart with wider limits.');
            assert(max(minAt) < size(resultList, 1), 'Error, best result was at upper boundary. Restart with wider limits.');
        end
    
        % What about when minAt has multiple values?
        minAtPrint = round(mean(minAt));
        
        %fprintf("=== Best before pass %d, s = %d, goodness = %d, bleaching = %d, pg = %d ===\n", ...
        %    passes, resultList(minAt, :));
        fprintf("p = %d, ma = %d dups = %d\n", passes, minAtPrint, length(minAt));
        summary{end+1} = sprintf("=== Best before pass %d, s = %8.4f, goodness = %8.4f, bleaching = %8.4f, pg = %6.2f ===\n", ...
            passes, resultList(minAtPrint, :));
        fprintf("%s", summary{end});
        
        % For now just use the best and points on each side.  Would it help to 
        % include other points when another point is nearly as low as the best?
        % Now that excess duplicates are trimmed, we can have points all the way
        % to the boundaries, so be sure not to exceed the array size.
        toCopy = max(1,min(minAt)-1):min(size(resultList, 1),max(minAt+1));
        newSize = length(toCopy)*2 - 1;
        
        if newSize > 5
            fprintf("================== Multiple best values, need %d new runs.\n", (newSize-1)/2);
        end
        
        % TODO: identical result values can grow to a long list without adding
        % anything useful.  Taking the middle few "bests" could work most of the
        % time, but it would be better to look for a point where bleaching is
        % above and below target on adjacent lines and center there.  Of course
        % there's no guarantee that bleaching will be monotonic with s!
        if newSize >= 9
            % Bring it down to 7
            fprintf("Removing extreme cases to reduce equal bests.\n");
            changed = true;
            while changed && newSize > 7
                changed = false;
                % Drop one from each end, but only if there's no sign change in
                % the error of bleaching relative to bleachingTarget.
                if sign(resultList(toCopy(end), 3) - bleachingTarget) == ...
                    sign(resultList(toCopy(end-1), 3) - bleachingTarget)
                    toCopy(end) = [];
                    newSize = length(toCopy)*2 - 1;    
                    changed = true;
                end
                if sign(resultList(toCopy(1), 3) - bleachingTarget) == ...
                    sign(resultList(toCopy(2), 3) - bleachingTarget)
                    toCopy(1) = [];
                    newSize = length(toCopy)*2 - 1;    
                    changed = true;
                end
            end
            % Tediously repeat the process to ignore sign changes when the
            % change is small and the list is long.
            changed = true;
            while changed && newSize > 7
                changed = false;
                % Drop one from each end if the error on the last is small.
                if abs(resultList(toCopy(end), 3) - bleachingTarget) < 0.001
                    toCopy(end) = [];
                    newSize = length(toCopy)*2 - 1;    
                    changed = true;
                end
                if sign(resultList(toCopy(1), 3) - bleachingTarget) < 0.001
                    toCopy(1) = [];
                    newSize = length(toCopy)*2 - 1;    
                    changed = true;
                end
            end
        end
        
        copyNow = max(toCopy);
        newList = NaN(newSize, 4);
        for i = newSize:-2:1
            newList(i, :) = resultList(copyNow, :);
            copyNow = copyNow - 1;
        end
        
        resultList = newList;
        
        % Fill in the even-numbered rows.
        for i = 2:2:newSize-1
            thisS = (resultList(i-1, 1)+resultList(i+1, 1))/2;
            [goodness, bleaching, pg] = runOnce(propInputValues, thisS, pd, bleachingTarget);
            resultList(i, :) = [thisS goodness bleaching pg];
        end
    end
    
    % One last time, find the best result.
    best = min(resultList(:, 2));
    minAt = find(resultList(:, 2) == best); 
    %fprintf("===== Final best result: s = %8.4f, goodness = %8.4f, bleaching = %8.4f, pg = %6.2f =====\n", ...
    %   resultList(minAt, :));
    % TODO: what if there's a poor value between the best ones?
    
    changed = true;
    while (length(minAt)) > 1 && changed
        changed = false;
        % Drop one from an end, but only if there's no sign change in
        % the error of bleaching relative to bleachingTarget.
        if sign(resultList(minAt(end), 3) - bleachingTarget) == ...
            sign(resultList(minAt(end-1), 3) - bleachingTarget)
            minAt(end) = [];
            changed = true;
        end
        if length(minAt) > 1
            if sign(resultList(minAt(1), 3) - bleachingTarget) == ...
                sign(resultList(minAt(2), 3) - bleachingTarget)
                minAt(1) = [];
                changed = true;
            end
        end
    end
    % Tediously repeat the process to ignore sign changes when the
    % change is small.
    changed = true;
    while changed && length(minAt) > 1
        changed = false;
        % Drop one from each end if the error on the last is small.
        if abs(resultList(minAt(end), 3) - bleachingTarget) < 0.001
            minAt(end) = [];
            changed = true;
        end
        if length(minAt) > 1
            if abs(resultList(minAt(1), 3) - bleachingTarget) < 0.001
                minAt(1) = [];
                changed = true;
            end
        end
    end
    if length(minAt) == 1
        ;
    elseif length(minAt) == 2
        minAt(2) = []; %arbitrary choice 
    else
        error('More than one sign change among remaining equal bests.  Check manually.');
    end
        
    

    summary{end+1} = sprintf("=== Final best result:  s = %8.4f, goodness = %8.4f, bleaching = %8.4f, pg = %6.2f ===\n", ...
            resultList(minAt, :));
    for i = 1:length(summary)
        fprintf("%s", summary{i});
    end
    fprintf("\n");

    propInputValues(4) = resultList(minAt, 1);
    parameters = propInputValues;
    quality = resultList(minAt, 2:4);

    fprintf('Completed %d passes in %7.1f seconds.\n', maxPasses, toc(wrapTimerStart));
    
end

function [goodness, bleaching, pg] = runOnce(propInputValues, s, pd, bleachingTarget)
    propInputValues(4) = s;
    SavePSWInputs
    thisPath = pwd;
    cd('..');
    [percentMortality, bleaching, ~, ~, ~] = A_Coral_Model(pd);
    cd(thisPath);
    [goodness, pg] = goodnessValueNew(bleachingTarget, percentMortality, bleaching);
end