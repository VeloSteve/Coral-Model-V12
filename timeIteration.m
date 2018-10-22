%#codegen
function [S, C, gi, vgi, origEvolved, bleach] = timeIteration(timeSteps, S, C, dt, ...
        temp, OA, omegaFactor, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSuperIndex, ...
        superSeedFraction, superMode, superAdvantage, oneShot, bleach, bleachParams, ...
        con)
    
    % currentAdvantage may be modified in some modes.  Don't change
    % superAdvantage
    if superMode == 8
        currentAdvantage = 0.0;
    else
        currentAdvantage = superAdvantage;
    end
    shuffleGFactor = ones(1, con.Cn);
    
    % Needed for bleaching calculations:
    % If would prevent wasted space when not using superMode 8, but mex won't
    % compile because variables are used later and it fears a lack of
    % definition.
    %if superMode == 8
        bleach(:, :) = false; % Important - otherwise we get old values!
        stepsPerYear = 12/dt;
        %thisYearC = NaN(con.Cn, 'like', C);
        %thisYearS = NaN(con.Sn, 'like', S);
        lastYearC = NaN(con.Cn, 'like', C);
        lastYearS = NaN(con.Sn, 'like', S);
        lastBleached = NaN(con.Cn, 1);  % Used for mortality in Clean_Bleach_Stats, but here to track shuffling times.
        hasLastYear = false;
        shuffle = false(con.Cn, 1);
        simYear = 1;
        sBleach = bleachParams.sBleach;  
        cBleach = bleachParams.cBleach;
        sRecoverySeedMult = bleachParams.sRecoverySeedMult;
        cRecoverySeedMult = bleachParams.cRecoverySeedMult;
        %extendedBleaching = bleachParams.yearsToMortality;
        %seedThresh = C_seed .* bleachParams.cSeedThresholdMult;
    %end
    
    origEvolved = 0.0;
    ri = zeros(timeSteps+1, con.Sn * con.Cn); % actual growth rate at optimal temp

    for i = 1:timeSteps
        rm  = con.a*exp(con.b*temp(i,1)) ; % maximum possible growth rate at optimal temp
        
        % Update of the G constant if acidification is included.
        if OA == 1   % to include OA effects on coral growth rate in model
            % modify growth rate based on aragonite saturation state
            % note that omegaFactor containts the required multiplier, not
            % the saturation state values.
            % This multiplies by factors of 0.55, 0.7, 0.85, 1.0
            % as omega steps from 1 to 4.
            con.G = shuffleGFactor .* [con.Gm con.Gb] * omegaFactor(i);
        else
            con.G = shuffleGFactor .* [con.Gm con.Gb];
        end
        
        %rm = 1; % try running wo Eppley eqn !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %ri(i,:) = (1- (vgi(i,:) + EnvV + (gi(i,:) - temp(i)).^2) ./ (2*SelVx)) * rm ; % symbiont average growth rate at time i
         
        % Original version prior to 2/1/2017:
        % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(0, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching

        
        % Try decreasing growth rate in cooler water based on Eppley
        % equation per John/Simon/Cheryl 2/8/2017.
        % (eq 3)
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
                                        
        % Compute bleaching state (new 8/14/2018)
        % Only check at the end of each year to be consistent with
        % Clean_Bleach_Stats
        if superMode == 8
            if mod(i, stepsPerYear) == 0
                % Compute this year's averages
                thisYearC = min(C(1+i-stepsPerYear:i, :), [], 1);
                thisYearS = min(S(1+i-stepsPerYear:i, :), [], 1);
                %% Code mostly from Clean_Bleach_Stats
                if hasLastYear
                    % Compute new bleaching state
                    for coral = 1:con.Cn
                        if bleach(simYear-1, coral)
                            % Check for recovery
                            % Is each component strong enough to be considered?
                            seedRecS = thisYearS(coral) > sRecoverySeedMult(coral)*S_seed(coral);
                            seedRecC = thisYearC(coral) > cRecoverySeedMult(coral)*C_seed(coral);
                            if seedRecS && seedRecC
                                bleach(simYear:end, coral) = false;
                                % Note that shuffling is not turned off immediately
                                % upon recovery.
                            else
                                % Didn't recover.  Update last bleaching date
                                % (this impliest that it's the last year of being in
                                % a bleaching state, not the last time bleaching
                                % started).
                                lastBleached(coral) = simYear;
                            end
                        else
                            % Not bleached, check for bleaching.
                            % Declines in either symbionts or bleaching can define bleaching.
                            sB = thisYearS(coral) < lastYearS(coral) * sBleach(coral);
                            cB = thisYearC(coral) < lastYearC(coral) * cBleach(coral);
                            if sB || cB
                                bleach(simYear:end, coral) = true;
                                lastBleached(coral) = simYear;
                                shuffle(coral) = true;
                                if superAdvantage > 0
                                    currentAdvantage = superAdvantage;
                                    shuffleGFactor(coral) = 0.5;
                                    % In shuffle mode, set a seed.
                                    if superSeedFraction < 1
                                        S_seed(3:end) = superSeedFraction * S_seed(3:end);
                                    end
                                end
                            else
                                % Wasn't bleached last year and didn't bleach this year.
                                % Is it time to turn off previous shuffling?
                                if simYear == lastBleached(coral) + 2
                                    shuffle(coral) = false;
                                    currentAdvantage = 0.0;
                                    shuffleGFactor(coral) = 1.0;
                                    % Don't a apply a seed when advantage is
                                    % zero.
                                    S_seed(3:end) = 0.0;

                                end
                            end
                        end
                    end
                    %% End Clean_Bleach_Stats section
                    
                else
                    hasLastYear = true;
                end
                % Save this year for next year.
                lastYearC = thisYearC;
                lastYearS = thisYearS;
                simYear = simYear + 1;
            end
        elseif (superMode == 9) && (con.Sn >= 2)
            % Don't turn anything abruptly on and off, but apply a growth
            % penalty when the tolerant symbionts dominate.   
            if SiPlusOne(3) > SiPlusOne(1)
                shuffleGFactor(1) = 0.5;
            else
                shuffleGFactor(1) = 1.0;
            end
            if SiPlusOne(4) > SiPlusOne(2)
                shuffleGFactor(2) = 0.5;
            else
                shuffleGFactor(2) = 1.0;                
            end
        end
        
        
        

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
        dgi  = ((vgi(i,:) .* (temp(i,1) - gi(i,:)) ) ./ SelVx) * rm; % Change in Symbiont Mean Genotype (eq 1)
        dvgi = MutVx - (vgi(i,:)) .^2 ./ SelVx * rm ; % Change in Symbiont Mean Variance (eq 2)
        gi(i+1,:)  =  gi(i,:) + dt .* dgi;  % Symbiont genotype at t=i (Euler)
        vgi(i+1,:) = vgi(i,:) + dt .* dvgi; % Symbiont variance at t=i (Euler)
        if superMode >= 7
            % For this mode only, symbiont advantage is relative to the native
            % symbiont at every time step.
            gi(i+1, 3:4) = gi(i+1, 1:2) + currentAdvantage;
            % For now, assume that the variance matches the natives.
            vgi(i+1, 3:4) = vgi(i+1, 1:2);
        elseif i > 1 && i == suppressSuperIndex
            % Important - enhanced genotype is set at the beginning of run,
            % but if E=1 it will have decayed.  Reset here!
            gi(i+1, 3:4) = gi(1, 3:4);
            origEvolved = gi(i, 1);
        end
    end  % End of time iterations for one area
end
