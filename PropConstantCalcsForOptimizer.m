%% PROPORTIONALITY CONSTANT CALCULATIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 8/26/16                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[basePath, outputPath, sstPath, SGPath, matPath, n, defaultThreads] = useComputer(3);


% SST DATASET?
Data = 1; % 1=ESM2M_norm
%Data = 2; % 2=HADISST (through 3/16/16)
if Data == 1
    dataset = 'ESM2M';
else
    dataset = 'HadISST';
end

%% DEFINE CLIMATE CHANGE SCENARIO (from normalized GFDL-ESM2M; J Dunne)
%for i={'rcp26','rcp85'}  
%RCP = char(i)
% RCP = 'rcp85'; % options; 'rcp26', 'rcp45', 'rcp60', 'rcp85'
format shortg; c = clock; date = strcat(num2str(c(1)),num2str(c(2)),num2str(c(3))); % today's date stamp

%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
%GetSST_norm_GFDL_ESM2M % sub m-file for extracting SSTs for a ALL reef grid cells
% [SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, matPath, Data, RCP);
% matPath is no longer used, 12/2019.
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);

SST_1861_2000 = SST(:,1:1680);
% never used? SSThist = SST_1861_2000;

%% LOAD OLD SELECTIONAL VARIANCE (psw2) 
%load ('~/Dropbox/Matlab/SymbiontGenetics/mat_files/psw2_trials.mat','psw2_var_allv2')

%% Store optimizer inputs from propInputValues with any constant values to be computed.
% expand the array once, including space for averages:
pswInputs(4, 65+ceil(65/4)) = 0;

pswInputs(:,1) = propInputValues';

%% Update 1/13/2020, values for targets 3, 5 and 10% bleaching.
% Now all cases are in sets which include all 4 RCP values, so averaging can be
% done automatically.


% Be sure to skip pswInputs(:, 1) because "1" use used for optimization.
% == Target 3, no advantage ==
pswInputs(:, 2) = [0.025; 1.5; 0.45; 3.1481]; % RCP 2.6, E=0, OA=0
pswInputs(:, 3) = [0.025; 1.5; 0.45; 3.4444]; % RCP 4.5, E=0, OA=0
pswInputs(:, 4) = [0.025; 1.5; 0.45; 3.0972]; % RCP 6, E=0, OA=0
pswInputs(:, 5) = [0.025; 1.5; 0.45; 3.1435]; % RCP 8.5, E=0, OA=0
pswInputs(:, 6) = [0.025; 1.5; 0.45; 3.7685]; % RCP 2.6, E=1, OA=0
pswInputs(:, 7) = [0.025; 1.5; 0.45; 4.0278]; % RCP 4.5, E=1, OA=0
pswInputs(:, 8) = [0.025; 1.5; 0.45; 3.7731]; % RCP 6, E=1, OA=0
pswInputs(:, 9) = [0.025; 1.5; 0.45; 3.6944]; % RCP 8.5, E=1, OA=0
pswInputs(:, 10) = [0.025; 1.5; 0.45; 3.7407]; % RCP 2.6, E=1, OA=1
pswInputs(:, 11) = [0.025; 1.5; 0.45; 4.0046]; % RCP 4.5, E=1, OA=1
pswInputs(:, 12) = [0.025; 1.5; 0.45; 3.7407]; % RCP 6, E=1, OA=1
pswInputs(:, 13) = [0.025; 1.5; 0.45; 3.6713]; % RCP 8.5, E=1, OA=1

% == Target 5, no advantage == 
pswInputs(:, 14) = [0.025; 1.5; 0.45; 4.3426]; % RCP 2.6, E=0, OA=0
pswInputs(:, 15) = [0.025; 1.5; 0.45; 4.4745]; % RCP 4.5, E=0, OA=0
pswInputs(:, 16) = [0.025; 1.5; 0.45; 4.3519]; % RCP 6, E=0, OA=0
pswInputs(:, 17) = [0.025; 1.5; 0.45; 4.339]; % RCP 8.5, E=0, OA=0
pswInputs(:, 18) = [0.025; 1.5; 0.45; 4.6806]; % RCP 2.6, E=1, OA=0
pswInputs(:, 19) = [0.025; 1.5; 0.45; 4.8056]; % RCP 4.5, E=1, OA=0
pswInputs(:, 20) = [0.025; 1.5; 0.45; 4.6898]; % RCP 6, E=1, OA=0
pswInputs(:, 21) = [0.025; 1.5; 0.45; 4.6574]; % RCP 8.5, E=1, OA=0
pswInputs(:, 22) = [0.025; 1.5; 0.45; 4.6528]; % RCP 2.6, E=1, OA=1
pswInputs(:, 23) = [0.025; 1.5; 0.45; 4.8009]; % RCP 4.5, E=1, OA=1
pswInputs(:, 24) = [0.025; 1.5; 0.45; 4.6574]; % RCP 6, E=1, OA=1
pswInputs(:, 25) = [0.025; 1.5; 0.45; 4.6389]; % RCP 8.5, E=1, OA=1
% == Target 5, advantage 1, penalty 0.25 == (only these 4 are at 0.25)
pswInputs(:, 26) = [0.025; 1.5; 0.45; 5.5324]; % RCP 2.6, E=0, OA=0
pswInputs(:, 27) = [0.025; 1.5; 0.45; 5.6667]; % RCP 4.5, E=0, OA=0
pswInputs(:, 28) = [0.025; 1.5; 0.45; 5.5417]; % RCP 6, E=0, OA=0
pswInputs(:, 29) = [0.025; 1.5; 0.45; 5.5417]; % RCP 8.5, E=0, OA=0
% == Target 5, advantage 0.5 ==
pswInputs(:, 30) = [0.025; 1.5; 0.45; 5.4259]; % RCP 2.6, E=0, OA=0
pswInputs(:, 31) = [0.025; 1.5; 0.45; 5.6111]; % RCP 4.5, E=0, OA=0
pswInputs(:, 32) = [0.025; 1.5; 0.45; 5.3009]; % RCP 6, E=0, OA=0
pswInputs(:, 33) = [0.025; 1.5; 0.45; 5.3056]; % RCP 8.5, E=0, OA=0
pswInputs(:, 34) = [0.025; 1.5; 0.45; 5.6574]; % RCP 2.6, E=1, OA=0
pswInputs(:, 35) = [0.025; 1.5; 0.45; 5.8102]; % RCP 4.5, E=1, OA=0
pswInputs(:, 36) = [0.025; 1.5; 0.45; 5.5231]; % RCP 6, E=1, OA=0
pswInputs(:, 37) = [0.025; 1.5; 0.45; 5.5231]; % RCP 8.5, E=1, OA=0
% == Target 5, advantage 1 ==
pswInputs(:, 38) = [0.025; 1.5; 0.45; 5.5509]; % RCP 2.6, E=0, OA=0
pswInputs(:, 39) = [0.025; 1.5; 0.45; 5.6713]; % RCP 4.5, E=0, OA=0
pswInputs(:, 40) = [0.025; 1.5; 0.45; 5.5417]; % RCP 6, E=0, OA=0
pswInputs(:, 41) = [0.025; 1.5; 0.45; 5.537]; % RCP 8.5, E=0, OA=0
pswInputs(:, 42) = [0.025; 1.5; 0.45; 5.8056]; % RCP 2.6, E=1, OA=0
pswInputs(:, 43) = [0.025; 1.5; 0.45; 5.8287]; % RCP 4.5, E=1, OA=0
pswInputs(:, 44) = [0.025; 1.5; 0.45; 5.7454]; % RCP 6, E=1, OA=0
pswInputs(:, 45) = [0.025; 1.5; 0.45; 5.6991]; % RCP 8.5, E=1, OA=0
% == Target 5, advantage 1.5 ==
pswInputs(:, 46) = [0.025; 1.5; 0.45; 5.3843]; % RCP 2.6, E=0, OA=0
pswInputs(:, 47) = [0.025; 1.5; 0.45; 5.3843]; % RCP 4.5, E=0, OA=0
pswInputs(:, 48) = [0.025; 1.5; 0.45; 5.3843]; % RCP 6, E=0, OA=0
pswInputs(:, 49) = [0.025; 1.5; 0.45; 5.2963]; % RCP 8.5, E=0, OA=0
pswInputs(:, 50) = [0.025; 1.5; 0.45; 5.6343]; % RCP 2.6, E=1, OA=0
pswInputs(:, 51) = [0.025; 1.5; 0.45; 5.6204]; % RCP 4.5, E=1, OA=0
pswInputs(:, 52) = [0.025; 1.5; 0.45; 5.6389]; % RCP 6, E=1, OA=0
pswInputs(:, 53) = [0.025; 1.5; 0.45; 5.4861]; % RCP 8.5, E=1, OA=0
% == Target 10, advantage 0 ==
pswInputs(:, 54) = [0.025; 1.5; 0.45; 5.8935]; % RCP 2.6, E=0, OA=0
pswInputs(:, 55) = [0.025; 1.5; 0.45; 5.9537]; % RCP 4.5, E=0, OA=0
pswInputs(:, 56) = [0.025; 1.5; 0.45; 5.8519]; % RCP 6, E=0, OA=0
pswInputs(:, 57) = [0.025; 1.5; 0.45; 5.8426]; % RCP 8.5, E=0, OA=0
pswInputs(:, 58) = [0.025; 1.5; 0.45; 6.3843]; % RCP 2.6, E=1, OA=0
pswInputs(:, 59) = [0.025; 1.5; 0.45; 6.4398]; % RCP 4.5, E=1, OA=0
pswInputs(:, 60) = [0.025; 1.5; 0.45; 6.3472]; % RCP 6, E=1, OA=0
pswInputs(:, 61) = [0.025; 1.5; 0.45; 6.2685]; % RCP 8.5, E=1, OA=0
pswInputs(:, 62) = [0.025; 1.5; 0.45; 6.4213]; % RCP 2.6, E=1, OA=1
pswInputs(:, 63) = [0.025; 1.5; 0.45; 6.4676]; % RCP 4.5, E=1, OA=1
pswInputs(:, 64) = [0.025; 1.5; 0.45; 6.3935]; % RCP 6, E=1, OA=1
pswInputs(:, 65) = [0.025; 1.5; 0.45; 6.2917]; % RCP 8.5, E=1, OA=1
% ===== Inputs below were computed separately =====
% They don't have the same sort order as those above.
% == Target 3, advantage 1 ==
pswInputs(:, 66) = [0.025; 1.5; 0.45; 4.3657]; % RCP 2.6, E=0, OA=0
pswInputs(:, 67) = [0.025; 1.5; 0.45; 4.4491]; % RCP 4.5, E=0, OA=0
pswInputs(:, 68) = [0.025; 1.5; 0.45; 4.3704]; % RCP 6, E=0, OA=0
pswInputs(:, 69) = [0.025; 1.5; 0.45; 4.2963]; % RCP 8.5, E=0, OA=0
pswInputs(:, 70) = [0.025; 1.5; 0.45; 4.6713]; % RCP 2.6, E=1, OA=0
pswInputs(:, 71) = [0.025; 1.5; 0.45; 4.6944]; % RCP 4.5, E=1, OA=0
pswInputs(:, 72) = [0.025; 1.5; 0.45; 4.6991]; % RCP 6, E=1, OA=0
pswInputs(:, 73) = [0.025; 1.5; 0.45; 4.5139]; % RCP 8.5, E=1, OA=0
% == Target 10, advantage 1 ==
pswInputs(:, 74) = [0.025; 1.5; 0.45; 7.3426]; % RCP 2.6, E=0, OA=0
pswInputs(:, 75) = [0.025; 1.5; 0.45; 7.75]; % RCP 4.5, E=0, OA=0
pswInputs(:, 76) = [0.025; 1.5; 0.45; 7.3519]; % RCP 6, E=0, OA=0
pswInputs(:, 77) = [0.025; 1.5; 0.45; 7.6991]; % RCP 8.5, E=0, OA=0
pswInputs(:, 78) = [0.025; 1.5; 0.45; 7.875]; % RCP 2.6, E=1, OA=0
pswInputs(:, 79) = [0.025; 1.5; 0.45; 8.3935]; % RCP 4.5, E=1, OA=0
pswInputs(:, 80) = [0.025; 1.5; 0.45; 7.5602]; % RCP 6, E=1, OA=0
pswInputs(:, 81) = [0.025; 1.5; 0.45; 8.1181]; % RCP 8.5, E=1, OA=0

% Average RCP values for otherwise identical cases in sets of 4.
currentSet = 100;
for i = [2:4:78]
    sSum = 0.0;
    for j = 0:3
        sSum = sSum + pswInputs(4, i+j);
    end
    % Copy the first 3 values and use the averaged s.
    pswInputs(:, currentSet) = [pswInputs(1, i), pswInputs(2, i), pswInputs(3, i), sSum/4];
    currentSet = currentSet + 1;
end

[~, pswCount] = size(pswInputs);



%% CALULATE PROP CONSTANT FOR EACH GRID CELL
% Change, Jan 2020.
% Instead of calculating all the cases for future use, at risk of mismatching
% the SST data and the cases, just do case 1 for the optimizer.  Only store the
% full list of input values, which will be used to calculate psw2 at the time of
% each simulation.

psw2_new = nan(length(Reefs_latlon),1); % initialize matrix
for reef = 1:length(Reefs_latlon)
    SSThistReef = SST_1861_2000(reef,:)';  % extract SSTs for grid cell bn 1861-2000
    % E = exp(0.063.*SSThistReef)
    % max(pMin,min(pMax,(mean(E)./var(E)).^exponent/divisor))
    for j = 1:1 % pswCount
        psw2_new(reef,j) = max(pswInputs(1, j),min(pswInputs(2, j),(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^pswInputs(3, j)/pswInputs(4, j))); % John's new eqn 7/25/16
    end
    clear SSThistReef
end

%% Save new psw2 values
cd(matPath);
save('Optimize_psw2.mat', 'pswInputs'); %% CAL 10-3-16 based on hist SSTs!
%save('Optimize_psw2.mat','psw2_new','Reefs_latlon','pswInputs'); %% CAL 10-3-16 based on hist SSTs!
cd(basePath);
