%#codegen
function [S, C, tOut, ri, gi, vgi, origEvolved] = tryDormandPrince(months, S0, C0, tMonths, ...
        temp, OA, omegaFactor, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSuperIndex, ...
        superSeedFraction, oneShot, con, dt)
    
    origEvolved = 0.0;
        
    % Note that S, C, gi, vgi, and others(?) are passed in a full arrays
    % but with only the first row initialized.  Since these can't be pre-computed,
    % they should now be treated
    % as additional ODEs with values at the time steps used by ode45,
    % rather than at fixed intervals.
    % 
    % ri is just zeros, and should be computed from vgi , gi, temp, and
    % constants.

    % Set up variables for using ode45.
   
    % Returned variables gi and vgi are used in outside diagnostics, but
    % not in the calculation.
    [ri, gi, vgi, gVec] = nonODEIterativeInputs(length(tMonths)-1, dt, ...
        temp, omegaFactor', vgi(1, :), gi(1, :), MutVx, SelVx, con);
       
    
    inVar = [S0 C0]';
    % Time is in months in the equations, so the tspan input should be
    % in those units.
    % Output is a single column of time and multiple columns of
    % matching computed values.
    opts = odeset('RelTol',1e-5);  % 1e-3 is the default.

    [tOut, yOut] = ode45(@(t, y) ...
        odeFunction(t, y, tMonths, temp, C_seed, S_seed, con, ri, gVec), ...
        [0 months], inVar, opts);

    cols = con.Sn*con.Cn;

    S = yOut(:, 1:cols);
    C = yOut(:, cols+1:cols*2);

    % XXX
    %    PROBLEM: super symbionts can't be introduced here - must be
    %    done in ode45 as a step function!
    %    OR: run ode45 from tStart to tIntroduction, add symbionts,
    %    then restart and run to end!
    % XXX

end
