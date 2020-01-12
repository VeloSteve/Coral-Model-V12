names = { ...
    'GlobalCoralCover_rcp26_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp45_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp85_E0OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp26_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp45_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp85_E0OA0_SymStrategy9Adv1.00C', ...
    'GlobalCoralCover_rcp26_E1OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp45_E1OA0_SymStrategy9Adv0.00C', ...
    'GlobalCoralCover_rcp85_E1OA0_SymStrategy9Adv0.00C'
    
    };
names = strcat('../FigureData/CoverPanels_Figure2/', names);
titles = { ...
    '(a) RCP 2.6', ...
    '(b) RCP 4.5', ...
    '(c) RCP 8.5', ...
    '(d)', ... 
    '(e)', ...
    '(f)', ...
    '(g)', ... 
    '(h)', ...
    '(i)'};
for i = 1:length(names)
    n = names{i};
    p1 = open(strcat(n,'.fig'));
    pax(i) = gca;
end

figure('color', 'w');
set(gcf,...
    'OuterPosition',[11 1 1440 1440]);

% Subplot arguments are rows, columns, counter by rows first
for i = 1:length(names)
    P = subplot(3,3,i);
    copyobj(get(pax(i),'children'),P);
    %n = strrep(names{i}, '_', ' ');
    title(titles{i});
    xlim([1950 2100]);
    if mod(i, 3) == 1 
        ylabel('%K');
        set(gca, 'XTick', [1950 2000 2050 2100]);
    else
        set(gca, 'XTick', [2000 2050 2100]);
    end
    set(P,'FontSize',28);
    % Make subplots a little wider. (kept as an example)
    %pos = get(gca, 'Position');
    %pos(1) = pos(1) - 0.005;
    %pos(3) = pos(3) + 0.01;
    %set(gca, 'Position', pos);
end

%leg = legend('show');
%set(leg,...
%    'Position',[0.858 0.489 0.140 0.162],...
%    'FontSize',18);
