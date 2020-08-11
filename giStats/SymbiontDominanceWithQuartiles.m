% Read all the genotype information from a given directory and calculate
% required stats.  This will be memory intensive, since there's about 2G of data
% on disk per run.
tic
dirList = {'D:/CoralTest/July2020_CurveE221_Target5_TempForFigures/ESM2M.rcp26.E1.OA0.sM9.sA1.0.20200728_maps/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_TempForFigures/ESM2M.rcp45.E1.OA0.sM9.sA1.0.20200728_maps/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_TempForFigures/ESM2M.rcp60.E1.OA0.sM9.sA1.0.20200728_maps/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_TempForFigures/ESM2M.rcp85.E1.OA0.sM9.sA1.0.20200728_maps/'};
baseColor = [0, 0, 1; 0, 1, 0; 0.9, 0.9, 0; 1, 0, 0];
cases = size(dirList, 2);
caseNames = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};


figure();
set(gcf, 'Units', 'inches', 'Position', [1, 1, 14, 6]);
subplot1 = subplot(1, 2, 1);
title("Mounding Corals");
subplot2 = subplot(1, 2, 2);
title("Branching Corals");
lineHandles(cases, 2) = 0;
for d = 1:cases
    [lineHandles(d, 1), lineHandles(d, 2), patchHandles(d, 1), patchHandles(d, 2), time] ...
        = addOneCase(caseNames{d}, dirList{d}, subplot1, subplot2, baseColor(d, :));
end
% The plot looks best with the lines on top of the colored areas.  Place
% each one on top within its axes.  Order of the lines versus eachother is less
% important.
% Also stacking the 25-75% patches above the 5-95% patches seemed like a good
% idea, but hardly made a difference other than making the legend more confusing.
axes(subplot1);
%{
for d = 1:cases
    uistack(patchHandles(d, 1), 'top');
end
%}
for d = 1:cases
    uistack(lineHandles(d, 1), 'top');
end
axes(subplot2);
%{
for d = 1:cases
    uistack(patchHandles(d, 2), 'top');
    end
%}
for d = 1:cases
    uistack(lineHandles(d, 2), 'top');
end

axes(subplot1);
    ylabel('Fraction of Tolerant Symbionts','FontWeight','bold');
    xlabel('Time (years)','FontWeight','bold');
    xlim([time(1) time(end)])
    % xlim([679732.007596597 767385.255717382]);
    ylim([0.4 1.0]);
    datetick('x', 'keeplimits', 'keepticks')
axes(subplot2);    
    ylabel('Fraction of Tolerant Symbionts','FontWeight','bold');
    xlabel('Time (years)','FontWeight','bold');
    xlim([time(1) time(end)])
    % xlim([679732.007596597 767385.255717382]);
    ylim([0.4 1.0]);
    datetick('x', 'keeplimits', 'keepticks')


set(subplot1,'FontSize',14,'FontWeight','bold','XTick',...
    [675000 693402 711804 730207 748609 767011],'XTickLabel',...
    {'1850','1900','1950','2000','2050','2100'},'YTick',[0 0.25 0.5 0.75 1 1.25]);
set(subplot2,'FontSize',14,'FontWeight','bold','XTick',...
    [675000 693402 711804 730207 748609 767011],'XTickLabel',...
    {'1850','1900','1950','2000','2050','2100'},'YTick',[0 0.25 0.5 0.75 1 1.25]);
legend(subplot1, lineHandles(:, 1), 'Location', 'northwest');
legend(subplot2, lineHandles(:, 2), 'Location', 'northwest');

toc


function [lh1, lh2, ph1, ph2, time] =  addOneCase(name, dir, subplotM, subplotB, baseColor)
    % Each filename looks like gi_Reef0000.mat, with 0000 replaced by the left
    % 0-padded reef number.  The contents are gi, vgi.  To save space, time is in a
    % separate mat file, times.mat, containing time.
    reefCount = 1925;
    load(strcat(dir, 'time.mat'), 'time');
    allFraction(reefCount, 2, size(time, 1)) = single(0);  % size array by setting the last element.
    for k = 1:reefCount
        % load(strcat(dir, 'DetailedSC_Reef', num2str(k, '%04d'), '.mat'), 'S');
        load(strcat(dir, 'DetailedSC_Reef', num2str(k), '.mat'), 'S');
        for j = 1:2 % Two coral types
            allFraction(k, j, :) = S(:, j+2) ./ (S(:, j) + S(:, j+2));
        end
    end
    clearvars S;


    fQuant(size(time, 1), 3, 2) = single(0); % (time, quantile, coral type)
    for i = 1:size(time, 1)
        fQuant(i, :, 1) = quantile(allFraction(:, 1, i), [0.25, 0.50, 0.75]);
        fQuant(i, :, 2) = quantile(allFraction(:, 2, i), [0.25, 0.50, 0.75]);
    end

    % Two panes with shading.

    axes(subplotM);
    hold on;

    % Create patch for 5-95
    transparency = 0.2;
    
    % Patch for 25-75
    ph1 = patch('Parent',subplotM,'DisplayName','25th - 75th percentile','YData',[fQuant(:, 1, 1);
        flipud(fQuant(:, 3, 1))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*baseColor);
    %plot(time, giMean(:, 1), '-k', 'DisplayName', 'mean');
    lh1 = plot(time, fQuant(:, 2, 1), 'Color', baseColor, 'LineWidth', 2.0, 'DisplayName', [name]);

    hold off;

    % Now the same for branching.
    axes(subplotB);
    hold on;

    % Create patch for 5-95
    transparency = 0.2;
    % Patch for 25-75
    ph2 = patch('Parent',subplotB,'DisplayName','25th - 75th percentile','YData',[fQuant(:, 1, 2);
        flipud(fQuant(:, 3, 2))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*baseColor); % [0.45 0.45 1]);
    %plot(time, giMean(:, 2), '-k', 'DisplayName', 'mean');
    lh2 = plot(time, fQuant(:, 2, 2), 'Color', baseColor, 'LineWidth', 2.0, 'DisplayName', [name]);
    hold off;
    clearvars allGi giMean giQuant;
    end
