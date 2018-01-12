%% Plot the given y variable against time.  The main thing here is to scale
%  the x-axis to years from MATLAB's numerical values.  It is the user's
%  responsibility to ensure that the y values cover the same span of time
%  as the time vector.  If the number of values is different (e.g. Y is
%  monthly or yearly) the required time points will be selected.
% XXX This makes assumtions which may not be true when "time" is unevenly
% spaced!
function Plot_ArbitraryYvsYears(Y, time, tText, yText, fn)

    disp('In PAYY');
    fontSize = 18;
    % control the X axis ticks;
    fiftyYears = 365.25*50;  % 1 unit per day in datetime form
    % ???
    tickStart = floor(1850*365.25);
    tickEnd = floor(2100*365.25);
    %tickVals = tickStart:fiftyYears:tickEnd;
    tickVals = tickStart:365.25*25:tickEnd;
    %tickVals = 1850:50:2100;
    disp(tickEnd)
    disp(time(end));
    
    % Shrink all time series to monthly for faster plotting.  Also shrink 
    % the longer input to match the shorter to support mismatched input.
    % Note that since this function does not return the variables, it is safe to
    % modify them in place.
    % First, if Y is more than monthly there will be more points than
    % output pixels. Most runs are 2880 months long.  For long control runs
    % the intervals won't be monthly.
    % Also, for subsets of the time range, the point intervals won't be
    % months, but it the graph shape should only get better.
    maxLen = 2880;
    if length(Y) > maxLen
        factor = round(length(Y)/maxLen);
        Y = decimate(Y, factor, 'fir');
        
        fprintf('A Length of time = %d and Y = %d after factor of %d\n', length(time), length(Y), factor);
        
    end

    % Now make the time array match.
    if length(time) ~= length(Y)
        factor = round(length(time)/length(Y));
        time = decimate(time, factor, 'fir');
        fprintf('B Length of time = %d and Y = %d after factor of %d\n', length(time), length(Y), factor);
    end

    if nargin == 5
        figure(fn);
    else
        figure();
    end
    plot(time, Y, 'k'); 

    title(tText);
    ylabel(yText);

    set(gca, 'FontSize',fontSize);
    set(gca,'XTick',tickVals);

    datetick('x','keeplimits');
    saveCurrentFigure(tText);
end