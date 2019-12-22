%% SET WORKING DIRECTORY AND PATH
addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');
addpath('D:/GitHub/m_map/');
sstPath = "D:/GitHub/Coral-Model-Data/ProjectionsPaper/";
RCP = 'rcp85';

% SST DATASET?
dataset = 'ESM2M';

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

% Get the SST deviation from the start to 1900.
SST1900 = SST(:, 1:yearEnd(1900));
sdSST1900 = std(SST1900, 0, 2);
MapGeneration(Reefs_latlon, sdSST1900, 1, "RCP 8.5 Standard deviation of SST, 1861-1900", 3);

% Same for 2050 to 2080
SST2050 = SST(:, yearStart(2050):yearEnd(2080));
sdSST2050 = std(SST2050, 0, 2);
MapGeneration(Reefs_latlon, sdSST2050, 2, "RCP 8.5 Standard deviation of SST, 2050-2080", 3);

% Delta 2050-historical
dt = sdSST2050-sdSST1900;
MapGeneration(Reefs_latlon, dt, 3, "RCP 8.5 Difference in SD from 1861-1900 to 2050-2080", 1);

function i = yearStart(y)
    % Calculate the index in the monthly time array for 15 Jan of the given
    % year.
    % the first date in the model is 15-Jan-1861
    i = 1 + (y-1861)*12
end
function i = yearEnd(y)
    % Calculate the index in the monthly time array for 15 Dec of the given
    % year.
    % the first date in the model is 15-Jan-1861
    % add 11 months to specify December
    i = 1 + (y-1861)*12 + 11
end
