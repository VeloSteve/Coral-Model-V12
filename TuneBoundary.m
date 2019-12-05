%% Find the values s and y used in the equation
%
% prop constant = (1/s) * (mean(E)/var(E))^y
% where E is shorthand for e^(bT).  b is a constant from Eppley 1972,
% and T is the monthly temperature history for each reef.
%
% to give the required average bleaching quantity.  This method finds a local
% optimum.  The bounds suggested below keep the solution away from some
% undesirable local optima which were discovered in early manual testing.
% However, much of this is still a manual process.  This script simply automates
% the finding of a single local optimum.  Additional runs will be required for
% each climate scenario and after major changes to the model which affect
% bleaching results.

%% Approach
% At each iteration, the coral model is run with a different array of psw2
% values, which have an effect on bleaching sensivity.  Each run returns a
% number which is the percentage of bleaching events observed relative to the 
% number of reef-years between 1985 and 2010. 
% A MATLAB optimization minimizes a "goodness" function based mainly on the
% difference between the bleaching value and a user-selected target value. To
% do this it varies one or two input parameters (s and y above) and repeats the
% runs until some tolerance requirements are met.
% Note that the optimization is not perfect.  The bleaching value involves
% division of one integer by another, so the output function is not quite
% smooth.  Slight differences in the initial condition give different results
% for s and y, but the differences are small enough that the bleaching value
% is typically within 0.01% of target regardless of path.

%% INSTRUCTIONS
% Setup
% 1) Make a copy of ./mat_files/Optimize_psw2.mat so that changes can be
%    reverted if this process fails.
% 2) Set basePath to the main model location, where this will be run.
% 3) If not already in place, download fminsearchbnd from the MATLAB repository
%    and place it in ./FMINSEARCHBND
% 4) Set targetBleaching if you want some value other than the default 5%.
%
% Finding the exponent, y.
% We prefer to find a single value of y to use in all runs, so that only the
% divisor s varies.  You may choose to keep both of these variable.
% 1) Use the default of 0.46, or follow these steps.
% 2) Set lowerBd(1) to 0.3, or any positive value you believe is below the
%    optimum.
% 3) Similarly set upperBd(1) to 0.7 or a value of your choice.
% 4) Leave lowerBd(2) and upperBd(2) at the defaults of 3 adn 6.
% 5) Check that x0 values are between lowerBd and upperBd.
% 6) Choose an RCP case and whether to include evolution by setting RCP and E.
% 7) Run this program, which will run the model on the order of 100 times, so
%    expect to wait.  A graph will appear to show progress.  A final goodness
%    value between 2.2 and 3.0 is typical.
% 8) Record the best y and s values found, from an output line like:
%    Best value y = 0.460000, s = 5.434000 for RCP = rcp45, E = 1
% 9) Check that the bleaching found is close to your target and that the 
%    "goodness" value is below 3.
% 10) Repeat steps 6 to 9 for all RCP and E combinations of interest to you,
%     typically all 8 combinations.
% 11) If you want to use a variable y value, the optimization is done, and
%     you can move to to "applying the new values".
% 12) For a single y value, simply average the values from all runs and round
%     to a convenient level.  Precision is not required because you are about
%     to repeat the optimization to get new "s" values.
%
% Finding the divisor, s.
% 1) If you have chosen a single new y value, follow these steps.
% 2) Set all of x0(1), lowerBd(1), and upperBd(1) to your y value.
% 3) Repeat all of the optimizations.  This will be faster because you
%    are optimizing a single variable rather than two.  Each optimization
%    typically requires around 10 to 25 model runs.
% 4) Record the s values, checking bleaching and goodness results as above.
%
% Applying the new values
% 1) Look in propConstantFunction for lines of the form 
%      pswInputs(:,28) = [0.36; 1.5; 0.46; 6.9778];  % RCP 2.6, E=0
%    The number "28" in the example is the one I will refer to as the line
%    number.
% 2) Optionally, delete any you won't be using.  Do not use or delete
%    number 1, which is changed during optimization.
% 3) Create a line for each RCP and E combination you have results for.
%    The values are [minimum psw2, maximum psw2, exponent, divisor], so
%    insert your s values as the divisor and y values as the exponent.
% 4) Run propConstantFunction, which will leave an updated version of
%    Optimize_psw2.mat in place.  The easiest way to run the function is to 
%    start one more optimization process.  The first run will create the new
%    file, and since line 1 is never used during actual simulations it doesn't
%    matter what parameters are used.
% 5) Now you will tell the model which set of new values to use for each case.
%    edit getPropTest.m, which is mostly a set of nested switch statements.
%    Run "help switch" on the MATLAB command line, if that is unfamiliar.
% 6) Find the bleaching target, E, and RCP case for each of your new values and
%    set the propTest value to the line number you used above.
% 7) The model will now use the new values.
%%

basePath = 'D:/GitHub/Coral-Model-V12/';
addpath('./FMINSEARCHBND');

targetBleaching = 5; % percent

% Starting point and limits, all three in the order y, s (exponent, divisor)
%x0 = [0.46, 5];   % starting value
x0 = [0.46, 5.434];   % starting value
lowerBd = [0.46, 3]; % minimum value
upperBd = [0.46, 6]; % maximum value

% Model parameters
RCP = 'rcp45';
E = true;

%% 
tuneStart = tic;

xOpt = bleachingTest(RCP, E, x0, lowerBd, upperBd, targetBleaching, basePath);

tuneElapsed = toc(tuneStart);
fprintf('Tuning finished in %7.1f seconds.\n', tuneElapsed); 

% bleachingTest is a wrapper to ensure that non-variable parameters are available
% to the function which is called with only the variables by fminsearch.
function [x] = bleachingTest(RCP, E, x0, lowerBd, upperBd, target, basePath)
    % Constants for the propConstant calculation
    pMin = 0.36;
    pMax = 1.5;
    % Set up the model input to run with the current RCP value and in 
    % optimizer mode.  optimizerMode causes the model to use only the
    % psw2 values specified by the optimization process, and suppresses
    % most output.
    [~, pd] = getInputStructure('.\modelVars.txt');
    pd.set('RCP', RCP);
    pd.set('E', E);
    pd.set('optimizerMode', true);
    pd.print()
   
    % See the help for fminsearch for option definitions.  Note that we are
    % optimzing a function which is not quite smooth, since it includes an
    % integer count of the number of bleached reefs in a certain time period.
    options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-3,'TolX',1e-4);

    x = fminsearchbnd(@bleachingRun, x0, lowerBd, upperBd, options);
    fprintf('Best value y = %f, s = %f for RCP = %s, E = %d\n', x(1), x(2), RCP, E);

    
    function [goodness] = bleachingRun(x0)
        % The script propConstantCalcsForOptimizer takes the given inputs and
        % updates the psw2 values used
        % when the coral model runs.  It expects to find this vector:
        propInputValues = [pMin, pMax, x0(1), x0(2)]; %#ok<NASGU>  Used in script below.
        psw2_new = propConstantFunction(RCP, propInputValues, basePath);

        % Run the model for all reefs
        [Bleaching_85_10_By_Event, ~] = aCoralModel(pd);


        [goodness, ~] = goodnessValue(target, psw2_new, Bleaching_85_10_By_Event);
        fprintf('Returning goodness = %f for params %f, %f \n', goodness, x0(1), x0(2));
    end
end

function [goodness, bleach] = goodnessValue(targetBleaching, psw2_new, b8510)
    % Optimize for the minimum difference between bleaching value and target,
    % but also bias toward prop constant values close to those in Baskett et al.
    % 2009.
    % That paper gives values of
    % "0.9 for Moorea and Curac¸ao; 0.8 for St. John, U.S. Virgin Islands;
    % 0.7 for all Australian sites; and 1.3 for Ko Phuket, Thailand."
    
    % The weightings of all of these factors were determined by trial and error
    % during early manual tuning efforts.  From now, don't change them without
    % a reason.  I better option would be to omit "empirical" completely if you
    % just want to hit a bleaching target.
    
    ko = abs(psw2_new(793) - 1.3);
    % St. John is at 18.35, -64.75  Reef 420 is at [-64.50,18.31]
    vi = abs(psw2_new(420) - 0.8);
    % Moorea is reef 144.
    mo = abs(psw2_new(144) - 0.9);
    add = (psw2_new(793) <= psw2_new(144)) + (psw2_new(144) <= psw2_new(420));  % penalty if out of order.
    empirical = add + ko*ko + vi*vi + mo*mo;
   
    bleach = b8510;
    bleachDiff = abs(targetBleaching - bleach);

    goodness = 1.0 * empirical + 8.0 * bleachDiff; 
end
