%#codegen
function [S, C, ri, gi, vgi, origEvolved] = timeIteration(timeSteps, S, C, dt, ri, ...
        temp, OA, omegaFactor, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSuperIndex, ...
        superSeedFraction, oneShot, con)
    
    origEvolved = 0.0;
    for i = 1:timeSteps
        rm  = con.a*exp(con.b*temp(i,1)) ; % maximum possible growth rate at optimal temp
        
        % Update of the G constant if acidification is included.
        if OA == 1   % to include OA effects on coral growth rate in model
            % modify growth rate based on aragonite saturation state
            % note that omegaFactor containts the required multiplier, not
            % the saturation state values.
            % This multiplies by factors of 0.55, 0.7, 0.85, 1.0
            % as omega steps from 1 to 4.
            con.G = [con.Gm con.Gb] * omegaFactor(i);
        end
        
        %rm = 1; % try running wo Eppley eqn !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %ri(i,:) = (1- (vgi(i,:) + EnvV + (gi(i,:) - temp(i)).^2) ./ (2*SelVx)) * rm ; % symbiont average growth rate at time i
         
        % Original version prior to 2/1/2017:
        % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(0, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching

        
        % Try decreasing growth rate in cooler water based on Eppley
        % equation per John/Simon/Cheryl 2/8/2017.
        ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(0, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(0, temp(i) - gi(i,:))) * rm;
        
        %{
        if i<962 && mod(i, 12) == 1
            fprintf('At i = 1 delta for old: %7.2f  for new: %7.2f\n', gi(i,1)-temp(i), gi(i,3)-temp(i));
            fprintf('         ri for    old: %7.2f  for new: %7.2f\n', ri(i,1), ri(i, 3));
        end
        %}
        
        % Solve ordinary differential equations using 2nd order Runge Kutta
        %Runge_Kutta_2_min0_160503 %% run sub-mfile to solve ODE using min0 to prevents cold water bleaching
        [SiPlusOne, CiPlusOne] = Runge_Kutta_2(S(i, :), C(i, :), i, dt, ...
                                            ri, rm, temp, vgi, gi, SelVx, C_seed, ...
                                            S_seed, con);

        C(i+1, :) = CiPlusOne;
        S(i+1, :) = SiPlusOne;
        % When it's time to introduce the super symbiont, do it at a single
        % time step.  Also reset the S_seed(:, 3:4) values to be this value if
        % it is less than or equal the normal seed, and otherwise to match
        % the normal seeds (S_seed(:, 1:2)
        if i < suppressSuperIndex || ~suppressSuperIndex
            S(i+1, 3:end) = 0.0;
        elseif i > 1 && i == suppressSuperIndex
            S(i+1, 3:end) = S_seed(3:end) * superSeedFraction;
            %fprintf('Introduced S3 at %7.2d i = %d\n', S(i+1, 3), (i+1));
            if oneShot
                S_seed(3:end) = 0.0;
            elseif superSeedFraction < 1
                S_seed(3:end) = superSeedFraction * S_seed(3:end);
            end
            %{
        elseif oneShot && (i > suppressSuperIndex)
            % Set S to zero if small.  Do we really want this?
            % It has little impact on mortality (surprisingly), but slows
            % down runs badly.
            S(S < 1.0) = 0.0;
            %}
        end
        % Next four lines were in the Runge Kutta file, but are not part of
        % that algorithm.
        dgi  = ((vgi(i,:) .* (temp(i,1) - gi(i,:)) ) ./ SelVx) * rm; % Change in Symbiont Mean Genotype
        dvgi = MutVx - (vgi(i,:)) .^2 ./ SelVx * rm ; % Change in Symbiont Mean Variance
        gi(i+1,:)  =  gi(i,:) + dt .* dgi;  % Symbiont genotype at t=i (Euler)
        vgi(i+1,:) = vgi(i,:) + dt .* dvgi; % Symbiont variance at t=i (Euler)
        if i > 1 && i == suppressSuperIndex
            % Important - enhanced genotype is set at the beginning of run,
            % but if E=1 it will have decayed.  Reset here!
            gi(i+1, 3:4) = gi(1, 3:4);
            origEvolved = gi(i, 1);
        end
    end  % End of time iterations for one area
end