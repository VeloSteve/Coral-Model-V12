% Goal:
% Given curves for 5 temperatures, 4 SST paths, and 2 coral types (plus sum)
% make 1 plot per climate scenario, each with 5 curves for total cover.
% Beside each, plot the percent branching coral, for a total of 10 plots in
% the figure.

close all;

titles = { ...
    'RCP 2.6', ...
    'RCP 4.5', ...
    'RCP 6.0', ...
    'RCP 8.5', ...
    };

lineColor = {[1 0.5 0], 'r', 'b', 'm'};

scenario = {'26', '45', '60', '85'};
deltaT = [0, 1, 2];

fig = figure('color', 'w');
%set(gcf,...
%    'OuterPosition',[11 1 1920 1440]);
set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 13, 18]);

nS = length(scenario);
nT = length(deltaT);
% Subplot arguments are rows, columns, counter by rows first
% Each scenario will have one row with two plots.
for i = 1:nS
    % Each deltaT will be a line in each plot.
    for j = 1:nT
        names{j} = strcat('MeanCoralCover_rcp', scenario{i}, '_E1OA0_SymStrategy0Adv', num2str(deltaT(j)), '.00C');
    end
    names = strcat('D:/CoralTest/V12-thesis/WholeDegree_fig/', names);
    % Get the figure handles for all temps in the current scenario
    for j = 1:nT
        p1 = open(strcat(names{j},'.fig'));
        pax(j) = gca;
        figHandles(j) = p1;
    end
    
    % Now each figHandle contains the curves we need in
    % figHandles(j).Children(2).Children
    % In which items 2-3 are lines for Total, Branching, and Massive coral

    % The last figure read is now "gcf", but we want the main figure now.
    figure(fig);

    % Left plot
    P = subplot(nS, 2, 1 + 2*(i-1)); % rows, columns, plot (across before down)
    %copyobj(get(pax(1),'children'),P);
    
    for j = 1:nT
        lines = findobj(pax(j), 'Type', 'line');
        line = lines(1); % 1 is total cover, 2 branching, 3 massive
        line.Color = lineColor{j};
        line.LineWidth = 2;
        copyobj(line, P);
        branchRatio(j, 1:length(lines(1).XData)) = 100.0 * lines(2).YData ./ lines(1).YData;
    end
    xd = lines(1).XData;
    
    %n = strrep(names{i}, '_', ' ');
    %title(titles{i});
    ylabel('%K');

    %xlim([1850 2100]);
    %set(gca, 'XTick', [1850 1900 1950 2000 2050 2100]);
    set(P,'FontSize',22);
    
    % Right plot
    P = subplot(nS, 2, 2 + 2*(i-1)); % rows, columns, plot (across before down)
    for j = 1:nT
        plot(P, xd, branchRatio(j, :), 'Color', lineColor{j}, 'LineWidth', 2);
        hold on;
    end
    ylabel('% Branching');
    set(P,'FontSize',22);

    close(figHandles(1:nT));
end


%leg = legend('show');
leg = legend('Native', '1 C assist', '2 C assist');
set(leg,...
    'Location','southwest',...
    'FontSize',18);
    % 'Position',[0.858 0.489 0.140 0.162],...

