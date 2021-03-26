% A Normal distribution to use as a phenotype graph in Figure S1
mainFig = figure('color', 'w');
set(gcf,...
    'Units', 'inches', ...
    'Position',[1  1 3 2]);

x = [-3.5:.1:3.5];
y = normpdf(x,0,1);
plot(x, y, '-k', 'LineWidth', 2);
hold on;
set(gca, 'FontSize', 14);
xlabel('Phenotype');
ylabel('Frequency');
yticks([]);
xticks(0);
xticklabels('g');
box off;
% Exaggerate the tick at zero, which is g
plot([0 0], [0 max(y)/10], '-k', 'LineWidth', 3);
%title('Environmental effects', 'FontWeight', 'normal');
% Arrow across the middle of the curve.
annotation(mainFig,'doublearrow',[0.41 0.62], [0.53 0.53], 'LineWidth', 1.5);
annotation(gcf, 'textbox', ...
    [0.47, 0.68, 0.03, 0.03], ...
    'String', '\sigma_e', ...
    'FontSize', 14, 'FitBoxToText', 'on', 'LineStyle', 'none');
saveCurrentFigure("C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\VectorBlackWhite\EnvEff")
