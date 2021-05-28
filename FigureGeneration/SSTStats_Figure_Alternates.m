% See whether SST measures correlate to coral cover or bleaching.
% The text output can be pasted into 
% D:\Library\MyDocs\Biology Study\_LoganLab\
%    Paper2017\June2020_ReviewerResponses\SSTStats\CorrelationTable.xlsx
%rcp = 'rcp60';
rcpList = {'rcp45', 'rcp85'}; % {'control400'}; 
%rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'}; % {'control400'}; 
adaptLabel = {'None', 'Evolve', 'Shuffle', 'E & S'};

% The exact colors used in Figures 1 and S9? for adaptations.
black = [0 0 0];         % none
blue =  [0.0 0.35 0.95]; % evolution
red  =  [0.9 0.1  0.1];  % shuffling
other = [0.6 0.0  0.8];  % both

aColor{1} = black;    
aColor{2} = blue;
aColor{3} = red;
aColor{4} = other;


% Two parameters determine what years are included in a window which is used as
% a possible predictor.  This was 2050 to 2080 in the original stats ending in
% 2100, and became the last 20 years before the end point in the next version.
windowSize = 30; % How many years
windowSetback = 0; % Where the window ends relative to the endYear.
% Some stats before looked at 2080, the end of the window, but now that can be
% the same as the end year.  Give it a separate offset in mid-window.
oneYearSetback = 15; % windowSetback + round(windowSize/2);

endYearSet = 2020:10:2100; % 2020

% Analysis method labels without endpoint-specific text for use in plot titles.
methodNameGeneric{5} = "All months SST RATE from window";
methodNameGeneric{4} = "All months \Delta std[SST] from 1861-1900 to window";
methodNameGeneric{1} = "Hottest Month \Delta SST 1861-1900 to " + oneYearSetback + " before endpoint";
methodNameGeneric{3} = "Hottest Month std[SST] based on window";
methodNameGeneric{2} = "SST vs. historical mean[SST] + 2* std[SST]";
letters = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j'];

% Storage for all the stats to plot in a single figure.  They are not computed in
% the order needed, so it's easier this way.
% Memory waste: just dimension the years to 2100, rather than indexing 1 to 240.
rsqTable(length(rcpList), 5, 4, 2100) = 0.0; % RCPs x analysis row x adaptations x years
        
fprintf("RCP|E|Advantage|end year|Analysis|rsq|slope|intercept\n");
for rrr = 1:length(rcpList)
    rcp = rcpList{rrr};
    for E = [0 1]
        for adv = [0 1]
            adapt = E + 2*adv;

            coralAreaDir = "D:\CoralTest\July2020_CurveE221_Target5_TempForFigures\";
            %areaFile = coralAreaDir + "CoralArea_" + rcp + "E=1OA=0Adv=0.mat";
            areaFile = coralAreaDir + "CoralArea_" + rcp + "E=" + num2str(E, 1) + "OA=0Adv=" + num2str(adv, 1) + ".mat";
            load(areaFile, "C_area");
            
            C_area_all = C_area;
            

            for endYear = endYearSet
         

                % New: remove reefs with less than 5% in the final year.
                idx = (C_area_all(end+endYear-2100, :, 1) + C_area_all(end+endYear-2100, :, 2)) >= 0.05;
                % Omit years with small numbers of reefs left to do stats on.
                % At 10 and at 50 most curves look about the same, but at 10
                % there are more high outliers late in the RCP 8.5 graphs.
                if nnz(idx) < 50
                    rsqTable(rrr, 1:5, adapt+1, endYear) = NaN;
                    fprintf("Skipping stats, only %d reefs qualify.\n", nnz(idx));
                else
                    %fprintf("Reefs used: %d\n", nnz(idx));
                    C_area = C_area_all(:, idx, :);
                    windowStart = endYear-windowSize-windowSetback;
                    windowEnd = endYear-windowSetback;
                    endSpanText = num2str(windowStart) + "-" + num2str(windowEnd);
                    oneYear = endYear - oneYearSetback;

                    methodName{5} = "All months SST RATE to " + endSpanText;
                    methodName{4} = "All months \Delta std[SST] from 1861-1900 to " + endSpanText;
                    methodName{1} = "Hottest Month \Delta SST 1861-1900 to " + oneYear;
                    methodName{3} = "Hottest Month std[SST] " + endSpanText;
                    methodName{2} = "SST vs. historical mean[SST] + 2* std[SST]";      
                    caseID = rcp + "|" + num2str(E) + "|" + num2str(adv, 1) + "|" + num2str(endYear);
                    indexEND = 240 - (2100-endYear);
                    C_areaEND = squeeze(C_area(indexEND, :, :));
                    % Fold the two types together.
                    C_areaEND = sum(C_areaEND,2);

                    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
                    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, 'ESM2M', rcp);
                    SST = SST(idx, :); % Just for the reefs in use.
                    % Use the measures defined in these files - and then possibly add more.
                    %SST_SD_ChangeMaps_45
                    %HotMonthSSTChangeMaps_45
                    %HotMonthSST_SD_ChangeMaps_45

                    SST1900 = SST(:, 1:yearEnd(1900));
                    sdSST1900 = std(SST1900, 0, 2);

                    SST_END = SST(:, yearStart(windowStart):yearEnd(windowEnd));
                    sdSST_END = std(SST_END, 0, 2);
                    %% Row 5
                    % New values: find the SST rate of increase during the
                    % window.
                    % Do a regression for each reef to get its SST rate, and
                    % then use that as input to the usual regression in
                    % rsqTable.
                    len = size(SST, 1);
                    rate = zeros(len, 1);
                    assert(len == length(SST_END(:, 1)), "SST_END not the same length as idx!");
                    % NOTE: this could be done outside some of the loops, since
                    % on changes with end year and RCP, but not with adaptation type.
                    for k = 1:len
                        [~, b] = regress([1:size(SST_END, 2)]', SST_END(k, :)'); % x is in months
                        rate(k) = 12 * b(2); % Rate per year from rate per month.
                    end
                    %rateSST_END = 
                    rsqTable(rrr, 5, adapt+1, endYear) = ...
                        compareNoPlot(rate, C_areaEND, methodName{5}, caseID);
                    
                    % Extra diagnostics:
                    if endYear == 2060
                        fprintf("%s 25th, 50th, 75th quartile rates (C/year): %7.3f %7.3f %7.3f (%6d reefs)\n", rcp, quantile(rate, [0.25 0.5 0.75]), len);
                    end

                    dt = sdSST_END-sdSST1900;
                    %% Row 4
                    rsqTable(rrr, 4, adapt+1, endYear) = ...
                        compareNoPlot(dt, C_areaEND, methodName{4}, caseID);

                    % From HotMonthSSTChangeMaps
                    SSTR = hottest(SST1900);
                    typSST1900 = mean(SSTR, 2);

                    SSTOneYear = SST(:, yearStart(oneYear):yearEnd(oneYear));
                    SSTR = hottest(SSTOneYear);
                    typSSTOneYear = mean(SSTR, 2);

                    dt = typSSTOneYear-typSST1900;
                    %% Row 1
                    rsqTable(rrr, 1, adapt+1, endYear) = ...
                        compareNoPlot(dt, C_areaEND, methodName{1}, caseID);


                    % From HotMonthSST_SD_ChangeMaps
                    hot1900 = hottest(SST1900);
                    hotSdSST1900 = std(hot1900, 0, 2);

                    % Same for the 20 years leading up to endYear
                    hotEND = hottest(SST_END);
                    hotSdSSTEND = std(hotEND, 0, 2);
                    %% Row 3
                    rsqTable(rrr, 3, adapt+1, endYear) = ...
                        compareNoPlot(hotSdSSTEND, C_areaEND, methodName{3}, caseID);
                    
                    %% Delta 2050-historical
                    hottestThisYear = SST(:, yearStart(endYear):yearEnd(endYear));
                    hottestThisYear = max(hottestThisYear, [], 2);
                    dt = hottestThisYear - (typSST1900 + 2 * hotSdSST1900);
                    % Row 2
                    rsqTable(rrr, 2, adapt+1, endYear) = ...
                        compareNoPlot(dt, C_areaEND, methodName{2}, caseID);
                end
            end
        end
    end
end
% Now plot the values in the same layout as Figure S8 (number as of 11/25/2020)
figure('color', 'w', 'Units', 'inches', 'Position', [1, 0.1, 13, 14]);

% Nh, Nw, gap, marg_h, marg_w
[ha, pos] = tight_subplot(5, length(rcpList), 0.04, [0.025 0.025]);
for rrr = 1:length(rcpList)
    rcp = rcpList{rrr};
    for method = 1:5
        ax = ha(rrr + (method - 1) * length(rcpList));
        axes(ax);
        for adapt = 0:3
            % rsqTable(length(rcpList), 5, 4, length(endYearSet)) = 0.0; % RCPs x analysis row x adaptations x years

            plot(endYearSet, squeeze(rsqTable(rrr, method, adapt+1, endYearSet)), ...
                'Color', aColor{adapt+1}, 'LineWidth', 2, 'DisplayName', adaptLabel{adapt+1});
            hold on;
        end
        if method == 1
            title(rcp);
            xticks([]);
        elseif method == 5
            xlabel("End Year");
        else
            xticks([]);
        end
        ylim([0 0.8]);
        if rrr == 1
            ylabel("R^2");
        end
        title("(" + letters(rrr + (method-1) * length(rcpList)) + ") " + rcp + "  " + methodName{method});
        legend('Location', 'best');
    end
end
        


function rsq = compareNoPlot(stat, area, name, caseID)
    [rsq, b] = regress(stat, area(:,1));
    fprintf("%s | %s | %12.3f | %12.4f | %12.4f \n", caseID, name, rsq, b(2), b(1));
end

function [rsq, b] = regress(x, y)
    % Regression
    X = [ones(length(x),1) x];
    b = X\y;  % Regression operator  b is slope AND intercept
    yCalc = X*b;
    %plot(x, yCalc, 'Color', col, 'LineStyle', '-', 'LineWidth', 1);
    rsq = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);
end


function i = yearStart(y)
    % Calculate the index in the monthly time array for 15 Jan of the given
    % year.
    % the first date in the model is 15-Jan-1861
    i = 1 + (y-1861)*12;
end
function i = yearEnd(y)
    % Calculate the index in the monthly time array for 15 Dec of the given
    % year.
    % the first date in the model is 15-Jan-1861
    % add 11 months to specify December
    i = 1 + (y-1861)*12 + 11;
end
function hot = hottest(sst)
    % Take an array of monthly SSD, sized reefs*months and return
    % just the hottest month of each year, now sized reefs*years
    hot = reshape(sst, size(sst,1), 12, []);
    hot = squeeze(max(hot,[], 2));
end