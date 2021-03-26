function SST_Bleaching()
% This is based on BleachingHistory*.m.  It combines bleaching statistics from
% the table outputs of each included run with SST history.
% As a first pass, try a single panel with each SST history in a different color
% and bleaching years in matching colored markers.  Perhaps adaptations can be
% shown by shape - dot for nothing, up triangle for adaptation, down for
% shuffling, 6-pointed star for both.
relPath = '../FigureData/healthy_4panel_figure1/Target5_E221_Nov2020/';
addpath('..'); % for tight_subplot

critical = 0.15; % Fraction of reefs signifying a critical bleaching year.
minBleach = 50;  % Don't show bleaching icons for less than this many reefs. Use 1 for all.
smooth = 3;  % 1 means no smoothing, n smooths over a total of n adjacent points.
smoothT = 1; % same, but applied to temps
patchWidth = 0.25; % fraction above and below the median
% Options. 1: rows near height of SST. 2: rows and bottom.
% 3: Rows at bottom, scale by reefs. 4: height by reefs bleached
% 5: Markers low as in 2, but with a line showing remaining reefs.
markerOption = 5; 
figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 10, 10]);

rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
rcpName = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};
rcpColor = {[0, 1, 1], [0, 1, 0], [.9, .9, 0], [1,0,0]};
adaptLabel = {'No adaptation', 'Evolution', 'Shuffling', 'Evolution and  Shuffling'};
adaptStyle = {'-', '--', ':', '-.'};

% Marker shapes in the order E=0, shuffle=0; E=1, shuffle = 0; E=0, shuffle=1;
% E=1, shuffle = 1.
mkr = {'o', '^', 'v', 'h'};
transparency = 0.2;
curves = size(rcpList, 2);
legendSubset = zeros(9, 1);
for i = 1:curves
    sp = subplot(2, 2, i);
    rrr = rcpList{i};
    % Get temperature data
    [tYears, ~, T] = getTemps(rrr, 'year', patchWidth, smoothT);
    fprintf(strcat('Plotting SST for ', rcpName{i}, '\n'));
    yyaxis('left');
    if patchWidth > 0
        legendSubset(2) = patch( ...
        'DisplayName',[num2str(50-patchWidth*100) '-' num2str(50+patchWidth*100) 'th percentile SST'], ...
        'YData',[T(1, :), fliplr(T(3, :))],...
        'XData',[tYears,fliplr(tYears)],...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',rcpColor{i});
        hold('on');
        legendSubset(1) = plot3(tYears, T(2, :), -0.1*ones(size(tYears)), 'Color', rcpColor{i}, ...
            'LineWidth', 2, 'DisplayName', 'SST'); % median line
    else
        legendSubset(1) = plot(tYears, T, 'Color', rcpColor{i}, ...
            'LineWidth', 2, 'DisplayName', 'SST'); % median line
        hold('on');
    end
    xlim([1990 2100]);
    yyaxis('right');
    % For that single SST history find bleaching years for all adaptations.
    for eee = 0:1
        for sss = 0:1  %:1      
            adapt = eee + 2*sss;
            % Note that shuffling is on/off, but we in the file name it is a
            % temperature value.  We just assume shufflng at 1C here.
            hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=0Adv=', num2str(sss), '.0.mat');
            fprintf("Loading %s\n", hFile);

            if i == 1 && eee == 0 && sss == 0 
                load(hFile, 'xForPlot');
            end

            load(hFile, 'bleachedThisYear', 'liveThisYear');
            
            [dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, bleachedThisYear, xForPlot, critical, minBleach);

            yyaxis('right');
            if markerOption == 1
                scatter(dropYears, (i+adapt/9)*ones(length(dropYears), 1), 54, mkr{adapt+1}, 'MarkerEdgeColor', rcpColor{i}, 'MarkerFaceColor', rcpColor{i});
                ylim([-1 5]);
                yticks([]);
            elseif markerOption == 2
                scatter(dropYears, (i+adapt/4)*ones(length(dropYears), 1), 54, mkr{adapt+1}, 'MarkerEdgeColor', rcpColor{i}, 'MarkerFaceColor', rcpColor{i});
                ylim([0.5 20]);            
                yticks([]);
            elseif markerOption == 3
                bc = max((bleachCount/3), 1);
                scatter(dropYears, (i+adapt/4)*ones(length(dropYears), 1), bc, mkr{adapt+1}, 'MarkerEdgeColor', rcpColor{i}, 'MarkerFaceColor', rcpColor{i});
                ylim([0.75 15]);            
                yticks([]);
            elseif markerOption == 4
                % recalculate bleachCount to reflect remaining reefs, not number bleached!
                [dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, liveThisYear, xForPlot, critical, minBleach);
                scatter(dropYears, bleachCount, 54, mkr{adapt+1}, 'MarkerEdgeColor', rcpColor{i}, 'MarkerFaceColor', rcpColor{i});
                ylim([0 2000]);
                yticks([0 500 1000 1500 2000]);
                ylabel('Remaining Unbleached Reefs')
            elseif markerOption == 5
                legendSubset(4+adapt*2) = plot3(xForPlot, liveThisYear, -0.1*ones(size(xForPlot)), ...
                    'Marker', 'none', 'Color', 'black', 'LineStyle', adaptStyle{adapt+1}, ...
                    'LineWidth', 2, 'DisplayName', adaptLabel{adapt+1}); % median line

                % recalculate bleachCount to reflect remaining reefs, not number bleached!
                [dropYears, bleachCount] = getBleachYears(bleachedThisYear./liveThisYear, ...
                    liveThisYear, xForPlot, critical, minBleach);
                legendSubset(3+adapt*2) = scatter(dropYears, 66*adapt*ones(length(dropYears), 1), 54, ...
                    mkr{adapt+1}, 'MarkerEdgeColor', rcpColor{i}, 'MarkerFaceColor', rcpColor{i}, ...
                    'DisplayName', [adaptLabel{adapt+1} ' Event']);
                ylim([0 2000]);
                yticks([0 500 1000 1500 2000]);
                ylabel('Remaining Unbleached Reefs')
            end
            

        end
    end
    yyaxis('right');
    ax = gca;
    ax.YColor = 'black';
    xlim([1980, 2100]);  
    yyaxis('left');
    ax = gca;
    ax.YColor = 'black';
    title(rcpName(i));
    xlabel('Year');
    ylabel('SST (\circ C)')
    if patchWidth > 0
        ylim([26, 32]);
        yticks([26 28 30 32]);
    else
        ylim([27, 30]);
        yticks([27 28 29 30]);
    end
end
% do these 3 lines do anything?
%for i = 1:curves
%    lines(i);
%end
sgtitle(['Bleaching Events by RCP Scenario and Adaptation, Threshold = ', num2str(critical*100, '% d'), ' % Width = ', num2str(patchWidth*2*100, '% d'), '%']);
legend(legendSubset, 'Location', 'NorthWest', 'NumColumns', 2, 'Orientation', 'horizontal' )
%legend( 'Location', 'NorthWest', 'NumColumns', 2, 'Orientation', 'horizontal' )
end



function [bleachYears, bleachCount] = getBleachYears(fracBleached, count, years, critical, minBleach)
    % The input is the percent of healthy reefs.  Consider that a drop of 50% of
    % the remaining healthy reefs is a critical bleaching year.
    %critBleach  = fracBleached > critical;
    critBleach  = (fracBleached > critical) & (count >= minBleach);
    bleachYears = years(critBleach);
    bleachCount = count(critBleach);
end
