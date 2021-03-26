% Replace the June 2020 version of figure S6 with one based on Figure 2 from
% Baskett et al. 2009.
% It has rows for SST, genotype, symbiont density, and coral
% populations, plus markers for bleaching events (and perhaps other events).
% All of this is for one reef, and there are 3 columns showing the same reef and
% data for other climate scenarios.
% Inputs: SST data direct from the climat input.
%           BleachingHistory data written from Stats_Tables (XXX - need separate
%           reef data!)
%           DetailedSC_Reef[n] data written from the main function.
%           gi_Reef[n] data written from the main function.
% Approach:
%   - Run for a single reef, which is hardwired but could become a parameter.
%   - For the first RCP, make all 4 plot types and place in a column.
%   - Repeat, building column-by-column.
%
% Note that at least one input file is written only for "dataReefs" in the main
% program.  Latest set: 36, 46, 106, 144, 402, 420, 1239.  "k" must be in
% dataReefs.
k = 36; % sample reef

rcpList = {'rcp45'};
rcpName = {'RCP 4.5'};
columns = length(rcpList);
xRange = [2005 2025];
xTick = [2000 2005 2010 2015 2020 2025];
axisYears =  string(xTick); % num2str does the wrong thing, creating a single string
axisNums = firstDayNum(xTick);
    
% Where run outputs are stored for the latest model version:
dataPath = 'D://CoralTest/Nov2020_CurveE221_Target5/';
for i = 1:columns
    scPath{i} = strcat(dataPath, 'ESM2M.', rcpList(i), '.E0.OA0.sM9.sA1.0.20201114_maps/');
    giPath{i} = strcat(scPath{i}, 'gi/');
    % note that gi files have reef numbers zero-padded to 4 digits, SC is unpadded.
end

addpath('..'); % for tight_subplot

critical = 0.25; % Fraction of reefs signifying a critical bleaching year.
smooth = 1;  % 1 means no smoothing, n smooths over a total of n adjacent points.

figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1, 8, 12]);

columns = length(rcpList);
rows = 2;

% Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
% E=1, shuffle = 1.
mkr = {'o', '^', 'v', 'h'};
legendColumn = [1 1 1];
lineWidth = 2;

%             tight_subplot(Nh, Nw, gap, marg_h, marg_w, ratio_w)
[splots, ~] = tight_subplot(rows, columns, 0.06, [], [0.1 0.05]);

for i = 1:columns
    rcp = rcpList{i};

    %sp = subplot(rows, columns, i);
    axes(splots(1));
    plotSST(k, rcp, smooth, xRange, axisNums, lineWidth);
    addGenotype(k, giPath{i}, xRange, axisNums, legendColumn(1)==i, lineWidth);
    set(splots(1),'FontSize',14,'FontWeight','bold');

    %sp = subplot(rows, columns, i + 1*columns);
    axes(splots(2));
    plotSDensity(k, scPath{i}, xRange, axisNums, axisYears, legendColumn(2)==i, lineWidth);
    set(splots(2),'FontSize',14,'FontWeight','bold');

    if rows >= 3
        %sp = subplot(rows, columns, i + 2*columns);
        plotCPop(k, scPath{i}, xRange, axisNums, axisYears, legendColumn(3)==i, lineWidth);
        set(splots(3),'FontSize',14,'FontWeight','bold');
    end

end
% sgtitle(['Reef ' num2str(k)], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');


function plotSST(k, rcp, smooth, xRange, axisNums, lineWidth) 
    % Get temperature data
    [~, time, T] = getTemps(rcp, 'month', 0, smooth, k);
    fprintf('Plotting SST for %s.\n', rcp);
    plot(time, T, 'Color', 'black', 'LineWidth', lineWidth, 'DisplayName', 'SST');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);
    %yOld = ylim;
    %ylim([floor(yOld(1)) ceil(yOld(2))]);
    ylim([26 31]);

    set(gca,'XGrid', 'on', 'XTick', axisNums, 'XTickLabel', []);

    title([rcp '  Reef ' num2str(k)]);
end

function addGenotype(k, path, xRange, axisNums, showLegend, lineWidth) 
    hold on; % Adding to the plot above.
    % Note that the input files are written only if saveGi is true in the main
    % program.
    load(strcat(char(path), 'gi_Reef', num2str(k, '%04d'), '.mat'), 'gi');
    load(strcat(char(path), 'time.mat'), 'time');  % In MATLAB units
    plot(time, gi(:, 1), 'LineWidth', lineWidth, 'DisplayName', 'Sensitive symbiont');
    plot(time, gi(:, 3), 'LineWidth', lineWidth, 'DisplayName', 'Tolerant symbiont');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);

    ylabel('Temperature ({\circ}C)');
    if showLegend
        ll = legend('FontSize', 12, 'FontWeight', 'normal', 'Location', 'south', ...
            'Orientation', 'horizontal');
        %ll.Position = ll.Position + [0.01 -0.027 0 0];
    end

    hold off;
end

function plotSDensity(k, path, xRange, axisNums, axisYears, showLegend, lineWidth)
    % Load variables C, S, and time, all stored monthly.
    load(strcat(char(path), 'DetailedSC_Reef', num2str(k, '%d'), '.mat'), 'C', 'S', 'time', 'bleachEvent');
    inLegend(1) = plot(time, S(:,1)./C(:,1), '-r', 'LineWidth', lineWidth, 'DisplayName', 'Mounding')
    hold on
    inLegend(2) = plot(time, S(:,2)./C(:,2), '-b', 'LineWidth', lineWidth, 'DisplayName', 'Branching')
    inLegend(3) = plot(time, S(:,3)./C(:,1), '--r', 'LineWidth', lineWidth, 'DisplayName', 'Mounding, 1C advantage')
    inLegend(4) = plot(time, S(:,4)./C(:,2), '--b', 'LineWidth', lineWidth, 'DisplayName', 'Branching, 1C advantage')
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', axisYears, 'XGrid', 'on');

    ylabel('Symbionts (cells/cm^2)');
    % ylabel('Symbiont Density (cells/cm^2)');
    
    
    % Add Bleaching events
    yearsMass = find(bleachEvent(:, 1));
    yearsBran = find(bleachEvent(:, 2));


    % Events are stored by year, not with an exact date.  Add 182 to place them
    % roughly mid-year.
    yearsMass = 182 + firstDayNum(1860 + yearsMass);
    yearsBran = 182 + firstDayNum(1860 + yearsBran);

    if ~isempty(yearsMass)
        scatter(yearsMass, zeros(length(yearsMass), 1), 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red');
    end
    if ~isempty(yearsBran)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
        scatter(yearsBran, zeros(length(yearsBran), 1), 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
    end
    if showLegend
        ll = legend(inLegend, 'FontSize', 11, 'FontWeight', 'normal', 'Location', 'north')
        ll.NumColumns = 2;
        % ll.Position = ll.Position + [0.0 0.005 0 0];
        %ll.Position = ll.Position + [0.0 -0.012 0 0];
    end
end

function plotCPop(k, path, xRange, axisNums, axisYears, showLegend, lineWidth)
    % Note that the input file is written only for "dataReefs" in the main
    % program.  Latest set: 36, 46, 106, 144, 402, 420, 1239
    % Load variables C, S, and time, all stored monthly.
    load(strcat(char(path), 'DetailedSC_Reef', num2str(k, '%d'), '.mat'), 'C', 'time', 'bleachEvent');
    plot(time, C(:,1), '-r', 'LineWidth', lineWidth, 'DisplayName', 'Mounding')
    hold on
    plot(time, C(:,2), '-b', 'LineWidth', lineWidth, 'DisplayName', 'Branching')
    xlim(firstDayNum(xRange));
    set(gca,'XGrid','on','XTick', axisNums, 'XTickLabel', axisYears);
    ylabel('Coral Cover (cm^2)');
    if showLegend
        legend('FontSize', 11, 'FontWeight', 'normal', 'Location', 'north', 'Orientation', 'horizontal');
    end
            
    hold off;
end



function [bleachYears] = getBleachYears(fracBleached, years, critical)
    % The input is the percent of healthy reefs.  Consider that a drop of 50% of
    % the remaining healthy reefs is a critical bleaching year.
    critBleach  = fracBleached > critical;
    bleachYears = years(critBleach);
end
