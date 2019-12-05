%% SET WORKING DIRECTORY AND PATH
Computer = 0; % 1=office; 2=laptop; 3=Steve; 4=Steve laptop; 0 = autodetect
addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');

sstPath = "D:/GitHub/Coral-Model-Data/ProjectionsPaper/";
RCP = 'rcp85';

% SST DATASET?
dataset = 'ESM2M';

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = getSSTnormGFDL_ESM2M(sstPath, dataset, RCP);

% Make "typical" historical temperature from first 48 months.
%SST48 = SST(:, 1:48);
%typSST = mean(SST48, 2);
%MapGeneration(Reefs_latlon, typSST, 1);
 
% Now go through 2001.
%SST = SST(:, 1:12*(2001-1861+1));
%typSST = mean(SST, 2);
%MapGeneration(Reefs_latlon, typSST, 2);

% Get the average the hottest month of each year to 1900.
SST1900 = SST(:, 1:1:12*(1900-1861+1));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST1900, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST1900 = mean(SSTR, 2);
MapGeneration(Reefs_latlon, typSST1900, 1, "RCP 8.5 Average of hottest month 1861-1900");

% Same for just 2050.
SST2050 = SST(:, 1+12*(2050-1861):1:12*(2050-1861+1));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST2050, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST2050 = mean(SSTR, 2);
MapGeneration(Reefs_latlon, typSST2050, 2, "RCP 8.5 Hottest month in 2050");

% Delta 2050-historical

MapGeneration(Reefs_latlon, typSST2050-typSST1900, 3, "RCP 8.5 Hottest Month SST change from 1861-1900 to 2050");

%cellSizes(Reefs_latlon)