%% This version of S7 fits in 4 example reefs where one was used before.  For 
%  each reef it shows:
%  - SST, gi(baseline), and gi (advantaged) in an upper panel
%  - Population density for each of 4 symbionts (mounding/branching and
%  baseline/advantaged) in a lower panel.
%  - Also in the lower panel, dots for bleaching events on the x axis.
%
% Note that each reef must have custom xlim values to show the time range of
% interest.
%
% Run time requirements
% - Each reef must be listed in "dataReefs" to get symbiont history
% - saveGi must be set true in A_Coral_Model
%
% Some interesting options for dataReefs.  These are selected for various
% reasons, including past use, high or low SST variance, and observed
% interesting symbiont shuffling behavior.
% % 36, 46, 58, 106, 144, 402, 420, 495, 610, 1010,  1239, 1487
%
%%
% Reefs may be shown in different RCP and adaptation combinations, so list them
% here.
reefs = [1487, 1010, 58, 495];
runDateString = {'20210309', '20210312', '20210312', '20210312'};  % Yuck.  This makes it hard to combine runs from diferent days.

panelID = {'(a)', '(b)', '(c)', '(d)'};
rcpList = {'rcp26', 'rcp45', 'rcp26', 'control400'};
rcpName = {'RCP 2.6', 'RCP 4.5', 'RCP 2.6', 'SST Control'};
E = {'0', '1', '1', '0'};
% Fits better:
% adapt = {'Shuffle', 'Shuffle & Evolve', 'Shuffle & Evolve', 'Shuffle'};
% Consistent with other figures:
adapt = {'Shuffling', 'Shuffling & Evolution', 'Shuffling & Evolution', 'Shuffling'};
Adv = {'1.0', '1.0', '1.0', '1.0'};
yearSets = [2000 2020; 2000 2020; 2000 2100; 2000 2200]; % Start and end for each reef.
tempSets = [24 31; 24 31; 27 33; 23 29]; % Start and end for each reef.
lineWidth = [1 1 1 0.5];

% Same for all
yRange = [0 4E6]; % Symbiont y axis
colorEvents = false;

cases = length(reefs);
% A quick check that the list have equal lengths.
assert(length(rcpList) == cases);
assert(length(rcpName) == cases);
assert(length(E) == cases);
assert(length(Adv) == cases);
assert(size(yearSets, 1) == cases);

% Where run outputs are stored for the latest model version:
dataPath = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5_extraReefs\';

% Two subplots per case - assume 2 columns for now.
columns = 2;
rows = 2*cases/columns;
figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [0.5, 0.5, 11, 13]);
addpath('..'); % for tight_subplot
%             tight_subplot(Nh, Nw, gap, marg_h, marg_w, ratio_w)
[splots, ~] = tight_subplot(rows, columns, 0.06, [], [0.1 0.05]);

% ! set E in file name!

critical = 0.25; % Fraction of reefs signifying a critical bleaching year.
smooth = 1;  % 1 means no smoothing, n smooths over a total of n adjacent points.
% Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
% E=1, shuffle = 1.
mkr = {'o', '^', 'v', 'h'};
legendColumn = [2 2 1];

row = 1; % Let row refer to the rows of subplots.
col = 1;
for i = 1:cases
    k = reefs(i);
    rcp = rcpList{i};
    % Build the path for the particular RCP and adaptation of this case.
    scPath{i} = strcat(dataPath, 'ESM2M.', rcpList(i), '.E', E(i), ...
        '.OA0.sM9.sA', Adv(i), '.', runDateString{i}, '_maps/');
    giPath{i} = strcat(scPath{i}, 'gi/');
    xRange = yearSets(i, :);
    % Axis ticks will need to get smarter than a fixed list!
    [xTick, axisYears, axisNums] = getTicks(xRange);

    
    % Subplots for this case.
    spUp = (row-1)*columns + col;
    spDown = spUp + columns;
    
    %% Upper axes
    axes(splots(spUp));
    plotSST(k, panelID{i}, rcp, rcpName{i}, adapt{i}, smooth, xRange, tempSets(i, :), axisNums, lineWidth(i));
    addGenotype(k, giPath{i}, xRange, axisNums, legendColumn(1)==i, 1.0);
    set(splots(spUp),'FontSize',14,'FontWeight','bold');
    
    %% Lower axes
    % plotSDensity also adds the bleaching points.
    axes(splots(spDown));
    plotSDensity(k, scPath{i}, xRange, yRange, axisNums, axisYears, legendColumn(2)==i, lineWidth(i), colorEvents);
    set(splots(spDown),'FontSize',14,'FontWeight','bold');
    col = col + 1;
    if col > columns
        col = 1;
        row = row + 2;
    end
end

% sgtitle(['Reef ' num2str(k)], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');


function plotSST(k, prefix, rcp, rcpName, adapt, smooth, xRange, yRange, axisNums, lineWidth) 
    % Get temperature data
    [~, time, T] = getTemps(rcp, 'month', 0, smooth, k);
    fprintf('Plotting SST for %s.\n', rcp);
    plot(time, T, 'Color', 'black', 'LineWidth', lineWidth, 'DisplayName', 'SST');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);
    %yOld = ylim;
    %ylim([floor(yOld(1)) ceil(yOld(2))]);
    ylim(yRange);

    set(gca,'XGrid', 'on', 'XTick', axisNums, 'XTickLabel', []);

    title([prefix '  ' rcpName '  Reef ' num2str(k) ' ' adapt]);
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
        %ll = legend('FontSize', 12, 'FontWeight', 'normal', 'Location', 'south', ...
        %    'Orientation', 'horizontal');
        %ll.Position = ll.Position + [0.28 -0.028 0 0];

        ll = legend('FontSize', 12, 'FontWeight', 'normal', 'Location', 'south');
        ll.Position = ll.Position + [0 -0.005 0 0];
    end

    hold off;
end

function plotSDensity(k, path, xRange, yRange, axisNums, axisYears, showLegend, lineWidth, colorEvents)
    % Load variables C, S, and time, all stored monthly.
    load(strcat(char(path), 'DetailedSC_Reef', num2str(k, '%d'), '.mat'), 'C', 'S', 'time', 'bleachEvent', 'coldEvent');
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
    ylim(yRange);

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
        % Just skip if there is no end point found!
        if isempty(find(time < firstDayNum(y+1), 1, 'last'))
            break;
        end
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
    yearsMassCold = find(coldEvent(:, 1));
    yearsBranCold = find(coldEvent(:, 2));


    % Events are stored by year, not with an exact date.  Add 182 to place them
    % roughly mid-year.
    yearsMass = 182 + firstDayNum(1860 + yearsMass);
    yearsBran = 182 + firstDayNum(1860 + yearsBran);
    yearsMassCold = 182 + firstDayNum(1860 + yearsMassCold);
    yearsBranCold = 182 + firstDayNum(1860 + yearsBranCold);
    
    if colorEvents
        mc = {'red', 'blue', 'yellow', 'cyan'};
        shift = 1.5e5;
    else
        mc = repmat({'black'}, 4, 1);
        shift = 0.0;
    end
    if ~isempty(yearsMass)
        %scatter(yearsMass, zeros(length(yearsMass), 1), 'MarkerEdgeColor', mc{1}, 'MarkerFaceColor', mc{1});
        scatter(yearsMass, zeros(length(yearsMass), 1), 36*4, 'MarkerEdgeColor', mc{1}, 'MarkerFaceColor', mc{1});
    end
    if ~isempty(yearsBran)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', mc{2}, 'MarkerFaceColor', mc{2});
        scatter(yearsBran, shift*ones(length(yearsBran), 1), 36*4, 'MarkerEdgeColor', mc{2}, 'MarkerFaceColor', mc{2});
    end
    if ~isempty(yearsMassCold)
        scatter(yearsMassCold, zeros(length(yearsMassCold), 1), 18*4, 'MarkerEdgeColor', mc{3}, 'MarkerFaceColor', mc{3});
    end
    if ~isempty(yearsBranCold)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', mc{4}, 'MarkerFaceColor', mc{4});
        scatter(yearsBranCold, shift*ones(length(yearsBranCold), 1), 18*4, 'MarkerEdgeColor', mc{4}, 'MarkerFaceColor', mc{4});
    end
    if showLegend
        ll = legend(inLegend, 'FontSize', 11, 'FontWeight', 'normal', 'Location', 'north');
        ll.NumColumns = 2;
        ll.Position = ll.Position + [0.016 0.045 0 0];
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

function [xTick, axisYears, axisNums] = getTicks(r)
    delta = r(2) - r(1);
    if delta < 6
        % Every year
        xTick = r(1):r(2);
    elseif delta <= 20
        % Every 5 years
        xTick = 10*floor(r(1)/10):5:10*ceil(r(2)/10);
    elseif delta <= 50
        % Every 10 years
        xTick = 10*floor(r(1)/10):10:10*ceil(r(2)/10);
    elseif delta <= 150
        % Every 25 years
        step = 25;
        rl = r(1) - mod(r(1), step);
        rh = r(2) + (step - mod(r(1), step));
        xTick = rl:step:rh;
    else
        % Every 100 years
        step = 100;
        rl = r(1) - mod(r(1), step);
        rh = r(2) + (step - mod(r(1), step));
        xTick = rl:step:rh;
    end
    axisYears =  string(xTick); % num2str does the wrong thing, creating a single string
    axisNums = firstDayNum(xTick);
end
