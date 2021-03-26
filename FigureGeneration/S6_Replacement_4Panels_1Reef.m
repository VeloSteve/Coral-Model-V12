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

rcpList = {'control400', 'rcp45', 'rcp85'};
rcpName = {'Control', 'RCP 4.5', 'RCP 8.5'};
columns = length(rcpList);
xRange = [2005 2025];
xTick = [2005 2010 2015 2020 2025];
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
set(gcf, 'Units', 'inches', 'Position', [1, 1, 12, 12]);


columns = length(rcpList);

% Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
% E=1, shuffle = 1.
mkr = {'o', '^', 'v', 'h'};


for i = 1:columns
    rcp = rcpList{i};
    sp = subplot(4, columns, i);
    plotSST(k, rcp, smooth, xRange, axisNums);
    sp = subplot(4, columns, i + columns);
    plotGenotype(k, giPath{i}, xRange, axisNums);
    sp = subplot(4, columns, i + 2*columns);
    plotSDensity(k, scPath{i}, xRange, axisNums);
    sp = subplot(4, columns, i + 3*columns);
    plotCPop(k, scPath{i}, xRange, axisNums, axisYears);
end
sgtitle(['Reef ' num2str(k)]);


function plotSST(k, rcp, smooth, xRange, axisNums) 
    % Get temperature data
    [~, time, T] = getTemps(rcp, 'month', 0, smooth, k);
    fprintf('Plotting SST for %s.\n', rcp);
    plot(time, T, 'Color', 'black', 'LineWidth', 2);
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);
    %yOld = ylim;
    %ylim([floor(yOld(1)) ceil(yOld(2))]);
    ylim([25 31]);

    set(gca,'XGrid', 'on', 'XTick', axisNums, 'XTickLabel', []);

    ylabel('SST ({\circ}C)');
    title(rcp);
    hold off;
end

function plotGenotype(k, path, xRange, axisNums) 
    % Note that the input files are written only if saveGi is true in the main
    % program.
    load(strcat(char(path), 'gi_Reef', num2str(k, '%04d'), '.mat'), 'gi');
    load(strcat(char(path), 'time.mat'), 'time');  % In MATLAB units
    plot(time, gi(:, 1));
    hold on;
    plot(time, gi(:, 3));
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);

    yOld = ylim;
    ylim([floor(yOld(1)) ceil(yOld(2))]);

    ylabel('Symbiont genotype ({\circ}C)');
    hold off;
end

function plotSDensity(k, path, xRange, axisNums)
    % Load variables C, S, and time, all stored monthly.
    load(strcat(char(path), 'DetailedSC_Reef', num2str(k, '%d'), '.mat'), 'C', 'S', 'time');
    plot(time, S(:,1)./C(:,1), '-r', 'LineWidth', 1, 'DisplayName', 'Mounding')
    hold on
    plot(time, S(:,2)./C(:,2), '-b', 'LineWidth', 1, 'DisplayName', 'Branching')
    plot(time, S(:,3)./C(:,1), '--r', 'LineWidth', 1, 'DisplayName', 'Mounding, 1C advantage')
    plot(time, S(:,4)./C(:,2), '--b', 'LineWidth', 1, 'DisplayName', 'Branching, 1C advantage')
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);

    ylabel('Symbiont Density (cells/cm^2)');
    hold off;
end

function plotCPop(k, path, xRange, axisNums, axisYears)
    % Note that the input file is written only for "dataReefs" in the main
    % program.  Latest set: 36, 46, 106, 144, 402, 420, 1239
    % Load variables C, S, and time, all stored monthly.
    load(strcat(char(path), 'DetailedSC_Reef', num2str(k, '%d'), '.mat'), 'C', 'time', 'bleachEvent');
    plot(time, C(:,1), '-r', 'LineWidth', 1, 'DisplayName', 'Mounding')
    hold on
    plot(time, C(:,2), '-b', 'LineWidth', 1, 'DisplayName', 'Branching')
    xlim(firstDayNum(xRange));
    set(gca,'XGrid','on','XTick', axisNums, 'XTickLabel', axisYears);
    ylabel('Coral Cover (cm^2)');
    
    % Add Bleaching events
    yearsMass = find(bleachEvent(:, 1));
    yearsBran = find(bleachEvent(:, 2));

    % At this point we have indexes which can be used to look up values in the C
    % array so that these points (which have no scale of their own) can be
    % plotted on the matching line.
    % Year 1 corresponds to index 12*8 (months * steps) in the array.  Use the
    % coral value from the midpoint of that year.
    cMass = C(yearsMass*12*8-6*8, 1);
    cBran = C(yearsBran*12*8-6*8, 2);
    % Events are stored by year, not with an exact date.  Add 182 to place them
    % roughly mid-year.
    yearsMass = 182 + firstDayNum(1860 + yearsMass);
    yearsBran = 182 + firstDayNum(1860 + yearsBran);

    if ~isempty(cMass)
        scatter(yearsMass, cMass, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red');
    end
    if ~isempty(cBran)
        scatter(yearsBran, cBran, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
    end
            
    hold off;
end



function [bleachYears] = getBleachYears(fracBleached, years, critical)
    % The input is the percent of healthy reefs.  Consider that a drop of 50% of
    % the remaining healthy reefs is a critical bleaching year.
    critBleach  = fracBleached > critical;
    bleachYears = years(critBleach);
end
