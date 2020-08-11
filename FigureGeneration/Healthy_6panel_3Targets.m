function  Healthy_6panel_3Targets()
addpath('..'); % for tight_subplot
% This is a variant of BleachingHistory_Subplots_WithDT_Row() used for comparing
% the effects of different bleaching targets.
% The old version has 3 or 4 plots left-to-right, for different RCP values.
% It has 4 curves on each - E=0, E=1, and those two options plus shuffling.
%
% As of 2020 there are two columns, representing RCP 4.5 and 8.5.  Each has
% 3 rows, for the 3, 5, and 10% targets.  Each plot has 5 lines, 3 for E=0 with no
% OA, with shuffling, and with shuffling and OA, and the 2 for E=1 with and
% without OA.  More compactly, E, OA, and Shuffling advantage are
% 000, 001, 011, 100, 110

path5 = '../FigureData/healthy_4panel_figure1/Target5_E221/';
path3 = '../FigureData/healthy_4panel_figure1/Target3_E221/';
path10 = '../FigureData/healthy_4panel_figure1/Target10_E221/';


inverse = true;  % 100% means 100% undamaged if true.
smooth = 5;  % 1 means no smoothing, n smooths over a total of n adjacent points.
smoothT = 7; % same, but applied to the background temps
figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [2, 0, 9.5, 13]);

cols = 2;
rows = 3;
rcpList = {'rcp45', 'rcp85'};
rcpName = {'RCP 4.5', 'RCP 8.5', '', '', '', ''};
%rcpName = {'(a) RCP 2.6', '(b) RCP 4.5', '(c) RCP 6.0', '(d) RCP 8.5'};
rcpList = repmat(rcpList, 1, rows);

% Use tight_subplot (license in license_tight_subplot.txt) to control spacing
% rows, columns, gap (h w), margin height (lower upper), margin width (left right), relative width (my addition)
[ha, pos] = tight_subplot(rows, cols, [0.04 0.06], [0.15 0.05], [0.2 0.15], [1 1]);

legText = {};
legCount = 1;
panels = size(rcpList, 2);
for i = 1:panels
    rrr = rcpList{i};
    row = ceil(i / cols);
    % Get temperature data to go with this plot
    [tYears, DT, T] = getTempDeltas(rrr, smoothT);

    % Below pick one of the axes set up by tight_subplot
    axes(ha(i)); %#ok<LAXES>
    cases = [];
    hFile = '';
    for eee = 0:1
        for ooo = 0:1           
            if ~(eee == 0 && ooo == 1)  % Skip one curve  !!!!
                % Eash row has its own path
                if row == 1
                    hFile = strcat(path3, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=0.0.mat');
                elseif row == 2
                    hFile = strcat(path5, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=0.0.mat');
                else
                    hFile = strcat(path10, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=0.0.mat');
                end
                fprintf("Loading non-shuffling %s\n", hFile);

                load(hFile, 'yForPlot');
                if inverse
                    yForPlot = 100 - yForPlot;
                end
                if (smooth > 1)
                    yForPlot = centeredMovingAverage(yForPlot, smooth, 'hamming');
                end
                cases = [cases; yForPlot]; %#ok<AGROW>
                legText{legCount} = strcat('E = ', num2str(eee), ' OA = ', num2str(ooo)); %#ok<AGROW>
                legCount = legCount + 1;
            end
        end
    end
    % In addition to the E and OA combinations, there is a shuffling line in
    % each panel.
    eee = 0;
    for ooo = 0:1           
        % Each row has its own path
        if row == 1
            hFile = strcat(path3, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=1.0.mat');
        elseif row == 2
            hFile = strcat(path5, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=1.0.mat');
        else
            hFile = strcat(path10, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), 'Adv=1.0.mat');
        end
        fprintf("Loading shuffling %s\n", hFile);
        load(hFile, 'yForPlot');
        if inverse
            yForPlot = 100 - yForPlot;
        end
        if (smooth > 1)
            yForPlot = centeredMovingAverage(yForPlot, smooth, 'hamming');
        end
        cases = [cases; yForPlot]; %#ok<AGROW>
        legText{legCount} = strcat("shuffling, OA=", num2str(ooo)); %#ok<AGROW>
        legCount = legCount + 1;
    end
    
    % Add
      
    % x values are the same for all. Use the latest file;
    load(hFile, 'xForPlot');
    % Temperature history has every year, but xForPlot may not.  Get the
    % needed values.
    % There's probably a nice way, but just iterate for now.
    tempYears = zeros(length(xForPlot), 1);
    dtPlot = zeros(length(xForPlot), 1);
    tempPlot = zeros(length(xForPlot), 1);
    jj = 1;
    for j = 1:length(xForPlot)
        while xForPlot(j) > tYears(jj)
            jj = jj + 1;
        end
        tempYears(j) = tYears(jj);
        dtPlot(j) = DT(jj);
        tempPlot(j) = T(jj);
    end
     
    oneSubplot(xForPlot, cases, dtPlot, legText, rcpName{i}, i==1, row==rows, mod(i, cols)==1);
    if i == 1
        % position units are based on the data plotted
        ylabel({'Target 3%'}, ...
            'FontSize',24,'FontWeight','bold'); %, 'Position', [1922 50]);
    elseif i == 3
        % next line is based on https://www.mathworks.com/matlabcentral/answers/59545-how-can-i-change-the-space-between-multiline-title
        tall_str = sprintf(['\\fontsize{36}' blanks(1) '\\fontsize{24}']);

        ylabel({'Percent of healthy coral reefs globally'; [tall_str 'Target 5%']}, ...
            'FontSize',24,'FontWeight','bold'); %, 'Position', [1922 50]);
    elseif i == 5
        ylabel({'Target 10%'}, ...
            'FontSize',24,'FontWeight','bold'); %, 'Position', [1922 50]);
    end

end

%  Get the right two axes positions for use in locating the colorbar and label
posN = pos{cols*2};
posNM = pos{cols*2-1};

% subplot positions are left, bottom, width, height
% Align the color bar to the top and bottom of the plots.
colorbar('Position', [posN(1)+posN(3)+0.025  posN(2)  0.03  posNM(2)+posNM(4)-posN(2)], ...
         'Ticks', 0:1:3);
% Add a label above the colorbar
annotation(gcf, 'textbox', ...
    [posN(1)+posN(3), posN(2)+posN(4)+0.01, 0.03, 0.03], ...
    'String', '\DeltaT(°C)', ...
    'FontSize', 20, 'FitBoxToText', 'on', 'LineStyle', 'none');

end

function oneSubplot(X, Yset, T, legText, tText, useLegend, labelX, labelY) 

    black = [0 0 0];
    blue =  [0.0 0.35 0.95];
    red  =  [0.9 0.1  0.1];
    other = [0.6 0.0  0.8]; 

    col{1} = black;    
    col{2} = blue;
    col{3} = blue;
    col{4} = red;
    col{5} = red;
    
    % Line styles for consistency between figures 1 and S5.
    % The first 5 are for this file, in display order.
    % The 6th is for the 3-panel Figure 1, the only non-duplicated combination.
    % E OA Adv
    % 0  0  0  black solid
    % 1  1  0  blue solid
    % 1  0  0  blue solid
    % 0  0  1  blue dash
    % 0  1  1  blue dash
    % 1  0  1  purple dash
    % 3  2  3  count of ones in each column.
    % Let purple = advantaged
    %     black = anything else
    %     solid = E=0, OA=0
    %     dash  = E=1, OA=0
    %     dot   = E=0, OA=1
    %     ???
    % OR
    % Let purple = E=1, Adv=1
    %     black  = E=0, Adv=0 (baseline)
    %     blue   =  Either E=1 or Adv=1
    %     solid = OA=0
    %     dashed = OA=1
    
    % Color background by temperature
    %colormap('redblue');
    cmap = coolwarm(200);
    % Make the map less intense and reload it.
    %cmap = min(1, cmap+0.2);
    %cmap = max(0.2, cmap);
    % "reduce darkness" function.  Smaller fraction is less intense.
    % We used 0.75 during summer 2018.  Trying for a paler effect now:
    cmap = 1-((1-cmap)*0.5);
    colormap(cmap)
    %cmap = jet;
    %cmap = min(cmap+0.3, 1);
    %colormap(cmap);
    %brighten(0.7);
    
    fprintf("T from %d to %d for %s\n", min(T), max(T), tText);
    TFrame = [T, T]';
    [~, h] = contourf(X, [0 100], TFrame, 0:0.005:3.0); %-0.22:0.2:3.2);
    h.LineStyle = 'none';
    caxis([0 3.0]);
    % colorbar();

    hold on;
    
    % Create multiple lines using matrix input to plot
    plot1 = plot(X,Yset(:, :));
    for i = size(Yset, 1):-1:1
        set(plot1(i),...
            'DisplayName',legText{i}, ...
            'Color', col{i}, ...
            'LineWidth', 2);
        %if mod(i, 2) == 1
        %    set(plot1(i), 'LineStyle', '--');
        %end 
        switch i
            case 1 
                set(plot1(i), 'LineStyle', '-');
            case 2 
                set(plot1(i), 'LineStyle', ':');
            case 3 
                set(plot1(i), 'LineStyle', '-');
            case 4 
                set(plot1(i), 'LineStyle', '-'); 
            case 5
                set(plot1(i), 'LineStyle', ':');
        end
    end
    

    
    % Some things are the same for all subplots:
    % Create title
    title(tText, 'FontSize', 22);

    ylim([0 100]);
    box('on');
    grid('on');
    
    % Other things are special for the first plot vs the others
    xlim([1950 2100]);
    if labelX
        xlabel('Year','FontSize',22);
        if labelY
            set(gca, 'FontSize',22,'XTick',[ 1950 2000 2050 2100 ],...
               'LineWidth', 1.0, 'GridAlpha', 0.35);
        else
            set(gca, 'FontSize',22,'XTick',[ 2000 2050 2100 ],...
                'LineWidth', 1.0, 'GridAlpha', 0.35);
        end
    else
        % side the grid, but omit labels.
        set(gca, 'FontSize',22,'XTick',[ 1950 2000 2050 2100 ],...
            'LineWidth', 1.0, 'GridAlpha', 0.35);
        set(gca, 'XTickLabel', []);
    end
    if labelY
        ylim([0 100]);
        set(gca, 'FontSize',22, ...
            'YTick',[0  50  100], 'LineWidth', 1.0, 'GridAlpha', 0.35);
    else
        set(gca, 'YTickLabel', []);
    end
     
    % Create legend
    hold off;
    if useLegend
        % Note that we load E/OA in the order 0/0, 1/0, 1/1, but that's not
        % the order for the legend.
        legend1 = legend([plot1(1) plot1(3) plot1(2) plot1(4), plot1(5)], ...                    
            'E=0, OA=0', 'E=1, OA=1', 'E=1, OA=0', 'Shuffling, OA=0', 'Shuffling, OA=1');
        set(legend1,'Location','southwest','FontSize',16);
    end 
end

function [years, DT, T_smooth] = getTempDeltas(RCP, smoothT) 
    % Get the global T history and crunch it down to global DT from 1861 to 2001.
    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
    dataset = "ESM2M";
    [SST, ~, ~, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
    % For each reef get the average peak for the first 140 years. (1861 to 2000)
    % Make indexes be reef, month, year counter
    SST_3D = reshape(SST, 1925, 12, []);
    % Get the max T for each reef and year.  It seems odd that max requires an
    % empty set of brackets while sum does not.
    SST_Maxes = squeeze(max(SST_3D, [], 2));  
    SST_2001AvMax = mean(SST_Maxes(:, 1:140), 2);
    
    % Get local DT for all reefs and years.
    SST_DT = SST_Maxes - SST_2001AvMax;
    % Only now we average the DT across all reefs (could do some sort of 2D
    % representation instead???)
    SST_out = mean(SST_DT, 1);
    min(SST_out(90:end));
    % Try smoothing just a little
    DT = centeredMovingAverage(SST_out, smoothT, 'hamming');
    T_smooth = centeredMovingAverage(SST_Maxes, smoothT, 'hamming');
    DT(DT<0) = 0.0;
    years = startYear:startYear+length(SST_out)-1;
    return
end

