% Make a map showing some combination of std[SST] and coral cover to show where
% in the world those two things are well correlated.  The difficulty is that
% we'd really like to know both values at once.  Note that coral cover is
% expressed as a percentage, while std[SST] ranges mostly from 1 to 4.  Also
% note that the slope of the correlation is negative.
% Try:
% - Color by cover - 25*std[SST]
% - Color by cover / std[SST]
% - Color value by cover, but intensity by std[SST]
% - Color by cover, pattern or shape by std[SST] - probably will require zooming
%   to a subset of the map.
%
% Persistent LAT and LONG in MapGeneration can be held over from other uses.
clear functions
% Start with just rcp45 and shuffling, where correlations are strongest.
rcp = 'rcp45';

rcpList = {'rcp45'}; % {'control400'}; 
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

E = 0;
adv = 1;
adapt = E + 2*adv;

coralAreaDir = "D:\CoralTest\July2020_CurveE221_Target5_TempForFigures\";
areaFile = coralAreaDir + "CoralArea_" + rcp + "E=" + num2str(E, 1) + "OA=0Adv=" + num2str(adv, 1) + ".mat";
load(areaFile, "C_area");

C_area_all = C_area;

windowSize = 30;
windowSetback = 20;
oneYearSetback = windowSetback + round(windowSize/2);
endYear = 2100;


%% New: remove reefs with less than 5% in the final year.
%idx = (C_area_all(end+endYear-2100, :, 1) + C_area_all(end+endYear-2100, :, 2)) >= 0.05;
%if nnz(idx) < 50
%    rsqTable(rrr, 1:5, adapt+1, endYear) = NaN;
%   fprintf("Skipping stats, only %d reefs qualify.\n", nnz(idx));
idx = 1:1925;  % while lines above are disabled
if false
    ;
else
    fprintf("Reefs used: %d\n", nnz(idx));
    C_area = C_area_all(:, idx, :);
    windowStart = endYear-windowSize-windowSetback;
    windowEnd = endYear-windowSetback;
    endSpanText = num2str(windowStart) + "-" + num2str(windowEnd);
    oneYear = endYear - oneYearSetback;


    caseID = rcp + "|" + num2str(E) + "|" + num2str(adv, 1) + "|" + num2str(endYear);
    indexEND = 240 - (2100-endYear);
    C_areaEND = squeeze(C_area(indexEND, :, :));
    % Fold the two types together.
    C_areaEND = sum(C_areaEND,2);

    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
    [SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, 'ESM2M', rcp);
    SST = SST(idx, :); % Just for the reefs in use.
    Reefs_latlon = Reefs_latlon(idx, :);
    % Use the measures defined in these files - and then possibly add more.
    %SST_SD_ChangeMaps_45
    %HotMonthSSTChangeMaps_45
    %HotMonthSST_SD_ChangeMaps_45

    SST1900 = SST(:, 1:yearEnd(1900));
    sdSST1900 = std(SST1900, 0, 2);

    SST_END = SST(:, yearStart(windowStart):yearEnd(windowEnd));
    sdSST_END = std(SST_END, 0, 2);
    %% Row 5
    methodName = "All months std[SST], " + endSpanText;

    compareNoPlot(sdSST_END, C_areaEND, methodName, caseID);

    % Just std(SST) for the window
    %MapGenerationSimple(Reefs_latlon, sdSST_END, 1, "std[SST]", [0 4], 1);
    % Just coral cover for the end date.
    %MapGenerationSimple(Reefs_latlon, C_areaEND*100, 2, "Cover", [0 100], 0);
    % Coral*100 - 25*std[SST]
    %MapGenerationSimple(Reefs_latlon, C_areaEND*100 - 25*sdSST_END, 3, "Cover - 25*std[SST]", [0 70], 0);    
    % Now try separate parameters - coral cover for color and std[SST] for
    % texture/pattern.
    %MapGenerationSimple(Reefs_latlon, C_areaEND*100, 4, "Cover with std[SST] hatch", [0 100], 0, sdSST_END);
    % Opposite order:
    MapGenerationSimple(Reefs_latlon, sdSST_END, 4, "Cover with std[SST] hatch", [0 4], 1, C_areaEND*100);

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
