% See whether SST measures correlate to coral cover or bleaching.
% This simply scatter plots various combinations and does linear regressions.
% This is meant for finding interesting relationships, not for proving them.
rcp = 'rcp26';
coralAreaDir = "D:\CoralTest\July2020_CurveE221_Target5_TempForFigures\";
areaFile = coralAreaDir + "CoralArea_" + rcp + "E=1OA=0Adv=0.mat";
load(areaFile, "C_area");
C_area2100 = squeeze(C_area(end, :, :));

sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
[SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, 'ESM2M', RCP);

% Use the measures defined in these files - and then possibly add more.
%SST_SD_ChangeMaps_45
%HotMonthSSTChangeMaps_45
%HotMonthSST_SD_ChangeMaps_45

figure('Units', 'inches', 'Position', [0.5, 0.5, 14, 10]);


SST1900 = SST(:, 1:yearEnd(1900));
sdSST1900 = std(SST1900, 0, 2);
compare(sdSST1900, C_area2100, 'All months std[SST], 1861-1900', 1);

SST2050 = SST(:, yearStart(2050):yearEnd(2080));
sdSST2050 = std(SST2050, 0, 2);
compare(sdSST2050, C_area2100, "All months std[SST], 2050-2080", 2);

dt = sdSST2050-sdSST1900;
compare(dt, C_area2100, "All months \Delta std[SST] from 1861-1900 to 2050-2080", 3);
compare(abs(dt), C_area2100, "All months abs[\Delta std[SST]] from 1861-1900 to 2050-2080", 4);

% From HotMonthSSTChangeMaps
SSTR = hottest(SST1900);
typSST1900 = mean(SSTR, 2);
compare(typSST1900, C_area2100, "Hottest Month SST 1861-1900", 5);

SST2080 = SST(:, yearStart(2080):yearEnd(2080));
SSTR = hottest(SST2080);
typSST2080 = mean(SSTR, 2);
compare(typSST2080, C_area2100, "Hottest Month SST 2080", 6);

dt = typSST2080-typSST1900;
compare(dt, C_area2100, "Hottest Month \Delta SST 1861-1900 to 2080", 7);


% From HotMonthSST_SD_ChangeMaps
hot1900 = hottest(SST1900);
hotSdSST1900 = std(hot1900, 0, 2);
compare(hotSdSST1900, C_area2100, "Hottest Month std[SST] 1861-1900", 8);

% Same for 2050 to 2080
hot2050 = hottest(SST2050);
hotSdSST2050 = std(hot2050, 0, 2);
compare(hotSdSST2050, C_area2100, "Hottest Month std[SST] 2050-2080", 9);
% Delta 2050-historical
dt = hotSdSST2050-hotSdSST1900;
compare(dt, C_area2100, "Hottest Month \Delta std[SST] 1861-1900 to 2050-2080", 10);



function compare(stat, area, name, sp)
    subplot(5, 2, sp);
    %figure()
    
    scatter(stat, area(:,1), 3, [1 0 0]); hold on;
    [rsqM, rsqMcut] = regress(stat, area(:,1), [1 0 0]);

    scatter(stat, area(:,2), 3, [0 0 1]);
    [rsqB, rsqBcut] = regress(stat, area(:,2), [0 0 1]);

    title(name);
    legend('Mounding',  strcat('R^2=', num2str(rsqM)), strcat('R^2=', num2str(rsqMcut)),...
           'Branching', strcat('R^2=', num2str(rsqB)), strcat('R^2=', num2str(rsqBcut)));
    
end

function [rsq, rsqCut] = regress(x, y, col)
    % Regression
    X = [ones(length(x),1) x];
    b = X\y;  % Regression operator  b is slope AND intercept
    yCalc = X*b;
    plot(x, yCalc, 'Color', col, 'LineStyle', '-', 'LineWidth', 1);
    rsq = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
    
    % Repeat after cutting out values of approximately zero area.
    idx = find(y>=0.02);
    x = x(idx);
    y = y(idx);
    
    X = [ones(length(x),1) x];
    b = X\y;  % Regression operator  b is slope AND intercept
    yCalc = X*b;
    rsqCut = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);

    % Dashed line doesn't work with full set of points as-is, so sort.
    [x, idx] = sort(x);
    y = y(idx);
    plot([x(1) x(end)], [yCalc(1) yCalc(end)], 'Color', col, 'LineStyle', '--', 'LineWidth', 2);
end


function i = yearStart(y)
    % Calculate the index in the monthly time array for 15 Jan of the given
    % year.
    % the first date in the model is 15-Jan-1861
    i = 1 + (y-1861)*12;
end
function i = yearEnd(y)
    % Calculate the index in the monthly time array for 15 Dec of the given
    % year.
    % the first date in the model is 15-Jan-1861
    % add 11 months to specify December
    i = 1 + (y-1861)*12 + 11;
end
function hot = hottest(sst)
    % Take an array of monthly SSD, sized reefs*months and return
    % just the hottest month of each year, now sized reefs*years
    hot = reshape(sst, size(sst,1), 12, []);
    hot = squeeze(max(hot,[], 2));
end
