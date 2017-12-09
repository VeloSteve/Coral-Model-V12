function [ subset ] = latitudeBin( ex, latlon )
% latitudeBin takes string "ex" as a specifier for a reef area.  Initially, only
% latitude zones are supported, but this could be extended to include other
% things such as "caribbean".
% Note that the subset retuns the index of each reef.  When the full arrays
% are supplied the indexes equal reef cell numbers.  if a subset of latlon is
% supplied, relative indexes are returned.
    if strcmp(ex, 'eq')
        subset = find(abs(latlon(:, 2))<=7)';
    elseif strcmp(ex, 'lo')
        subset = find(abs(latlon(:, 2))<=15 & abs(latlon(:, 2)) > 7)';
    elseif strcmp(ex, 'hi')
        subset = find(abs(latlon(:, 2))>15)';
    else
        error('ERROR: everyx = %s was not one of the supported strings.', ex);
    end

end

