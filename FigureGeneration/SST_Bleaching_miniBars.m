function SST_Bleaching_miniBars()
% This is based on BleachingHistory*.m.  It combines bleaching statistics from
% the table outputs of each included run with SST history.
% As a first pass, try a single panel with each SST history in a different color
% and bleaching years in matching colored markers.  Perhaps adaptations can be
% shown by shape - dot for nothing, up triangle for adaptation, down for
% shuffling, 6-pointed star for both.
relPath = '../FigureData/healthy_4panel_figure1/Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/';
addpath('..'); % for tight_subplot

critical = 0.001; % Fraction of reefs signifying a critical bleaching year.
minBleach = 0;  % Don't show bleaching icons for less than this many reefs. Use 0 for all.
smooth = 5;  % 1 means no smoothing, n smooths over a total of n adjacent points.
smoothT = 1; % same, but applied to temps
patchWidth = 0.25; % fraction above and below the median
% Options. 1: rows near height of SST. 2: rows and bottom.
% 3: Rows at bottom, scale by reefs. 4: height by reefs bleached
% 5: Markers low as in 2, but with a line showing remaining reefs.
% 6: Marker altitude is now determined by the fraction of remaining reefs
% bleache
markerOption = 6; 
figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 10, 10]);

rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
rcpName = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};
rcpColor = {[0, 1, 1], [0, 1, 0], [.9, .9, 0], [1,0,0]};
%adaptLabel = {'No adaptation', 'Evolution', 'Shuffling', 'Evolution and  Shuffling'};
adaptLabel = {'None', 'Evolve', 'Shuffle', 'S & E'};
% Line types now match figure 1 - all solid.
%adaptStyle = {'-', '--', ':', '-.'};
adaptStyle = {'-', '-', '-', '-'};

% The exact colors used in Figure one for adaptations.
black = [0 0 0];         % none
blue =  [0.0 0.35 0.95]; % evolution
red  =  [0.9 0.1  0.1];  % shuffling
other = [0.6 0.0  0.8];  % both

aColor{1} = black;    
aColor{2} = blue;
aColor{3} = red;
aColor{4} = other;
sstColor = [0.45 0.45 0.45];

% Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
% E=1, shuffle = 1.
mkr = {'o', '^', 'v', 'h'};
transparency = 0.2;
rcpCount = size(rcpList, 2);
% spOrder = [1 3 2 4 5 7 6 8];
spOrder = [1 3 5 7 9  2 4 6 8 10  11 13 15 17 19  12 14 16 18 20];
spCount = 1;

% tight_subplot does not allow creating the subplots out of order.  Instead,
% it makes them all at once. Make them all here and use as needed.
% arguments: Nh, Nw, gap, marg_h, marg_w, ratio_w, ratio_h
% h = height, w = width, note the inconsistent order of the last 2.
subplotList = tight_subplot_vspaceHack(2*5, 2, [0.01 0.03], [], [0.05 0.065], [], ...
    [1 0.2 0.2 0.2 0.2  1 0.2 0.2 0.2 0.2], [0 0 0 0 0.06 0 0 0 0]);
for i = 1:rcpCount
    spTop = subplotList(spOrder(spCount)); spCount = spCount + 1;

    axes(spTop);
    rrr = rcpList{i};
    % Get temperature data
    [tYears, ~, T] = getTemps(rrr, 'year', patchWidth, smoothT);
    fprintf(strcat('Plotting SST for ', rcpName{i}, '\n'));
    yyaxis('left');
    if patchWidth > 0
        legendSubset(2) = patch( ...
        'DisplayName',[num2str(50-patchWidth*100) '-' num2str(50+patchWidth*100) 'th %ile SST'], ...
        'YData',[T(1, :), fliplr(T(3, :))],...
        'XData',[tYears,fliplr(tYears)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor', sstColor);
        hold('on');
        legendSubset(1) = plot3(tYears, T(2, :), -0.1*ones(size(tYears)), 'Color', sstColor, ...
            'LineWidth', 2, 'DisplayName', 'SST'); % median line
    else
        legendSubset(1) = plot(tYears, T, 'Color', sstColor, ...
            'LineWidth', 2, 'DisplayName', 'SST'); % median line
        hold('on');
    end
    xlim([1980 2100]);
    % For that single SST history find bleaching years for all adaptations.
    for eee = 0:1
        for sss = 0:1  %:1    
            spBottom = subplotList(spOrder(spCount)); spCount = spCount + 1;

            adapt = eee + 2*sss;
            % Note that shuffling is on/off, but we in the file name it is a
            % temperature value.  We just assume shufflng at 1C here.
            hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=0Adv=', num2str(sss), '.0.mat');
            fprintf("Loading %s\n", hFile);

            if i == 1 && eee == 0 && sss == 0 
                load(hFile, 'xForPlot');
            end

            %load(hFile, 'bleachedThisYear', 'liveThisYear');
            % Change the population history to healthy rather than not
            % permanently dead
            % liveThisYear is an absolute count.
            % yForPlot is percent damaged
            load(hFile, 'bleachedThisYear', 'yForPlot', 'canBleachCount');
            if (smooth > 1)
                yForPlot = centeredMovingAverage(yForPlot, smooth, 'hamming');
            end
            % as reefs
            % liveThisYear = (100 - yForPlot) * 1925 / 100;
            % as percent
            liveThisYear = 100 - yForPlot;
            
            %[dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, ...
            %    bleachedThisYear, xForPlot, critical, minBleach);

            axes(spTop);
            yyaxis right;
            %% Remaining Reefs
            legendSubset(3+adapt) = plot3(xForPlot, liveThisYear, -0.1*ones(size(xForPlot)), ...
                'Marker', 'none', 'Color', aColor{adapt+1}, 'LineStyle', adaptStyle{adapt+1}, ...
                'LineWidth', 2, 'DisplayName', adaptLabel{adapt+1}); % median line

            %% Bars for bleaching events
            % bleachCount will now actually be the fraction of remaining
            % reefs bleached.
            % Scaled by healthy number - but we can get bleaching > healthy,
            % appearing that > 100% of reefs have bleached.
            %[dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, ...
            %    bleachedThisYear./liveThisYear, xForPlot, critical, minBleach);
            % Scaled as percent of ALL reefs
            %[dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, ...
            %    bleachedThisYear/1925, xForPlot, critical, minBleach);
            % Scaled with new measure, reefs that can bleach.  Note that this is
            % shifted back a year, which may have been more correct for the
            % others as well.
            % Preferred as of 10 AM 22 Nov 2020
            % [dropYears, bleachCount] = getBleachYears(bleachedThisYear(2:end)./canBleachCount(1:end-1), ...
            %     bleachedThisYear(2:end)./canBleachCount(1:end-1), xForPlot(2:end), critical, minBleach, 1980);
            % As of 24 Nov 2020 just plot absolute counts, which shows the surge
            % of bleaching in middle years followed by a decline as reefs adapt
            % and/or there are simply fewer left to bleach.
            [dropYears, bleachCount] = getBleachYears(bleachedThisYear(2:end)./canBleachCount(1:end-1), ...
                 bleachedThisYear(2:end), xForPlot(2:end), critical, minBleach, 1980);
            %[dropYears, bleachCount] = getBleachYears(bleachedThisYear./canBleachCount, ...
            %    bleachedThisYear./canBleachCount, xForPlot, critical, minBleach, 1980);
            axes(spBottom);
            fprintf('Plotting eee = %d, sss = %d, color %d %d %d Max bar ht = %5.2f\n', eee, sss, aColor{adapt+1}, max(bleachCount));
            bar(dropYears, bleachCount, 'EdgeColor', aColor{adapt+1}, 'FaceColor', aColor{adapt+1}, ...
                'DisplayName', [adaptLabel{adapt+1} ' Event']);
            hold on;
            %ylim([0 1.2]);
            ylim([0 650]);
            if mod(i, 2) == 0
                yyaxis right
                set(gca, 'YColor', 'black');
                ylabel(adaptLabel{adapt+1});
                yticks([]);
            else
                if adapt == 2
                    yl = ylabel("Number of Reefs Bleached", 'FontSize', 12);
                    yl.Position = yl.Position + [ 0 -400 0]; % vert, hor, depth
                end
                yticks([0 500]);
            end
            xlim([1980 2100]);
            xticks([]);
            

        end
    end
    % Label the SST/healthy reef panel
    axes(spTop);
    % Right side, reef count (now percent)
    yyaxis('right');
    ax = gca;
    ax.YColor = 'black';
    xlim([1980, 2100]); 
    % ylim([0 2000]);
    ylim([0 100]);
    if mod(i, 2) == 0
        ylabel('Percent Healthy Reefs');
        yticks([0 50 100]);
    else
        yticks([]);
    end
    % Left side, SST
    yyaxis('left');
    ax = gca;
    ax.YColor = 'black';
    title(rcpName(i));
    if mod(i, 2) == 1
        ylabel('SST (\circ C)');
        if patchWidth > 0
            ylim([26, 32]);
            yticks([26 28 30 32]);
            yticklabels({'26' '28' '30' '32'});
        else
            ylim([27, 30]);
            yticks([27 28 29 30]);
        end
    else
        if patchWidth > 0
            ylim([26, 32]);
            yticks([]);
        else
            ylim([27, 30]);
            yticks([]);
        end
    end
    
    % Label the lower 4 panels
    axes(spBottom);
    xlabel('Year');
    xticks([1980:20:2100]);
end
% do these 3 lines do anything?
%for i = 1:rcpCount
%    lines(i);
%end
ll = legend(legendSubset, 'Location', 'NorthWest', 'NumColumns', 3, 'Orientation', 'horizontal' );
ll.Position = [.35 .474 0.274 0.0352];
end



function [bleachYears, bleachCount] = getBleachYears(fracBleached, count, years, critical, minBleach, firstYear)
    % The input is the percent of healthy reefs.  Consider that a drop of 50% of
    % the remaining healthy reefs is a critical bleaching year.
    % Start by removing years earlier that firstYear.
    keep = find(years >= firstYear);
    fracBleached = fracBleached(keep);
    count = count(keep);
    years = years(keep);
    
    %critBleach  = fracBleached > critical;
    critBleach  = (fracBleached > critical) & (count >= minBleach);
    bleachYears = years(critBleach);
    bleachCount = count(critBleach);
end
