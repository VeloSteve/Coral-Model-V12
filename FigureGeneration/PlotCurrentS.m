% A utility script to plot symbiont densities from one-reef S and C
% arrays which have been loaded by hand.

v1 = figure();
set(gcf, 'Units', 'inches', 'Position', [2, 0, 7, 5]);

plot(time, S(:,1)./C(:,1), '-r', 'LineWidth', 1, 'DisplayName', 'Mounding')
hold on
plot(time, S(:,2)./C(:,2), '-b', 'LineWidth', 1, 'DisplayName', 'Branching')
plot(time, S(:,3)./C(:,1), '--r', 'LineWidth', 1, 'DisplayName', 'Mounding, 1C advantage')
plot(time, S(:,4)./C(:,2), '--b', 'LineWidth', 1, 'DisplayName', 'Branching, 1C advantage')
ylabel('Symbiont Density in Coral');
yyaxis right
plot(time, S(:,1), 'Color', [0 1 0], 'DisplayName', 'Mounding Population', 'Marker','.',...
    'LineStyle','none');
ylabel('Symbiont Density in Reef Cell');

set(gca,'XGrid','on','XTick',...
    [693402 700763 702603 702971 703339 703707 704444 711804 722846 726526 730206 733887 735727 737568 739408],...
    'XTickLabel',...
    {'1900','1920','1925','1926','1927','1928','1930','1950','1980','1990','2000','2010', '2015', '2020', '2025'});

xlim([702603, 703707])
xlabel('Year');
legend('Location', 'southwest')

% Another time range
% Copy the previous figure's contents
yyaxis left
childrenL = get(gca, 'Children');
yyaxis right
childrenR = get(gca, 'Children');
% Make a new one and populate it
V2 = figure();
set(gcf, 'Units', 'inches', 'Position', [2, 4, 7, 5]);

axNew = axes();
copyobj(childrenL, axNew);
yyaxis right
copyobj(childrenR, gca);

set(gca,'XGrid','on','XTick',...
    [693402 700763 702603 702971 703339 703707 704444 711804 722846 726526 730206 733887 735727 737568 739408],...
    'XTickLabel',...
    {'1900','1920','1925','1926','1927','1928','1930','1950','1980','1990','2000','2010', '2015', '2020', '2025'});

xlim([722846, 733887])
legend('Location', 'north')

% A THIRD time range
% Copy the previous figure's contents
yyaxis left
childrenL = get(gca, 'Children');
yyaxis right
childrenR = get(gca, 'Children');
% Make a new one and populate it
V3 = figure();
set(gcf, 'Units', 'inches', 'Position', [2, 8, 7, 5]);

axNew = axes();
copyobj(childrenL, axNew);
yyaxis right
copyobj(childrenR, gca);

set(gca,'XGrid','on','XTick',...
    [693402 700763 702603 702971 703339 703707 704444 711804 722846 726526 730206 733887 735727 737568 739408],...
    'XTickLabel',...
    {'1900','1920','1925','1926','1927','1928','1930','1950','1980','1990','2000','2010', '2015', '2020', '2025'});

xlim([733887, 739408])
legend('Location', 'north')
