% Convert a year as text or an integer to the MATLAB datenum for the first day
% of that year.
function num = firstDayNum(year)
    % datenum works with a column vector, but not a row.
    if size(year, 2) > 1
        year = year';
    end
    if isnumeric(year)
        num = datenum(strcat('1-Jan-', num2str(year)));
    else
        num = datenum(strcat('1-Jan-', year));
    end
end