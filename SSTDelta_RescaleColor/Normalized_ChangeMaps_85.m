%% SET WORKING DIRECTORY AND PATH
Computer = 0; % 1=office; 2=laptop; 3=Steve; 4=Steve laptop; 0 = autodetect
addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');
addpath('D:/GitHub/m_map/');
sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
RCP = 'rcp85';

% SST DATASET?
dataset = 'ESM2M';

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

% Get the SST deviation from the start to 1900.
SST1900 = SST(:, 1:1:12*(1900-1861+1));
sdSST1900 = std(SST1900, 0, 2);

% Get the average of the hottest month of each year to 1900.
SST1900 = SST(:, 1:1:12*(1900-1861+1));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST1900, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST1900 = mean(SSTR, 2);



% SD for just 2050.
%SST2050 = SST(:, 1+12*(2050-1861):1:12*(2050-1861+1));
%sdSST2050 = std(SST2050, 0, 2);

% SST for just 2050
SST2050 = SST(:, 1+12*(2050-1861):1:12*(2050-1861+1));
% Reshape to have groups of 12 (second index is 12 months of a year)
SSTR = reshape(SST2050, 1925, 12, []);
SSTR = squeeze(max(SSTR,[], 2));
typSST2050 = mean(SSTR, 2);

% Now calculate the noise-normalized warming.
% (delta SST)/dev(SST)
% It's not clear whether to normalize each temperature by the SD
% during that time period, and then take deltas, or to simply divide
% the deltas by a SD.  I'm going to start with the latter, and just use
% the 1860 to 1900 SD, since a single-year SD seems shaky.
normDelta = (typSST2050 - typSST1900) ./ sdSST1900;

MapGeneration(Reefs_latlon, normDelta, 6, "RCP 8.5 Noise-normalized SST rise to 2050", 4);
