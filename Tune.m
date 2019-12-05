% Find the values s and y used in the equation
%
% prop constant = p = (1/s) * (mean(E)/var(E))^y
% where E is shorthand for e^(bT).  b is a constant from Eppley 1972,
% and T is the monthly temperature history for each reef.
%
% to give the required average bleaching quantity.  Without the luxury of
% MATLAB's optimization toolbox, try not to miss global optima by simple finding
% the local optimum from several starting points.

% NOTES:
% First full run, 60 iterations (about 120 runs) with everyx=2, E=1, rcp45
% best y = 0.491185, s = 6.014050, goodness = 2.357564, bleaching = 4.99805 
% For RCP 4.5, everyx = 1. Incomplete - file conflict running 2 instances.
% best y = 0.423749, s= 4.834302, goodness = 2.33130

% For RCP 6.0   y = 0.436414, s = 4.989708, goodness = 2.329956
% For RCP 8.5  goodness = 2.326494 for params 0.447716, 5.123547 
% For RCP 2.6, 403 runs, maximum evaluations reached. Looking near
% Returning goodness = 3.105784 for params 0.667187, 3.968750 
% but lower values were found MUCH earlier, e.g. 
% For RCP 2.6, goodness = 2.977912 for params 0.667384, 3.973364 

% Note for RCP 4.5, E=1.  First 5 runs gave exactly the same goodness =
% 5.295594, and after than it went to higher values and eventually seemed to get
% stuck at 13.879011 y = 0.70, s = 3.9999.  The result seems to be
% super-sensitive for these inputs, and there may be no good optimum.  Even when
% printed inputs match to 6 decimal places, the output is now 13.879011!

% For RCP 4.5, stopping manually after 82 runs and using the best early result:
% For RCP 4.5 goodness = 5.295594 for params 0.700000, 4.000000  (DO NOT TRUST)

% For RCP 2.6 E=0 goodness = 2.300583 for params 0.485106, 5.223673 


% === test with TolFun = 1e-3, TolX = 2e-4.  Defaults are 1e-4 for both.
% Repeating RCP 4.5, E=1. - try restart with y = 0.46 as in the paper. (left
% window)


% Repeating RCP 2.6, E=0 with new tolerance. (right window)
% Stop at     19           38          2.30073         contract inside
% to try TolFun = 1e-2, TolX = 2e-4 
% Note that a single reef changes by about 0.2 for a year, or 0.008 for 25 years!
% still running, bleaching is excellent, but still playing with 4th digit of
% parameters at 31 iterations.
% last iteration:     32           72          2.30058         reflect
% Returning goodness = 2.300583 for params 0.485104, 5.223685 
% RESTART with TolX = 5e-4

tuneStart = tic;


targetBleaching = 5; % percent
yRange = [0.25, 1.0];  % exponent
sRange = [2, 8]; % divisor
RCP = 'rcp45';
E = false;
% XXX TODO: select more than one initial y and s from the range above.
par0 = [0.7, 4];
xOpt = bleachingTest(RCP, E, par0, targetBleaching);

tuneElapsed = toc(tuneStart);
fprintf('Tuning finished in %7.1f seconds.\n', tuneElapsed); 

% Bleach test is a wrapper to ensure that non-variable parameters are available
% to the function which is called with only the variables by fminsearch.
function [x] = bleachingTest(RCP, E, par0, target)
    % Constants for the propConstant calculation
    pMin = 0.36;
    pMax = 1.5;
    % Set up the model input to run with the current RCP value and in 
    % optimizer mode.
    [~, pd] = getInputStructure('.\modelVars.txt');
    pd.set('RCP', RCP);
    pd.set('E', E);
    pd.set('optimizerMode', true);
    % USE WITH CARE: set everyx > 1 to skip reefs for faster, less accurate
    % exploration of the results.
    pd.set('everyx', 1);
    % And if everyx > 1, be sure reefs used in the optimizer are not skipped.
    pd.set('keyReefs', [144 420 793]);  % no harm when everyx == 1
    pd.print()
   
    %options = optimset('PlotFcns',@optimplotfval);
    options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-2,'TolX',5e-4);

    x = fminsearch(@bleachingRun, par0, options);
    fprintf('Best value y = %f, s = %f for RCP = %s, E = %d\n', x(1), x(2), RCP, E);

    
    function [goodness] = bleachingRun(par0)
        % The script propConstantCalcsForOptimizer takes the given inputs and
        % updates the psw2 values used
        % when the coral model runs.  It expects to find this vector:
        propInputValues = [pMin, pMax, par0(1), par0(2)]; %#ok<NASGU>  Used in script below.
        psw2_new = propConstantFunction(RCP, propInputValues);

        % Run the model for all reefs
        [Bleaching_85_10_By_Event, ~] = aCoralModel(pd);


        [goodness, ~] = goodnessValue(target, psw2_new, Bleaching_85_10_By_Event);
        fprintf('Returning goodness = %f for params %f, %f \n', goodness, par0(1), par0(2));
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
    % a reason.
    
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
    % fprintf('Diffs: ko = %f, vi = %f, mo = %f, empirical = %f, bleaching = %d, goodness = %f\n', ko, vi, mo, empirical, bleach, goodness);
end
