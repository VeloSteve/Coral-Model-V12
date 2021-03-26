if ~isfolder(figureDir) || ~isfolder(runOutputs)
    error("This script must have input and output directories pre-set.");
end

vertical = false;
rcps = [ 4.5 8.5];
letters = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'];

description = strings(8,1);

% Collect the maps in vectors.  Plot them later.
% Less loop-based approached so we can have an arbitrary display order.
num = 0;
eee = 0;
adapt = '0.0';
panelRCP(8) = 0; % preallocate.
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;
    description(num) = ' No Adaptation';
    % Example directory
    %   C:\CoralTest\Feb2021_Target5_M2.6_2.8_y0.32_min0.35\ESM2M.rcp26.E0.OA0.sM9.sA0.0.20210223_maps
    % Example file name
    % ESM2M.rcp26.E0.OA0.sM9.sA0.0_LastHealthyBothTypesV2.fig
    commonPart = strcat('ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA', adapt);
    dataDir = strcat(runOutputs, commonPart, '.', runDateString, '_maps/');
    n = strcat(dataDir, commonPart, '_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% Add shuffling panels
eee = 0;
adapt = '1.0';
for rcp = rcps
    num = num + 1;    
    panelRCP(num) = rcp;
    description(num) = ' Symbiont Shuffling';

    commonPart = strcat('ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA', adapt);
    dataDir = strcat(runOutputs, commonPart, '.', runDateString, '_maps/');
    n = strcat(dataDir, commonPart, '_LastHealthyBothTypesV2');    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% And now E=1, no shuffling
eee = 1;
adapt = '0.0';
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;

    description(num) = ' Symbiont Evolution';
    
    commonPart = strcat('ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA', adapt);
    dataDir = strcat(runOutputs, commonPart, '.', runDateString, '_maps/');
    n = strcat(dataDir, commonPart, '_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% Finally, E=1 PLUS shuffling
eee = 1;
adapt = '1.0';
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;

    description(num) = ' Symbiont Shuffling and Evolution';
    commonPart = strcat('ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA', adapt);
    dataDir = strcat(runOutputs, commonPart, '.', runDateString, '_maps/');
    n = strcat(dataDir, commonPart, '_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end

panels = num;

% use this to get the color scale of one of the plots:
%cmap = colormap(pax(1));
% or this to load from a file
addpath('..');
cmap = customScale();

yearRange = [2000 2100];
ticks = [2000 2050 2100];

fh = figure('color', 'w');
%set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 17, 5.5]);

% Place a line above the top row, and RCP numbers above that
annotation(fh,'line',[0.015 0.89], [0.935 0.935], 'LineWidth', 1.5);
annotation(gcf, 'textbox', ...
    [0.16, 0.978, 0.03, 0.03], ...
    'String', 'RCP 4.5', 'FontWeight', 'bold',  ...
    'FontSize', 18, 'FitBoxToText', 'on', 'LineStyle', 'none');
annotation(gcf, 'textbox', ...
    [0.61, 0.978, 0.03, 0.03], ...
    'String', 'RCP 8.5', 'FontWeight', 'bold', ...
    'FontSize', 18, 'FitBoxToText', 'on', 'LineStyle', 'none');

% Use tight_subplot (license in license_tight_subplot.txt) to control spacing
% rows, columns, gap h/gap w, lower/upper margin height, left/right margin width
%[ha, pos] = tight_subplot(2, 2, [0.05, -0.09], [0.04, 0.1], [0.0 0.05]);
% Sizing note: for vector conversion, it's best to stay withing 8.5x11".
if vertical
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 8.0, 11]);
    [ha, pos] = tight_subplot(panels, 1, [0.0, 0.0], [0.0, 0.0], [0.0 0.05]);
else
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 8.5, 5.25]);
    [ha, pos] = tight_subplot(panels/2, 2, [0.02, 0], [0.0, 0.1], [0.0 0.1]);
end


num = 0;
for num = 1:panels
    axes(ha(num)); %#ok<LAXES>
    % P = subplot(panels/2,2,num);
    copyobj(get(pax(num),'children'), gca);
    %n = strrep(names{i}, '_', ' ');
    axis off;
    set(gca,'FontSize',12);
    caxis(yearRange);  % Limit and make consistent
    colormap(cmap); %(flipud(jet)
    %ti = title(strcat('(', letters(num), ') RCP ', {' '}, num2str(panelRCP(num)), description(num)));
    ti = title(strcat('(', letters(num), {') '}, description(num)));
    % Shift title down a bit
    pos = get(ti, 'position');
    pos(2) = pos(2) - 0.2;
    set(ti, 'position', pos);
end
% The close works in the main loop, but keep it out because that has caused
% trouble in other cases.
for num = 1:panels
   close(p1(num));
end
%colorbar('Ticks',ticks,...
%    'Limits',yearRange,...
%    'Color',[0.15 0.15 0.15],...
%    'FontSize',12);
cb = colorbar('Position',...
    [0.91 0.15 0.022 0.65],...
    'Ticks',ticks,...
    'Limits',yearRange,...
    'Color',[0.15 0.15 0.15],...
    'FontSize',12);
set(cb, 'YAxisLocation','right')
drawnow;
return;
if figureDir ~= ""
    fullName = strcat(figureDir, 'Figure3_Maps_', runID);
    %saveas(fh, strcat(fullName, ".png"));
    savefig(strcat(fullName, '.fig'));
    addpath('..');
    saveCurrentFigure(fullName);
end