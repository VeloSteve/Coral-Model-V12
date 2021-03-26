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
% dataReefs.  Of this set, 46 is the most likely to show "back and forth"
% shuffling.
% Also, saveGi must be set true in A_Coral_Model
k = 58; % sample reef  

% ! set E in file name!
rcpList = {'rcp26'};
rcpName = {'RCP 2.6'};
columns = length(rcpList);
xRange = [2000 2100];
xTick = [1860 1880 1900 1910 1920 1930 1940 1950 1960 1970 1980 1990 1995 2000 2005 2010 2015 2020 2025];
axisYears =  string(xTick); % num2str does the wrong thing, creating a single string
axisNums = firstDayNum(xTick);
    
% Where run outputs are stored for the latest model version:
dataPath = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5_extraReefs\';
%dataPath = 'D://CoralTest/Feb2021_CurveE221_Target5/';
for i = 1:columns
    scPath{i} = strcat(dataPath, 'ESM2M.', rcpList(i), '.E1.OA0.sM9.sA1.0.20210309_maps/');
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

    % plotSDensity also adds the bleaching points.
    axes(splots(2));
    plotSDensity(k, scPath{i}, xRange, axisNums, axisYears, legendColumn(2)==i, lineWidth);
    set(splots(2),'FontSize',14,'FontWeight','bold');

    % XXX - not for the published version:
    % plotSST_bottomRight(k, rcp, smooth, xRange, axisNums, lineWidth);


    if rows >= 3
        %sp = subplot(rows, columns, i + 2*columns);
        plotCPop(k, scPath{i}, xRange, axisNums, axisYears, legendColumn(3)==i, lineWidth);
        set(splots(3),'FontSize',14,'FontWeight','bold');
    end

end
% sgtitle(['Reef ' num2str(k)], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
;


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

function plotSST_bottomRight(k, rcp, smooth, xRange, axisNums, lineWidth) 
    % Get temperature data
    [~, time, T] = getTemps(rcp, 'month', 0, smooth, k);
    fprintf('Plotting SST for %s.\n', rcp);
    yyaxis right;
    plot(time, T, 'Color', 'black', 'LineWidth', lineWidth, 'DisplayName', 'SST');

    %yOld = ylim;
    %ylim([floor(yOld(1)) ceil(yOld(2))]);
    ylim([24 31]);

    yyaxis left;
end
function addGenotype(k, path, xRange, axisNums, showLegend, lineWidth) 
    hold on; % Adding to the plot above.
    % Note that the input files are written only if saveGi is true in the main
    % program.
    giColor = [0.8290 0.5940 0.0250];
    load(strcat(char(path), 'gi_Reef', num2str(k, '%04d'), '.mat'), 'gi');
    load(strcat(char(path), 'time.mat'), 'time');  % In MATLAB units
    plot(time, gi(:, 1), '-', 'Color', giColor, 'LineWidth', lineWidth, 'DisplayName', 'Sensitive symbiont');
    plot(time, gi(:, 3), '--', 'Color', giColor, 'LineWidth', lineWidth+1, 'DisplayName', 'Advantaged symbiont');
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
    inLegend(1) = plot(time, S(:,1)./C(:,1), '-r', 'LineWidth', lineWidth, 'DisplayName', 'Mounding');
    hold on
    inLegend(2) = plot(time, S(:,2)./C(:,2), '-b', 'LineWidth', lineWidth, 'DisplayName', 'Branching');
    inLegend(3) = plot(time, S(:,3)./C(:,1), '--r', 'LineWidth', lineWidth, 'DisplayName', 'Mounding, 1C advantage');
    inLegend(4) = plot(time, S(:,4)./C(:,2), '--b', 'LineWidth', lineWidth, 'DisplayName', 'Branching, 1C advantage');
    % Next 2 lines were just a check of totals during the shuffle.
    % inLegend(5) = plot(time, S(:,2)./C(:,2) + S(:,4)./C(:,2), '-y', 'LineWidth', lineWidth, 'DisplayName', 'Branching, both');
    % inLegend(6) = plot(time, S(:,1)./C(:,1) + S(:,3)./C(:,1), '-g', 'LineWidth', lineWidth, 'DisplayName', 'Mounding, both');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', axisYears, 'XGrid', 'on');

    ylabel('Symbionts (cells/cm^2)');
    % ylabel('Symbiont Density (cells/cm^2)');
    
    %% For diagnostics, print the minimum for each S in each year.
    %  For 2 coral types S columns are arranged as (symbiont 1 in coral 1, symbiont 1 in coral 2,
    %  symbiont 2 in coral 1, etc.

    tRange = firstDayNum(xRange);
    iRange(1) = find(time>tRange(1), 1);
    iRange(2) = find(time<tRange(2), 1, 'last');
    for y = xRange(1):xRange(2)-1
        iRange(1) = find(time > firstDayNum(y), 1);
        iRange(2) = find(time < firstDayNum(y+1), 1, 'last');
        clear sFold  % Note the same size in the first (or last?) year.
        sFold(:, 1) = S(iRange(1):iRange(2), 1) + S(iRange(1):iRange(2), 3);
        sFold(:, 2) = S(iRange(1):iRange(2), 2) + S(iRange(1):iRange(2), 4);
        sMin = min(sFold(:, :), [], 1);
        if y == xRange(1)
            fprintf('%d %10.3e          %10.3e \n', y, sMin); 
        else
            f1 = sMin(1)/sOld(1);
            f2 = sMin(2)/sOld(2);
            if (f1 <= 0.3) || (f2 <= 0.3)
                drop = "DROP";
            else
                drop = "";
            end
            fprintf('%d %10.3e %8.3f %10.3e %8.3f %s\n', y, sMin(1), f1, sMin(2), f2, drop); 
        end
        sOld = sMin;
    end
    
    
    %% Add Bleaching events
    yearsMass = find(bleachEvent(:, 1));
    yearsBran = find(bleachEvent(:, 2));


    % Events are stored by year, not with an exact date.  Add 182 to place them
    % roughly mid-year.
    yearsMass = 182 + firstDayNum(1860 + yearsMass);
    yearsBran = 182 + firstDayNum(1860 + yearsBran);

    if ~isempty(yearsMass)
        %scatter(yearsMass, zeros(length(yearsMass), 1), 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red');
        scatter(yearsMass, zeros(length(yearsMass), 1), 36*4, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black');
    end
    if ~isempty(yearsBran)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
        scatter(yearsBran, zeros(length(yearsBran), 1), 36*4, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black');
    end
    if showLegend
        ll = legend(inLegend, 'FontSize', 11, 'FontWeight', 'normal', 'Location', 'north');
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
