% To use this, put the old Figure 1 on the screen and then run this script.

% Flip all curves on all axes.
fig = gcf;
axList = findall(fig, 'type', 'axes');
for a = 1:4
    set(fig, 'currentaxes', axList(a));
    aux = get(gca, 'Children');
    for i = 1:4
        y = get(aux(i), 'YData');
        set(aux(i), 'YData', 100-y);
    end
end

% Legend position is relative to the entire figure, not the axis
% it falls in.  Move it down so it doesn't hide the curves.
leg = findall(fig, 'type', 'legend');
leg.Position(2) = 0.5615

% Change the y label
textItems = findall(fig, 'type', 'text')
for t = 1:length(textItems)
    text = textItems(t);
    if contains(text.String, 'Percent')
        textItems(t).String = 'Percent of healthy coral reefs globally';
        break
    end
end

