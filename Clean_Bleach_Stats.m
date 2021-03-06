function [ C_monthly, S_monthly, C_yearly, S_yearly, bleachEvent, coldEvent, bleached, dead ] ...
    = Clean_Bleach_Stats( C, S, C_seed, S_seed, dt, TIME, temp, bleachParams, coralConstants )
%Clean_Bleach_Stats computes columns of coral health flags for plotting and tables.
    %   This is a complete rewrite of Get_Bleach_Freq to remove any unneeded
    %   code and variables. The list-of-events approach is scrapped.
    %   Required outputs, straight from the the feature request, except that
    %   some may be better computed in the per-reef plot routine.

    % No longer consider drops in coral population to be bleaching.  This has
    % little effect on overall results, and removes the objection that these
    % drops may not be due to bleaching.
    ignoreCoralDrops = true;
    
    % Inside a single reef's run:
    % 
    % coral cover by month
    % symbiont density by month
    % bleaching events by year
    % SST by month
    % DHM by month

    % Outside, for all reefs. Yearly unless otherwise noted:
    % 
    % coral cover (downsampled with the decimate "fir" method)
    % bleached state (permanence can be derived)
    % mortality state
    % count of bleaching events in each year
    % unrecovered state in EITHER coral type - return both and compute, or do this in the loop?
    % Special:
    % 
    % 1985-2010 stats are potentially month-based and may need to be computed in-loop

    %% Indexes and counts used below.
    % Number of corals and symbionts can vary.
    % Also (4 Jan 2019) note that mode 9 shuffling implies 4 symbionts in each
    % of two corals.  The other modes have 4 symbionts in 4 corals.
    % Cn and Sn are the number of types, not the number of populations.
    numCorals = coralConstants.Cn;
    numSymb = coralConstants.Sn;
    [crow, ccol] = size(C);
    [srow, scol] = size(S);
    % No longer assume that each symbiont gets its own coral!
    % assert(ccol == numCorals*numSymb, 'Corals should have one column for each coral/symbiont type combination.');
    assert(mod(ccol, numCorals) == 0, 'Corals should have one column for each coral/symbiont type combination.');
    assert(scol == numCorals*numSymb, 'Symbionts should have one column for each coral/symbiont type combination.');
    assert(srow == crow, 'Length of C and S arrays must match.');
    % dt is the fraction of a month for each time step
    stepsPerYear = 12/dt;
    yearCount = crow/stepsPerYear;
    stepsPerMonth = 1/dt;
    monthCount = yearCount*12;
    assert(length(C)*dt == length(TIME), 'Expected months in TIME to equal timesteps in C times dt.');

    %%  Cover
    % Preallocate by setting the last value to zero.
    C_monthly(monthCount, ccol) = 0;
    C_yearly(yearCount, ccol) = 0;
    S_monthly(monthCount, scol) = 0;
    S_yearly(yearCount, scol) = 0;

    % Reduce to monthly or yearly using a filter rather than just picking
    % points.  decimate handles vectors, not matrices.
    for i=1:ccol
        C_monthly(:, i) = decimate(C(:, i), stepsPerMonth , 'fir');
        C_yearly(:, i) = decimate(C(:, i), stepsPerYear, 'fir');
        %fprintf("===== WARNING: 'fir' is the production code. Temporarily replaced by yearly mean. =====\n");
        %y = 1;
        %for m = 1:12:240*12
        %    C_yearly(y, i) = mean(C_monthly(m:m+11, i));
        %    y = y + 1;
        %end
    end
    for i = 1:scol
        S_monthly(:, i) = decimate(S(:, i), stepsPerMonth , 'fir');
        % S_yearly isn't used in this function, but is a return value.
        S_yearly(:, i) = decimate(S(:, i), stepsPerYear , 'fir');
    end

    %% Bleaching
    % Bleaching will be based on annual minimum values.  This tends to occur in
    % summer, so this is less than ideal for southern-hemisphere reefs.
    % Note that Cmin (unlike the C_* arrays above only includes 2 columns, 
    % because the others are duplicates.  Also note that Cmin is one row per
    % year, NOT the same as in the old Get_bleach_freq code.
    % Smin is similar, but S is first SUMMED across odd and even columns, since
    % either type of symbiont is considered to count interchangeably.
    Cmin(yearCount, numCorals) = 0;
    Smin(yearCount, numCorals) = 0;
    
    % Sum S.  S columns are arranged as (symbiont 1 in coral 1, symbiont 1 in
    % coral2, symbiont 2 in coral 1, etc. - it should really be 3D.
    % The "S" part is unchanged by the addition of mode 9 shuffling.
    Ssum(:, 1:numCorals) = S(:, 1:numCorals);
    for j = numCorals+1:scol
        jFirst = numCorals - mod(j, numCorals);  % shift to first set of columns.
        Ssum(:, jFirst) = Ssum(:, jFirst) + S(:, j);
    end
    % Now get the annual minimum for each.
    for i = 1:yearCount
        iEnd =  i*stepsPerYear;
        iStart = iEnd - stepsPerYear + 1;
        Cmin(i, 1:numCorals) = min(C(iStart:iEnd, 1:numCorals));
        Smin(i, 1:numCorals) = min(Ssum(iStart:iEnd, 1:numCorals));
    end

    % The actual bleaching calculation begins here.
    % vectors of one bleaching ratio per coral type
    sBleach = bleachParams.sBleach;  
    cBleach = bleachParams.cBleach;
    sRecoverySeedMult = bleachParams.sRecoverySeedMult;
    cRecoverySeedMult = bleachParams.cRecoverySeedMult;
    extendedBleaching = bleachParams.yearsToMortality;
    seedThresh = C_seed .* bleachParams.cSeedThresholdMult;

    % Result arrays, eventually for output
    % Note that in the boolean arrays, the year can be deduced from the
    % index even though only true/false is stored.
    bleached = false(yearCount, numCorals);
    dead = false(yearCount, numCorals);
    bleachEvent = false(yearCount, numCorals);
    coldEvent = false(yearCount, numCorals);
    lastBleaching = nan(numCorals,1);
    for coral = 1:numCorals
        bleachFlag = false;
        deadFlag = false;
        lastBleaching(coral) = NaN;
        for y = 2:yearCount
            if bleachFlag
                % Check for recovery
                % Is each component strong enough to be considered?
                seedRecS = Smin(y, coral) > sRecoverySeedMult(coral)*S_seed(coral);
                seedRecC = Cmin(y, coral) > cRecoverySeedMult(coral)*C_seed(coral);
                % Note 2/1/2018: variables massiveSeedMort and massRec were always
                % false, so both are now removed.
                if seedRecS && seedRecC
                    bleachFlag = false;
                    bleached(y:end, coral) = false;
                    lastBleaching(coral) = NaN;
                    % If the coral was dead, now it's not.
                    if deadFlag
                        dead(y:end, coral) = false;
                        deadFlag = false;
                    end
                else
                    % If coral is bleached and didn't recover, check for
                    % mortality
                    if ~deadFlag
                        if 1+y-lastBleaching(coral) > extendedBleaching
                            dead(y:end, coral) = true;
                            deadFlag = true;
                        end
                    end
                end
            else
                % Not bleached, check for bleaching.
                % Declines in either symbionts or bleaching can define bleaching.
                sB = Smin(y, coral) < Smin(y-1, coral) * sBleach(coral);
                if ignoreCoralDrops
                    cB = false;
                else
                    cB = Cmin(y, coral) < Cmin(y-1, coral) * cBleach(coral);
                end
                if sB || cB
                    bleached(y:end, coral) = true;
                    bleachFlag = true;
                    lastBleaching(coral) = y;
                    bleachEvent(y, coral) = true;               
                    % Call it cold water bleaching if it was 0.5 C warmer 2 months ago.
                    % BUT we are working with annual min/max.  Try getting the
                    % month of the annual low, and working back to SST.
                    % 
                    % Are we looking for annual C min or S min?
                    % Check if sB is true, use that, otherwise use cB (one must
                    % be true).
                    % However we define cold water bleaching, start by finding
                    % the recent minimum population of the organism which
                    % triggered the event.
                    endStep =  y * stepsPerYear;                % last step of this year
                    startStep = endStep - stepsPerYear + 1;     % first step of this year
                    if sB
                        % Ssum is the sum of all symbiont populations in each
                        % coral type, at time-step frequency.
                        [~, iMin] = min(Ssum(startStep:endStep, coral));  % step with lowest S for each coral type
                    else
                        [~, iMin] = min(C(startStep:endStep, coral));
                    end
                    % iMin is the index of the minimum within the subset year.
    
                    coldVersion = 2;
                    if coldVersion == 1
                        % Is the temperature 2 months back colder than 4 months
                        % back?
                        
                        %sstMin = temp(startStep + iMin - 1);
                        %sstBack2 = temp(startStep + iMin - 1 - 2 * stepsPerMonth); 
                        % There seems to be a lag.  Try comparing 2 months back to
                        % 4.
                        sstBack2 = temp(startStep + iMin - 1 - 2 * stepsPerMonth);
                        sstBack4 = temp(startStep + iMin - 1 - 4 * stepsPerMonth);
                        coldEvent(y, coral) = sstBack4 - sstBack2 > 0.5;
                    elseif coldVersion == 2
                        % Is the T average over the 4 months leading up the the
                        % annual minimum population lower than the
                        % 4-year average?
                        stepMin = startStep + iMin - 1;
                        step4Mon = max(1, stepMin - 4 * stepsPerMonth + 1);
                        step4Yr = max(1, stepMin - 4 * 12 * stepsPerMonth + 1);
                        sstRecent = mean(temp(step4Mon:stepMin));
                        sstAv = mean(temp(step4Yr:stepMin));
                        coldEvent(y, coral) = sstAv > sstRecent;
                    else
                        fprintf("WARNING: undefined cold bleaching test!\n");
                    end
                 
                end
            end
            
            % Most of this "for" is about bleaching at potentially healthy
            % coral levels, but also check for mortality based on an extreme
            % low value of coral cover.
            % Note that we also consider coral with this type of mortality
            % to be bleached.
            % NOTE: The coral becomes bleached, be we don't record this as
            % a bleaching event even though it updates the last bleaching
            % date.         
            if ~deadFlag
                if Cmin(y, coral) < seedThresh(coral)
                    % mort implies bleached.
                    bleachFlag = true;
                    bleached(y:end, coral) = true;
                    lastBleaching(coral) = y;
                    dead(y:end, coral) = true;
                    deadFlag = true;
                end
            end
        end % end years
    end % end coral types
    % TODO: see if calculating sBleach*Smin into a new array and then
    % comparing would be faster, possibly with yet another temporary array
    % storing _potential_ bleaching points.
    bleachEvent = sparse(bleachEvent);
    
end


