close all
vertical = false;
rcps = [ 4.5 8.5];
letters = ['a' 'b' 'c' 'd' 'e' 'f'];
inputPath = 'D:/Library/MyDocs/Biology Study/_LoganLab/Paper2017/SST_Deltas/';
description = strings(6,1);
%cornerX = [1, 9, 1, 9, 1, 9, 1, 9];
%cornerY = [8, 8, 4, 4, 1, 1];
%widthBar = 0.5;
%widthAxes = 0.7;
%heightAll = 3;

cornerX = [.01, .51, .01, .51, .01, .51];
cornerY = [.6, .6, .3, .3, 0, 0];
widthAxes = 0.45;
heightAll = 0.33;
% Less loop-based approached so we can have an arbitrary display order.
num = 0;
eee = 0;
panelRCP(6) = 0; % preallocate.

% Hottest Month deltas
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;
    description(num) = ' - \Delta Hottest Month SST 1861-1900 to 2050';
    n = strcat(inputPath, 'Deltas_', num2str(rcp));
    fprintf('Opening map %s\n', n);
    p1 = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    bar(num) = findall(p1, 'type', 'colorbar'); %#ok<SAGROW>
    figureHandles(num) = p1; %#ok<SAGROW>
end
    % Add change in standard deviation
    for rcp = rcps
        num = num + 1;    
        panelRCP(num) = rcp;
        description(num) = ' - \Delta std[SST] 1861-1900 to 2050-80';

        % n = strcat(inputPath, 'SDHotDeltas_', num2str(rcp));
        n = strcat(inputPath, 'SDDeltas_', num2str(rcp));
        fprintf('Opening map %s\n', n);
        p1 = open(strcat(n,'.fig'));
        pax(num) = gca; %#ok<SAGROW>
        bar(num) = findall(p1, 'type', 'colorbar'); %#ok<SAGROW>    
        figureHandles(num) = p1; %#ok<SAGROW>
    end
    % And now the future standard deviation of hot months (for 2050-2080)
    for rcp = rcps
        num = num + 1;
        panelRCP(num) = rcp;

        description(num) = ' - Future std[SST] 2050-80';

        % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
        %n = strcat(inputPath, 'SDHot2050_', num2str(rcp));
        n = strcat(inputPath, 'SD2050_', num2str(rcp));
        fprintf('Opening map %s\n', n);
        p1 = open(strcat(n,'.fig'));
        pax(num) = gca; %#ok<SAGROW>
        bar(num) = findall(p1, 'type', 'colorbar'); %#ok<SAGROW>
        figureHandles(num) = p1; %#ok<SAGROW>
    end


panels = num;



fig = figure('color', 'w');
%set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 17, 5.5]);

% Use tight_subplot (license in license_tight_subplot.txt) to control spacing
% rows, columns, gap h/gap w, lower/upper margin height, left/right margin width
%[ha, pos] = tight_subplot(2, 2, [0.05, -0.09], [0.04, 0.1], [0.0 0.05]);
if vertical
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 13, 14]);
else
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 17, 8.5]);
end

% Before, subpanels worked, but with separate colorbars it's easier to
% just copy into the figure and reposition.
num = 0;
for num = 1:panels

    hab = copyobj([pax(num), bar(num)], fig);

    posBoth = get(hab, 'position');
    pos = posBoth{1}; % For the axes
    pos(1) = cornerX(num);
    pos(2) = cornerY(num);
    pos(3) = widthAxes;
    pos(4) = heightAll;
    set(hab(1), 'position', pos);
    
  
    %n = strrep(names{i}, '_', ' ');
    axis off;
    set(hab(1),'FontSize',14);
    %D caxis(yearRange);  % Limit and make consistent
    %D colormap(cmap); %(flipud(jet)
    ti = title(hab(1), strcat('(', letters(num), ') RCP ', num2str(panelRCP(num)), description(num)));
    % Shift title down a bit
    %pos = get(ti, 'position');
    %pos(2) = pos(2) - 0.2;
    %set(ti, 'position', pos);

end


