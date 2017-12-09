function output = trailingAverageFilt(y, n, backfill)
% Calculates a moving average.
% y is an incoming vector
% n is the number of periods to average
% backfill = false is the default, leaving n-1 NaN values at the beginning. This is
%   consistent with the results of tsmovavg with the 's' option.
% backfill = true replaces those NaN values with the first non-nan.

    if nargin == 2
        backfill = false;
    elseif nargin ~= 3
        error('trailingAverageFilt must have two or three arguments.');
    end
       
    mask = ones(1, n);              % n ones to average over n values
    output = filter(mask, n, y);    % sums values
    if backfill
        output(1:n-1) = output(n);
    else
        output(1:n-1) = NaN;            % we want NaN where there are not n values
    end
    %output = output / n;            % divide by n to get the average

end


