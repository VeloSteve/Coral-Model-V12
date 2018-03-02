function hughesPlot(events, runStart, txt, base)
    % Plot cumulative bleaching events starting in 1980, similar to Hughes et
    % al. 2018, Figure S2B.
    first = 1980;
    last = 2016;
    firstI = first - runStart + 1;
    lastI = last - runStart + 1;
    
    if nargin == 4
        baseline = base;
    else
        baseline = events(firstI-1);
    end
    % Subset and subtract baseline
    events = events(firstI:lastI) - baseline;
    figure();
    ax = gca;
    plot(ax, first:last, events);
    ylim([0 230]);
    xlim([first-1, last+1]);
    title(txt);
end

