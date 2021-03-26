%% Create a .mat file of Degree Cooling Weeks, similar to the DHM files in ../ClimateData.
%  Use that format (reef x time units) with a corresponding Time array.  Make
%  the definition consistent with (?? which method in ??) 
%  "Predicting cold-water bleaching in corals: role of temperature, and potential
%  integration of light exposure" by 
%  Pedro C. González-Espinosa and Simon D. Donner.
% 
%% Method selection
% p. 139: The best temperature-based model, according to AIC, was Model 4
% (based on DCW1), according to which the probability of bleaching reaches 50%
% with a DCW value of ?9°C·week (Fig. 2).
%
% The steps in calculating their Model 4 DCW values for a site are
% 1) Calculate mMM, minimum monthly mean, the coldest monthly value between 1985
% and 2005.
% 2) Calculate CS, ColdSpot values for each week, zero when SST for that week is
% greater than mMM and the delta between the two when less.
% 3) DWC in decC/week is the sum of any coldspots over the preceeding 12 weeks,
% counting only those exceeding a defined threshold.
% QUESTION: for week N is this N-13 to N-1 or N-12 to N?

%% The only real difficulty here is defining weeks in a useful way when they are
% not any consistent fraction of a month.  It may be useful that the MATLAB time
% unit is in days.  The step between SST months alternates between 30 and 31,
% occasionally less.  In the model, temperatures for one reef are interpolated
% to 1/8 month time steps using 
%     temp = interp(SSThist,1/dt); 
% How do we work in units of weeks and compare the result to bleaching events
% occuring on 1/8 month time steps?


%% 
threshold = -1.0;
rcpList = {'rcp45', 'rcp60', 'rcp85'}; %'rcp26';
baseYears = [1985, 2005];
weeks = 12;
 
parfor rrr = 1:length(rcpList)
    computeOneCase(rcpList{rrr}, baseYears, threshold, weeks);
end



% findDateIndex has a persistent variable.  Clear it at exit in case there is some
% inconsistency when used in the main model.
clear findDateIndex

function [dcw] = computeOneCase(RCP, baseYears, threshold, weeks) 
    %% load SSTs
    addpath('..'); % for findDateIndex and GetSST_norm...
    sstPath = "../ClimateData/";
    dataset = "ESM2M";
    
    fprintf("Computing DCW for threshold of %d and rcp %s.\n", threshold, RCP);
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
    
    %% Step 1, Calculate minimum monthly mean
    iStart = findDateIndex(strcat('01-Jan-', num2str(baseYears(1))), ...
                           strcat('31-Jan-', num2str(baseYears(1))), TIME);
    iEnd =   findDateIndex(strcat('01-Dec-', num2str(baseYears(2))), ...
                           strcat('31-Dec-', num2str(baseYears(2))), TIME);
    mMM = min(SST(:, iStart:iEnd), [], 2);

    %% Step 2, ColdSpot values
    % Here we have to deal with the fact that months, weeks, and model time
    % steps do not align.
    % An approach:
    % 1) Interpolate to 1/8 months in exactly the way done in the model.
    % 2) Compute degree cooling days for every day, using temperatures linearly
    %    interpolated from the values in step 1.
    % 3) For each time step used in the model, group the previous 7*12 days into
    %    weeks.  For each week use the median day to compute its temperature
    %    delta.  Add the week to the sum if it meets the threshold value.
    
    modelStepsPerMonth = 8;
    times = round(interp(TIME,modelStepsPerMonth,1,0.0001)); % as in the model, 8/month, but rounded.
    days = times(end)-times(1)+1;
    dcd(days) = 0.0; % array for each day's cooling in one reef.
    dcw = zeros(size(SST, 1), length(times));
    for i = 1:size(SST,1)
        fprintf("Reef %d\n", i);
        temps = interp(SST(i, :),modelStepsPerMonth);
        dcd = interp1(times, temps, times(1):times(end)); % interp to daily values   
        dcd = min(0.0, dcd - mMM(i));  % Subtract mMM, only keep negatives.
        % Now get dcw for each time step in times.  Skip the first few months
        % when we can't look back far enough.
        % Note that ti indexes model times (23040 points) while iStart, iNow,
        % and iWeek index daily times (87628 values).
        for ti = 1+7*weeks:length(times)
            now = times(ti);
            iNow = 1 + now - times(1);  % index in dcd, NOT in temps or times!
            iStart = iNow - 7*weeks + 1;
            for iWeek = iStart:7:iNow-1
                delta = median(dcd(iWeek:iWeek+6));
                if delta < threshold
                    dcw(i, ti) = dcw(ti) + delta;
                end
            end
            
        end     
    end
    save(strcat('DCW_Thresh_', num2str(threshold), '_', RCP, '.mat'), 'dcw');
end