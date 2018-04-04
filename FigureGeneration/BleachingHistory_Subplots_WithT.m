function BHSCO()
%relPath = '../bleaching_history/';
%relPath = 'D:/CoralTest/V11Test_SC/bleaching/';
relPath = 'D:\GoogleDrive\Coral_Model_Steve\_Paper Versions\Figures\Survival4Panel\bleaching_FineTimeScale_March8\';
inverse = true;  % 100% means 100% undamaged if true.
topNote = ''; %  {'5% Bleaching Target for 1985-2010', 'Original OA Factor CUBED'};

figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 17, 11]);

% Make subplots across, each for one rcp scenario.
% Within each, have lines for E=0/1 and OA=0/1
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
rcpName = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};

%{
    paperYears26 = [2000 2020 2028 2039 2040 2041 2044 2050 2060 2080 2099];
    paperHFB26   = [0.5  4.0  11.0 31.0 30.0 29.0 27.0 17.0 18.0 23.0 17.0];
    
    paperYears45 = [2000 2020 2028 2039 2040 2041 2044 2050 2058 2060 2070 2075 2080 2099];
    paperHFB45   = [0.5  7.5  12.5 30.0 30.0 28.0 36.0 55.0 74.5 70.0 75.0 89.0 92.0 97.0];
    
    paperYears85 = [2000 2020 2028 2039 2040 2041 2044 2050 2060 2080];
    paperHFB85   = [0.0  4.0  6.0  58.0 67.0 72.0 87.0 87.0 98.0 100.0];
    paperYears60 = [2000 2020 2028 2039 2040 2041 2044 2050 2056 2060 2080 2099];
    paperHFB60   = [0.5  2.5  7.0  25.0 30.0 33.0 42.0 46.0 51.0 61.0 98.0 100.0];
%}

legText = {};
legCount = 1;
for i = 1:4
    rrr = rcpList{i};
    % Get temperature data to go with this plot
    [tYears, T] = getTempHistory(rrr);
    subplot(2,2,i);
    cases = [];
    hFile = '';
    for eee = 0:1
        for ooo = 1:-1:0           
            %if ~(eee == 0 && ooo == 1)  % Skip one curve
                hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), '.mat');
                load(hFile, 'yForPlot');
                if inverse
                    yForPlot = 100 - yForPlot;
                end
                cases = [cases; yForPlot]; %#ok<AGROW>
                legText{legCount} = strcat('E = ', num2str(eee), ' OA = ', num2str(ooo));
                legCount = legCount + 1;
            %end
        end
    end
    % x values are the same for all. Use the latest file;
    load(hFile, 'xForPlot');
    % Temperature history has every year, but xForPlot may not.  Get the
    % needed values.
    % There's probably a nice way, but just iterate for now.
    tempYears = zeros(length(xForPlot), 1);
    tempPlot = zeros(length(xForPlot), 1);
    jj = 1;
    for j = 1:length(xForPlot)
        while xForPlot(j) > tYears(jj)
            jj = jj + 1;
        end
        tempYears(j) = tYears(jj);
        tempPlot(j) = T(jj);
    end
    
    
    oneSubplot(xForPlot, cases, tempYears, tempPlot, legText, rcpName{i}, i, i==1, i > 2);

    %{
    if strcmp(rcpList{i}, 'rcp85')
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i, paperYears85, paperHFB85);
    elseif strcmp(rcpList{i}, 'rcp60')
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i, paperYears60, paperHFB60);
    elseif strcmp(rcpList{i}, 'rcp26')
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i, paperYears26, paperHFB26);    
    elseif strcmp(rcpList{i}, 'rcp45')
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i, paperYears45, paperHFB45);
    else
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i);
    end
    %}
    if i == 1
        yHandle = ylabel({'Percent of  ''undamaged'' coral reefs globally'},'FontSize',24,'FontWeight','bold');
        set(yHandle, 'Position', [1925 -20 0])
    end

end
%colorbar();
hp4 = get(subplot(2,2,4),'Position')
% subplot positions are left, bottom, width, height
c = colorbar('Position', [hp4(1)+hp4(3)+0.025  hp4(2)  0.03  hp4(2)+hp4(3)*2.1-0.04], ...
         'Ticks', 26:1:30);
%c.Label.String = 'Annual Average SST, °C';
% try adding a label above the colorbar
annT = annotation(gcf, 'textbox', ...
    [hp4(1)+hp4(3)+0.025, 0.92, 0.03, 0.03], ...
    'String', 'SST (°C)', ...
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

function oneSubplot(X, Yset, tYears, T, legText, tText, baseColor, useLegend, labelX) 

    % Create axes
    %axes1 = axes;
    %hold(axes1,'on');
    %{
    switch baseColor
        case 1 
            base = [0 0 .9];
            light = [0.5 0.5 1.0];
        case 2 
            base = [0 .7 0];
            light = [0.4 1.0 0.4];
        case 3 
            %base = [.6 .6 0];
            %light = [0.9 0.9 0];
            base = [1.0 0.55 0];
            light = [1.0 0.65 0.1];
        case 4 
            base = [.9 0 0];
            light = [1.0 0.5 0.5];
    end
    %}
    base = [0 0 0];
    light = [0.5 0.5 0.5];
    col{1} = light;    % XXX - NOTE that this line is hidden for now.
    col{2} = light;

    col{3} = base;
    col{4} = base;
    
    % Color background by temperature
    fprintf("T from %d to %d for %s\n", min(T), max(T), tText);
    TFrame = [T, T]';
    [~, h] = contourf(X, [0 100], TFrame, 26:0.1:30);
    h.LineStyle = 'none';
    brighten(0.2);
    caxis([26 30]);
    % colorbar();

    hold on;
    
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
    

    
    % Create xlabel
    if labelX; xlabel('Year','FontSize',14); end

    % Create title
    title(tText, 'FontSize', 22);


    xlim([1950 2100]);
    ylim([0 100]);
    box('on');
    grid('on');
    % Set the remaining axes properties
    set(gca, 'FontSize',22,'XTick',[ 1950 2000 2050 2100 ],...
        'YTick',[0  50  100]);
    % Create legend
    hold off;
    if useLegend
        %legend1 = legend('show');
        % Specify each line so the contours don't get a legend entry.
        legend1 = legend([plot1(1) plot1(2) plot1(3) plot1(4)]);
        set(legend1,'Location','southwest','FontSize',20);
    end 
end

function [years, SST_out] = getTempHistory(RCP) 
    % Get the global T history and crunch it down to global averages.
    sstPath = "D:/GitHub/Coral-Model-Data/ProjectionsPaper/";
    dataset = "ESM2M";
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
    % Make global averages across all reefs.
    SST_global = mean(SST, 1);
    % Now we have one list of dates, 12 per years.  Reshape so all values for a
    % year are together.
    SST_2D = reshape(SST_global, 12, []);
    SST_out = mean(SST_2D, 1);
    years = startYear:startYear+length(SST_out)-1;
    % asdf
    return
end
