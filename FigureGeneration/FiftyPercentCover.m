T = readtable('..\FigureData\Cover50PctStats.txt', 'ReadVariableNames', 0);

% Variable number and meaning
% 2 cover
% 4 rcp, 6 E, 8 OA
% 10 superMode, 12 superAdvantage
dt = T.Var12;

rows26 = strcmp(T.Var4, 'rcp26');
rows45 = strcmp(T.Var4, 'rcp45');
rows60 = strcmp(T.Var4, 'rcp60');
rows85 = strcmp(T.Var4, 'rcp85');
rowsmode0 = T.Var10==0;
rowsmode7 = T.Var10==7;
rowsmode9 = T.Var10==9;

styles = ["-", "--", ":"];
colors = [26 26 204; 158 203 145; 225 143 29; 200 51 0]/255;
lw = 4;
ct = 0;
fh = figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 17, 11]);
%for i = [0, 7, 9]
for i = [7, 9]
    ct = ct + 1;
    modeRows = T.Var10==i;
    
    rcp26 = sortrows(T(rows26 & modeRows, :), 12);
    ph(ct, 1) = plot(rcp26.Var12, rcp26.Var2, styles(ct), 'Color', colors(1, :), 'LineWidth', lw);
    hold on;
    rcp45 = sortrows(T(rows45 & modeRows, :), 12);
    ph(ct, 2) = plot(rcp45.Var12, rcp45.Var2, styles(ct), 'Color', colors(2, :), 'LineWidth', lw);
    rcp60 = sortrows(T(rows60 & modeRows, :), 12);
    ph(ct, 3) = plot(rcp60.Var12, rcp60.Var2, styles(ct), 'Color', colors(3, :), 'LineWidth', lw);
    rcp85 = sortrows(T(rows85 & modeRows, :), 12);
    ph(ct, 4) = plot(rcp85.Var12, rcp85.Var2, styles(ct), 'Color', colors(4, :), 'LineWidth', lw);
end
plot([0.5, 5], [50, 50], '-k', 'LineWidth', 2.0);
xlim([0.5 4]);
xlabel("Temperature (°C)");
ylabel("Global Average Cover in 2100");
%legend(ph(1, :), "RCP 2.6",       "RCP 4.5",       "RCP 6.0",        "RCP 8.5", "Location", "best");
%grid("on");
aaa = gca;
set(aaa, 'FontSize',30,'XTick',[ 1 2 3 4 ],...
        'YTick',[0  50  100], 'LineWidth', 2.0, 'GridAlpha', 0.25);

annotation(fh,'textbox',...
    [0.142544117647059 0.856 0.0482718922815791 0.0579347580280418],...
    'String','RCP 2.4',...
    'LineStyle','none',...
    'FontSize',24,...
    'FitBoxToText','off');

% Create textbox
annotation(fh,'textbox',...
    [0.154954915040791 0.637720488466756 0.0482718922815791 0.0579347580280418],...
    'String','RCP 4.5',...
    'LineStyle','none',...
    'FontSize',24,...
    'FitBoxToText','off');

% Create textbox
annotation(fh,'textbox',...
    [0.237486717709112 0.546811397557665 0.048271892281579 0.0579347580280418],...
    'String','RCP 6.0',...
    'LineStyle','none',...
    'FontSize',24,...
    'FitBoxToText','off');

% Create textbox
annotation(fh,'textbox',...
    [0.428612997572592 0.352781546811396 0.0482718922815791 0.0579347580280418],...
    'String','RCP 8.5',...
    'LineStyle','none',...
    'FontSize',24,...
    'FitBoxToText','off');
