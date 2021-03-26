% See whether SST measures correlate to coral cover or bleaching.
% The text output can be pasted into 
% D:\Library\MyDocs\Biology Study\_LoganLab\
%    Paper2017\June2020_ReviewerResponses\SSTStats\CorrelationTable.xlsx
%rcp = 'rcp60';
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'}; % {'control400'}; 

% Two parameters determine what years are included in a window which is used as
% a possible predictor.  This was 2050 to 2080 in the original stats ending in
% 2100, and became the last 20 years before the end point in the next version.
windowSize = 20; % How many years
windowSetback = 10; % Where the window ends relative to the endYear.
% Some stats before looked at 2080, the end of the window, but now that can be
% the same as the end year.  Give it a separate offset in mid-window.
oneYearSetback = windowSetback + round(windowSize/2);
        
fprintf("RCP|E|Advantage|end year|Analysis|rsq|slope|intercept\n");
for rcp = rcpList
    for E = [0 1]
        for adv = [0 1]
            coralAreaDir = "D:\CoralTest\July2020_CurveE221_Target5_TempForFigures\";
            %areaFile = coralAreaDir + "CoralArea_" + rcp + "E=1OA=0Adv=0.mat";
            areaFile = coralAreaDir + "CoralArea_" + rcp + "E=" + num2str(E, 1) + "OA=0Adv=" + num2str(adv, 1) + ".mat";
            load(areaFile, "C_area");

            for endYear = 2020:10:2100
                windowStart = endYear-windowSize-windowSetback;
                windowEnd = endYear-windowSetback;
                oneYear = endYear - oneYearSetback;
                caseID = rcp + "|" + num2str(E) + "|" + num2str(adv, 1) + "|" + num2str(endYear);
                indexEND = 240 - (2100-endYear);
                C_areaEND = squeeze(C_area(indexEND, :, :));
                % Fold the two types together.
                C_areaEND = sum(C_areaEND,2);

                sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
                [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, 'ESM2M', rcp);

                % Use the measures defined in these files - and then possibly add more.
                %SST_SD_ChangeMaps_45
                %HotMonthSSTChangeMaps_45
                %HotMonthSST_SD_ChangeMaps_45
                drawnow
                figure('Color', 'w', 'Units', 'inches', 'Position', [0.5, 0.5, 14, 10]);


                SST1900 = SST(:, 1:yearEnd(1900));
                sdSST1900 = std(SST1900, 0, 2);
                compare(sdSST1900, C_areaEND, 'All months std[SST], 1861-1900', 1, caseID);

                SST_END = SST(:, yearStart(windowStart):yearEnd(windowEnd));
                sdSST_END = std(SST_END, 0, 2);
                endSpanText = num2str(windowStart) + "-" + num2str(windowEnd);
                compare(sdSST_END, C_areaEND, "All months std[SST], " + endSpanText, 2, caseID);

                dt = sdSST_END-sdSST1900;
                compare(dt, C_areaEND, "All months \Delta std[SST] from 1861-1900 to " + endSpanText, 3, caseID);
                compare(abs(dt), C_areaEND, "All months abs[\Delta std[SST]] from 1861-1900 to " + endSpanText, 4, caseID);

                % From HotMonthSSTChangeMaps
                SSTR = hottest(SST1900);
                typSST1900 = mean(SSTR, 2);
                compare(typSST1900, C_areaEND, "Hottest Month SST 1861-1900", 5, caseID);

                SSTOneYear = SST(:, yearStart(oneYear):yearEnd(oneYear));
                SSTR = hottest(SSTOneYear);
                typSSTOneYear = mean(SSTR, 2);
                compare(typSSTOneYear, C_areaEND, "Hottest Month SST " + oneYear, 6, caseID);

                dt = typSSTOneYear-typSST1900;
                compare(dt, C_areaEND, "Hottest Month \Delta SST 1861-1900 to " + oneYear, 7, caseID);


                % From HotMonthSST_SD_ChangeMaps
                hot1900 = hottest(SST1900);
                hotSdSST1900 = std(hot1900, 0, 2);
                compare(hotSdSST1900, C_areaEND, "Hottest Month std[SST] 1861-1900", 8, caseID);

                % Same for the 20 years leading up to endYear
                hotEND = hottest(SST_END);
                hotSdSSTEND = std(hotEND, 0, 2);
                compare(hotSdSSTEND, C_areaEND, "Hottest Month std[SST] " + endSpanText, 9, caseID);
                % Delta 2050-historical
                dt = hotSdSSTEND-hotSdSST1900;
                compare(dt, C_areaEND, "Hottest Month \Delta std[SST] 1861-1900 to " + endSpanText, 10, caseID);

                sgtitle(num2str(endYear) + " cover  " + rcp + " E = " + num2str(E, 1) + " Shuffle = " + num2str(adv, 1));
            end
        end
    end
end

function compare(stat, area, name, sp, caseID)
    subplot(5, 2, sp);
    %figure()
    
    scatter(stat, area, 3, [0.3 0.3 1]); hold on;
    [rsq, b] = regress(stat, area(:,1), [0 0 0]);
    fprintf("%s | %s | %12.3f | %12.4f | %12.4f \n", caseID, name, rsq, b(2), b(1));

    ylabel('% Cover');
    if sp > 8
        xlabel('\circ C');
    end
    ylim([0 1.1]);
    yticks([0 1]);
    
    title(name);
    set(gca, 'FontSize', 14);
    legend({'Total Cover',  append('R^2 = ', num2str(rsq, '% 6.3f'), ' slope = ', num2str(b(2), '% 6.2f'))}, ...
        'FontSize', 11, 'Location', 'best');
    
end

function [rsq, b] = regress(x, y, col)
    % Regression
    X = [ones(length(x),1) x];
    b = X\y;  % Regression operator  b is slope AND intercept
    yCalc = X*b;
    plot(x, yCalc, 'Color', col, 'LineStyle', '-', 'LineWidth', 1);
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
