%% SET WORKING DIRECTORY AND PATH
addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');
addpath('D:/GitHub/m_map/');
sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
RCP = 'rcp45';

% SST DATASET?
dataset = 'ESM2M';

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

% Get the average the hottest month of each year to 1900.
SST1900 = SST(:, 1:yearEnd(1900));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST1900, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST1900 = mean(SSTR, 2);
MapGeneration(Reefs_latlon, typSST1900, 1, "RCP 4.5 Average of hottest month 1861-1900");

% Same for 2050 to 2080.
SST2050 = SST(:, yearStart(2050):yearEnd(2080));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST2050, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST2050 = mean(SSTR, 2);
MapGeneration(Reefs_latlon, typSST2050, 2, "RCP 4.5 Average of hottest month in 2050-2080");

% Delta 2050-historical
dt = typSST2050-typSST1900;
MapGeneration(Reefs_latlon, dt, 3, "RCP 4.5 Hottest Month SST change from 1861-1900 to 2050-2080", 4);

% Now try grouping the reefs in just 3 sets - top 10%, bottom 10%, and middle.
splits = prctile(dt, [10,90])

dtFlag = 2*ones(size(dt)); %, 'int8');
dtFlag(dt < splits(1)) = 0;
dtFlag(dt > splits(2)) = 5;

MapGeneration(Reefs_latlon, dtFlag, 4, "RCP 4.5 10% Largest and Smallest Changes");

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