%% CORAL AND SYMBIONT POPULATION DYNAMICS
% MAIN FILE TO TEST PROPORTIONALITY CONSTANTS AND VARIANCE
% 14.9, 14.3, 14.8 V8 speed, everyx=1 one key reef, pdfs off
% 19.2, 18.1, 18.6 V6 speed, with two ways of computing bleaching.
% 11.7 seconds, V8 after more cleanup and removing large broadcast
% variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 5-3-16                                              %
% Performance and structural changes 9/2016 by Steve Ryan (jaryan)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Make "typical" historical temperature from first 48 months.
SST = SST(:, 1:48);
typSST = mean(SST, 2);


 MapGeneration(Reefs_latlon, typSST, 1, "");
 
 CellSizes(Reefs_latlon)