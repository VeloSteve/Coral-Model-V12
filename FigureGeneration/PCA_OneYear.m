addpath '..'; % for GetSST_norm...
% See whether SST measures correlate to coral cover or bleaching.
% Previous attempts with linear regression were interesting (SSTStats_Figure.m),
% but we may learn more from PCA.
%
% TODO:
% gather likely predictors into an array
% use pca() and plot values to see groups
% plot those on a map by color to see if they group geographically
%
% use "Partial Least Squares Regression and Principal Components Regression"
% from the MATLAB documentation to see what is is different with plsregress()
%
%rcpList = {'rcp45', 'rcp85'}; % {'control400'}; 
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'}; % {'control400'}; 
%rcpList = {'rcp45'}; % {'control400'}; 
adaptLabel = {'None', 'Evolve', 'Shuffle', 'E & S'};

% Two parameters determine what years are included in a window which is used as
% a possible predictor. 
windowSize = 30; % How many years
windowSetback = 0; % Where the window ends relative to the endYear.
% When looking at a single year
oneYearSetback = 0; % windowSetback + round(windowSize/2);

endYear = 2040;

rFig = figure();

E = 0;
adv = 0.0;
for rrr = 1:length(rcpList)
    rcp = rcpList{rrr};
    clear pcaInputs

    coralAreaDir = "D:\CoralTest\Dec2020_CurveE221_Target5\";
    areaFile = coralAreaDir + "CoralArea_" + rcp + "E=" + num2str(E, 1) ...
        + "OA=0Adv=" + num2str(adv, 1) + ".mat";
    load(areaFile, "C_area");


    % New: remove reefs with less than 5% in the final year.
    idx = (C_area(end+endYear-2100, :, 1) + C_area(end+endYear-2100, :, 2)) >= 0.05;
    % Omit years with small numbers of reefs left to do stats on.
    % At 10 and at 50 most curves look about the same, but at 10
    % there are more high outliers late in the RCP 8.5 graphs.
    if nnz(idx) < 50
        rsqTable(rrr, 1:5, adapt+1, endYear) = NaN;
        fprintf("Skipping stats, only %d reefs qualify.\n", nnz(idx));
        break;
    else
        fprintf("Reefs used: %d\n", nnz(idx));
        C_area = C_area(:, idx, :);
    end

    windowStart = endYear-windowSize-windowSetback;
    windowEnd = endYear-windowSetback;
    endSpanText = num2str(windowStart) + "-" + num2str(windowEnd);
    oneYear = endYear - oneYearSetback;

    methodName{5} = "All months std[SST], " + endSpanText;
    methodName{4} = "All months \Delta std[SST] from 1861-1900 to " + endSpanText;
    methodName{1} = "Hottest Month \Delta SST 1861-1900 to " + oneYear;
    methodName{3} = "Hottest Month std[SST] " + endSpanText;
    methodName{2} = "Hottest Month \Delta std[SST] 1861-1900 to " + endSpanText; 
    caseID = rcp + "|" + num2str(E) + "|" + num2str(adv, 1) + "|" + num2str(endYear);

    % Get the coral area, which is the dependent variable, but it won't
    % be used for a while in the pca approach.
    indexEND = 240 - (2100-endYear);
    C_areaEND = squeeze(C_area(indexEND, :, :));
    % Fold the two types together.
    C_areaEND = sum(C_areaEND,2);

    % Similar, but for a pre-warming window.  This is later than the SST
    % historical window to get past the model spinup period.
    C_areaHIST = C_area(240-2100+1900:240-2100+1950, :, :);
    C_areaHIST = sum(C_areaHIST, 3); % sum across coral types

    %% Include historical coral cover in the pca since changes are more
    %  interesting than a comparison to a hypothetical K value.
    % pca() takes an n-by-p matrix with n observations of p variables.
    % To start, use the 5 predictors in Figure n in the same order used
    % there, and add pre-warming coral cover as a 6th.
    % Storing the last column first has the convenient side effect of
    % initializing the memory size correctly.
    varName{6} = 'Pre-warming cover';
    pcaInputs(:, 6) = mean(C_areaHIST, 1); % mean over time

    % Most independent variables are SST-based.
    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, 'ESM2M', rcp);
    SST = SST(idx, :); % Just for the reefs in use.
    SST1900 = SST(:, 1:yearEnd(1900));  % historical SST

    %% Row 5
    SST_END = SST(:, yearStart(windowStart):yearEnd(windowEnd));
    sdSST_END = std(SST_END, 0, 2);
    varName{5} = 'Window std[SST]';
    pcaInputs(:, 5) = sdSST_END;

    %% Row 4
    sdSST1900 = std(SST1900, 0, 2);
    % pcaInputs(:, 4) = sdSST_END-sdSST1900;  % Exact replication of old approach
    varName{4} = 'Historical std[SST]';
    pcaInputs(:, 4) = sdSST1900;  % New variable without the linear combination

    %% Row 1
    % From HotMonthSSTChangeMaps
    SSTR = hottest(SST1900);
    typSST1900 = mean(SSTR, 2);  % historical mean hottest month

    SSTOneYear = SST(:, yearStart(oneYear):yearEnd(oneYear));
    SSTR = hottest(SSTOneYear);  % recent one-year hottest month
    typSSTOneYear = mean(SSTR, 2); % XXX mean of a single value???

    dt = typSSTOneYear-typSST1900;  % Change in hot month SST
    varName{1} = 'SST Delta to present';
    pcaInputs(:, 1) = dt;

    %% Row 3
    % From HotMonthSST_SD_ChangeMaps
    hot1900 = hottest(SST1900);

    % Same for the 20 years in the sliding window
    hotEND = hottest(SST_END);
    hotSdSSTEND = std(hotEND, 0, 2);
    varName{3} = 'Window hot month std[SST]';
    pcaInputs(:, 3) = hotSdSSTEND;

    %% Row 2
    % Delta 2050-historical
    hotSdSST1900 = std(hot1900, 0, 2);
    dt = hotSdSSTEND-hotSdSST1900;
    varName{2} = 'Historical hot month std[SST]';

    % pcaInputs(:, 2) = hotSdSSTEND-hotSdSST1900;  % Exact replication of old approach
    pcaInputs(:, 2) = hotSdSST1900;  % New variable without the linear combination

    %% Now the actual pca
    %[coeff, score, latent, tsquared, explained, mu] = pca(pcaInputs);
    % NumComponents limits the columns returned, but doesn't change the ones presented.
    clear coeff score latent tsquared explained mu
    % XXX removing values:
    %keep = [1 4 5];
    keep = [1 3 5]; % with SST hot month and 2 others
    %keep = [1:5]; % all except historical cover
    pcaInputs = pcaInputs(:, keep);
    varName = varName(keep);
    [coeff, score, latent, tsquared, explained, mu]  = pca(pcaInputs, "NumComponents", 3);
    fprintf("                                  PC1     PC2     PC3   . . .\n");
    for i = 1:size(coeff, 1)
        fprintf(['%30s ' repmat('%8.3f',1,size(coeff, 2)) '\n'], varName{i}, coeff(i, :));
    end
    fprintf(['  Explained:                   ' repmat('%8.1f',1,size(coeff, 2)) '\n'], explained(1:size(coeff, 2)));
    fprintf('  Sum of first 2 only:         %8.1f\n', sum(explained(1:2)));



    figure();
    biplot(coeff(:,1:3),'scores',score(:,1:3),'varlabels',varName);
    title(rcp);
    
    % Build vectors based on PC1 and 2 for all active reefs
    clear vector1 vector2 vector3
    vector1(nnz(idx), 1) = 0.0;
    vector2(nnz(idx), 1) = 0.0;
    vector3(nnz(idx), 1) = 0.0;
    for i = 1:size(coeff, 1)
            vector1 = vector1 + coeff(i, 1) .* pcaInputs(:, i);
            vector2 = vector2 + coeff(i, 2) .* pcaInputs(:, i);
            vector3 = vector3 + coeff(i, 3) .* pcaInputs(:, i);
    end
    figure()
    for i = 1:size(coeff, 1)
        scatter(vector1, pcaInputs(:, i), 'DisplayName', varName{i}); hold on;
    end
    title("Inputs vs. PC1 vector");
    legend();
    figure()
    for i = 1:size(coeff, 1)
        scatter(vector2, pcaInputs(:, i), 'DisplayName', varName{i}); hold on;
    end
    title("Inputs vs. PC2 vector");
    legend();
    figure()
    for i = 1:size(coeff, 1)
        scatter(vector3, pcaInputs(:, i), 'DisplayName', varName{i}); hold on;
    end
    title("Inputs vs. PC3 vector");
    legend();


    set(0, 'currentfigure', rFig);  
    compare(vector1, C_areaEND, rcp, 3*(rrr-1) + 1, "PC1");
    compare(vector2, C_areaEND, rcp, 3*(rrr-1) + 2, "PC2");
    compare(vector3, C_areaEND, rcp, 3*(rrr-1) + 3, "PC3");

end

 


function rsq = compareNoPlot(stat, area, name, caseID)
    [rsq, b] = regress(stat, area(:,1));
    fprintf("%s | %s | %12.3f | %12.4f | %12.4f \n", caseID, name, rsq, b(2), b(1));
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

function compare(stat, area, name, sp, xl)
    subplot(4, 3, sp);
    %figure()
    
    scatter(stat, area, 3, [0.3 0.3 1]); hold on;
    [rsq, b] = regress(stat, area, [0 0 0]);
    fprintf("%s | %12.3f | %12.4f | %12.4f \n", name, rsq, b(2), b(1));

    ylabel('% Cover');
    %if sp > 6
        xlabel(xl + ' \circ C');
    %end
    ylim([0 1.1]);
    yticks([0 1]);
    
    title(name);
    set(gca, 'FontSize', 14);
    legend({'Total Cover',  append('R^2 = ', num2str(rsq, '% 6.3f'), ' slope = ', num2str(b(2), '% 6.2f'))}, ...
        'FontSize', 11, 'Location', 'best');
    
end
