% Unlike the other merge scripts, this keeps one more or less intact and
% adds a few curves from the other.  Then legends are modified to suit.
today = '20170929';
names = {
    strcat('SDC_', today, '_144_normSSTrcp85_-18_-150_prop0.94_NF1_E0.fig'), ...
    strcat('SDC_', today, '_144_normSSTrcp85_-18_-150_prop0.86_NF1_E1.fig')   
};
names = strcat('D:\GoogleDrive\Coral_Model_Steve\_Paper Versions\Figures\Fig2_SSTDensityCoverDHM\', names);

% Open E=1 as the one to add to.
fig = openfig(names{2}, 'new');
sp2 = subplot(2,2,2)
sp3 = subplot(2,2,3)

% Improve labels for old lines.
oldLines = findobj(sp2, 'Type', 'line');
set(oldLines(1), 'DisplayName', 'Branching E=1');
set(oldLines(2), 'DisplayName', 'Massive E=1');
oldLines = findobj(sp3, 'Type', 'line');
set(oldLines(1), 'DisplayName', 'Branching E=1');
set(oldLines(2), 'DisplayName', 'Massive E=1');

other = open(names{1});
otherAx = gca;
otherFig = gcf;
% Upper right and lower left subplots:
sp2source = subplot(2,2,2)
sp3source = subplot(2,2,3)


% Get just the lines
sp2lines = findobj(sp2source, 'Type', 'line');
sp3lines = findobj(sp3source, 'Type', 'line');

% Fade colors for comparison (upper right).  Also update names.
set(sp2lines(1), 'Color', [0.5 0.5 1.0], 'DisplayName', 'Branching E=0');
set(sp2lines(2), 'Color', [1.0 0.5 1.0], 'DisplayName', 'Massive E=0');

% Darken colors for comparison (lower left)
set(sp3lines(1), 'Color', [0.0 0.5 0.0], 'DisplayName', 'Branching E=0');
set(sp3lines(2), 'Color', [0.5 0.5 0.0], 'DisplayName', 'Massive E=0');

copyobj(sp2lines, sp2);
copyobj(sp3lines, sp3);

allLines2 = findobj(sp2, 'Type', 'line');
allLines3 = findobj(sp3, 'Type', 'line');

legend(allLines2, 'Location', 'west');
legend(allLines3, 'Location', 'northeast');

close(otherFig);
