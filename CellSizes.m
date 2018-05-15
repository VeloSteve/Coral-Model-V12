function CellSizes(locations)
% Calculate the approximate size of all cells in kilometers.
% Cells as defined have only a location.  Longitudes are in regular 1 degree
% steps, but latitudes vary, so we must rely on deducing the spacing from
% adjacent cell locations.
% Note that variable names used here may not have the same meaning as in to
% accompanying mapping functions.
    latSort = unique(locations(:, 2));
    height = zeros(length(latSort), 1);
    % For most cells average the distance between those above and below.
    height(2:end-1) = (latSort(3:end) - latSort(1:end-2))/2.0;
    % End cases
    height(1) = latSort(2) - latSort(1);
    height(end) = latSort(end) - latSort(end-1);
    
    % If there are gaps in the latitude list, which will show up as abnormally 
    % large sizes.  Check in a for loop so its easy to report on corrections
    % made.
    % Note: the code below makes no changes, but it seemed good to check!
    found = 99;
    while found
        found = 0;
        for i = 1:length(height)
            if i == 1
                nh = height(i+1);
            elseif i == length(height)
                nh = height(i-1);
            else
                nh = min(height(i+1), height(i-1));
            end
            if nh * 1.5 < height(i)
                height(i) = nh;
                fprintf("Adjusted height at lat %d to %d\n", latSort(i), height(i));
                found = found + 1;
            end
        end
        if found
            fprintf('Changed %d heights.  Making another pass to be sure.\n', found);
        end
    end
    
    % Now that we have cell heights for each latitude, we can use these as a
    % lookup table.
    area = zeros(length(locations(:, 1)), 1);
    % Remember that the longitude width of each cell is 1, so no term appears
    % for it.
    % This seems really awkward, but for each latitude in the latSort array,
    % find all matches in locations and fill their area values based on the
    % matching height.
    lats = locations(:, 2);
    for i = 1:length(latSort)
        lat = latSort(i);
        % idx = find(lats == lat);
        idx = lats == lat;
        area(idx) = height(i);
    end
    % areas is just a height in degrees.  We want kilometers.
    % Roughly, 1 degree longitude = 111 km and 1 degree latitude is that times
    % the cosine of latitude.
    area = area .* abs(cos(pi*lats/180.0)) * 111 * 111;
    fprintf('Area ranges from %d to %d, with a mean of %d km^2\n.', ...
        min(area), max(area), mean(area));
end
