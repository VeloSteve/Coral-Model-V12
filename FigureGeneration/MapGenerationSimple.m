%% Make Maps
% MapGeneration has features wired for specific figures, but it is limiting for
% other uses.  This is a stripped-down version.
function [] = MapGenerationSimple(Reefs_latlon, values, figNum, tName, colorLimits, flip, values2 )
    format shortg;

    % A scale for "red=bad, blue=good" plots.
    customColors = customScale();
    if flip
        customColors = flipud(customColors);
    end

    %tName = strcat('Reef Cell Historical Temperatures, °C');
    % Green points everywhere
    if nargin < 7
        oneMap(figNum, Reefs_latlon(:, 1), Reefs_latlon(:, 2), values, customColors, tName, colorLimits);
    else
        oneMap(figNum, Reefs_latlon(:, 1), Reefs_latlon(:, 2), values, customColors, tName, colorLimits, values2);
    end
end  % End the main MapGeneration function.

% Arguments:
% n     figure number
% lons  longitudes (was [events.lon])
% lats  latitudes
% values what to plot at each position
% cRange min and max data values for color scale
% t title
function [] = oneMap(n, lons, lats, values, cMap, t, colorLimits, values2)
    persistent LONG LAT longSort latSort;
    f = figure(n);
    set(gca, 'Color', 'w');
    % Scatter the locations a bit to see them draw.
    % (left, bottom, width, height)
    set(gcf, 'Units', 'inches', 'Position', [0.5 + n/3, 0.5 + n/4, 27, 10]);

        clf;
        % first pass only:
        %m_proj('miller'); % , 'longitude', 155); % - offsets map, but drops some data!
        m_proj('miller', 'lat',[-40 40],'long',[20 340]); % [0 360] for world, but no reefs from -28.5 to +32 longitude
        m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
        m_grid('box','off','linestyle','none','backcolor',[.9 .99 1], ...
            'xticklabels', [], 'yticklabels', [], 'ytick', 0, 'xtick', 0);

    % Assume that all maps in a run will use the same lat/lon inputs, so we
    % can save time by re-using the values computed here:
    if isempty(LONG) || isempty(LAT) || isempty(longSort) || isempty(latSort)
        idx = find(lons < 0);
        lons(idx) = lons(idx) + 360; % for shifted map (0 to 360 rather than -180 to 180)
        [LONG,LAT] = m_ll2xy(lons,lats); % convert reef points to M-Map lat long

        % Get unique coordinates in ascending order.
        longSort = unique(LONG);
        latSort = unique(LAT);

        longSort(end, 2) = longSort(end, 1)-longSort(end-1, 1);
        longSort(1, 2) = longSort(2, 1)-longSort(1, 1);
        longSort(2:end-1, 2) = min(longSort(2:end-1, 1)-longSort(1:end-2, 1), longSort(3:end, 1)-longSort(2:end-1, 1));
        latSort(end, 2) = latSort(end, 1)-latSort(end-1, 1);
        latSort(1, 2) = latSort(2, 1)-latSort(1, 1);
        latSort(2:end-1, 2) = min(latSort(2:end-1, 1)-latSort(1:end-2, 1), latSort(3:end, 1)-latSort(2:end-1, 1));

        % If a longitude location has no adjacent neighbor the cell will be too
        % wide.  Don't let a width value be more than 50% bigger than its neighbors.
        idx = find(longSort(2:end, 2) > 1.5*longSort(1:end-1, 2));
        idx = idx + 1;
        while ~isempty(idx)
            disp('Shrinking multiple longitude steps.');
            longSort(idx, 2) = min(longSort(idx+1, 2), longSort(idx-1, 2));
            idx = find(longSort(2:end, 2) > 1.5*longSort(1:end-1, 2));
            idx = idx + 1;
        end

        % Same for latitude, though it does not seem to happen there.
        idx = find(latSort(2:end, 2) > 1.5*latSort(1:end-1, 2));
        idx = idx + 1;
        while ~isempty(idx)
            disp('Shrinking multiple latitude steps.');
            latSort(idx, 2) = min(latSort(idx+1, 2), latSort(idx-1, 2));
            idx = find(latSort(2:end, 2) > 1.5*latSort(1:end-1, 2));
            idx = idx + 1;
        end
    end
    
    % Rectangles don't do color mapping, so make a substitute.
    % If using less than 1 for max, round to tenths instead of 1s.
    if isempty(colorLimits)
        minT = min(values);
        maxT = min(values);
    else
        minT = colorLimits(1);
        maxT = colorLimits(2);
    end
    tRange = maxT - minT;
    cVals = length(cMap);
    fprintf('minT = %d, maxT = %d, value range %d to %d \n', minT, maxT, min(values), max(values))
    
    % The second variable is continuous, but we only have a few symbols
    % available.  Split at 1/3 percentiles.
    thirds = quantile(values2, [1/3.0, 2/3.0]);
    fprintf("Splitting value2 at %f and %f\n", thirds);
    drawnow;
    %scatter(LONG,LAT,5, values) ; % plot bleaching events onto map
    % Added later: report on reef cell sizes it's easy to do here since
    % the basic values are already being calculated.
    for i = 1:length(LONG)
        % Position is [left x, lower y, width, height]
        x = LONG(i);
        w = longSort(find(longSort(:, 1) == x), 2);        
        y = LAT(i);
        h = latSort(find(latSort(:, 1) == y), 2);
        reefColor = cMap(min(cVals, max(1, floor(cVals*(values(i)-minT)/tRange))), :);
        % rectangle works well, but doesn't work with hatchfill.  Try a patch.
        % rect = rectangle('Position', [x - w/2, y - h/2, w, h], 'FaceColor', reefColor, 'EdgeColor', reefColor    );
        % Note also that building one patch with many faces could be a lot
        % faster than doing each one in a loop - but then can hatchfill be used?
        % patch(X, Y, C), with vertices clockwise.  I'll start from top left.
        X = [x-w/2, x+w/2, x+w/2, x-w/2];
        Y = [y+h/2, y+h/2, y-h/2, y-h/2];
        ppp = patch(X, Y, reefColor, 'LineStyle', 'none');
        if nargin > 7
            % 3rd param is angle for hatches, width for speckling, 4th is
            % spacing or density
            if values2(i) > thirds(2)
                hatchfill(ppp, 'cross', 45, 4, reefColor);
            elseif values2(i) > thirds(1)
                hatchfill(ppp, 'speckle', 20, 0.2, reefColor);
            else
                % hh1 = hatchfill(ppp, 'single', -45, 3, reefColor);
            end
        end
        if mod(i, 400) == 0
            drawnow;
        end
    end
    
  
    if isempty(cMap)
        colormap default;
    else
        colormap(cMap)
    end

     caxis([minT maxT]);
    % caxis([20 30]);
    
    % For just Galapagos to Bermuda:
    %xlim([-1.8 -1])
    %ylim([-0.1 .7])
    % For just low latitudes
    %ylim([-0.7 0.7])

    cb = colorbar;

    %cb.Ticks = [0 0.5 1 1.5];
    %cb.TickLabels = [{'0'} {'0.5'} {'1'} {'1.5'}]; 

    aaa = gca;
    aaa.FontSize = 32;
    title(t)
    
    % Eliminate wasted whitespace per 
    % https://www.mathworks.com/help/releases/R2019b/matlab/creating_plots/save-figure-with-minimal-white-space.html
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width-0.005 ax_height];
    

    hold off;
end
