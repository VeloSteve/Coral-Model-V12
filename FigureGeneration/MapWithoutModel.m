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
SST48 = SST(:, 1:48);
typSST = mean(SST48, 2);
MapGeneration(Reefs_latlon, typSST, 1);
 
% Now go through 2001.
SST = SST(:, 1:12*(2001-1861+1));
typSST = mean(SST, 2);
MapGeneration(Reefs_latlon, typSST, 2);

% And finally, average the hottest month of each year only.
SST = SST(:, 1:1:12*(2001-1861+1));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST = mean(SSTR, 2);
MapGeneration(Reefs_latlon, typSST, 3);


cellSizes(Reefs_latlon)