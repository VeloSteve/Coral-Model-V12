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
SSThist = SST_1861_2000;

%% LOAD OLD SELECTIONAL VARIANCE (psw2) 
%load ('~/Dropbox/Matlab/SymbiontGenetics/mat_files/psw2_trials.mat','psw2_var_allv2')

%% Store optimizer inputs from propInputValues with any constant values to be computed.
pswInputs(:,1) = propInputValues';

%% Updated 9/20/2017, target 10% with first 3 parameters fixed to the same
% values as the 5% cases numbered 20 to 27.
%  === For 10% target ===
pswInputs(:,2) = [0.36; 1.5; 0.46; 6.4367];  % RCP 2.6, E=0
pswInputs(:,3) = [0.36; 1.5; 0.46; 7.0778];  % RCP 2.6, E=1
pswInputs(:,4) = [0.36; 1.5; 0.46; 6.5311];  % RCP 4.5, E=0
pswInputs(:,5) = [0.36; 1.5; 0.46; 7.1600];  % RCP 4.5, E=1
pswInputs(:,6) = [0.36; 1.5; 0.46; 6.4978];  % RCP 6.0, E=0
pswInputs(:,7) = [0.36; 1.5; 0.46; 7.1389];  % RCP 6.0, E=1
pswInputs(:,8) = [0.36; 1.5; 0.46; 6.5233];  % RCP 8.5, E=0
pswInputs(:,9) = [0.36; 1.5; 0.46; 7.1189];  % RCP 8.5, E=1

%% Updated 9/19/2017, as for 10%
%  === For 3% target ===
pswInputs(:,10) = [0.36; 1.5; 0.46; 3.7633];  % RCP 2.6, E=0
pswInputs(:,11) = [0.36; 1.5; 0.46; 4.2711];  % RCP 2.6, E=1
pswInputs(:,12) = [0.36; 1.5; 0.46; 3.9344];  % RCP 4.5, E=0
pswInputs(:,13) = [0.36; 1.5; 0.46; 4.4422];  % RCP 4.5, E=1
pswInputs(:,14) = [0.36; 1.5; 0.46; 3.8133];  % RCP 6.0, E=0
pswInputs(:,15) = [0.36; 1.5; 0.46; 4.3533];  % RCP 6.0, E=1
pswInputs(:,16) = [0.36; 1.5; 0.46; 3.7778];  % RCP 8.5, E=0
pswInputs(:,17) = [0.36; 1.5; 0.46; 4.2933];  % RCP 8.5, E=1

%% 9/19/2017  Adjust for new seed values divisors are larger by about 0.61
% === For 5% target ===
pswInputs(:,20) = [0.36; 1.5; 0.46; 4.8356];  % RCP 2.6, E=0
pswInputs(:,21) = [0.36; 1.5; 0.46; 4.8444];  % RCP 8.5, E=0
pswInputs(:,22) = [0.36; 1.5; 0.46; 5.2389];  % RCP 2.6, E=1
pswInputs(:,23) = [0.36; 1.5; 0.46; 5.3222];  % RCP 8.5, E=1
% 2/28/17 Add rcp4.5 and 6.0
pswInputs(:,24) = [0.36; 1.5; 0.46; 4.9411];  % RCP 4.5, E=0
pswInputs(:,25) = [0.36; 1.5; 0.46; 4.8700];  % RCP 6.0, E=0
pswInputs(:,26) = [0.36; 1.5; 0.46; 5.4411];  % RCP 4.5, E=1
pswInputs(:,27) = [0.36; 1.5; 0.46; 5.3756];  % RCP 6.0, E=1

%% New on 12/21/2019
%  === For 5% target, adding shuffling, mode 9, 1C, 1861 ===
pswInputs(:,28) = [0.2; 1.5; 0.46; 12.4200];  % RCP 2.6, E=0
pswInputs(:,29) = [0.2; 1.5; 0.46; 14.8222];  % RCP 2.6, E=1
pswInputs(:,30) = [0.2; 1.5; 0.46; 12.7211];  % RCP 4.5, E=0
pswInputs(:,31) = [0.2; 1.5; 0.46; 15.3667];  % RCP 4.5, E=1
pswInputs(:,32) = [0.2; 1.5; 0.46; 12.4111];  % RCP 6.0, E=0
pswInputs(:,33) = [0.2; 1.5; 0.46; 14.8833];  % RCP 6.0, E=1
pswInputs(:,34) = [0.2; 1.5; 0.46; 12.1222];  % RCP 8.5, E=0
pswInputs(:,35) = [0.2; 1.5; 0.46; 14.5878];  % RCP 8.5, E=1

% Shuffling, 1.5C (2C was nearly impossible to reach)
pswInputs(:,36) = [0.025; 1.5; 0.46; 34.5378]; % RCP 2.6, E=1

% Shuffling, 1.5C, 0.25 growth penalty (all cases above assumed 0.5)
pswInputs(:,44) = [0.025; 1.5; 0.46; 33.9722]; % RCP 2.6, E=1

% Shuffling, 1C, 0.25 growth penalty
pswInputs(:,52) = [0.025; 1.5; 0.46; 15.2778]; % RCP 2.6, E=1
[~, pswCount] = size(pswInputs);


%% CALULATE PROP CONSTANT FOR EACH GRID CELL
psw2_new = nan(length(Reefs_latlon),1); % initialize matrix
for reef = 1:length(Reefs_latlon)
    SSThistReef = SST_1861_2000(reef,:)';  % extract SSTs for grid cell bn 1861-2000
    % XXX Note that SSThistReef was created but not used in the code I
    % received!
    %psw2(k,1) = max(0.7,min(1.3,(mean(exp(0.063*SSThistReef))/var(exp(0.063*SSThistReef)))^0.5 -1.2));% John's new eqn 7/19/16
    
    %psw2_new(reef,2) = max(0.6,min(1.3,()); % John's new eqn 7/25/16
    % break up to find error:
    %middle = mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef)).^0.25/2;
    %psw2_new(reef,2) = max(0.6,min(1.3,middle));
    %{
    psw2_new(reef,1) = max(propInputValues(1),min(propInputValues(2),(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^propInputValues(3)/propInputValues(4))); % John's new eqn 7/25/16
    % Fixed values - this costs a little time on each iteration, but keeps
    % them available.
    % Next 2 were used between about 1/13 and 1/17/2017
    %psw2_new(reef,2) = max(0.35,min(1.8,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.355/2.0167)); % 1/13/17 rcp 8.5 optimized
    %psw2_new(reef,3) = max(0.35,min(1.8,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.4556/2.556)); % 1/13/17 rcp 2.6 optimized
    % Re-optimized on 1/17 to a 1985-2010 bleaching level of 3 percent.  2%
    % did not seem feasible
    psw2_new(reef,2) = max(0.35,min(2.0,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.5/2.517)); % 1/17/17 rcp 8.5 E=0 optimized
    psw2_new(reef,3) = max(0.35,min(2.0,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.5/3.104)); % 1/17/17 rcp 8.5 E=1 optimized
    psw2_new(reef,4) = max(0.35,min(2.0,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.5/2.390)); % 1/17/17 rcp 2.6 E=0 optimized
    psw2_new(reef,5) = max(0.35,min(2.0,(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^0.5/3.063)); % 1/17/17 rcp 2.6 E=1 optimized
    %}
    % Try to show the equation more readably:
    % E = exp(0.063.*SSThistReef)
    % max(pMin,min(pMax,(mean(E)./var(E)).^exponent/divisor))
    for j = 1:pswCount
        psw2_new(reef,j) = max(pswInputs(1, j),min(pswInputs(2, j),(mean(exp(0.063.*SSThistReef))./var(exp(0.063.*SSThistReef))).^pswInputs(3, j)/pswInputs(4, j))); % John's new eqn 7/25/16
    end
    clear SSThistReef
end

%% Save new psw2 values
cd(matPath);
save('Optimize_psw2.mat','psw2_new','Reefs_latlon','pswInputs'); %% CAL 10-3-16 based on hist SSTs!
cd(basePath);
