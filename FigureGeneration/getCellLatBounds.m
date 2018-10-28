function [bounds] = getCellLatBounds(lats)
    % GETCELLLATBOUNDS Get cell latitude boundaries for plotting or spatial
    % matching.
    % bounds = getCellLatBounds(lats) returns an array of upper and lower bounds
    % for each cell bounded by the centroids listed in lats.
    %
    % The function assumes that there are no latitude gaps.  In other words, for
    % each cell there is another (perhaps at a different longitude) adjacent to
    % the north and another adjacent to the south, except for the two "end case"
    % cells at the extremes.
    % This also assumes that the boundary between two cells his halfway between
    % their centroids, which is not strictly true since cells are stretched to
    % be taller away from the equator.
    
    %Get unique coordinates in ascending order.
    latSort = unique(lats);

    b = NaN(length(latSort), 3); % bottom, top, height
    b(2:end, 1) = (latSort(2:end) + latSort(1:end-1)) / 2.0; % bottoms
    b(1:end-1, 2) = (latSort(1:end-1) + latSort(2:end)) / 2.0; % tops
    b(2:end-1, 3) = b(2:end-1, 2) - b(2:end-1, 1);
    % Roughly, the end cells are as big as their neighbors
    b(1, 3) = b(2, 3);
    b(1, 1) = b(1, 2) - b(1, 3);
    b(end, 3) = b(end-1, 3);
    b(end, 2) = b(end, 1) + b(end, 3);
    
    % Now we have the bounds for each unique latitude.  Get them for each cell,
    % knowing that the lats array is not ordered.
    bounds = NaN(length(lats), 2);
    count = 0;
    for i = 1:length(latSort)
        lat = latSort(i);
        idx = find(lats == lat);
        bounds(idx, 1) = b(i, 1);
        bounds(idx, 2) = b(i, 2);
        % fprintf("Assigning %d cells at latitude %6.1f\n", length(idx), lat);
        count = count + length(idx);
    end
    fprintf("Assigned latitude bounds for %d reefs.\n", count);
    if any(isnan(bounds))
        fprintf("Bounds array as NaNs!");
    end
    return
end
        