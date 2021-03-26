vertical = false;
rcps = [ 4.5 8.5];
letters = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'];
% inputPath = '../FigureData/LastYearMaps_Figure3/CurveE_221/';
inputPath = '../FigureData/LastYearMaps_Figure3_Feb2021/';
description = strings(8,1);

% Collect the maps in vectors.  Plot them later.
% Less loop-based approached so we can have an arbitrary display order.
num = 0;
eee = 0;
panelRCP(8) = 0; % preallocate.
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;
    description(num) = ' no adaptation';
    % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
    n = strcat(inputPath, 'ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA0.0_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% Add shuffling panels
eee = 0;
for rcp = rcps
    num = num + 1;    
    panelRCP(num) = rcp;
    description(num) = ' symbiont shuffling';

    n = strcat(inputPath, 'ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA1.0_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% And now E=1, no shuffling
eee = 1;
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;

    description(num) = ' symbiont evolution';
    
    % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
    n = strcat(inputPath, 'ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA0.0_LastHealthyBothTypesV2');
    fprintf('Opening map %s\n', n);
    p1(num) = open(strcat(n,'.fig'));
    pax(num) = gca; %#ok<SAGROW>
    figureHandles(num) = p1(num); %#ok<SAGROW>
end
% Finally, E=1 PLUS shuffling
eee = 1;
for rcp = rcps
    num = num + 1;
    panelRCP(num) = rcp;

    description(num) = ' evolution and shuffling';
    
    % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
    n = strcat(inputPath, 'ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA1.0_LastHealthyBothTypesV2');
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

figure('color', 'w');
%set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 17, 5.5]);

% Use tight_subplot (license in license_tight_subplot.txt) to control spacing
% rows, columns, gap h/gap w, lower/upper margin height, left/right margin width
%[ha, pos] = tight_subplot(2, 2, [0.05, -0.09], [0.04, 0.1], [0.0 0.05]);
if vertical
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 13, 14]);
    [ha, pos] = tight_subplot(panels, 1, [0.0, 0.0], [0.0, 0.0], [0.0 0.05]);
else
    set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 17, 10.5]);
    [ha, pos] = tight_subplot(panels/2, 2, [0.02, 0], [0.0, 0.05], [0.0 0.1]);
end


num = 0;
for num = 1:panels
    axes(ha(num)); %#ok<LAXES>
    % P = subplot(panels/2,2,num);
    copyobj(get(pax(num),'children'), gca);
    %n = strrep(names{i}, '_', ' ');
    axis off;
    set(gca,'FontSize',14);
    caxis(yearRange);  % Limit and make consistent
    colormap(cmap); %(flipud(jet)
    ti = title(strcat('(', letters(num), ') RCP ', num2str(panelRCP(num)), description(num)));
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
%    'FontSize',14);
cb = colorbar('Position',...
    [0.91 0.15 0.022 0.65],...
    'Ticks',ticks,...
    'Limits',yearRange,...
    'Color',[0.15 0.15 0.15],...
    'FontSize',14);
set(cb, 'YAxisLocation','right')

