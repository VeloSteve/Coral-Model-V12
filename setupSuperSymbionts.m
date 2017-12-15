function [startSymFractions, superStartYear, superSeedFraction, oneShot] = ...
    setupSuperSymbionts(superMode, RCP, E, superAdvantage, superStart, maxReefs)
%SETUPSUPERSYMBIONTS Set symbiont internal variables based on input choices.

    startSymFractions = [1.0 0.0];  % Starting fraction for native and super symbionts.
    if superMode >= 3 && superMode <=5
        fn = strcat('longMortYears_', RCP, '_', num2str(E));
        load(fn, 'longMortYears');
        superStartYear = longMortYears;
        % XXX - next two lines for testing only!!!
        %subFrom = (superStartYear > 1882);
        %superStartYear = superStartYear - 20*subFrom;
    elseif superMode >= 6
        fn = strcat('firstBleachYears_', RCP, '_', num2str(E));
        load(fn, 'firstBleachYears');
        superStartYear = firstBleachYears;
    elseif superAdvantage == 0.0
        % If there's no advantage it's a case where there's no addition.
        % Delay to the end or we'll end up "seeding" extra symbionts.
        if strcmp(RCP, 'control400')
            last = 1860+400+1;
        else
            last = 2100 + 1;
        end
        superStartYear = last*ones(maxReefs, 1); % Until this date set S(:, 3:4) to zero.  Use 1861 to start from the beginning.
    else  
        % Start the symbionts in this fixed year for all reefs.
        superStartYear = superStart*ones(maxReefs, 1); % Until this date set S(:, 3:4) to zero.  Use 1861 to start from the beginning.
    end
    assert(length(superStartYear) == maxReefs, 'By-year symbiont starts should have a start year for every reef.');

    %superInitYears = [2025 2035]; % Years from which adaptation temp is selected.
    superSeedFraction = 10^-3;      % Fraction of S_seed to use for seeding super symbionts.
    % sizing notes: for massive,
    % KSm = 3000000
    % seed = 100000
    % KSm/seed = 30
    % the seed fraction is a fraction of this value.
    % for 0.01 -> KSm/introduced = 3000
    % for 0.0001 -> KSm/introduced = 300000
    oneShot = true;  % After supersymbiont introduction, set its seed to zero.
    assert(startSymFractions(2) == 0, 'Start with no symbionts if they are to be suppressed at first.');
    assert(sum(startSymFractions) == 1.0, 'Start fractions should sum to 1.');
end

