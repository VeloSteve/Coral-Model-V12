%% CORAL AND SYMBIONT POPULATION DYNAMICS
% MAIN FILE TO TEST PROPORTIONALITY CONSTANTS AND VARIANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 5-3-16                                              %
% Performance and structural changes 9/2016 by Steve Ryan (jaryan)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [SST, TIME] = A_Coral_Model(parameters)
function A_Coral_Model(parameters)
timerStart = tic;

%% Input parameters are to be passed in as an object of type ParameterDictionary,
%  but also accept a JSON string directly
if nargin < 1
    parameters = 'D:\GoogleDrive\Coral_Model_Steve\GUIState_AndRunHistory\modelVars.txt';
    % Normal code - above is for debug only.
    % error('The coral model requires input parameters.  Either a ParameterDictionary object or a JSON-encoded parameters are accepted.');
end
% Get a structure of run parameters in any of several ways.
% Be sure we ALSO have a ParameterDictionary because it can be used to
% generate path names.
[ps, pd] = getInputStructure(parameters);
pd.print()

% Clear variables which I want to examine between runs, but not carry over.
clearvars bleachEvents bleachState mortState resultSimilarity Omega_factor C_yearly;

% Constants NOT controllable from the GUI or scripts are set first:
bleachingTarget = 5;    % Target used to optimize psw2 values.  3, 5 and 10 are defined as of 8/29/2017
maxReefs = 1925;        % never changes
doDormandPrince = false; % Use Prince-Dormand solver AND ours (for now)
doHughesComparison = false;
dt = 1/8; % 1/64.0;         % The fraction of a month for 2nd order R-K time steps


% New code, December 2017.  Variables were previously hardcoded in this file.
% Now they are received as inputs.  This call is admittedly ugly, but it
% does serve as a list of all variable arguments.  This is intended to
% allow A_Coral_Model to never be edited during normal use.
[dataset, RCP, E, OA, superMode, superAdvantage, superStart,...
 outputPath, sgPath, sstPath, matPath, m_mapPath, GUIBase, ...
 architecture, useThreads, everyx, specialSubset, ...
 keyReefs, skipPostProcessing, doProgressBar, doPlots, ...
 doCoralCoverMaps, doCoralCoverFigure, doGrowthRateFigure, ...
 doGenotypeFigure, doDetailedStressStats, allPDFs, ...
 saveVarianceStats, newMortYears] = explodeVariables(ps);

% XXX timeIteration expects a double for superMode - that probably should be
% changed, but for now just do a cast.
superMode = double(superMode);


%% Handle super symbiont options
[startSymFractions, superStartYear, superSeedFraction, oneShot] = ...
    setupSuperSymbionts(superMode, RCP, E, superAdvantage, superStart, maxReefs);

%% Put keyReefs in order without duplicates.  Shouldn't matter, but why not?
keyReefs = unique(keyReefs);
% A list of reefs for which to save data at maximum resolution for detailed
%  analysis or plotting.  Not in the GUI - mainly for diagnistics.
dataReefs = [];

%% Use of parallel processing on the local machine.
% no argument: uses the existing parallel pool if any.
% 0:  runs sequentially.
% > 0 tries to start the requested number of workers, failing if the value
%     is greater than the value specified in Matlab's Parallel Preferences.
fprintf('%d Threads from GUI or script\n', useThreads);
[queueMax] = parallelSetup(useThreads);
fprintf('Starting (after parallel setup) at %s\n', datestr(now));

%% Less frequently changed model parameters

initYear = '2001';  % SelV and hist will be initialized from 1861 to this year.

%% Some useful paths and text strings to be used later.
% A string for building long ugly file names that reflect the run
% parameters.
modelChoices = pd.getModelChoices();
% pdfDirectory contains the per-reef pdfs and a mat file
% mapDirectory contains maps, console output, and miscellaneous figures
pdfDirectory = strcat(pd.getDirectoryName('_figs/'));
mapDirectory = strcat(pd.getDirectoryName('_maps/'));
mkdir(pdfDirectory);
mkdir(mapDirectory);
mkdir(strcat(outputPath, 'bleaching'));

% Initialize a file for logging most of what goes to the console.
echoFile = fopen(strcat(mapDirectory, 'console.txt'), 'w+');
logTwo(echoFile); % Required first call to set output path.

% Also put a copy of the model parameters in JSON format into the maps
% directory in a separate file.  This can be used as input to duplicate this
% run.
paramFile = fopen(strcat(mapDirectory, 'modelParameters.json'), 'w+');
fprintf(paramFile, '%s', pd.getJSON());
fclose(paramFile);


%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
[SST, Reefs_latlon, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, RCP);
lenTIME = length(TIME);
assert(maxReefs == length(Reefs_latlon), 'maxReefs must match the input data');

%% LOAD Omega (aragonite saturation) values if needed

if OA == 1
    [Omega_all] = GetOmega(sgPath, RCP);
    if strcmp(RCP, 'control400')
        % Enlarge the array to match the extended control400 array
        copyLine = Omega_all(:, 2880);
        for iii = lenTIME:-1:2881
            Omega_all(:, iii) = copyLine;
        end
    end 
    % Convert omegas to growth-factor multipliers so there's
    % less logic inside the time interations.
    [Omega_factor] = omegaToFactor(Omega_all);
else
    % It is wasteful to make a big empty array, but it makes entering the
    % parallel loop simpler.  Note that only the last value is set.
    Omega_factor(maxReefs, lenTIME) = 0.0;
end
clearvars Omega_all;

%% SUB-SAMPLE REEF GRID CELLS
% Build a list of reefs for the current run.
[toDo, reefsThisRun] = ...
    reefsToDo(specialSubset, everyx, maxReefs, keyReefs, dataReefs, Reefs_latlon);
logTwo('Modeling %d reefs.\n', reefsThisRun);


%% LOAD SELECTIONAL VARIANCE (psw2)
psw2_new = 0; % Let the system know it's a variable at parse time!
load (strcat(matPath, 'Optimize_psw2.mat'),'psw2_new', 'pswInputs')
% pswInputs are not used in computations, but they are recorded to document
% each run.
% Selection of variance column from psw2_new.
if exist('optimizerMode', 'var')
    propTest = 1;
else
    propTest = getPropTest(E, RCP, bleachingTarget);
end
pswInputs = pswInputs(:, propTest); %#ok<NODEF>

%% Load growth, carrying capacity and other constants:
% Load .mat file for Coral and Symbiont genetics constants
% As of 1/3/2017 the file contains a structure rather than individual
% variables.  As of 12/17/2017 it also includes the bleachParams structure
% which defines bleaching and recovery thresholds.
load(strcat(matPath, 'Coral_Sym_constants_4.mat'), 'bleachParams', 'coralSymConstants');
bleachParams = bleachParams;  %#ok<ASGSL,NODEF> % Trick so parallel workers see the loaded variable.
assert(length(startSymFractions) == coralSymConstants.Sn, ...
    'Symbiont start fractions should match number of symbionts.'); %#ok<NODEF>

% Define the seed values below which populations are not allowed to drop.
% 1% of K for massive and 0.1% for branching corals.
% The values are 741,250 and 102,500 square cm of coral per 625 square m of reef.
C_seed = [coralSymConstants.KCm*0.01 coralSymConstants.KCb*0.001];

% 10^-5 % of seed, based on having corals at their seed levels as well.
% The values are 222,375 and 41,000 cells per 625 square meters of reef.
msSeed = 10^-7 * coralSymConstants.KSm * C_seed(1);
bsSeed = 10^-7 * coralSymConstants.KSb * C_seed(2);
S_seed = [msSeed bsSeed msSeed bsSeed];


% Mutational Variance w (E=1) and w/o Evolution (E=0)
if E==0
    vM = 0;     % Mutational variance (degC^2/yr) (convert to months/12)
else
    % Mutational variance (degC^2/yr) (convert to months/12)
    vM = coralSymConstants.ve*.001/12;
end 
MutV  = [vM vM];               % Mutational variance matrix for symbiont calcs
MutVx = repmat(MutV,1,coralSymConstants.Sn);     % Mutational variance matrix for coral calcs
% January 2016, more variables need replication when Sn > 1
coralSymConstants.EnvVx = repmat(coralSymConstants.EnvV,1,coralSymConstants.Sn);     % Environmental variance matrix
coralSymConstants.KSx = repmat(coralSymConstants.KS,1,coralSymConstants.Sn);     % Environmental variance matrix

%% Set up indexing and time arrays before entering the main loop.
months = length(TIME);

assert(mod(months, 12) == 0, 'Calculations assume a time span of whole years.');
years = months/12;
stepsPerYear = 12/dt;
% All years in this run:
fullYearRange = [startYear startYear+years-1];

time = interp(TIME,1/dt,1,0.0001)'; % Interpolate time so there's a point for every Runge-Kutta time step.
% Set index for mean historical Temp between 1861-2000 (ESM2M_historical; yrs
% used in Baskett et al 2009) Note: original code had a different end point for
% SST dataset ESM2M vs. HadISST. TODO: figure out whether this index max sense
% for runs with Dormand-Prince, which doesn't have fixed step sizes.
% The clear makes sure a persistent variable inside the function isn't left from
% a previous run, which may have a different step size.  Only needed on the
% first call in a given run.
clear findDateIndex;
initIndex = findDateIndex(strcat('30-Dec-', initYear), strcat('31-Dec-', initYear), time);

% Convert years for symbiont activation to indexes in the time array for
% quicker use later.   superStartYear units are years.
neverIndex = length(time) + 1;
for i = length(superStartYear):-1:1
    ssY = superStartYear(i);
    % Introduce in summer, with a simple flip at the equator.  Remember that
    % latlon contains lon, then lat.
    if Reefs_latlon(i, 2) < 0
        mon = '-Feb-';
    else
        mon = '-Aug-';
    end
    % equivalent to the original approach:
    %mon = '-Jan-';
    if ssY > fullYearRange(2)
        superStartIndex(i) = neverIndex;
    else
        superStartIndex(i) = findDateIndex(strcat('14', mon, num2str(ssY)), strcat('16', mon, num2str(ssY)), time);
    end
end

% max so it's always a valid index, BUT note that superStartIndex
% can be zero when a super symbiont is never needed!
superStartIndexM10 = max(1, superStartIndex - 10*stepsPerYear);

% Same for the SST and TIME arrays, but they are coarser, with dates at the
% 15th of each month.
initSSTIndex = findDateIndex(strcat('14-Dec-', initYear), strcat('16-Dec-',initYear), TIME);
timeSteps = length(time) - 1;      % number of time steps to calculate

% This should cause the "parfor" to run as serial code when plotting
% more than one reef per plot.  The single-reef plot options work fine in
% parallel.  Note that this does NOT remove the overhead of copying arrays
% for the parallel code.
% Also override queueMax so the arrays are handled correctly.

%% Split up reefs into batches for parallel computation.  With one core
%  specified, it simply uses one batch.
[parSwitch, queueMax, chunkSize, toDoPart] = parallelInit(queueMax, toDo);

% Several arrays are built in the parallel loop and then used for
% later analysis.  Parfor doesn't like indexing into part of an array.  The
% trick is to make a local array for each iteration inside the parfor, and
% then assemble them into the desired shape afterwards.  Note: all the "false(1,1)"
% entries are there because the parfor needs to have the "empty" output
% arrays defined before the loop.  Instead of creating the contents at full
% size and passing big arrays of nan to the workers, it make more sense to
% pass these dummy arrays and allocate the required memory in each worker.
for i = queueMax:-1:1
    kOffset(i) = min(toDoPart{i}); % Number of first reef in these chunks.
    % Inputs
    iStart = min(toDoPart{i});
    iEnd = max(toDoPart{i});
    LatLon_chunk{i} = Reefs_latlon(iStart:iEnd,1:2);
    SST_chunk{i} = SST(iStart:iEnd, :);
    Omega_chunk{i} = Omega_factor(iStart:iEnd, :);
    suppressSI_chunk{i} = superStartIndex(iStart:iEnd);
    suppressSIM10_chunk{i} = superStartIndexM10(iStart:iEnd);
    superStart_chunk{i} = superStartYear(iStart:iEnd);

    % Outputs
    bleachEvents_chunk{i} = false(1,1);
    bleachState_chunk{i} = false(1,1);
    mortState_chunk{i} = false(1,1);

    C_cum_chunk{i} = zeros(length(time), coralSymConstants.Sn*coralSymConstants.Cn); % Sum coral cover for all reefs.
    % 3D array sized (time by reef by coral type).  Note that we don't care
    % about the identity of the reefs in this case, so we just need enough
    % columns for all reefs actually calculated, ignoring those which are
    % skipped.
    C_year_chunk{i} = zeros(years, chunkSize, coralSymConstants.Cn); % Coral cover for all reefs, but just 2 columns.
    Massive_dom_chunk{i} = zeros(length(time), 1);

end

%% RUN EVOLUTIONARY MODEL
% Get the correct compiled solver for this case.
iteratorHandle = selectIteratorFunction(length(time), architecture);
% the last argument in the parfor specifies the maximum number of workers.
timerStartParfor = tic;
parfor (parSet = 1:queueMax, parSwitch)
%for parSet = 1:queueMax
    %  pause(1); % Without this pause, the fprintf doesn't display immediately.
    %  fprintf('In parfor set %d\n', parSet);
    reefCount = 0;
    % How often to print progress.
    %printFreq = max(10, ceil(length(toDoPart{parSet})/4)); % The last digit is the number of pieces to report.
    % More often for progress bar
    if doProgressBar
        printFreq = max(2, ceil(length(toDoPart{parSet})/20)); % The last number is the number of pieces to report.
    else
        printFreq = max(10, ceil(length(toDoPart{parSet})/4)); % The last number is the number of pieces to report.
    end

    % Variables to collect and return, since parfor won't allow direct
    % insertion into an output array.
    % TODO see if length(toDoPart(parSet)) should be used instead of
    % chunkSize.
    par_bleachEvents = false(length(toDoPart(parSet)), years, coralSymConstants.Cn); %#ok<PFBNS>
    par_bleachState = par_bleachEvents;
    par_mortState = par_bleachEvents;
    par_SST = SST_chunk{parSet};
    par_Omega = Omega_chunk{parSet};
    par_LatLon = LatLon_chunk{parSet};
    par_SupressSI = suppressSI_chunk{parSet};
    par_SupressSIM10 = suppressSIM10_chunk{parSet};
    par_superStart = superStart_chunk{parSet};
    par_kOffset = kOffset(parSet);
    par_C_cum = C_cum_chunk{parSet};
    par_C_year = C_year_chunk{parSet};
    par_Massive_dom = Massive_dom_chunk{parSet};
    par_HistSuperSum = 0.0;
    par_HistOrigSum = 0.0;
    par_HistOrigEvolvedSum = 0.0;
    for k = toDoPart{parSet}
        reefCount = reefCount + 1;
        kChunk = 1 + k - par_kOffset;
        SST_LOC = par_SST(kChunk, :);                     % Reef grid cell location
        SSThist = SST_LOC';                      % Transpose SST matrix
        Omega_hist = par_Omega(kChunk, :);
        psw2 = psw2_new(k, propTest) ;         % UPDATED** max(0.3,min(1.3,(mean(exp(0.063.*SSThist))./var(exp(0.063.*SSThist))).^0.5/7)); % John's new eqn 8/10/16** try this
        reefLatlon = par_LatLon(kChunk, :);
        suppressSI = par_SupressSI(kChunk);
        suppressSIM10 = par_SupressSIM10(kChunk);
        superStart = par_superStart(kChunk);
        lat = num2str(round(reefLatlon(2)));
        lon = num2str(round(reefLatlon(1)));

        % Interpolate data and create time stamp
        %% Set timestep and interpolate temperature, omega, and time stamp
        temp = interp(SSThist,1/dt); % Resample temp 4X times higher rate using lowpass interpolation
        omega = interp(Omega_hist, 1/dt);
        % new vector is 4x length of orginal


        %% Make Histogram of psw2 and map of var(SSThist)
        % hist_prop_fig     % run sub m-file to make map & histogram

        % Use a limited range of SSTHist for selectional variance, so
        % that we don't include modern climate change.
        SelV = [1.25 1]*psw2*var(SSThist(1:initSSTIndex));
        SelVx = repmat(SelV,1,coralSymConstants.Sn);     % Selectional variance matrix for coral calcs
        %SelV = [1.25 1]*psw2*var(SSThist_anom(:))

        % Initialize symbiont genotype, sym/coral population sizes, carrying capacity

        %ssss = findDateIndex(strcat('14-Jan-', num2str(par_SuppressYears(kChunk)-10)), strcat('16-Jan-',num2str(par_SuppressYears(kChunk)-10)), time);
        %eeee = findDateIndex(strcat('14-Dec-', num2str(par_SuppressYears(kChunk))), strcat('16-Dec-',num2str(par_SuppressYears(kChunk))), time);

        [vgi, gi, S, C, hist] = Init_genotype_popsize(time, initIndex, temp, coralSymConstants, ...
            E, vM, SelV, superMode, superAdvantage, startSymFractions, ...
            [suppressSI suppressSIM10]);

       

        %fprintf('super will start at index %d\n', suppressSI);
        %% MAIN LOOP: Integrate Equations 1-5 through 2100 using Runge-Kutta method
        
        % First run the built-in Prince-Dormand solver.  For now, compare
        % and discard the results so the existing results are not affected.
        if doDormandPrince
            % Compute outside the loop once this is working, but for
            % now make a time array in month units each time.
            % The preserve the uneven spacing of SST values, compute tMonths
            % from TIME, recognizing that the first time of the simulation is
            % the beginning of January 1861, but the first SST value corresponds
            % to 1/15/1861.
            tMonths = TIME - TIME(1);  % shift to zero
            % span of TIME is the number of simulated months minus one, since
            % min-month values are stored.  Add 0.5 so the interpolation matches
            % the inputs.
            
            tMonths = 0.5 + (tMonths * (length(TIME)-1) / (TIME(end) - TIME(1)));
            % Convert supersymbiont start year to months, since that's the 
            % unit used inside.
            if superStart < fullYearRange(2)
                superMonth = (superStart - fullYearRange(1))*12;
            else
                superMonth = -1;
            end
            tic
            % TODO - the fineness of the interpolated variables temp, gVec
            % and ri (and omega) may be affecting the results of Dormand Prince.  This
            % was observed when changing dt values for the OTHER algorithm!
            % The interpolation done above is
            % temp = interp(SSThist,1/dt); % Resample temp 4X times higher rate using lowpass interpolation
            % While inside the function we get values from
            % T = interp1q(tMonths, temp, t);
            % XXX Remove after looking at graphs! - arbitrarily use 100 to
            % 110 months.
            %{
            figure(451); hold off;
            % plot uninterpolated temp
            mOne = linspace(0, months, length(SSThist));
            plot(mOne, SSThist, 'o', 'DisplayName', 'Monthly'); hold on;
                            xlim([100 200]);

            % now add the values passed in below
            plot(tMonths, temp, '+', 'DisplayName', 'Four per month');
                            xlim([100 200]);

            % interpolate as currently coded to hundredths of months and plot
            testMonths = 100:0.01:200;
            testMonths = testMonths';
            iT1q = interp1q(tMonths, temp, testMonths); % "quick 1D linear interpolation (not recommended)
            plot(testMonths, iT1q, '*', 'DisplayName', 'interp 1q');
                            xlim([100 200]);

            % use interp1, which supports a spline function (and
            % others)
            iT1 = interp1(tMonths, temp, testMonths, 'spline');
            plot(testMonths, iT1, '.', 'DisplayName', 'interp1 from Four/month');
                            xlim([100 200]);

            % use interp1 direct from single months
            iT2 = interp1(mOne, SSThist, testMonths, 'spline');
            plot(testMonths, iT2, '.', 'DisplayName', 'interp1 from monthly');
                            xlim([100 200]);

            legend('show')
            hold off;
            %}

            [S, C, tResults, gi, vgi, origEvolved] = tryDormandPrince(months, S(1,:) , C(1,:), tMonths, ...
                SSThist, OA, Omega_hist, vgi(1, :), gi(1, :), MutVx, SelVx, C_seed, S_seed, superMonth, ...
                superSeedFraction, oneShot, coralSymConstants, dt, k); 
            fprintf('Reef %d ', k);
            toc
 
            tSteps = tResults(2:end) - tResults(1:end-1);
            tSteps = tSteps(tSteps ~= 0);
            fprintf('DP steps range from %d to %d (%d steps)\n', min(tSteps), max(tSteps), length(tSteps));
            % Now convert tResults to MATLAB's "serial date number" for consistency with the code
            % below.  tResults is in months from the start of the simulation,
            % and temperatures are provided based on the 15th of each month
            % (uneven number of days).
            % TIME is the original unevenly-spaced "15th of month" times at which we have temperatures.
            % tMonths are the evenly spaced months used to interpolate those temperatures in D-P.

            tResults = interp1(tMonths, TIME, tResults, 'linear', 'extrap');     
            % Reef 337 goes to a near-zero step size at 11-Aug-2038 07:12:00 !
            % Is coral going negative at about 744500?
            
            % Interpolate to fixed time steps for easy post-processing.
            % Would it be worth joining these arrays so that only one
            % interpolation is needed?
            C = interp1(tResults, C, time, 'pchip');
            S = interp1(tResults, S, time, 'pchip');
            gi = interp1(tMonths, gi, time, 'pchip');
            vgi = interp1(tMonths, vgi, time, 'pchip');

        else
        % timeIteration is called here, with the version determined by
        % iteratorHandle.

            [S, C, gi, vgi, origEvolved] = iteratorHandle(timeSteps, S, C, dt, ...
                        temp, OA, omega, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSI, ...
                        superSeedFraction, superMode, superAdvantage, oneShot, coralSymConstants);
            tResults = time;  % Dormand-Prince creates its own time steps, R-K uses time.
        end
        %Plot_ArbitraryYvsYears(ri(:,2), tResults, strcat('Temperature Effect on Branching Growth, k = ', num2str(k)), 'Growth rate factor')
                    
        % These, with origEvolved, compare the average native and
        % supersymbiont genotypes with the evolved state of the native
        % symbionts just before the supersymbionts are introduced.
        origHist = gi(1,1);
        superHist = gi(1,3);

        par_HistSuperSum = par_HistSuperSum + superHist;
        par_HistOrigSum = par_HistOrigSum + origHist;
        par_HistOrigEvolvedSum = par_HistOrigEvolvedSum + origEvolved;

        if any(dataReefs == k) % Save detailed history
            matName = strcat('DetailedSC_Reef', num2str(k), '_', modelChoices, '.mat');
            saveAsMat(strcat(mapDirectory, matName), C, S, time, temp);
        end
        if doPlots && (doGrowthRateFigure || doGenotypeFigure) && any(keyReefs == k)  % temporary genotype diagnostic
            suff = '';
            if superMode && superMode ~= 5
                suff = sprintf('_%s_E%d_SymStrategy%d_Reef%d', RCP, E, superMode, k);
            elseif superMode == 0 || superMode == 5
                suff = sprintf('_%s_E%d_SymStrategy%dAdv%0.2fC_Reef%d', RCP, E, superMode, superAdvantage, k);
            end
            if doGenotypeFigure
                genotypeFigure(mapDirectory, suff, k, time, gi, suppressSI);
            end
            if doGrowthRateFigure
                % Growth rate vs. T as well
                % TODO: dies when suppressSI = 0
                if strcmp(RCP(1:3), 'rcp')
                    growthRateFigure(mapDirectory, suff, datestr(time(suppressSI), 'yyyy'), ...
                        k, temp, fullYearRange, gi, vgi, suppressSI, ...
                        coralSymConstants, SelVx, RCP);         
                end
            end
        end


        par_C_cum = par_C_cum + C; % interp1(tResults, C, TIME, 'pchip');
        par_Massive_dom = par_Massive_dom + C(:, 1) > C(:, 2);
        % Time and memory will be consumed, but we need stats on coral
        % cover.
        par_C_year(:, reefCount, 1) =  decimate(C(:, 1), stepsPerYear, 'fir');
        par_C_year(:, reefCount, 2) =  decimate(C(:, 2), stepsPerYear, 'fir');
        
        %% New clean stats section
        
        [ C_monthly, S_monthly, ~, bleachEventOneReef, bleachStateOne, mortStateOne ] = ...
            Clean_Bleach_Stats(C, S, C_seed, S_seed, dt, TIME, bleachParams, coralSymConstants);
     
        if doPlots && (any(keyReefs == k) || allPDFs)
            % Now that we have new stats, reproduce the per-reef plots.
            Plot_One_Reef(C_monthly, S_monthly, bleachEventOneReef, psw2, time, temp, lat, lon, RCP, ...
                  hist, dataset, sgPath, k, ...
                  pdfDirectory, E, lenTIME);
        end

        if ~isempty(bleachEventOneReef)
            % bleachEventOneReef is returned as a sparse array which is
            % great for plotting and saving space.  Unfortunately, sparse
            % arrays are limited to 2D, so here it gets expanded.  It could
            % be better to return a set or list of sparse arrays, but this
            % is much clearer.
            par_bleachEvents(reefCount, :, :) = full(bleachEventOneReef);
        end
        % Like bleachEventOneReef, but the bleaching and mortality states
        % are never empty.  Also, these aren't stored as sparse since they
        % can have long sequences of "true".
        par_bleachState(reefCount, :, :) = bleachStateOne;
        par_mortState(reefCount, :, :) = mortStateOne;

        if parSwitch && mod(reefCount, printFreq) == 0
            pct = (100*reefCount/length(toDoPart{parSet}));
            if  doProgressBar
                pf = fopen(strcat(GUIBase, '/Prog_', num2str(parSet)), 'w');
                fprintf(pf, '%d', round(pct));
                fclose(pf);
            else
                fprintf('Set %d is %3.0f percent complete.\n', parSet, pct);
            end
        end

    end % End of reef areas for one parallel chunk
    % Progress is now 100% for this chunk.
    if  doProgressBar
        pf = fopen(strcat(GUIBase, '/Prog_', num2str(parSet)), 'w');
        fprintf(pf, '%d', 100);
        fclose(pf);
    end
    % Collect per-worker parts back into the _chunk arrays.
    bleachEvents_chunk{parSet} = par_bleachEvents;
    bleachState_chunk{parSet} = par_bleachState;
    mortState_chunk{parSet} = par_mortState;
    C_cum_chunk{parSet} = par_C_cum;
    C_year_chunk{parSet} = par_C_year(:, 1:reefCount, :);
    Massive_dom_chunk{parSet} = par_Massive_dom;
    histSuper_chunk(parSet) = par_HistSuperSum;
    histOrig_chunk(parSet) = par_HistOrigSum;
    histOrigEvolved_chunk(parSet) = par_HistOrigEvolvedSum;


end % End of parfor loop
elapsedParfor = toc(timerStartParfor);

% Clear variables used only as inputs inside the loop.
clearvars SST_chunk Omega_chunk LatLon_chunk;

% Build these variables from the chunks.
% bleachEvents_chunk contains a chunk per worker.  Each worker's chunk
% contains a 3D array where the first index is the sequential number of the
% reef in that to-do chunk.  Here we build a full 3D array for all possible
% reefs, sized (reefs, years, coral types).
% old way: bleachEvents = horzcat(bleachEvents_chunk{:});
bleachEvents = false(maxReefs, years, coralSymConstants.Cn);
bleachState = false(maxReefs, years, coralSymConstants.Cn);
mortState = false(maxReefs, years, coralSymConstants.Cn);
for i = 1:queueMax
    tdp = toDoPart{i}';
    chunkE = bleachEvents_chunk{i};
    chunkB = bleachState_chunk{i};
    chunkM = mortState_chunk{i};
    assert(size(chunkE, 1) == length(tdp), 'Number of bleach event results must match list of reef numbers.');
    assert(size(chunkB, 1) == length(tdp), 'Number of bleach state results must match list of reef numbers.');
    assert(size(chunkM, 1) == length(tdp), 'Number of mortality state results must match list of reef numbers.');
    for chunkIndex = 1:size(chunkE, 1)
        k = toDoPart{i}(chunkIndex);
        bleachEvents(k, :, :) = chunkE(chunkIndex, :, :);
        bleachState(k, :, :) = chunkB(chunkIndex, :, :);
        mortState(k, :, :) = chunkM(chunkIndex, :, :);
    end
end
clearvars bleachEvents_chunk bleachState_chunk mortState_chunk; % release some memory.

C_yearly = horzcat(C_year_chunk{:});
% Total coral cover across all reefs, for ploting shift of dominance.
% C_cumulative = zeros(length(time), coralSymConstants.Sn*coralSymConstants.Cn);
% Massive_dom_cumulative = zeros(length(time), 1);
superSum = 0.0;
histSum = 0.0;
histEvSum = 0.0;
for i = 1:queueMax
    % C_cumulative = C_cumulative + C_cum_chunk{i};
    % Massive_dom_cumulative = Massive_dom_cumulative + Massive_dom_chunk{i};
    superSum = superSum + histSuper_chunk(i);
    histSum = histSum + histOrig_chunk(i);
    histEvSum = histEvSum + histOrigEvolved_chunk(i);
end
clearvars C_cum_chunk C_year_chunk Massive_dom_chunk histSuper_chunk histOrig_chunk histOrigEvolved_chunk;
superSum = superSum/reefsThisRun;
histSum = histSum/reefsThisRun;
histEvSum = histEvSum/reefsThisRun;
logTwo('Super symbiont genotype = %5.2f C.  Base genotype %5.2f C (advantage %5.2f), Evolved base %5.2f (advantage %5.2f).\n', ...
    superSum, histSum, (superSum-histSum), histEvSum, (superSum-histEvSum));



if ~skipPostProcessing

    % Count bleaching events between 1985 and 2010 inclusive.
    i1985 = 1985 - startYear + 1;
    i2010 = 2010 - startYear + 1;
    % Count by reef
    for k = maxReefs:-1:1
        events85_2010(k) = nnz(bleachEvents(k, i1985:i2010, :));
        eventsAllYears(k) = nnz(bleachEvents(k, :, :));
    end
    % Count for all reefs over this time period.
    count852010 = sum(events85_2010);
    
    if doHughesComparison
        %{
        Number of reefs in each region:
         Hughes  Logan
         AuA   32      906
         IO-ME 24      310
         Pac   22      480
         WAtl  22      199
         Far           30
        %}
        % Now go back and get a running cumulative count of bleaching events for all
        % reefs by year.
        for y = size(bleachEvents, 2):-1:1
            % Note: this combines branching and massive bleaching events.  When we
            % have these in consecutive years it may look like two events where
            % another study would call it one.
            cumBleachEvents(y) = nnz(bleachEvents(:, y, :));
        end
        cumBleachEvents = cumsum(cumBleachEvents);
    
        % XXX - the line below is only valid when matched to the keyReefs!!!
        %cumBleachEvents = cumBleachEvents*32.0/906.0;  % 32/906 for Au
        
        hughesPlot(cumBleachEvents, startYear, 'Bleaching events, m+b, Au, matched reefs');
    end
    
    Bleaching_85_10_By_Event = 100*count852010/reefsThisRun/(2010-1985+1);
    fprintf('Bleaching by event = %6.4f\n', ...
        Bleaching_85_10_By_Event);

    % Build an array with the last year each reef is alive. First add a
    % column to mortState which is true when all coral types are dead.
    % Also find the last bleaching event here.
    fullReef = coralSymConstants.Cn + 1;
    lastYearAlive = nan(maxReefs, 1);
    lastBleachEvent = nan(maxReefs, fullReef);
    for k = 1:maxReefs
        for i = 1:years
            % XXX If one type is dead and the other is bleached, we don't mark
            % either state for the reef.  It should probably be considered
            % bleached.
            mortState(k, i, fullReef) = all(mortState(k, i, 1:fullReef-1));
            bleachState(k, i, fullReef) = all(bleachState(k, i, 1:fullReef-1));
            % Now find the last year alive - leave NaN if it ends alive.
        end
        if mortState(k, years, fullReef)
            ind = find(~mortState(k, :, fullReef), 1, 'last');
            assert(~isempty(ind), 'Reef %d should never start out dead.', k);
            lastYearAlive(k) = ind(1) + startYear - 1;
        end
        for rr = 1:fullReef
            if bleachState(k, years, rr)
                ind = find(~bleachState(k, :, rr), 1, 'last');
                assert(~isempty(ind), 'Reef %d coral type %d should never start out bleached.', k, rr);
                lastBleachEvent(k, rr) = ind(1) + startYear - 1;
            end
        end
    end
    frequentBleaching = defineFrequentBleaching(bleachEvents);
    
    if saveVarianceStats
        assert(length(toDo) == maxReefs, 'Only save variance data when running all reefs!');
        % Save selectional variance and last year of cover for binned plotting
        % by case.  Note that these numbers are computed inside the parallel
        % loop, but it's easier to recompute them here than to build and
        % extract arrays from the parallel code.
        selVariance(maxReefs) = 0;
        tVariance(maxReefs) = 0;
        for k = 1:maxReefs
            SSThist = SST(k, :);
            tVariance(k) = var(SSThist(1:initSSTIndex));
            selVariance(k) = psw2_new(k)*tVariance(k);
        end
        save(strcat(basePath, 'LastYear', '_selV_', RCP, 'E=', num2str(E), ...
            'OA=', num2str(OA), '.mat'), ...
            'psw2_new', 'selVariance', 'tVariance', 'lastYearAlive', 'RCP', 'OA', 'E');
    end

    format shortg;
    % Don't save all this data if we're just optimizing.
    if doPlots
        % Save parameters which created this run.  Note that ps (the
        % parameter structure) makes most of the others redundant, but
        % those are small so leave them for easy reference.
        fname = strcat(pdfDirectory, modelChoices, '.mat');
        save(fname, 'toDo', ...
            'E','OA','pdfDirectory','dataset', ...
            'Reefs_latlon','everyx','RCP','reefsThisRun', 'ps');

        if doCoralCoverMaps
            addpath(m_mapPath);
            MapsCoralCoverClean(mapDirectory, Reefs_latlon, toDo, lastYearAlive, ...
                events85_2010, eventsAllYears, frequentBleaching, ...
                mortState, bleachState, ...
                fullYearRange, ...
                modelChoices);
        end
        if doCoralCoverFigure
            coralCoverFigure(C_yearly, coralSymConstants, startYear, years, RCP, E, OA, superMode, ...
                    superAdvantage, mapDirectory)
        end
    end
    % Note that percentMortality is not used in normal runs, but it is
    % examined by the optimizer when it is used.
    oMode = exist('optimizerMode', 'var') && optimizerMode;  % must exist for function call.
    Stats_Tables(bleachState, mortState, lastYearAlive, ...
       lastBleachEvent, frequentBleaching, toDo, Reefs_latlon, outputPath, startYear, RCP, E, OA, ...
        bleachParams, doDetailedStressStats, oMode);
    
    % New 3/7/2018: output cover in 2100.
    coralCover2100(C_yearly, coralSymConstants, startYear);


    % Get the years when reefs first experienced lasting mortality and 
    % bleaching.  This isn't wanted in every run, and certainly not when 
    % super symbionts are introduced in a variable way.
    if superMode == 0 && newMortYears
        if everyx ~= 1
            disp('WARNING: saving mortality and bleaching should only be done when all reefs are computed.');
        end
        saveMortYears(mortState, startYear, RCP, E, OA, mapDirectory, ...
            modelChoices, Reefs_latlon, bleachState, maxReefs);
    end

    logTwo('Bleaching by event = %6.4f\n', Bleaching_85_10_By_Event);
end % End postprocessing block.

elapsed = toc(timerStart);
logTwo('Parallel section: %7.1f seconds.\n', elapsedParfor);
logTwo('Serial sections:  %7.1f seconds.\n', elapsed-elapsedParfor);
logTwo('Finished in       %7.1f seconds.\n', elapsed);
logTwo('Finished at %s\n', datestr(now));
fclose(echoFile);

%% After each run, update an excel file with descriptive information.
% 1) There seems to be no easy way to know the number of rows in the file, so
% it must be read each time.  This takes almost 1.5 seconds, even on a
% small file, so it would be best to rename the file occasionally and start
% over with a small current file.
% 2) Much of the code below is there to handle what happens when the file
% is open in Excel.  Writing is block, so user is prompted to skip the
% write or close Excel and retry.  This probably applies to any application
% using the file, not just Excel.
if (~exist('optimizerMode', 'var') || optimizerMode == false) && ...
    (~skipPostProcessing)

    saveExcelHistory(outputPath, now, RCP, E, everyx, queueMax, elapsed, ...
        Bleaching_85_10_By_Event, bleachParams, pswInputs);
end
%% Cleanup
fclose('all'); % Just in case some file was left open.
% Not needed in function form: clearvars SST Omega_factor

end % End the coral model main function

