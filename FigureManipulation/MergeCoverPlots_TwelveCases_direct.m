if ~exist('runOutputs', 'var')
    error("Script requires the source directory runOutputs to be set.");
end
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
%names = strcat('../FigureData/CoverPanels_Figure2/', names);
names = strcat(runOutputs, '*\', names, '.fig');

titles = { ...
    {'RCP 2.6',''}, ...
    {'RCP 4.5','No Adaptation'}, ...
    {'RCP 8.5',''}, ...
    '', ... 
    {'Symbiont Shuffling'}, ...
    '', ...
    '', ... 
    {'Symbiont Evolution'}, ...
    '', '', ...
    {'Symbiont Shuffling and Evolution'}, ...
    ''};


mainFig = figure('color', 'w');
set(gcf,...
    'Units', 'inches', ...
    'OuterPosition',[0  0 8.5 8.5]);

% Subplot arguments are rows, columns, counter by rows first
for i = 1:length(names)
    n = names{i};
    ddd = dir(n);
    
    
    hSingle = open(strcat(ddd(1).folder, '\', ddd(1).name));
    drawnow;  % Be sure the incoming figure is ready before copying parts.
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
            yl.Position = yl.Position + [-20 -85 0];
        end
        %ylabel(rowLabel{(i-1)/3 + 1});
        set(gca, 'XTick', [1950 2000 2050 2100]);
    else
        set(gca, 'XTick', [2000 2050 2100]);
    end
    set(P,'FontSize',14);
    % Make subplots a little wider. (kept as an example)
    %pos = get(gca, 'Position');
    %pos(1) = pos(1) - 0.005;
    %pos(3) = pos(3) + 0.01;
    %set(gca, 'Position', pos);
    if i == 3
        ppp = get(P, 'children');
        ll = legend([ppp(1) ppp(2)], "Branching", "Mounding", ...
            'FontSize', 11, 'Location', 'northeast', 'LineWidth', 1.5);
        % ll.Position = ll.Position + [0.04 0.04 0 0];
        ll.Position = ll.Position + [0.03 0.022 0 0];
    end
    %drawnow;
    close(hSingle);
end

%% Draw lines above row titles
annotation(mainFig,'line',[0.09 0.92], [0.945 0.945], 'LineWidth', 1.5);
annotation(mainFig,'line',[0.09 0.92], [0.725 0.725], 'LineWidth', 1.5);
annotation(mainFig,'line',[0.09 0.92], [0.505 0.505], 'LineWidth', 1.5);
annotation(mainFig,'line',[0.09 0.92], [0.287 0.287], 'LineWidth', 1.5);

%% Output
if (exist('figureDir', 'var') == 1) && (length(figureDir) > 0)
    fullName = strcat(figureDir, 'Figure2_', runID);
    %saveas(mainFig, strcat(fullName, ".png"));
    savefig(strcat(fullName, '.fig'));
    addpath('..');
    saveCurrentFigure(fullName);
end
