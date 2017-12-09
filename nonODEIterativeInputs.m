% Calculate values used in the ODE iterations, but not dependent on them.
function [ri, gi, vgi, gVec] = nonODEIterativeInputs(timeSteps, dt, ...
        temp, omegaFactor, vgi0, gi0, MutVx, SelVx, con)
    
    gVec = [con.Gm con.Gb] .* omegaFactor;

         % Update of the G constant if acidification is included.
         %{
        if OA == 1   % to include OA effects on coral growth rate in model
            con.G = gVec(i, :);
        end
         %}
   
    rmVec = con.a*exp(con.b*temp);
    % Allocate memory
    gi(length(temp), 4) = 0;
    vgi(length(temp), 4) = 0;
    % Initialize
    gi(1, :) = gi0;
    vgi(1, :) = vgi0;
    
    for i = 1:timeSteps
        rm  = rmVec(i); % maximum possible growth rate at optimal temp

        % Step vgi forward
        dvgi = MutVx - vgi(i,:) .^2 ./ SelVx * rm ; % Change in Symbiont Mean Variance
        vgi(i+1,:) = vgi(i,:) + dt .* dvgi; % Symbiont variance at t=i (Euler)
        % Step gi forward
        dgi  = ((vgi(i,:) .* (temp(i) - gi(i,:)) ) ./ SelVx) * rm; % Change in Symbiont Mean Genotype
        gi(i+1,:)  =  gi(i,:) + dt .* dgi;  % Symbiont genotype at t=i (Euler)
    end
    % Faster outside the loop because it vectorizes:
    ri = (1- (vgi + con.EnvVx + (min(0, gi - temp)).^2) ./ (2*SelVx)) .* exp(con.b*min(0, temp - gi)) .* rmVec;
    
end
