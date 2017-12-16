%% Extract SSTs for all Reef Grid Cells
% Evolutionary model for coral cover (from Baskett et al. 2009)
% M-file for extracting SST data from normalized GFDL-ESM2M (JD)
% or HADISST data
% modified by Cheryl Logan (clogan@csumb.edu) 16 May 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Extract SSTs from normalized GFDL-ESM2M (JD) or HADISST
function [SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP)
    % Get ESM2M Normalized SSTs for a ALL reef grid cells

    if strcmp(dataset, 'ESM2M') % GFDL-ESM2M_norm (John's normalized dataset)
        if strcmp(RCP, 'rcp26');load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'),'ModelTime','SSTR_2M26_JD','ESM2M_reefs_JD');
            SST = SSTR_2M26_JD; clear SSTR_2M85_JD;  % RCP2.6
        elseif strcmp(RCP, 'rcp45');load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'),'ModelTime','SSTR_2M45_JD','ESM2M_reefs_JD');
            SST = SSTR_2M45_JD; clear SSTR_2M45_JD;  % RCP4.5
        elseif strcmp(RCP, 'rcp60');load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'),'ModelTime','SSTR_2M60_JD','ESM2M_reefs_JD');
            SST = SSTR_2M60_JD; clear SSTR_2M60_JD;  % RCP4.5
        elseif strcmp(RCP, 'rcp85');load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'),'ModelTime','SSTR_2M85_JD','ESM2M_reefs_JD');
            SST = SSTR_2M85_JD; clear SSTR_2M85_JD;  % RCP8.5
        elseif strcmp(RCP, 'control');load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'),'ModelTime','SSTR_control_to1961','ESM2M_reefs_JD');
            SST = SSTR_control_to1961; clear SSTR_control_to1961;  % control
        elseif strcmp(RCP, 'control400');load(strcat(sstPath, '../SSTR_ESM2M_picontrol_biascorr_lonlat_091716.mat'),'ModelTime','SSTR','ESMUnique_W');
            SST = SSTR; clear SSTR;  % control
            ESM2M_reefs_JD = ESMUnique_W;  % kludge so the name fits code below.
        else
            fprintf('ERROR: SST data choice %s is not defined for dataset = %s\n', RCP, dataset);
        end
        % 'ESM2M_reefs_JD' gives lat/lon (1925 x 2)
        % 'SSTR_2M85_JD' is temp in C ; size (1925 x 2880)
        Reefs_latlon = ESM2M_reefs_JD; clear ESM2M_reefs_JD
        TIME = ModelTime;
        % Old hardwire: strdate = 1861;
        % This gives 1860 with the current data, which has 15-Jan-1860 as
        % the first entry.
        startYear = str2double(datestr(TIME(1), 'yyyy'));
        
    elseif strcmp(dataset, 'HadISST') % HadISST (through March 16, 2016)
        load('~/Dropbox/Matlab/SymbiontGenetics/HadISST_SSTs.mat','time','HAD_latlon','SST_reefs');
        % 'HAD_latlon' gives lat/lon (1539 x 2)
        % 'SST_reefs' is temp in C ; size (1539 x 1755)
        SST = SST_reefs; clear SST_reefs
        Reefs_latlon = HAD_latlon; clear HAD_latlon
        TIME = time; clear time;
        % Old hardwire: strdate = 1870;
        startYear = str2double(datestr(TIME(1), 'yyyy'));
    else
        fprintf('Data option %s is not defined.\n', dataset);
    end

end