% A utility script to plot symbiont densities from one-reef S and C
% arrays which have been loaded by hand.  This is typically from files named as
% DetailedSC_Reef36.mat which include C, S, temperature, and time.

V1 = figure();
set(gcf, 'Units', 'inches', 'Position', [2, 0, 10, 5]);

plot(time, S(:,1)./C(:,1), '-r', 'LineWidth', 1, 'DisplayName', 'Mounding')
hold on
plot(time, S(:,2)./C(:,2), '-b', 'LineWidth', 1, 'DisplayName', 'Branching')
plot(time, S(:,3)./C(:,1), '--r', 'LineWidth', 1, 'DisplayName', 'Mounding, 1C advantage')
plot(time, S(:,4)./C(:,2), '--b', 'LineWidth', 1, 'DisplayName', 'Branching, 1C advantage')
ylabel('Symbiont Density in Coral');
yticks([0 1e6 2e6 3e6 3.5e6]);
yyaxis right

% Now we plot SST in response to a reviewer suggestion.
plot(time, temp, 'Color', [0 0 0], 'DisplayName', 'SST (\circ C)', 'Marker','none',...
    'LineStyle','-');
ylabel('SST ({\circ}C)');
yticks([26 27 28 29 30 31]);

axisYears =  {'1900','1920','1925','1926','1927','1928','1930'};
axisNums = firstDayNum(axisYears)';
set(gca,'XGrid','on','XTick', axisNums, 'XTickLabel', axisYears);

xlim([firstDayNum(1925), firstDayNum(1928)])
xlabel('Year');
legend('Location', 'southwest')

% ====================
% Another time range
% Copy the previous figure's contents
axisYears =  {'1980','1990','2000', '2010'};
V2 = reRange(gca, axisYears, 4);


% ====================
% A THIRD time range
% Copy the previous figure's contents
axisYears =  {'2000', '2005', '2010', '2015', '2020'};
V3 = reRange(gca, axisYears, 8);
ylim([26 32]);


% Use data from an existing figure but adjust ranges.
function [newFig] = reRange(original, axisYears, yPlace) 
    % Copy parts of the old plot.
    axes(original);
    yyaxis left
    childrenL = get(original, 'Children');

    yyaxis right
    childrenR = get(original, 'Children');
    % Make a new one and populate it
    newFig = figure();
    set(gcf, 'Units', 'inches', 'Position', [2, yPlace, 10, 5]);

    % Build the new plot.
    axNew = axes();
    set(axNew,'FontSize',14,'FontWeight','bold');
    copyobj(childrenL, axNew);
    ylabel('Symbiont Density in Coral');  % not copied
    ylim([0 3.5e6]);
    yticks([0 1e6 2e6 3e6 3.5e6]);

    yyaxis right
    copyobj(childrenR, gca);
    ylabel('SST ({\circ}C)');
    yticks([24 26  28  30  32]);
    temp = gca;
    temp.YColor = 'black';

    axisNums = firstDayNum(axisYears)';
    set(gca,'XGrid','on','XTick', axisNums, 'XTickLabel', axisYears);

    xlim([firstDayNum(axisYears(1)), firstDayNum(axisYears(end))])
    legend('Location', 'north')
   
end