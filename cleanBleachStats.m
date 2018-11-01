function [ C_monthly, S_monthly, C_yearly, bleachEvent, bleached, dead ] ...
    = cleanBleachStats( C, S, C_seed, S_seed, dt, TIME, bleachParams, coralConstants )
%cleanBleachStats computes columns of coral health flags for plotting and tables.
    %   This is a complete rewrite of Get_Bleach_Freq to remove any unneeded
    %   code and variables. The list-of-events approach is scrapped.
    %   Required outputs, straight from the the feature request, except that
    %   some may be better computed in the per-reef plot routine.

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
    numCorals = coralConstants.Cn;
    numSymb = coralConstants.Sn;
    [crow, ccol] = size(C);
    [srow, scol] = size(S);
    assert(ccol == numCorals*numSymb, 'Corals should have one column for each coral/symbiont type combination.');
    assert(scol == numCorals*numSymb, 'Symbionts should have one column for each coral/symbiont type combination.');
    assert(srow == crow, 'Length of C and S arrays must match.');
    % dt is the fraction of a month for each time step
    stepsPerYear = 12/dt;
    yearCount = crow/stepsPerYear;
    stepsPerMonth = 1/dt;
    monthCount = yearCount*12;
    assert(length(C)*dt == length(TIME), 'Expected months in TIME to equal timesteps in C times dt.');

    %%  Cover
    C_monthly(monthCount, ccol) = 0;
    C_yearly(yearCount, ccol) = 0;
    S_monthly(monthCount, scol) = 0;

    for i=1:ccol
        C_monthly(:, i) = decimate(C(:, i), stepsPerMonth , 'fir');
        C_yearly(:, i) = decimate(C(:, i), stepsPerYear, 'fir');
    end
    for i = 1:scol
        S_monthly(:, i) = decimate(S(:, i), stepsPerMonth , 'fir');
    end

    %% Bleaching
    % Bleaching will be based on annual minimum values.  This tends to occur in
    % summer, so this is less than ideal for southern-hemisphere reefs.
    % Note that Cmin (unlike the C_* arrays above only includes 2 columns, 
    % because the others are duplicates.  Also note that Cmin is one row per
    % year, NOT the same as in the old Get_bleach_freq code.
    % Smin is simular, but S is first SUMMED across odd and even columns, since
    % either type of symbiont is considered to count interchangeably.
    Cmin(yearCount, numCorals) = 0;
    Smin(yearCount, numCorals) = 0;
    
    % Sum S.  S columns are arranged as (symbiont 1 in coral 1, symbiont 1 in
    % coral2, symbiont 2 in coral 1, etc. - it should really be 3D.
    Ssum(:, 1:numCorals) = S(:, 1:numCorals);
    for j = numCorals+1:scol
        jFirst = j - numCorals*(ceil(j/numCorals) - 1);  % shift to first set of columns.
        Ssum(:, jFirst) = Ssum(:, jFirst) + S(:, j);
    end
    % Now get the annual minimum for each.
    for j = 1:numCorals
        for i = 1:yearCount
            iEnd =  i*stepsPerYear;
            iStart = iEnd - stepsPerYear + 1;
            Cmin(i, j) = min(C(iStart:iEnd, j));
            Smin(i, j) = min(Ssum(iStart:iEnd, j));
        end
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
                cB = Cmin(y, coral) < Cmin(y-1, coral) * cBleach(coral);
                if sB || cB
                    bleached(y:end, coral) = true;
                    bleachFlag = true;
                    lastBleaching(coral) = y;
                    bleachEvent(y, coral) = true;
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


