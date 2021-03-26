function shuffleStats(S_yearly, coralSymConstants, S_seed, startYear, saveDir)
    % S_yearly has dimensions year/reef/symbiont
    if size(S_yearly, 3) == coralSymConstants.Sn
        % No alternate symbionts, so there no shuffling.
        return;
    end
    % S_yearly has columns year/reef/symbiont population
    
    % Unlike the branching dominance check, look at all years.
    % It would be quicker to combine branching and massive, but start by doing
    % them separately to maximize what we can learn.
    assert(size(S_yearly, 3) == 4, "This only works for 4 symbionts.");
    % Get the fraction of tolerant symbionts at all times.
    fraction = S_yearly(:, :, 3:4)./(S_yearly(:, :, 1:2) + S_yearly(:, :, 3:4));
    % Let the last dimension of tooLow represent the tolerant symbiont in 
    % massive and branching corals.
    tooLow = false(size(S_yearly, 1), size(S_yearly, 2), 3);
    % Max values of S are around 8E13, and the minimum based on the product
    % of seeds is 1.6484E11 for massive and 4.2025E9 for branching.
    tooLow(:, :, 1) = S_yearly(:, :, 3) < 4 * 1.65E11; % * S_seed(1);
    tooLow(:, :, 2) = S_yearly(:, :, 4) < 4 * 4.20E9; % * S_seed(2);
    
    reefCount = size(S_yearly, 2);
    yearCount = size(S_yearly, 1);
    stopAt = NaN(reefCount, 2);
    for i = 1:reefCount
        tll = find(~tooLow(:, i, 1), 1, 'last');
        if isempty(tll)
            % For a test case with RCP 4.5, E=1, no reefs come here.
            stopAt(i, 1) = 1;
        else
            stopAt(i, 1) = tll;
        end
        tll = find(~tooLow(:, i, 2), 1, 'last');
        if isempty(tll)
            % For a test case with RCP 4.5, E=1, shuffling with a 1C advantage
            % the reefs that come here are 610, 616, 621, 630,638, and 1925.
            stopAt(i, 2) = 1;
        else
            stopAt(i, 2) = tll;
        end
    end
   
    foo = 1861:1861+yearCount-1;
    %{
    % Note that the DisplayNames will be wrong if not all reefs are used, since
    % they are just numbered consecutively.
    figure()
    hold on;
    for i = 1:reefCount
        plot(foo(1, 1:stopAt(i, 1)), fraction(1:stopAt(i, 1), i, 1), 'DisplayName', strcat('Reef ',num2str(i)));
    end
    title({"Symbionts in Massive Corals", "one curve per reef"});
    xlabel("year");
    ylabel("fraction of tolerant symbionts");
    
    figure()
    hold on;
    for i = 1:reefCount
        plot(foo(1, 1:stopAt(i, 2)), fraction(1:stopAt(i, 2), i, 2), 'DisplayName', strcat('Reef ',num2str(i)));
    end
    title({"Symbionts in Branching Corals", "one curve per reef"}); %#ok<CLARRSTR>
    xlabel("year");
    ylabel("fraction of tolerant symbionts");
    %}
    % Now make a single curve show the fraction of reefs dominated by tolerant
    % symbionts.  Define this as 0.6 or greater, since 0.5 appears at the start
    % and when both are at seed values.
    % Original, including dead reefs:
    %flags = fraction(:, :, :) > 0.6;
    %reefs = size(fraction, 2);
    %globalFraction = squeeze(sum(flags, 2)/reefs);    
    % Only include reefs which are not permantly below the "stopAt" index.
    flags = fraction(:, :, :) > 0.6;
    globalFraction = NaN(size(S_yearly, 1), 2);
    % Here, fraction is fraction(year, reef, symbiont)
    %       flags is similar, but booleans
    %       stopAt is stopAt(reef, symbiont type)
    
    % Build an array showing where reefs are to be counted.  The compute
    % the sum of flags for just those reefs divided by the count of those reefs.
    validFlags = true(size(flags));
    for i = 1:reefCount
        if stopAt(i, 1) < yearCount
            validFlags(stopAt(i, 1)+1:yearCount, i, 1) = false;
        end
        if stopAt(i, 2) < yearCount
            validFlags(stopAt(i, 2)+1:yearCount, i, 2) = false;
        end
    end
    % Get the value for each year
    flags = flags .* validFlags;
    for y = 1:yearCount
        globalFraction(y, 1) = sum(flags(y, :, 1)) / sum(validFlags(y, :, 1));
        globalFraction(y, 2) = sum(flags(y, :, 2)) / sum(validFlags(y, :, 2));
    end
    
    
    figure()
    plot(foo(1,:), globalFraction(:, 1), 'DisplayName', 'In Massive');
    hold on;
    plot(foo(1,:), globalFraction(:, 2), 'DisplayName', 'In Branching');
    title("Dominance of Tolerant Symbionts");
    xlabel("year");
    ylabel("Fraction");
    legend('Location', 'NorthWest');
    
    if verLessThan('matlab', '8.2')
        saveas(gcf, strcat(saveDir, 'SymbiontDominance'), 'fig');
    else
        fprintf('Saving coral cover as fig file.');
        savefig(strcat(saveDir, 'SymbiontDominance', '.fig'));
    end
    
    logTwo("Tolerant symbionts dominate in massive coral in %5.1f percent of the %5.1f percent of global reefs with significant populations.\n", 100*globalFraction(end, 1), 100*sum(stopAt(:,1)==240)/reefCount); 
    logTwo("Tolerant symbionts dominate in branching coral in %5.1f percent of the %5.1f percent of global reefs with significant populations.\n", 100*globalFraction(end, 2), 100*sum(stopAt(:,2)==240)/reefCount); 
    
    return;
    
    % For now just look at 2100.
    y = (2100-startYear);
    
    % Version 2 - calculate cover for each reef separately, then average.
    % For one reef, cover is % cover for branching plus % for massive, summed
    % and capped at 1.
    % With only one reef, we can't use squeeze because we need to retain the
    % reef (second) dimension, even if it is 1.
    if size(C_yearly,2) == 1
        C_2100 = C_yearly(y, 1, :);
        % remove the leading "1" dimension, but not the second.
        C_2100 = reshape(C_2100, [1, size(C_yearly, 3)]);
    else
        C_2100 = squeeze(C_yearly(y, :, :));
    end
    C_2100(:, 1) = C_2100(:, 1) / coralSymConstants.KCm;
    C_2100(:, 2) = C_2100(:, 2) / coralSymConstants.KCb;
    fraction_2100 = C_2100(:, 2)./(C_2100(:, 1)+C_2100(:, 2));
    flagBranchingDominant = (fraction_2100 > 0.5);
    branchingDominant = sum(flagBranchingDominant)/length(flagBranchingDominant);
    Csum = min(1.0, sum(C_2100, 2));
    flags = (Csum < 0.10);
    lowCover = 100*sum(flags)/length(flags);
    Cmean = 100.0*mean(Csum);
    logTwo("Global average percent coral cover: %4.1f \n", Cmean);
    logTwo("Percent of reefs with less than 10 pct cover: %4.1f \n", lowCover);
    logTwo("Fraction of reefs dominated by branching coral: %6.3f \n", branchingDominant);
end
