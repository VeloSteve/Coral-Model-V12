function hughesPlot(events, runStart)
    % Plot cumulative bleaching events starting in 1980, similar to Hughes et
    % al. 2018, Figure S2B.
    first = 1980;
    last = 2020;
    firstI = first - runStart + 1;
    lastI = last - runStart + 1;
    
    baseline = events(firstI-1);
    % Subset and subtract baseline
    events = events(firstI:lastI) - baseline;
    figure();
    ax = gca;
    plot(ax, first:last, events);
    ylim([0 200]);
end

