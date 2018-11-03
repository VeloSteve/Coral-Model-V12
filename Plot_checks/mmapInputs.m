
function [] = mapInputs(fullDir, Reefs_latlon, SST, psw2_new, propTest, ...
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

var2040_2060 = var(SST(:, (2040-1860)*12:(2060-1860)*12), 0, 2);

varScale = [0 10];  % a few numbers are very high ceil(max(max(varHistorical), max(var2040_2060)))];

deltaVar = var2040_2060-varHistorical;
deltaScale = [-1 1];
%% Make map of  historical SST variance

% A scale for "red=bad, blue=good" plots.
customColors = customScale();

tName = strcat(modelChoices,'. Historical Variance');
fileBase = strcat(fullDir, modelChoices,'_HistoricalVarianceMap');
outFile = strcat(fileBase, '.pdf');
oneMap(1, Reefs_latlon(:, 1), Reefs_latlon(:, 2), varHistorical, varScale, customColors, tName, outFile, false);

% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

%% Make map of  2040-2060 SST variance

% A scale for "red=bad, blue=good" plots.
customColors = customScale();

tName = strcat(modelChoices,'. 2040-2060 Variance');
fileBase = strcat(fullDir, modelChoices,'20402060VarianceMap');
outFile = strcat(fileBase, '.pdf');
oneMap(2, Reefs_latlon(:, 1), Reefs_latlon(:, 2), var2040_2060, varScale, customColors, tName, outFile, false);

% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end

%% Make map of the change in variance

% A scale for "red=bad, blue=good" plots.
customColors = customScale();

tName = strcat(modelChoices,'. 2040-2060 vs Historical Variance');
fileBase = strcat(fullDir, modelChoices,'20402060DeltaVarianceMap');
outFile = strcat(fileBase, '.pdf');
oneMap(3, Reefs_latlon(:, 1), Reefs_latlon(:, 2), deltaVar, deltaScale, customColors, tName, outFile, false);

% This one may be post-processed, so save .fig
if verLessThan('matlab', '8.2')
    saveas(gcf, fileBase, 'fig');
else
    savefig(strcat(fileBase,'.fig'));
end
return;




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
    set(gcf, 'color', 'w', 'Units', 'inches', 'Position', [1+6*n, 8, 6, 3]);

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
