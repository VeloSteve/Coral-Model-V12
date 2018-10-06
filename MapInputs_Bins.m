%% Make Maps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 1-6-15                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = MapInputs_Bins(fullDir, Reefs_latlon, SST, psw2_new, propTest, ...
        modelChoices)
% Add paths and load mortality statistics
%load(strcat('~/Dropbox/Matlab/SymbiontGenetics/',filename,'/201616_testNF_1925reefs.mat'),'Mort_stats')
format shortg;
% filename = '201616_figs'; %filename = strcat(dateString,'_figs'); mkdir(filename); % location to save files
% map %% NOTE: worldmap doesn't seem to be working on work computer

%%
SSThist = SST(:,1:1680);  % SST(reef, month)  1680 is the months up to 2000
        %SelV = [1.25 1]*psw2*var(SSThist(1:initSSTIndex));
varHistorical = var(SSThist, 0, 2);

j2040 = (2040-1860)*12;
j2060 = (2060-1860)*12;
var2040_2060 = var(SST(:, j2040:j2060), 0, 2);

varScale = [0 6];  % a few numbers are very high ceil(max(max(varHistorical), max(var2040_2060)))];

deltaVar = var2040_2060-varHistorical;
deltaScale = [-0.5 1];

% A scale for "red=bad, blue=good" plots.
customColors = flipud(customScale());

% Plot the next 3 together
figure('color', 'w');
[ha, pos] = tight_subplot(3, 1, [0.05, -0.09], [0.04, 0.1], [0.0 0.05]);

%% Make map of  historical SST variance

tName = strcat(modelChoices,'. Historical Variance');
fileBase = strcat(fullDir, modelChoices,'_HistoricalVarianceMap');
axes(ha(1));
oneMap(1, Reefs_latlon(:, 1), Reefs_latlon(:, 2), varHistorical, varScale, customColors, tName, fileBase, false, true);

%% Make map of  2040-2060 SST variance

tName = strcat(modelChoices,'. 2040-2060 Variance');
fileBase = strcat(fullDir, modelChoices,'20402060VarianceMap');

axes(ha(2));
oneMap(2, Reefs_latlon(:, 1), Reefs_latlon(:, 2), var2040_2060, varScale, customColors, tName, fileBase, false, true);

%% Make map of the change in variance

tName = strcat(modelChoices,'. 2040-2060 minus Historical Variance');
fileBase = strcat(fullDir, modelChoices,'20402060DeltaVarianceMap');
axes(ha(3));
oneMap(3, Reefs_latlon(:, 1), Reefs_latlon(:, 2), deltaVar, deltaScale, customColors, tName, fileBase, false, true);

%% Now plot SST rate of change
% 8 steps/month * 12 months/year * 10 years
% The function is not made for arrays (perhaps it should have been) so just
% loop (slowly) through all reefs.
% Smooth temps over 3 years
for i = length(Reefs_latlon(:, 1)):-1:1
    avSST(i, :) = centeredMovingAverage(SST(i, :), 1+8*12*3, 'rectangle');
end
% Get delta over 2 decades
for i = length(Reefs_latlon(:, 1)):-1:1
    rateSST(i) = (avSST(i, j2060) - avSST(i, j2040)) / 2;
end
%rateScale = [floor(min(rateSST)*100)/100.0, ceil(max(rateSST)*100)/100.0];
rateScale = [0.02 0.23];
tName = strcat(modelChoices,'. 2040-2060 SST increase per decade');
fileBase = strcat(fullDir, modelChoices,'20402060SSTRateMap');
oneMap(4, Reefs_latlon(:, 1), Reefs_latlon(:, 2), rateSST, rateScale, customColors, tName, fileBase, false, false);

end  % End the main MapsCoralCover function.

% Arguments:
% n     figure number
% lons  longitudes (was [events.lon])
% lats  latitudes
% values what to plot at each position
% cRange man and max data values for color scale
% t title
% outFile pdf output file
function [] = oneMap(n, lons, lats, values, cRange, cMap, t, fileBase, add, panels)
    if ~panels
        f = figure(n);
        set(gcf, 'color', 'w', 'Units', 'inches', 'Position', [1+8*(n-1), 8, 8, 3]);
    end

    if add
        hold on;
    else
        if ~panels 
            clf;
        end
        % first pass only:
        m_proj('miller', 'lat', [-40 40]); % , 'lon', 155.0); - offsets map, but drops some data!
        m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
        m_grid('box','fancy','linestyle','none','backcolor',[.9 .99 1], 'xticklabels', [], 'yticklabels', []);
    end

    % Points with last-year mortality values:
    [LONG,LAT] = m_ll2xy(lons,lats); hold on % convert reef points to M-Map lat long

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
    
    if false && ~isempty(fileBase)
        print(f, '-dpdf', '-r200', strcat(fileBase, '.pdf'));
        if verLessThan('matlab', '8.2')
            saveas(gcf, fileBase, 'fig');
        else
            savefig(strcat(fileBase,'.fig'));
        end
    end
    hold off;
end
