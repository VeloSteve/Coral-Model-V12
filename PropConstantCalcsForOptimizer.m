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

%% Update 1/9/2020, values for targets 3, 5 and 10% bleaching.
% The 5% target values are complete for most combinations of parameters,
% while 3% and 10% are there for comparision in a supplemental figure.
% Except where noted, the growth penalty is 0.5.

% === Target 3% ===
% No shuffling advantage
pswInputs(:, 2) = [0.025; 1.5; 0.45; 3.4444]; % RCP 4.5, E=0, OA=0
pswInputs(:, 3) = [0.025; 1.5; 0.45; 3.1435]; % RCP 8.5, E=0, OA=0
pswInputs(:, 4) = [0.025; 1.5; 0.45; 4.0278]; % RCP 4.5, E=1, OA=0
pswInputs(:, 5) = [0.025; 1.5; 0.45; 3.6944]; % RCP 8.5, E=1, OA=0
pswInputs(:, 6) = [0.025; 1.5; 0.45; 4.0046]; % RCP 4.5, E=1, OA=1
pswInputs(:, 7) = [0.025; 1.5; 0.45; 3.6713]; % RCP 8.5, E=1, OA=1

% === Target 5% ===
% No shuffling advantage
pswInputs(:, 8) = [0.025; 1.5; 0.45; 4.3426]; % RCP 2.6, E=0, OA=0
pswInputs(:, 9) = [0.025; 1.5; 0.45; 4.4745]; % RCP 4.5, E=0, OA=0
pswInputs(:, 10) = [0.025; 1.5; 0.45; 4.3519]; % RCP 6, E=0, OA=0
pswInputs(:, 11) = [0.025; 1.5; 0.45; 4.339]; % RCP 8.5, E=0, OA=0
pswInputs(:, 12) = [0.025; 1.5; 0.45; 4.6806]; % RCP 2.6, E=1, OA=0
pswInputs(:, 13) = [0.025; 1.5; 0.45; 4.8056]; % RCP 4.5, E=1, OA=0
pswInputs(:, 14) = [0.025; 1.5; 0.45; 4.6898]; % RCP 6, E=1, OA=0
pswInputs(:, 15) = [0.025; 1.5; 0.45; 4.6574]; % RCP 8.5, E=1, OA=0
% Shuffling advantage of 0.5 C
pswInputs(:, 60) = [0.025; 1.5; 0.45; 5.4259]; % RCP 2.6, E=0, OA=0
pswInputs(:, 61) = [0.025; 1.5; 0.45; 5.6111]; % RCP 4.5, E=0, OA=0
pswInputs(:, 62) = [0.025; 1.5; 0.45; 5.3009]; % RCP 6, E=0, OA=0
pswInputs(:, 63) = [0.025; 1.5; 0.45; 5.3056]; % RCP 8.5, E=0, OA=0
pswInputs(:, 64) = [0.025; 1.5; 0.45; 5.6574]; % RCP 2.6, E=1, OA=0
pswInputs(:, 65) = [0.025; 1.5; 0.45; 5.8102]; % RCP 4.5, E=1, OA=0
pswInputs(:, 66) = [0.025; 1.5; 0.45; 5.5231]; % RCP 6, E=1, OA=0
pswInputs(:, 67) = [0.025; 1.5; 0.45; 5.5231]; % RCP 8.5, E=1, OA=0



% The next 4 have a growth penalty of 0.25 rather than 0.5
% Shuffling advantage 1 C from here.
pswInputs(:, 16) = [0.025; 1.5; 0.45; 5.5324]; % RCP 2.6, E=0, OA=0
pswInputs(:, 17) = [0.025; 1.5; 0.45; 5.6667]; % RCP 4.5, E=0, OA=0
pswInputs(:, 18) = [0.025; 1.5; 0.45; 5.5417]; % RCP 6, E=0, OA=0
pswInputs(:, 19) = [0.025; 1.5; 0.45; 5.5417]; % RCP 8.5, E=0, OA=0
% Back to a penalty of 0.5
pswInputs(:, 20) = [0.025; 1.5; 0.45; 5.5509]; % RCP 2.6, E=0, OA=0
pswInputs(:, 21) = [0.025; 1.5; 0.45; 5.6713]; % RCP 4.5, E=0, OA=0
pswInputs(:, 22) = [0.025; 1.5; 0.45; 5.5417]; % RCP 6, E=0, OA=0
pswInputs(:, 23) = [0.025; 1.5; 0.45; 5.537]; % RCP 8.5, E=0, OA=0
pswInputs(:, 24) = [0.025; 1.5; 0.45; 5.8056]; % RCP 2.6, E=1, OA=0
pswInputs(:, 25) = [0.025; 1.5; 0.45; 5.8287]; % RCP 4.5, E=1, OA=0
pswInputs(:, 26) = [0.025; 1.5; 0.45; 5.7454]; % RCP 6, E=1, OA=0
pswInputs(:, 27) = [0.025; 1.5; 0.45; 5.6991]; % RCP 8.5, E=1, OA=0
% Shuffling advantage 1.5 from here.
pswInputs(:, 28) = [0.025; 1.5; 0.45; 5.3843]; % RCP 2.6, E=0, OA=0
pswInputs(:, 29) = [0.025; 1.5; 0.45; 5.3843]; % RCP 4.5, E=0, OA=0
pswInputs(:, 30) = [0.025; 1.5; 0.45; 5.3843]; % RCP 6, E=0, OA=0
pswInputs(:, 31) = [0.025; 1.5; 0.45; 5.2963]; % RCP 8.5, E=0, OA=0
pswInputs(:, 32) = [0.025; 1.5; 0.45; 5.6343]; % RCP 2.6, E=1, OA=0
pswInputs(:, 33) = [0.025; 1.5; 0.45; 5.6204]; % RCP 4.5, E=1, OA=0
pswInputs(:, 34) = [0.025; 1.5; 0.45; 5.6389]; % RCP 6, E=1, OA=0
pswInputs(:, 35) = [0.025; 1.5; 0.45; 5.4861]; % RCP 8.5, E=1, OA=0

% === Target 10% ===
% Shuffling advantage back to 0.
pswInputs(:, 36) = [0.025; 1.5; 0.45; 5.9537]; % RCP 4.5, E=0, OA=0
pswInputs(:, 37) = [0.025; 1.5; 0.45; 5.8426]; % RCP 8.5, E=0, OA=0
pswInputs(:, 38) = [0.025; 1.5; 0.45; 6.4398]; % RCP 4.5, E=1, OA=0
pswInputs(:, 39) = [0.025; 1.5; 0.45; 6.2685]; % RCP 8.5, E=1, OA=0
pswInputs(:, 40) = [0.025; 1.5; 0.45; 6.4676]; % RCP 4.5, E=1, OA=1
pswInputs(:, 41) = [0.025; 1.5; 0.45; 6.2917]; % RCP 8.5, E=1, OA=1

% Average RCP values for otherwise identical cases.  There's always
% a first case at RCP 2.6, average with the next 3.
% NOTE: this gives indexes up to 58, but don't add more consecutively because
% there is a block of entries above from 60 to 67.  If more cases appear, make a
% new loop and skip to 70 or higher.
startI = [8, 12, 16, 20, 24, 28, 32, 60, 64];
currentSet = 50;
for i = startI
    cum = 0.0;
    for j = 0:3
        cum = cum + pswInputs(4, i+j);
    end
    ppp = pswInputs(:, startI);
    pswInputs(:, currentSet) = [ppp(1), ppp(2), ppp(3), cum/4];
    currentSet = currentSet + 1;
end
% Averaged s values as of 10 Jan 2020 are:
% [4.3770,4.70835,5.570625,5.575225,5.7697,5.3623,5.594925]
% for 57 and 58 values are 5.4109 and 5.6285.



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
