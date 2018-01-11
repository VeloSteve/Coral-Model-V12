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
        elseif strcmp(specialSubset('hughes'))
            toDo = [1601 1664 1579 1512 1640 991 1738 1680 961 1053 1679 1679 956 1496 804 994 1197 915 935 1267 1093 1232 813 1402 1342 831 1630 1108 1758 1176 807 928 1181 851 762 1086 1148 657 553 473 706 516 622 583 695 636 566 477 502 488 624 572 471 720 493 615 71 335 1540 103 275 321 1913 144 240 1525 126 70 1845 1903 1702 1785 1458 282 313 1811 57 1818 343 445 258 422 402 420 301 348 284 329 398 399 311 224 265 339 261 283 411 419 440 409];
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
