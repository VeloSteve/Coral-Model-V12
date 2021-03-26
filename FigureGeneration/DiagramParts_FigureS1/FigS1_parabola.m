% A Normal distribution to use as a phenotype graph in Figure S1
mainFig = figure('color', 'w');
set(gcf,...
    'Units', 'inches', ...
    'Position',[1  1 3.0 2.7]);

x = [-5:0.1:5];
y = 25 - x.*x;
plot(x, y, '-k', 'LineWidth', 2);
xlim([-6 6]);
ylim([0 30]);
hold on;
set(gca, 'FontSize', 14);
xlabel('Phenotype');
ylabel('Population growth rate');
yticks([15]);
yticklabels('r_i_m(t)');
ytickangle(90);
xticks(0);
xticklabels('\Theta(t)');
box off
% Exaggerate the tick at zero, which is g
plot([0 0], [0 max(y)/10], '-k', 'LineWidth', 3);
%title('Environmental effects', 'FontWeight', 'normal');
% Arrow across the middle of the curve.
annotation(mainFig,'doublearrow',[0.388 0.74], [0.57 0.57], 'LineWidth', 1.5);
% Above the line
annotation(gcf, 'textbox', ...
    [0.48, 0.71, 0.03, 0.03], ...
    'String', '\sigma_w_m', ...
    'FontSize', 14, 'FitBoxToText', 'on', 'LineStyle', 'none');
% Below the line
annotation(gcf, 'textbox', ...
    [0.39, 0.55, 0.03, 0.03], ...
    'String', ["(coral host-"; "dependent)"], ...
    'FontSize', 14, 'FitBoxToText', 'on', 'LineStyle', 'none');
saveCurrentFigure("C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\VectorBlackWhite\Fitness")
