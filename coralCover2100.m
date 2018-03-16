function coralCover2100(C_yearly, coralSymConstants, startYear)
    % C_yearly has year/reef/coral type
    % For now just look at 2100.
    y = (2100-startYear);
    %{
    Version 1 - sum all reefs and corals, divide by sum of K values.
    C_2100 = squeeze(C_yearly(y, :, :));
    % Across all reefs
    means = mean(C_2100, 1);
    logTwo("Percent coral cover relative to carrying capacity at 2100 is ");
    logTwo("%4.1f for massive, %4.1f for branching, and %4.1f combined.\n", ...
        100*means(1)/coralSymConstants.KCm, ...
        100*means(2)/coralSymConstants.KCb, ...
        100*sum(means)/(coralSymConstants.KCm + coralSymConstants.KCb)); 
    %}
    % Version 2 - calculate cover for each reef separately, then average.
    % For one reef, cover is % cover for branching plus % for massive, summed
    % and capped at 1.
    C_2100 = squeeze(C_yearly(y, :, :));
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
