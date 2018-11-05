%% Make Maps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 1-6-15                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = mapsCoralCoverClean(fullDir, Reefs_latlon, activeReefs, ...
    lastYearAlive, events85_2010, eventsAllYears, frequentBleaching, ...
    mortState, bleachState, fullYearRange, modelChoices)
% Add paths and load mortality statistics
%load(strcat('~/Dropbox/Matlab/SymbiontGenetics/',filename,'/201616_testNF_1925reefs.mat'),'Mort_stats')
format shortg;
% filename = '201616_figs'; %filename = strcat(dateString,'_figs'); mkdir(filename); % location to save files
% map %% NOTE: worldmap doesn't seem to be working on work computer

%% yearRange provides the scale for all time related color bars.  It spans
% all years  during which a reef died, rounded out to the nearest ten.  If
% no reefs die, a default of 1960 to 2100 is used.
if ~any(lastYearAlive)
    yearRange = [1960 2100];
else
    yearRange = [min(lastYearAlive) max(lastYearAlive)];
    % Plotting chokes if the values are equal.
    if yearRange(1) == yearRange(2)
        yearRange(2) = yearRange(2) + 1;
    end
    % Also round out to a multiple of 10
    if mod(yearRange(1), 10)
        yearRange(1) = 10*floor(yearRange(1)/10);
    end
    if mod(yearRange(2), 10)
        yearRange(2) = 10*ceil(yearRange(2)/10);
    end
end

%% Make map of last mortality event recorded

% We need to map a spot for all reefs, to show those that never bleached.
% Not every reef has a last mortality, but all have BLEACH8510 stats.
activeLatLon(1:length(activeReefs), 1) = Reefs_latlon(activeReefs, 1);
activeLatLon(1:length(activeReefs), 2) = Reefs_latlon(activeReefs, 2);

% A scale for "red=bad, blue=good" plots.
customColors = customScale();

tName = strcat(modelChoices,'. Year Corals No Longer Persist');
fileBase = strcat(fullDir, modelChoices,'_LastYrCoralMap');
% Green points everywhere
oneMap(12, activeLatLon(:, 1), activeLatLon(:, 2), [0 0.8 0], yearRange, parula, tName,'', false);

% Color-scaled points where there is a last year
outFile = strcat(fileBase, '.pdf');
if any(lastYearAlive)
    %ind = find(lastYearAlive);
    % Skip the nans!
    ind = find(lastYearAlive > 0);
    oneMap(12, Reefs_latlon(ind, 1), Reefs_latlon(ind, 2), lastYearAlive(ind), yearRange, customColors, tName, outFile, true);
end

% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

%% Make map showing # all bleaching events bn 1985-2010
tName = 'Bleaching Events Between 1985-2010';
fileBase = strcat(fullDir, modelChoices,'_MortEvents8510Map');
outFile = strcat(fileBase, '.pdf');
oneMap(13, activeLatLon(:, 1), activeLatLon(:, 2), events85_2010(activeReefs), [], jet, tName, outFile, false);
% Another one with postprocessing...
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

%% Figure 14 Make map showing # all bleaching events
rangeText = sprintf('%d-%d',fullYearRange);
tName = strcat('Bleaching Events Between ', rangeText);
outFile = strcat(fullDir, modelChoices,'_AllMortEventsMap','.pdf');
oneMap(14, activeLatLon(:, 1), activeLatLon(:, 2), eventsAllYears(activeReefs), [], jet, tName, outFile, false);


%% Figure 15  Same as 14 but with restricted color scale
cRange = [0, 20];
outFile = strcat(fullDir, modelChoices,'_AllMortEventsMap_Scale20','.pdf');
oneMap(15, activeLatLon(:, 1), activeLatLon(:, 2), eventsAllYears(activeReefs), cRange, jet, tName, outFile, false);


%% Figure 16  Same as 14 but with log2 of the number of events
% tName = 'Bleaching Events Between 1861-2100 (log base 2)';
% outFile = strcat(fullDir, modelChoices, '_AllMortEventsMap_log2', '.pdf');
% oneMap(16, activeLatLon(:, 1), activeLatLon(:, 2), log2(eventsAllYears(activeReefs)), [], jet, tName, outFile, false);


%% Figure 17.  Maps first year of unhealthy coral, defined as:
% - no full-reef bleaching
% - no full-reef mortality
% - not currently bleached
% This can be expressed as the minimum the first year for each of those
% indicators.
% Store indexes, not years in lastHealthy, until just before plotting.
firstUnhealthy = NaN(length(Reefs_latlon), 1);
fbMass = frequentBleaching(:, :, 1);
msMass = mortState(:, :, 1);
bBoth = bleachState(:, :, end);

for k = activeReefs
    % Frequent
    ind = find(fbMass(k, :), 1, 'first');
    if ~isempty(ind)
        firstUnhealthy(k) = ind;
    end
    % Mortality (It may be that bleaching is always flagged when this is
    % true, so it could be skipped - but for now be safe.)
    ind = find(msMass(k, :, 1), 1, 'first');
    if ~isempty(ind)
        firstUnhealthy(k) = min(firstUnhealthy(k), ind);
    end
    % Current bleaching
    ind = find(bBoth(k, :), 1, 'first');
    if ~isempty(ind)
        firstUnhealthy(k) = min(firstUnhealthy(k), ind);
    end
end
% Convert from indices to year.  NaN stays NaN.
firstUnhealthy = firstUnhealthy + fullYearRange(1) - 1;
tName = strcat(modelChoices,'. First Year of Unhealthy Reef');
fileBase = strcat(fullDir, modelChoices, '_FirstUnHealthyReef');

outFile = strcat(fileBase, '.pdf');
oneMap(17, activeLatLon(:, 1), activeLatLon(:, 2), firstUnhealthy(activeReefs), [], customColors, tName, outFile, false);

%% Figure 18.  Maps last year of healthy coral, defined as:
% - no full-reef bleaching
% - no full-reef mortality
% - not currently bleached
% Do this by combining all the flags and then looking for the last year
% of health.
%
% Dimensions:
% frequentBleaching, mortState, and bleachState are all reefs x years x coral types.
% mortState and bleachState include an extra column for "all"
% Store indexes, not years in lastHealthy, until just before plotting.

lastHealthy = NaN(length(Reefs_latlon), 1);

combo = frequentBleaching(:, :, 1) | mortState(:, :, 1) | bleachState(:, :, 1);
% Now we need do find the last time the value is false (healthy)

for k = activeReefs
    ind = find(~combo(k, :), 1, 'last');
    if ~isempty(ind)
        lastHealthy(k) = ind;
    end
end
% Convert from indices to year.  NaN stays NaN.
lastHealthy = lastHealthy + fullYearRange(1) - 1;
lastYearRange = [1950 2100];
tName = strcat(modelChoices,'. Last Year of Healthy Reef');
fileBase = strcat(fullDir, modelChoices, '_LastHealthyReef');
outFile = strcat(fileBase, '.pdf');
oneMap(18, activeLatLon(:, 1), activeLatLon(:, 2), lastHealthy(activeReefs), lastYearRange, customColors, tName, outFile, false);
% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

%% Figure 19.  Maps last year of healthy coral, defined as: 
%{
%
% "Maps include the last year that one or both of the coral types
% experienced high frequency bleaching or mortality with no recovery"
% - I'll assume that this means "did not experience".
%
% In terms of the events flagged:
% - bleaching - no longer included?
% - no mortality of either coral type
% - no high-frequency bleaching of either coral type
% Do this by combining all the flags and then looking for the last year
% of health.
%
% Dimensions:
% frequentBleaching, mortState, and bleachState are all reefs x years x coral types.
% mortState and bleachState include an extra column for "all"
% Store indexes, not years in lastHealthy, until just before plotting.

lastHealthy = NaN(length(Reefs_latlon), 1);

combo = frequentBleaching(:, :, 1) | frequentBleaching(:, :, 2) | mortState(:, :, 1) | mortState(:, :, 2);
% Now we need do find the last time the value is false (healthy)

for k = activeReefs
    ind = find(~combo(k, :), 1, 'last');
    if ~isempty(ind)
        lastHealthy(k) = ind;
    end
end
% Convert from indices to year.  NaN stays NaN.
lastHealthy = lastHealthy + fullYearRange(1) - 1;
lastYearRange = [1950 2100];
tName = strcat(modelChoices,'. Last Year of Healthy Reef');
fileBase = strcat(fullDir, modelChoices, '_LastHealthyBothTypes');
outFile = strcat(fileBase, '.pdf');
oneMap(19, activeLatLon(:, 1), activeLatLon(:, 2), lastHealthy(activeReefs), lastYearRange, customColors, tName, outFile, false);
% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end
%}

%% Figure 20.  Maps last year of healthy coral, defined as: 
%
% Fig 19 showed early problems when massive corals were still healthy.  Try
% basing more on just the massives.
%
% In terms of the events flagged:
% - bleaching - no longer included?
% - no mortality of either coral type
% - no high-frequency bleaching of either coral type
% Do this by combining all the flags and then looking for the last year
% of health.
%
% Dimensions:
% frequentBleaching, mortState, and bleachState are all reefs x years x coral types.
% mortState and bleachState include an extra column for "all"
% Store indexes, not years in lastHealthy, until just before plotting.

lastHealthy = NaN(length(Reefs_latlon), 1);

combo = frequentBleaching(:, :, 1) | (mortState(:, :, 1) & mortState(:, :, 2));
% Now we need do find the last time the value is false (healthy)

for k = activeReefs
    ind = find(~combo(k, :), 1, 'last');
    if ~isempty(ind)
        lastHealthy(k) = ind;
    end
end
% Convert from indices to year.  NaN stays NaN.
lastHealthy = lastHealthy + fullYearRange(1) - 1;
lastYearRange = [1950 2100];
tName = strcat(modelChoices,'. Last Year of Healthy Reef');
fileBase = strcat(fullDir, modelChoices, '_LastHealthyBothTypesV2');
outFile = strcat(fileBase, '.pdf');
oneMap(20, activeLatLon(:, 1), activeLatLon(:, 2), lastHealthy(activeReefs), lastYearRange, customColors, tName, outFile, false);
% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

end  % End the main MapsCoralCover function.

% Arguments:
% n     figure number
% lons  longitudes (was [events.lon])
% lats  latitudes
% values what to plot at each position
% cRange man and max data values for color scale
% t title
% outFile pdf output file
function [] = oneMap(n, lons, lats, values, cRange, cMap, t, outFile, add)
    f = figure(n);
    if add
        hold on;
    else
        clf;
        % first pass only:
        m_proj('miller', 'lat', [-40 40]); % , 'lon', 155.0); - offsets map, but drops some data!
        m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
        m_grid('box','fancy','linestyle','none','backcolor',[.9 .99 1], 'xticklabels', [], 'yticklabels', []);
    end

    % Points with last-year mortality values:
    [LONG,LAT] = m_ll2xy(lons,lats); hold on % convert reef points to M-Map lat long

    if (length(values) == 3) && (max(values) > 1)
        fprintf("I do not know how to plot exactly 3 reef values because scatter thinks the values are a single color specification!\n");
        return;
    end
    scatter(LONG,LAT,5, values) ; % plot bleaching events onto map
    
    if isempty(cMap)
        colormap default;
    else
        colormap(cMap)
    end
    if ~isempty(cRange)
        caxis(cRange);
    end
    colorbar
    title(t)
    
    if ~isempty(outFile)
        print(f, '-dpdf', '-r200', outFile);
    end
    hold off;
end
