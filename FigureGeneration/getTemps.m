% Load and return the ANNUAL temperatures for any RCP scenario. Smooth optionally.
% Inputs:
%   RCP - the RCP scenario to retrieve
%   increment - 'year' or 'month'.  Month is the raw data, year is a yearly
%      average.
%   plusMinus - default (0) is to return T as a vector averaged across all reefs.
%      with a positive value up to 50 the specified quartiles above and below
%      50%  will be returned in T, which is now 3 columns.
%   smoothT - if >1 apply a centered hamming smoothing.
%   k is an optional final argument.  If specified, return SST for a single
%       reef.  This is not compatible with plusMinus > 0.
%
% XXX notes...
% we start with a 1925 x 2880 array of SST by reef and month.
% This may be averaged within years, or across reefs, but may also
% be analyzed by quantile instead of averaging across reefs.
% 
function [years, time, T] = getTemps(RCP, increment, plusMinus, smoothT, varargin)

    if length(varargin) == 1
        oneReef = true;
        k = varargin{1};
    else
        oneReef = false;
    end
    
    if strcmp(increment, 'year')
        byYear = true;
    elseif strcmp(increment, 'month')
        byYear = false;
    else
        error('Only month and year are supported!');
    end
    
    % Get the global T history
    addpath('..'); % for GetSST_norm...
    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
    dataset = "ESM2M";
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
    
    % Now we have the option to just return monthly values
    if byYear
        % For each reef get the average SST for each years.
        % Make indexes be reef, month, year counter
        % SST is 1925x2880, reefs * months
        if oneReef
            SST_3D = reshape(SST(k, :),   1, 12, []); % now reefs * 12 * years
        else
            SST_3D = reshape(SST,      1925, 12, []); % now reefs * 12 * years
        end

        % Get the average T for each reef and year.  It seems odd that max requires an
        % empty set of brackets while sum does not.
        if oneReef
            SST_YearMean = reshape(mean(SST_3D, 2), 1, []);  % Keep single 1st dimension.
        else
            SST_YearMean = squeeze(mean(SST_3D, 2));
        end
        % Only now we average the DT across all reefs 
        if plusMinus == 0
            SST_out = mean(SST_YearMean, 1);
        elseif plusMinus <= 0.5
            % Note that the p=0.5 line here is the median, so not equal to the
            % mean line returned when plusMinus = 0.
            SST_out = quantile(SST_YearMean, [0.5-plusMinus, 0.5, 0.5+plusMinus], 1); 
        else
            error('plusMinus must be between 0 and 0.5');
        end
    else
        if oneReef
            SST_out = SST(k, :);
        else
            if plusMinus == 0
                SST_out = mean(SST, 1);
            elseif plusMinus <= 0.5
                SST_out = quantile(SST, [0.5-plusMinus, 0.5, 0.5+plusMinus], 1); 
            else
                error('plusMinus must be between 0 and 0.5');
            end
            
        end
    end

    % Try smoothing just a little
    if smoothT < 2
        T = SST_out;
    else
        T = centeredMovingAverage(SST_out, smoothT, 'hamming');
    end
    if byYear
        years = startYear:startYear+length(SST_out)-1;
        time = TIME(1:12:end);
    else
        years = [];  % No 1:1 correspondence between output and years.
        time = TIME;
    end
end
