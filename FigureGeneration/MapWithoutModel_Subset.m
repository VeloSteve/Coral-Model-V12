%% This generates a map of historical SST, but subsetted to show reefs selected
%  by some external program.
%% SET WORKING DIRECTORY AND PATH
Computer = 0; % 1=office; 2=laptop; 3=Steve; 4=Steve laptop; 0 = autodetect
addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');

% Replace the "useComputer" call below with
% sstPath = "directory where you put the SST and Lat/Lon data";
[basePath, outputPath, sstPath, SGPath, matPath, Computer, defaultThreads] ...
    = useComputer(Computer);


RCP = 'rcp85';

% SST DATASET?
dataset = 'ESM2M';

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

load('IndexRCP45Both.mat', 'idx');
SST = SST(idx, :);
Reefs_latlon = Reefs_latlon(idx, :);

% Make "typical" historical temperature from first 48 months.
SST = SST(:, 1:48);
typSST = mean(SST, 2);


 MapGeneration(Reefs_latlon, typSST, 1, "");
 
 CellSizes(Reefs_latlon)