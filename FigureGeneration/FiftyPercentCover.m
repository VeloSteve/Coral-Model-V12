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
ct = 0;
figure();
for i = [0, 7, 9]
    ct = ct + 1;
    modeRows = T.Var10==i;
    rcp26 = sortrows(T(rows26 & modeRows, :), 12);
    plot(rcp26.Var12, rcp26.Var2, strcat(styles(ct), 'm'), 'LineWidth', 2.0);
    hold on;
    rcp45 = sortrows(T(rows45 & modeRows, :), 12);
    plot(rcp45.Var12, rcp45.Var2, strcat(styles(ct), 'c'), 'LineWidth', 2.0);
    rcp60 = sortrows(T(rows60 & modeRows, :), 12);
    plot(rcp60.Var12, rcp60.Var2, strcat(styles(ct), 'r'), 'LineWidth', 2.0);
    rcp85 = sortrows(T(rows85 & modeRows, :), 12);
    plot(rcp85.Var12, rcp85.Var2, strcat(styles(ct), 'b'), 'LineWidth', 2.0);
end
plot([0.5, 5], [50, 50], '-k');
xlim([0.5 4]);
xlabel("Second Symbiont Advantage [C]");
ylabel("Global Average Cover in 2100");
aaa = gca;
aaa.FontSize = 32;

% individual runs for rcp2.6 as a check.  E=0, OA=0.
% mode 0 60.2
% mode 7 60.2
% mode 9 44.6
