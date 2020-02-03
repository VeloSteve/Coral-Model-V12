function [toDo, reefsThisRun] = ...
    reefsToDo(specialSubset, everyx, maxReefs, keyReefs, dataReefs, Reefs_latlon)
    % Determine all reefs to computed in this run.  Subset reefs according
    % to specialSubset and everyx, and then add in any others specified in
    % keyReefs or dataReefs.
    if strcmp(specialSubset, 'no')
        toDo = 1:maxReefs;
    elseif strcmp(specialSubset, 'useEveryx') && isnumeric(everyx)
        toDo = 1:everyx:maxReefs;   % as specified by everyx
    elseif strcmp(specialSubset, 'keyOnly')
        toDo = [];
    else
        % specialSubset can specify a reef area (eq, lo, hi)
        if any(strcmp({'eq', 'lo', 'hi'}, specialSubset))
            toDo = latitudeBin(specialSubset, Reefs_latlon);
        else
            error('special subset %s does not match a latitude area', specialSubset);
        end
    end
    toDo = unique([toDo keyReefs dataReefs]); % add keyReefs defined above
    % toDo entries make sense as integers, but MATLAB likes doubles!
    toDo = double(toDo);
    if isempty(toDo)
        error('No reefs specified.  Exiting.');
    end
    reefsThisRun = length(toDo);
end
