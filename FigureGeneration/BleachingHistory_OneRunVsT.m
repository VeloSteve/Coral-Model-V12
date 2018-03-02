function BHSCO()
%relPath = '../bleaching_history/';
relPath = 'D:/CoralTest/V12Test/bleaching/';
%relPath = 'D:\GoogleDrive\Coral_Model_Steve\_Paper Versions\Figures\Survival4Panel\bleaching_NewK_NewSeed_Target5\';

% We need the temperature history for comparison.
sstPath = 'D:/GitHub/Coral-Model-Data/ProjectionsPaper/';
dataset = 'ESM2M';
RCP = 'rcp60';
[SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
%timeArray = datetime(TIME, 'ConvertFrom', 'datenum');
meanSST = mean(SST);
clear SST;

figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 17, 11]);

% Make subplots across, each for one rcp scenario.
% Within each, have lines for E=0/1 and OA=0/1
rcpList = {'rcp60'};
rcpName = {'RCP 6.0'};

legText = {};
legCount = 1;
for i = 1:1
    rrr = rcpList{i};
    cases = [];
    hFile = '';
    for eee = 1:1
        for ooo = 1:1           
                hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), '.mat');
                load(hFile, 'yForPlot');
                cases = [cases; yForPlot];
                legText{legCount} = strcat('Damge, E = ', num2str(eee), ' OA = ', num2str(ooo));
                legCount = legCount + 1;
            %end
        end
    end
    % x values are the same for all. Use the latest file;
    load(hFile, 'xForPlot');
    xSerial = datenum(xForPlot, 1, 15);
    yyaxis left;
    ylim([0 105]);

    oneSubplot(xSerial, cases, legText, rcpName{i}, i, i==1);

    if i == 1
        yHandle = ylabel({'Percent of  ''damaged'' coral reefs globally'},'FontSize',22);
        set(yHandle, 'Position', [1925 -10 0])
    end

end

% To set x limits we need 1950 as a serial date.  The others are for ticks.
x1950 = datenum(1950, 1, 15);
x2000 = datenum(2000, 1, 15);
x2050 = datenum(2050, 1, 15);
x2100 = datenum(2100, 1, 15);


yyaxis right;
xlim([x1950 xSerial(end)]);
ylim([26 30]);
plot(TIME, meanSST, 'DisplayName', 'SST global mean', ...
            'Color', [0.8 0.4 0.4], ...
            'LineWidth', 1, ...
            'LineStyle', '-');
         ...
set(gca, 'YTick',[26 28 30], 'XTick', [x1950 x2000 x2050 x2100]);
datetick('x', 'keepticks');

hold on;
mean5Y = centeredMovingAverage(meanSST, 61);
yyaxis right;
ylim([26 30]);
plot(TIME, mean5Y, 'DisplayName', 'SST 5Y moving av', ...
            'Color', [0.8 0 0], ...
            'LineWidth', 3, ...
            'LineStyle', '-');
         ...
set(gca, 'FontSize',22,...
        'YTick',[26 28 30]);
    
slope = zeros(1, length(mean5Y));
slope(1:end-1) = mean5Y(2:end)-mean5Y(1:end-1);
% Scale slope - values will be meaningless, but it will be visible.
% Set zero equal to 28 degrees as a reference.
minS = min(slope);
maxS = max(slope);
maxDelta = max(abs(minS), abs(maxS));
scaleS = 2.0/maxDelta;  % scale to no more than 2 up or down.
slope = 28.0 + slope * scaleS;
slope5y5y = centeredMovingAverage(slope, 61);
yyaxis right;
%ylim([26 30]);


plot(TIME, slope5y5y, 'DisplayName', 'SST 5Y slope', ...
            'Color', [0 0.7 0], ...
            'LineWidth', 1.5, ...
            'LineStyle', '-');

plot([TIME(1) TIME(end)], [28 28], 'DisplayName', 'zero slope', ...
            'Color', [0 0 0], ...
            'LineWidth', 1, ...
            'LineStyle', '-');
%set(gca, 'FontSize',22,...
%        'YTick',[26 28 30]);
    
    
end

function oneSubplot(X, Yset, legText, tText, baseColor, useLegend) 

    % Create axes
    %axes1 = axes;
    %hold(axes1,'on');
    switch baseColor
        case 1 
            base = [0 0 .9];
            light = [0.5 0.5 1.0];
        case 2 
            base = [0 .7 0];
            light = [0.4 1.0 0.4];
        case 3 
            base = [.6 .6 0];
            light = [0.9 0.9 0];
        case 4 
            base = [.9 0 0];
            light = [1.0 0.5 0.5];
    end
    col{1} = base;    % XXX - NOTE that this line is hidden for now.
    col{2} = base;

    col{3} = light;
    col{4} = light;
    
    % Create multiple lines using matrix input to plot
    plot1 = plot(X,Yset(:, :));
    for i = size(Yset, 1):-1:1
        set(plot1(i),...
            'DisplayName',legText{i}, ...
            'Color', col{i}, ...
            'LineWidth', 2);
        if i == 2 || i == 4
            set(plot1(i), 'LineStyle', '--');
        end     
    end
    % Old code - with extra x and y instead of useLegend
    %{
    if nargin == 7
        % Add the Logan GCB line
        hold on;
        plot2 = plot(extraX, extraY);
        set(plot2,...
            'DisplayName','Logan et al. 2014', ...
            'Color', [0 0 0], ...
            'LineWidth', 2);
        hold off;
    end
    %}
    % Create xlabel
    xlabel('Year','FontSize',13.2);

    % Create title
    title(tText, 'FontSize', 22);


    box('on');
    grid('on');
    % Set the remaining axes properties
    set(gca, 'FontSize',22,...
        'YTick',[0  50  100]);
    datetick('x','keeplimits');

    % Create legend
    hold off;
    if useLegend
        legend1 = legend('show');
        set(legend1,'Location','northwest','FontSize',20);
    end


    
end

%{
Interactive commands used before this function was developed:
meanSST = mean(SST)
plot(SST60)
plot(meanSST60)
sst60smooth = trailingAverageFilt(meanSST60, 24, true);
plot(sst60smooth)
sst60smooth(2)
slope = sst60smooth(2:end)-sst60smooth(1:end-1)
plot(slope)
smoothSlope = trailingAverageFilt(slope, 24, true)
plot(smoothSlope)
smoothSlope = trailingAverageFilt(slope, 48, true);
plot(smoothSlope)
sst60smooth48 = trailingAverageFilt(meanSST60, 48, true);
plot(sst60smooth48)
slope48 = sst60smooth48(2:end)-sst60smooth48(1:end-1)
plot(slope48)
smoothSlope48 = trailingAverageFilt(slope48, 48, true);
plot(smoothSlope48)
smoothSlope48_96 = trailingAverageFilt(slope48, 96, true);
plot(smoothSlope48_96)
SST, TIME = A_Coral_Model;
[SST, TIME] = A_Coral_Model;
plot(TIME, smoothSlope48_96)
smoothSlope48_96(2880) = 0;
plot(TIME, smoothSlope48_96)
sst60smooth60 = trailingAverageFilt(meanSST60, 60, true);
plot(TIME, sst60smooth60)
T1950 = TIME(1081:2880)
sst60_60_1950 = sst60smooth60(1081:2880)
plot(T1950, sst60_60_1950)
Y1950 = 1950+T1950-T1950(1)
plot(Y1950, sst60_60_1950)
Y1950 = 1950+150*(T1950-T1950(1))/(T1950(end)-T1950(1));
plot(Y1950, sst60_60_1950)
yyaxis(right)
yyaxis right
plot(Y1950, sst60_60_1950)
yyaxis right
plot(Y1950, sst60_60_1950)
slope60_60 = sst60_60_1950(2:end)-sst60_60_1950(1:end-1)
plot(Y1950, slope60_60)
slope60_60(1800) = 0
plot(Y1950, slope60_60)
smoothSlope60_60 = trailingAverageFilt(slope60_60, 60, true);
plot(Y1950, smoothSlope60_60)
saveCurrentFigure('SST, monthly slope, smoothed over 5 years')
saveCurrentFigure('RCP60_withGlobalMeanSST_smoothed5years')
saveCurrentFigure('SST_monthlySlope_smoothed5years')
a = 5
%}