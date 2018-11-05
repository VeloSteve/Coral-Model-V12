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
SST = SST(:, 1:48);
typSST = mean(SST, 2);


 MapGeneration(Reefs_latlon, typSST);
 
 cellSizes(Reefs_latlon)