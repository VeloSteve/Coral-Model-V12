% This generates Figure 2 in the submitted paper, but with an extra row showing
% results with evolution and shuffling.
names = { ...
    'GlobalCoralCover_rcp26_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp45_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp85_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp26_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp45_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp85_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp26_E1OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp45_E1OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp85_E1OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp26_E1OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp45_E1OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp85_E1OA0_SymStrategy9Adv1.00C'
    };
names = strcat('../FigureData/CoverPanels_Figure2/', names);

titles = { ...
    {'RCP 2.6',''}, ...
    {'RCP 4.5','No Adaptation'}, ...
    {'RCP 8.5',''}, ...
    '', ... 
    {'Symbiont Shuffling'}, ...
    '', ...
    '', ... 
    {'Evolution'}, ...
    '', '', ...
    {'Symbiont Shuffling and Evolution'}, ...
    ''};


mainFig = figure('color', 'w');
set(gcf,...
    'OuterPosition',[11 1 1440 1440]);

% Subplot arguments are rows, columns, counter by rows first
for i = 1:length(names)
    n = names{i};
    hSingle = open(strcat(n, '.fig'));
    drawnow;
    paxSingle(i) = gca;
    figure(mainFig);
    P = subplot(length(names)/3, 3, i); % rows, then columns
    copyobj(get(paxSingle(i),'children'),P);
    %n = strrep(names{i}, '_', ' ');
    title(titles{i});
    xlim([1950 2100]);
    if mod(i, 3) == 1 
        if i == 4 % Now just do one since it is long
            yl = ylabel('Relative Coral Extent');
            yl.Position = yl.Position + [-20 -85 0]
        end
        %ylabel(rowLabel{(i-1)/3 + 1});
        set(gca, 'XTick', [1950 2000 2050 2100]);
    else
        set(gca, 'XTick', [2000 2050 2100]);
    end
    set(P,'FontSize',27);
    % Make subplots a little wider. (kept as an example)
    %pos = get(gca, 'Position');
    %pos(1) = pos(1) - 0.005;
    %pos(3) = pos(3) + 0.01;
    %set(gca, 'Position', pos);
    if i == 3
        ppp = get(P, 'children');
        legend([ppp(1) ppp(2)], "Branching", "Mounding", ...
            'FontSize', 24, 'Location', 'northeast', 'LineWidth', 2);
    end
    drawnow;
    close(hSingle);
end
