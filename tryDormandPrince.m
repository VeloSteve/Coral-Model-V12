%#codegen
function [S, C, tOut, gi, vgi, origEvolved] = tryDormandPrince(months, S0, C0, tMonths, ...
        temp, OA, omegaFactor, vgi, gi, MutVx, SelVx, C_seed, S_seed, superMonth, ...
        superSeedFraction, oneShot, con, dt, k)
    
    origEvolved = 0.0;
    
    % Making this a Mex file only speeds it up a little - are there gains to be
    % found?  Do this later: "first make it right, then make it fast".
        
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
        temp, omegaFactor', vgi, gi, MutVx, SelVx, superMonth, con);
    %Plot_ArbitraryYvsYears(ri(:,2), tMonths, 'DP Temperature Effect on Branching Growth', 'Growth rate factor')

    % Coral seeds are specified for just two types, but we need one per each
    % copy computed.
    %No? C_seed = repmat(C_seed, 1, con.Sn);
       
    
    inVar = [S0 C0]';
    
    % Use ode45 in the form [t,y] = ode45(odefun,tspan,y0,options)
    %
    % Time is in months in the equations, so the tspan input should be
    % in those units.  We compute from zero months to the number required for
    % the simulation.  If there are supersymbionts, split into two simulations
    % so the step function can be applied at the right time.
    
    % Output is a single column of time and multiple columns of
    % matching computed values.
    % Time/reef vs RelTol
    % 1e-3  27.1 sec
    % 1e-2  21.7 sec
    % 1e-4  43.9 sec
    % 1e-1  fails
    % 1e-5  69.0 sec
    opts = odeset('RelTol',1e-3);  % 1e-3 is the default.

    if superMonth < 0
        [tOut, yOut] = ode45(@(t, y) ...
            odeFunction(t, y, tMonths, temp, C_seed, S_seed, con, ri, gVec), ...
            [0 months], inVar, opts);
    else
            try
                [tOut, yOut] = ode45(@(t, y) ...
                odeFunction(t, y, tMonths, temp, C_seed, S_seed, con, ri, gVec), ...
                [0 superMonth], inVar, opts);
            catch ME
                fprintf('Caught an error in first integration for reef %d\n', k);
                rethrow(ME);
            end
            % Add super symbionts.
            % TODO - this is a "one shot" introduction only. The flag is
            % ignored.
            e = length(S_seed);
            newIn = yOut(end, :);
            newIn(3:e) = newIn(3:e) + superSeedFraction*S_seed(3:e);
            newIn = newIn';
            
            % This is a diagnostic, recording gi at the moment of
            % supersymbiont introduction.    
            giNow = interp1(tMonths, gi, superMonth, 'spline');
            origEvolved = giNow(1);

            try
                [tOut2, yOut2] = ode45(@(t, y) ...
                odeFunction(t, y, tMonths, temp, C_seed, S_seed, con, ri, gVec), ...
                [superMonth months], newIn, opts);
            catch ME
                fprintf('Caught an error in second integration for reef %d\n', k);
                rethrow ME;
            end
            
            % concatenate the pre- and post-symbiont segments, dropping the
            % duplicate point which would cause iterpolation issues later.
            tOut = vertcat(tOut(1:end-1, :), tOut2);
            yOut = vertcat(yOut(1:end-1, :), yOut2);
    end

    cols = con.Sn*con.Cn;

    S = yOut(:, 1:cols);
    C = yOut(:, cols+1:cols*2);

end
