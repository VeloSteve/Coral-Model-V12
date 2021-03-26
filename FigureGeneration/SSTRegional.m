function SST_Bleaching_miniBars()
% Simple traces of SST over time, using red for one region and blue for another.
relPath = '../FigureData/healthy_4panel_figure1/Target5_E221_Nov2020/';
addpath('..'); % for tight_subplot

smooth = 5;  % 1 means no smoothing, n smooths over a total of n adjacent points.
smoothT = 1; % same, but applied to temps

figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 10, 10]);


% The exact colors used in Figure one for adaptations.
black = [0 0 0];         % none
blue =  [0.0 0.35 0.95]; % evolution
red  =  [0.9 0.1  0.1];  % shuffling
other = [0.6 0.0  0.8];  % both

% lat min, lat max, lon min, lon max
region(1, :) = [9.53, 13.01, -71.74, -60.25]; % off Venezuela
region(2, :) = [9.53, 27.48, -83.68, -59.91]; % north to Bahamas, west to Costa Rica
region(3, :) = [12.43, 25.39, -86.89, -83.00]; % add Nicaragua coast and western Cuba
region(4, :) = [14.91, 23.74, -89.41, -82.84]; % add Yucatan coast 
region(5, :) = [19.32, 28.44, -89.41, -76.56]; % Most of Cuba and Bahamas

rcpName = 'RCP 45';
RCP = 'rcp45';
sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
dataset = "ESM2M";
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

% The Venezuela coast and offshore islands is (roughly) region 1.  The Caribbean
% is (roughly) the sum of regions 2:4 minus any overlap in region 1.
venSet = [];
carSet = [];
% Note that "latlon" is in the order longitude, latitude!
reg = 1;
[row, col] = find((Reefs_latlon(:, 2) > region(reg, 1)) & (Reefs_latlon(:, 2) < region(reg, 2)) ...
                & (Reefs_latlon(:, 1) > region(reg, 3)) & (Reefs_latlon(:, 1) < region(reg, 4)));
venSet = row;
reg = 2;
[row, col] = find((Reefs_latlon(:, 2) > region(reg, 1)) & (Reefs_latlon(:, 2) < region(reg, 2)) ...
                & (Reefs_latlon(:, 1) > region(reg, 3)) & (Reefs_latlon(:, 1) < region(reg, 4)));
carSet = union(carSet, row);
reg = 3;
[row, col] = find((Reefs_latlon(:, 2) > region(reg, 1)) & (Reefs_latlon(:, 2) < region(reg, 2)) ...
                & (Reefs_latlon(:, 1) > region(reg, 3)) & (Reefs_latlon(:, 1) < region(reg, 4)));
carSet = union(carSet, row);
reg = 4;
[row, col] = find((Reefs_latlon(:, 2) > region(reg, 1)) & (Reefs_latlon(:, 2) < region(reg, 2)) ...
                & (Reefs_latlon(:, 1) > region(reg, 3)) & (Reefs_latlon(:, 1) < region(reg, 4)));
reg = 5;
[row, col] = find((Reefs_latlon(:, 2) > region(reg, 1)) & (Reefs_latlon(:, 2) < region(reg, 2)) ...
                & (Reefs_latlon(:, 1) > region(reg, 3)) & (Reefs_latlon(:, 1) < region(reg, 4)));
cubSet = row;

carSet = setdiff(carSet, venSet);
carSet = setdiff(carSet, cubSet);

hold on;
for k = carSet
    pCar = plot(TIME, SST(k, :), '-r'); 
end
for k = venSet
    pVen = plot(TIME, SST(k, :), '-b');
end


fprintf("Values as in Figure S9 (e), std[hottest month SST] for 2050-2080\n");
hottest1900 = SST(:, 1:yearEnd(1900));
stdVen = std(hottest1900(venSet, :), 0, 2);
stdCar = std(hottest1900(carSet, :), 0, 2);
stdCub = std(hottest1900(cubSet, :), 0, 2);
quantVen = quantile(stdVen, [0.05 0.25 0.50 0.75 0.95]);
quantCar = quantile(stdCar, [0.05 0.25 0.50 0.75 0.95]);
quantCub = quantile(stdCub, [0.05 0.25 0.50 0.75 0.95]);
fprintf("Venezuela region 5th, 25th, 50th, 75th, 95th percentiles: %5.2f %5.2f %5.2f %5.2f %5.2f C std[hottest month SST]\n", quantVen);
fprintf("Caribbean region 5th, 25th, 50th, 75th, 95th percentiles: %5.2f %5.2f %5.2f %5.2f %5.2f C std[hottest month SST]\n", quantCar);
fprintf("Cuba      region 5th, 25th, 50th, 75th, 95th percentiles: %5.2f %5.2f %5.2f %5.2f %5.2f C std[hottest month SST]\n", quantCub);
fprintf("These sets are disjoint.\n");
fprintf("  Cuba: about the western 3/4 of Cuba, north to include southern Florida and the Bahamas. 45 cells.\n");
fprintf("  Venezuela: From about Maracaibo to east of Trinidad, and north to include Aruba. 21 cells.\n");
fprintf("  Caribbean: The Caribbean minus the areas above.  Turks and Caicos is included, but little or none of the Gulf of Mexico. 104 cells.\n");


x1950 = datenum(1950, 1, 15);
x2000 = datenum(2000, 1, 15);
x2050 = datenum(2050, 1, 15);
x2100 = datenum(2100, 1, 15);
xlim([x1950 x2100]);




    ylabel('SST (\circ C)');

        %yticks([26 28 30 32]);
        %yticklabels({'26' '28' '30' '32'});

xlabel('Year');
xticks([x1950 x2000 x2050 x2100]);
xticklabels({'1950' '2000' '2050' '2100'});

legend([pCar(1) pVen(1)], ["Caribbean", "Venezuela"], 'Location', 'SouthEast' )
end

function hot = hottest(sst)
    % Take an array of monthly SSD, sized reefs*months and return
    % just the hottest month of each year, now sized reefs*years
    hot = reshape(sst, size(sst,1), 12, []);
    hot = squeeze(max(hot,[], 2));
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