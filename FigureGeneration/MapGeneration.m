%% Make Maps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 1-6-15                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = MapGeneration(Reefs_latlon, values, figNum, tName, lowestScaleMax )
    if nargin < 5
        lowestScaleMax = 5;
    end
    format shortg;

    % A scale for "red=bad, blue=good" plots.
    % customColors = customScale();

    %tName = strcat('Reef Cell Historical Temperatures, °C');
    % Green points everywhere
    oneMap(figNum, Reefs_latlon(:, 1), Reefs_latlon(:, 2), values, parula, tName, lowestScaleMax);

end  % End the main MapGeneration function.

% Arguments:
% n     figure number
% lons  longitudes (was [events.lon])
% lats  latitudes
% values what to plot at each position
% cRange man and max data values for color scale
% t title
function [] = oneMap(n, lons, lats, values, cMap, t, lowestScaleMax)
    persistent LONG LAT longSort latSort;
    f = figure(n);
    if n == 3
        set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 15, 4]);
    elseif n == 4
        set(gcf, 'Units', 'inches', 'Position', [17, 1.5, 15, 4]);
    elseif n == 1
        set(gcf, 'Units', 'inches', 'Position', [1, 7.0, 15, 4]);
    elseif n == 2
        set(gcf, 'Units', 'inches', 'Position', [17, 7.0, 15, 4]);
    else
        set(gcf, 'Units', 'inches', 'Position', [4, 4, 15, 4]);
    end

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
    if lowestScaleMax < 0.999
        minT = floor(min(values)*10)/10.0;
        maxT = ceil(max(values)*10)/10.0;
    else
        minT = floor(min(values));
        maxT = ceil(max(values));
    end
    if maxT < lowestScaleMax
        maxT = lowestScaleMax;
    end
    tRange = maxT - minT;
    cVals = length(cMap);
    fprintf('minT = %d, maxT = %d \n', minT, maxT)
    
    %scatter(LONG,LAT,5, values) ; % plot bleaching events onto map
    % Added later: report on reef cell sizes it's easy to do here since
    % the basic values are already being calculated.
    for i = 1:length(LONG)
        % Position is [left x, lower y, width, height]
        x = LONG(i);
        w = longSort(find(longSort(:, 1) == x), 2);        
        y = LAT(i);
        h = latSort(find(latSort(:, 1) == y), 2);
        reefColor = cMap(max(1, floor(cVals*(values(i)-minT)/tRange)), :);
        rectangle('Position', [x - w/2, y - h/2, w, h], 'FaceColor', reefColor, 'EdgeColor', reefColor    );
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
    % These maps were originally developed for temperature, using 5 C multiples.
    % When using standard deviation, values will be smaller.  As a kludge, use
    % the size of lowestScalMax (less than 5) as an indicator that the range
    % will be small.
    if lowestScaleMax >= 5
        cb.Ticks = [0 5 10 15 20 25 30 35];
        cb.TickLabels = [{'0 °C'} {'5 °C'} {'10 °C'} {'15 °C'} {'20 °C'} {'25 °C'} {'30 °C'} {'35 °C'}];
    elseif lowestScaleMax < 0.999
        cb.Ticks = [-1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1];
        cb.TickLabels = [{'-1'} {'-0.8'} {'-0.6'} {'-0.4'} {'-0.2'} {'0'} {'0.2'} {'0.4'} {'0.6'} {'0.8'} {'1'}]; 
    else
        cb.Ticks = [-1 0 1 2 3 4 5 6];
        cb.TickLabels = [{'-1'} {'0'} {'1'} {'2'} {'3'} {'4'} {'5'} {'6'}];        
    end
    aaa = gca;
    aaa.FontSize = 32;
    title(t)
    

    hold off;
end
