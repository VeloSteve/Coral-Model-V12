function output = trailingSameDateAverage(y, n, m)
%XXX this function may give incorrect results when n==1.  CHECK!
% Calculates a moving average over n years with m time steps per year, just
% looking at the same time each year.  Unlike trailingAverageFilt, this
% function will filter each column of a 2D multiple-column input array.
% Note that the output contains n*m-1 NaN values at the beginning. This is
% consistent with the results of tsmovavg with the 's' option.
    year = zeros(1, m);
    year(1) = 1;                  % Now we have 1 year's mask
    [~, w] = size(y);
    mask = repmat(year, 1, n);      % Mask is w wide now to match the array.
    mask(:, end+1) = 0;             % The spot matching this year is not in the average.
    % filter is for vectors, so work through each column.
    output(length(y), w) = 111;
    for i = 1:w
        output(:, i) = filter(mask, 5, y(:, i));    % sums values
        output(1:m*n, i) = NaN;            % we want NaN where there are not n values
    end
end