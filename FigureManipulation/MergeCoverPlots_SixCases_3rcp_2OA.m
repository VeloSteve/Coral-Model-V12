names = { ...
    'GlobalCoralCover_rcp26_E0OA0_SymStrategy0Adv0.00C', ...
    'GlobalCoralCover_rcp45_E0OA0_SymStrategy0Adv0.00C', ...
    'GlobalCoralCover_rcp85_E0OA0_SymStrategy0Adv0.00C', ...
    'GlobalCoralCover_rcp26_E1OA0_SymStrategy0Adv0.00C', ...
    'GlobalCoralCover_rcp45_E1OA0_SymStrategy0Adv0.00C', ...
    'GlobalCoralCover_rcp85_E1OA0_SymStrategy0Adv0.00C'   
    };
names = strcat('D:/CoralTest/V11Test/gatherCoverPlots/', names);
titles = { ...
    'RCP 2.6', ...
    'RCP 4.5', ...
    'RCP 8.5', ...
    'RCP 2.6 E=1', ... 
    'RCP 4.5 E=1', ...
    'RCP 8.5 E=1'};
for i = 1:length(names)
    n = names{i};
    p1 = open(strcat(n,'.fig'));
    pax(i) = gca;
    figHandles(i) = p1;
end

figure('color', 'w');
set(gcf,...
    'OuterPosition',[11 1 1920 1440]);

% Subplot arguments are rows, columns, counter by rows first
for i = 1:length(names)
    P = subplot(2,3,i);
    copyobj(get(pax(i),'children'),P);
    %n = strrep(names{i}, '_', ' ');
    if i <= 3
        title(titles{i});
    end
    if ~mod(i-1, 3)
        ylabel('%K');
    end
    xlim([1950 2100]);
    set(gca, 'XTick', [2000 2050 2100]);
    set(P,'FontSize',28);
    close(figHandles(i));
end

%{
leg = legend('show');
set(leg,...
    'Position',[0.858 0.489 0.140 0.162],...
    'FontSize',18);
%}
