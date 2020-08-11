% Read all the genotype information from a given directory and calculate
% required stats.  This will be memory intensive, since there's about 2G of data
% on disk per run.
tic
dirList = {'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp26.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp45.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp60.E1.OA0.sM9.sA0.0.20200722_maps/gi/', ...
    'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp85.E1.OA0.sM9.sA0.0.20200721_maps/gi/'};
dirList = {'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp85.E1.OA0.sM9.sA0.0.20200721_maps/gi/'};
baseColor = [0, 0, 1; 0, 1, 0; 0.9, 0.9, 0; 1, 0, 0];
cases = size(dirList, 2);
caseNames = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};

% Create a single figure, but use the function to add to specified subplots.

%{ 
% works, but not preferred.
figure();
set(gcf, 'Units', 'inches', 'Position', [1, 1, 14, 4+2*cases]);

sub = 1;
for d = 1:cases
    subplot1 = subplot(cases, 2, sub);
    subplot2 = subplot(cases, 2, sub+1);
    addOneCase(dirList{d}, subplot1, subplot2);
    sub = sub + 2;
end
%}

% Repeat with the same data, but stacked in just 2 subplots.
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
ylabel('\Delta gi (C)','FontWeight','bold');
xlabel('Time (years)','FontWeight','bold');
    xlim([time(1) time(end)])
    % xlim([679732.007596597 767385.255717382]);
    ylim([-0.2 1.25]);
    datetick('x', 'keeplimits', 'keepticks')
axes(subplot2);    
    ylabel('\Delta gi (C)','FontWeight','bold');
    xlabel('Time (years)','FontWeight','bold');
    xlim([time(1) time(end)])
    % xlim([679732.007596597 767385.255717382]);
    ylim([-0.2 1.25]);
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


function [lh1, lh2, ph1, ph2, time] =  addOneCase(name, dir, subplotB, subplotM, baseColor)
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

    % Repeat plot as two panes with shading.

    axes(subplotB);
    hold on;

    % Create patch for 5-95
    transparency = 0.2;
    %{
    Skip this for a cleaner look but keep the calculation in case we want it
    back.
    patch('Parent',subplotB,'DisplayName','5th - 95th percentile','YData', ...
        [giQuant(:, 1, 1); flipud(giQuant(:, 5, 1))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',baseColor);
    %}
    % Overlay patch for 25-75
    ph1 = patch('Parent',subplotB,'DisplayName','25th - 75th percentile','YData',[giQuant(:, 2, 1);
        flipud(giQuant(:, 4, 1))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*baseColor);
    %plot(time, giMean(:, 1), '-k', 'DisplayName', 'mean');
    lh1 = plot(time, giQuant(:, 3, 1), 'Color', baseColor, 'LineWidth', 2.0, 'DisplayName', [name]);

    hold off;

    % Now the same for branching.
    axes(subplotM);
    hold on;

    % Create patch for 5-95
    transparency = 0.2;
    %{
    Skip this for a cleaner look but keep the calculation in case we want it
    back.
    patch('Parent',subplotM,'DisplayName','5th - 95th percentile','YData',[giQuant(:, 1, 2);
        flipud(giQuant(:, 5, 2))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',baseColor); %[0.75 0.75 1]);
    %}
    % Overlay patch for 25-75
    ph2 = patch('Parent',subplotM,'DisplayName','25th - 75th percentile','YData',[giQuant(:, 2, 2);
        flipud(giQuant(:, 4, 2))],...
        'XData',[time; flipud(time)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',0.8*baseColor); % [0.45 0.45 1]);
    %plot(time, giMean(:, 2), '-k', 'DisplayName', 'mean');
    lh2 = plot(time, giQuant(:, 3, 2), 'Color', baseColor, 'LineWidth', 2.0, 'DisplayName', [name]);
    hold off;
    clearvars allGi giMean giQuant;
    end
