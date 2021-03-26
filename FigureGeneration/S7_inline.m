%% This version of the S7 script is modified to be called at runtime, rather
%  than in postprocessing.  It will be slow to run, but when reef need to be 
%  selected by how the output looks this will be faster than a guess-and-try
%  approach.
%  Inputs:
%  k  reef number
%  rcp name, e.g. 'rcp26'
function S7_inline(k, rcp, S, C, gi, time, monthlyTemp, bleachEvent, coldEvent, saveDir)
    % Plot at full scale - this can be changed afterwards if a plot is
    % promising.
    xRange = [1865 2100];
    xTick = 1860:20:2100;
    axisYears =  string(xTick); % num2str does the wrong thing, creating a single string
    axisNums = firstDayNum(xTick);

    figure('color', 'w');
    set(gcf, 'Units', 'inches', 'Position', [1, 1, 8, 12]);

    columns = 1;
    rows = 2;

    % Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
    % E=1, shuffle = 1.
    lineWidth = 1;

    %             tight_subplot(Nh, Nw, gap, marg_h, marg_w, ratio_w)
    [splots, ~] = tight_subplot(rows, columns, 0.06, [], [0.1 0.05]);

    axes(splots(1));
    plotSST(k, rcp, time, monthlyTemp, xRange, axisNums, lineWidth);

    addGenotype(gi, time, xRange, axisNums, true, lineWidth);
    set(splots(1),'FontSize',14,'FontWeight','bold');

    % plotSDensity also adds the bleaching points.
    axes(splots(2));
    plotSDensity(time, S, C, bleachEvent, coldEvent, xRange, axisNums, axisYears, true, lineWidth);
    set(splots(2),'FontSize',14,'FontWeight','bold');
    
    fn = ['S7_Reef' num2str(k)];
    savefig(strcat(saveDir, fn, '.fig'));
    saveCurrentFigure(strcat(saveDir, fn));

end


function plotSST(k, rcp, time, T, xRange, axisNums, lineWidth) 
    % Get temperature data
    plot(time, T, 'Color', 'black', 'LineWidth', lineWidth, 'DisplayName', 'SST');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);

    ylim([23 33]);

    set(gca,'XGrid', 'on', 'XTick', axisNums, 'XTickLabel', []);

    title([rcp '  Reef ' num2str(k)]);
end

function addGenotype(gi, time, xRange, axisNums, showLegend, lineWidth) 
    hold on; % Adding to the plot above.
    % Note that the input files are written only if saveGi is true in the main
    % program.
    giColor = [0.8290 0.5940 0.0250];

    % Time is monthly, so cut down gi.
    gim(size(gi, 1)/8, 2) = 0.0;
    gim(:, 1) = decimate(gi(:, 1), 8 , 'fir');
    gim(:, 2) = decimate(gi(:, 3), 8 , 'fir');

    plot(time, gim(:, 1), '-', 'Color', giColor, 'LineWidth', lineWidth, 'DisplayName', 'Sensitive symbiont');
    plot(time, gim(:, 2), '--', 'Color', giColor, 'LineWidth', lineWidth+1, 'DisplayName', 'Advantaged symbiont');
    xlim(firstDayNum(xRange));
    set(gca,'XTick', axisNums, 'XTickLabel', []);

    ylabel('Temperature ({\circ}C)');
    if showLegend
        legend('FontSize', 12, 'FontWeight', 'normal', 'Location', 'south', ...
            'Orientation', 'horizontal');
    end

    hold off;
end

function plotSDensity(time, S, C, bleachEvent, coldEvent, xRange, axisNums, axisYears, showLegend, lineWidth)
    % Load variables C, S, and time, all stored monthly.
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
    yearsMassCold = find(coldEvent(:, 1));
    yearsBranCold = find(coldEvent(:, 2));


    % Events are stored by year, not with an exact date.  Add 182 to place them
    % roughly mid-year.
    yearsMass = 182 + firstDayNum(1860 + yearsMass);
    yearsBran = 182 + firstDayNum(1860 + yearsBran);
    yearsMassCold = 182 + firstDayNum(1860 + yearsMassCold);
    yearsBranCold = 182 + firstDayNum(1860 + yearsBranCold);
    
    % Red/yellow means massive
    % Blue/cyan means massive
    % cyan and yellow indicate cold events
    if ~isempty(yearsMass)
        %scatter(yearsMass, zeros(length(yearsMass), 1), 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red');
        scatter(yearsMass, zeros(length(yearsMass), 1), 36*4, 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red');
    end
    if ~isempty(yearsBran)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
        scatter(yearsBran, 1.5e5*ones(length(yearsBran), 1), 36*4, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
    end
    if ~isempty(yearsMassCold)
        scatter(yearsMassCold, zeros(length(yearsMassCold), 1), 18*4, 'MarkerEdgeColor', 'yellow', 'MarkerFaceColor', 'yellow');
    end
    if ~isempty(yearsBranCold)
        % offset branching up a bit: scatter(yearsBran, 1e5*ones(length(yearsBran), 1), 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
        scatter(yearsBranCold, 1.5e5*ones(length(yearsBranCold), 1), 18*4, 'MarkerEdgeColor', 'cyan', 'MarkerFaceColor', 'cyan');
    end
    if showLegend
        ll = legend(inLegend, 'FontSize', 11, 'FontWeight', 'normal', 'Location', 'north');
        ll.NumColumns = 2;
        % ll.Position = ll.Position + [0.0 0.005 0 0];
        %ll.Position = ll.Position + [0.0 -0.012 0 0];
    end
end


