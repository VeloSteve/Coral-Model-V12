%% Find the index in "time" corresponding to the specified time range,
%  looking more widely if no index is an exact match and picking an index
%  near the center if more than one is found.
function I = findDateIndex(dateStr1, dateStr2, tArray)
    persistent tMap;
    % Especially for symbiont start dates, it is likely that the same dates
    % will be looked up repeatedly, so use a map which should be much
    % faster than doing "find" on the whole time array each time.  This
    % made looking up a constant start date 6 times faster - admittedly
    % saving less than 2 seconds per run.
    if isempty(tMap)
        if ~exist('tMap', 'class')
            tMap = containers.Map;
        end
    elseif isKey(tMap, dateStr1)
        I = tMap(dateStr1);
        if I > 0
            return
        end
    end
 
    I = [];
    span = 0;
    while isempty(I)
        I = find( datenum(dateStr1)-span < tArray & tArray < datenum(dateStr2)+span );
        span = span + 1;
        assert(span < 10, 'Not finding the requested date in a reasonable range!');
    end
    % For very small dt we may get more than one I value.  Pick one near
    % the middle.
    if length(I) > 1
        I = I(floor(length(I)/2));
    end
    tMap(dateStr1) = I;
end
