function BleachingHistory_Subplots_WithDT_Row()
% This figure displays data from multiple runs.  The bleaching history output
% for each run is written by Stats_Tables.m into the bleaching/BleachingHistory
% directory within the base output directory for model runs.  For detailed
% yearly output after 1950, set the model parameter doDetailedStressStats true.
% The files for a new set of runs to be plotted should be copied to safe place
% and referenced in relPath below.  This is intentionally a manual step so that
% test runs made later can't accidentally overwrite the data we want to publish.
relPath = '../FigureData/healthy_4panel_figure1/bleaching_NoAdvantage_Jan10/';
shufflePath = '../FigureData/healthy_4panel_figure1/shuffle_1C_Jan10/';

inverse = true;  % 100% means 100% undamaged if true.
topNote = ''; %  {'5% Bleaching Target for 1985-2010', 'Original OA Factor CUBED'};
smooth = 5;  % 1 means no smoothing, n smooths over a total of n adjacent points.
smoothT = 7; % same, but applied to the background temps
figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 19, 7.5]);

% Make subplots across, each for one rcp scenario.
% Within each, have lines for E=0/1 and OA=0/1
rcpList = {'rcp26', 'rcp45', 'rcp85'};
rcpName = {'(a) RCP 2.6', '(b) RCP 4.5', '(c) RCP 8.5'};

% Use tight_subplot (license in license_tight_subplot.txt) to control spacing
% rows, columns, gap, height, width
[ha, pos] = tight_subplot(1, 3, 0.03, [0.15 0.06], 0.1, [3 2 2]);

% Can we mess with the positions now?  pos contains one array per subplot, each
% representing left, bottom, width, height.  Note that pos contains cells but ha
% contains axes arrays.
p1 = pos{1};
p2 = pos{2};
p3 = pos{3};
% The goal is to make the 3 plots take the same space with the same gaps, but
% have the left two 2/3 the size of the first, since they represent 100 years,
% and the first is 150 years.
%{
leftEnd = p1(1);
baseWidth = p1(3);
widthUnit = baseWidth*3/7;
gap = p2(1) - (leftEnd + baseWidth);
ha(1).Position(3) = 3 * widthUnit;
ha(2).Position(1) = leftEnd + 3 * widthUnit + gap;
ha(2).Position(3) = 2 * widthUnit;
ha(3).Position(1) = leftEnd + 5 * widthUnit + 2 * gap;
ha(3).Position(3) = 2 * widthUnit;
% For some reason the operations above change the vertical locations.  1 looks
% okay.  OuterPosition has changed, rather than Position.
ha(2).OuterPosition(2) = ha(1).OuterPosition(2);
ha(2).OuterPosition(4) = ha(1).OuterPosition(4);
%}
legText = {};
legCount = 1;
for i = 1:3
    rrr = rcpList{i};
    % Get temperature data to go with this plot
    [tYears, DT, T] = getTempDeltas(rrr, smoothT);
    % original subplot subplot(2,2,i);
    % Below pick one of the axes set up by tight_subplot
    axes(ha(i)); %#ok<LAXES>
    cases = [];
    hFile = '';
    for eee = 0:1
        for ooo = 0  %:1           
            if ~(eee == 1 && ooo == 1)  % Skip one curve  !!!!
                hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), '.mat');
                fprintf("Loading non-shuffling %s\n", hFile);

                load(hFile, 'yForPlot');
                if inverse
                    yForPlot = 100 - yForPlot;
                end
                if (smooth > 1)
                    yForPlot = centeredMovingAverage(yForPlot, smooth, 'hamming');
                end
                cases = [cases; yForPlot]; %#ok<AGROW>
                legText{legCount} = strcat('E = ', num2str(eee), ' OA = ', num2str(ooo));
                legCount = legCount + 1;
            end
        end
    end
    
    % //////// ADD Symbiont shuffling curves.
    for eee = 0:1
    for ooo = 0:0  % 1:-1:0           
            hFile = strcat(shufflePath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), '.mat');
            fprintf("Loading shuffling %s\n", hFile);
            load(hFile, 'yForPlot');
            if inverse
                yForPlot = 100 - yForPlot;
            end
            if (smooth > 1)
                yForPlot = centeredMovingAverage(yForPlot, smooth, 'hamming');
            end
            cases = [cases; yForPlot]; %#ok<AGROW>
            legText{legCount} = strcat('E = ', num2str(eee), ' OA = ', num2str(ooo), ' Shuffling');
            legCount = legCount + 1;
    end
    end
    
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
    
    % Save this RCP case as a CSV so Cheryl can look at it in R:
    % heading = {'Year', 'Tmax', 'DT', 'E0_OA1', 'E0_OA0', 'E1_OA1', 'E1_OA0'}
    % fname = strcat("healthy_", rcpList(i), ".csv");
    % NOTE: csvwrite can't write a cell array.  For now just add the header line
    % with vi!
    % csvstuff = horzcat(xForPlot', tempPlot, dtPlot, cases');
    % csvwrite(fname, csvstuff, 1, 0); 
    
    oneSubplot(xForPlot, cases, dtPlot, legText, rcpName{i}, i==1);

    if i == 1
        % position units are based on the data plotted
        ylabel({'Percent of healthy coral reefs globally'}, ...
            'FontSize',24,'FontWeight','bold', 'Position', [1922 50]);
    end

end

%  Get the right two axes positions for use in locating the colorbar and label
pos3 = pos{3};
pos2 = pos{2};

% subplot positions are left, bottom, width, height
% Align the color bar to the top and bottom of the plots.
colorbar('Position', [pos3(1)+pos3(3)+0.025  pos3(2)  0.03  pos2(2)+pos2(4)-pos3(2)], ...
         'Ticks', 0:1:3);
% Add a label above the colorbar
annotation(gcf, 'textbox', ...
    [pos3(1)+pos3(3)+0.015, 0.97, 0.03, 0.03], ...
    'String', '\DeltaT(°C)', ...
    'FontSize', 20, 'FitBoxToText', 'on', 'LineStyle', 'none');

% Add a text box at top center if text is provided.
if ~isempty(topNote)
    ann = annotation(gcf,'textbox',...
        [0.5 0.5 0.2 0.08],...
        'String',topNote,...
        'FontSize',20,...
        'FitBoxToText','on');
    loc = ann.Position;
    % Shift to top center
    newLoc = loc;
    newLoc(1) = 0.47 - loc(3)/2;  % 0.47 roughly centers - could calculate from subplot locations.
    newLoc(2) = 0.98 - loc(4);
    ann.Position = newLoc;
end


end

function oneSubplot(X, Yset, T, legText, tText, useLegend) 

    base = [0 0 0];
    light = [0.5 0.5 0.5];
    other = [0.6 0.0 0.8]; % orange:[1.0 0.5 0.0];

    col{1} = base;    
    col{2} = light;

    col{3} = base;
    col{4} = other;

    
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
                set(plot1(i), 'LineStyle', '--');
            case 4 
                set(plot1(i), 'LineStyle', '-');            

        end
    end
    

    
    % Some things are the same for all subplots:
    % Create title
    title(tText, 'FontSize', 22);
    xlabel('Year','FontSize',22);
    ylim([0 100]);
    box('on');
    grid('on');
    
    % Other things are special for the first plot vs the others
    if useLegend
        xlim([1950 2100]);
        set(gca, 'FontSize',22,'XTick',[ 1950 2000 2050 2100 ],...
           'YTick',[0  50  100], 'LineWidth', 1.0, 'GridAlpha', 0.35);        
    else
        xlim([2000 2100]);
        set(gca, 'FontSize',22,'XTick',[ 2050 2100 ],...
            'YTick',[0  50  100], 'LineWidth', 1.0, 'GridAlpha', 0.35);
        set(gca, 'YTickLabel', []);
    end
     
    % Create legend
    hold off;
    if useLegend
        % Note that we load E=0, E=1, Shuffle E=0, Shuffle E=1, but that's not
        % the order for the legend.
        legend1 = legend([plot1(1) plot1(3) plot1(2) plot1(4)], ...                    
            'no adaptation', 'symbiont shuffling', 'symbiont evolution', 'shuffling & evolution');
        set(legend1,'Location','southwest','FontSize',20);
    end 
end

function [years, DT, T_smooth] = getTempDeltas(RCP, smoothT) 
    % Get the global T history and crunch it down to global DT from 1861 to 2001.
    sstPath = "D:/GitHub/Coral-Model-Data/ProjectionsPaper/";
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

