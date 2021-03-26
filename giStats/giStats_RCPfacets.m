% Read all the genotype information from a given directory and calculate
% required stats.  This will be memory intensive, since there's about 2G of data
% on disk per run.
tic
addpath('../FigureGeneration'); % for getting temperatures
dirList = {'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp26.E1.OA0.sM9.sA0.0.20210309_maps/gi/', ...
    'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp45.E1.OA0.sM9.sA0.0.20210309_maps/gi/', ...
    'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp60.E1.OA0.sM9.sA0.0.20210309_maps/gi/', ...
    'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp85.E1.OA0.sM9.sA0.0.20210309_maps/gi/'};
%dirList = {'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp26.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
%    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp45.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
%    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp60.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
%    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp85.E1.OA0.sM9.sA0.0.20200721_maps/gi/'};
cases = size(dirList, 2);
caseNames = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};
rcpNames = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};


figure();
set(gcf, 'Units', 'inches', 'Position', [0.5, 0.5, 13.5, 13.5], 'Color', 'w');
for d = 1:cases
    subs(1) = subplot(2, 2, d);
    title(caseNames(d));
    oneCase(caseNames{d}, rcpNames{d}, dirList{d}, subs(1));
end
% The plot looks best with the lines on top of the colored areas.  Place
% each one on top within its axes.  Order of the lines versus eachother is less
% important.
% Also stacking the 25-75% patches above the 5-95% patches seemed like a good
% idea, but hardly made a difference other than making the legend more confusing.

%%





toc


function oneCase(name, rcp, dir, sub)
    % Each filename looks like gi_Reef0000.mat, with 0000 replaced by the left
    % 0-padded reef number.  The contents are gi, vgi.  To save space, time is in a
    % separate mat file, times.mat, containing time.
    reefCount = 1925;
    load(strcat(dir, 'time.mat'), 'time');
    allGi(reefCount, 4, size(time, 1)) = single(0);  % size array by setting the last element.
    for k = 1:reefCount
        load(strcat(dir, 'gi_Reef', num2str(k, '%04d'), '.mat'), 'gi');
        for j = 1:4
            allGi(k, j, :) = gi(:, j);
        end
    end
    clearvars gi vgi;


    % Question 1.  What is the largest change in genotype?
    % Assume that baseline and advantaged symbionts have the same delta, which is
    % always true in mode 9.
    maxDeltaM = 0;
    maxDeltaB = 0;
    maxMReef = 0;
    maxBReef = 0;
    minDeltaM = 1000;
    minDeltaB = 1000;
    minMReef = 0;
    minBReef = 0;

    for k = 1:reefCount
        deltaM = max(allGi(k, 1, :)) - min(allGi(k, 1, :));
        deltaB = max(allGi(k, 2, :)) - min(allGi(k, 2, :));
        if deltaM > maxDeltaM
            maxDeltaM = deltaM;
            maxMReef = k;
        end
        if deltaB > maxDeltaB
            maxDeltaB = deltaB;
            maxBReef = k;
        end
        if deltaM < minDeltaM
            minDeltaM = deltaM;
            minMReef = k;
        end
        if deltaB < minDeltaB
            minDeltaB = deltaB;
            minBReef = k;
        end
    end
    fprintf("For " + name + "\n");

    fprintf("Mounding adaptation:  max %5.2f on reef %4d, min %5.2f on reef %4d\n", maxDeltaM, maxMReef, minDeltaM, minMReef);
    fprintf("Branching adaptation: max %5.2f on reef %4d, min %5.2f on reef %4d\n", maxDeltaB, maxBReef, minDeltaB, minBReef);
    
    % Replace gi with delta from the first point in each reef.
    allGi(:, :, :) = allGi(:, :, :) - allGi(:, :, 1);

    % Question 2. What is the mean and variance of gi over time?
    giMean(size(time, 1), 2) = single(0);
    %giVar(size(time, 1), 2) = single(0);
    giQuant(size(time, 1), 5, 2) = single(0);
    for i = 1:size(time, 1)
        giMean(i, 1) = mean(allGi(:, 1, i));
        giMean(i, 2) = mean(allGi(:, 2, i));
        giQuant(i, :, 1) = quantile(allGi(:, 1, i), [0.05, 0.25, 0.50, 0.75, 0.95]);
        giQuant(i, :, 2) = quantile(allGi(:, 2, i), [0.05, 0.25, 0.50, 0.75, 0.95]);
        %giVar(i, 1) = var(allGi(:, 1, i));    
        %giVar(i, 2) = var(allGi(:, 2, i));
    end

    fprintf("Change in mean is %5.2f for mounding and %5.2f for branching.\n", ...
        range(giMean(:, 1)), range(giMean(:, 2)));

    % Plot both coral types in a single subplot, for one RCP
    
    % First show SST in black
    % new function [years, time, T] = getTemps(RCP, increment, plusMinus, smoothT, varargin)

    [~, sstTime, SST] = getTemps(rcp, 'year', 0, 0);
    axes(sub);
    hold on;
    yyaxis right;
    ax = gca;
    ax.YColor = 'black';
    lh3 = plot(sstTime, SST, 'Color', [0 0 0], 'LineWidth', 2.0, 'LineStyle', ':', 'DisplayName', 'SST');
    ylabel('Median SST ({\circ}C)','FontWeight','bold');
    ylim([26 30]);
    % ===== Branching =====

    yyaxis left;
    ax = gca;
    ax.YColor = 'black';
    transparency = 0.2;

    % Quartile patch for 25-75, branching
    %ph1 = patch('Parent',sub,'DisplayName','25th - 75th percentile','YData',[giQuant(:, 2, 1);
    ph1 = patch('Parent',sub,'HandleVisibility','off','YData',[giQuant(:, 2, 1);
        flipud(giQuant(:, 4, 1))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*[1 0 0]);
   
    transparency = 0.2;
    % Quartile patch for 25-75, massive
    %ph2 = patch('Parent',sub,'DisplayName','25th - 75th percentile','YData',[giQuant(:, 2, 2);
    ph2 = patch('Parent',sub,'HandleVisibility', 'off','YData',[giQuant(:, 2, 2);
        flipud(giQuant(:, 4, 2))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*[0 0 1]); % [0.45 0.45 1]);
    
    % Draw the median lines last so they aren't faded by the patches.
    lh1 = plot(time, giQuant(:, 3, 1), 'Color', [1 0 0], 'LineWidth', 2.0, 'LineStyle', '-', 'DisplayName', 'Branching gi');

    lh2 = plot(time, giQuant(:, 3, 2), 'Color', [0 0 1], 'LineWidth', 2.0, 'LineStyle', '-', 'DisplayName', 'Mounding gi');


    ylabel('\Delta gi ({\circ}C)','FontWeight','bold');
    xlabel('Time (years)','FontWeight','bold');
    xlim([time(1) time(end)])
    ylim([-0.2 1.25]);
    datetick('x', 'keeplimits', 'keepticks');
    
    hold off;
    clearvars allGi giMean giQuant;
       
    set(sub,'FontSize',14,'FontWeight','bold','XTick',...
      [675000 693402 711804 730207 748609 767011],'XTickLabel',...
      {'1850','1900','1950','2000','2050','2100'},'YTick',[0 0.25 0.5 0.75 1 1.25]);

    %legend(sub, lineHandles(:, 1), 'Location', 'northwest');
    if strcmp(rcp, 'rcp26')
        legend('Location', 'northwest');
    end
end