% Calculate values used in the ODE iterations, but not dependent on them.
function [ri, gi, vgi, gVec] = nonODEIterativeInputs(timeSteps, dt, ...
        temp, omegaFactor, vgi0, gi0, MutVx, SelVx, superMonth, con)
    
    % XXX override dt - now we work in whole months
    dt = 1.0;
    
    gVec = zeros(length(omegaFactor), 2);
    gVec(:, 1) = con.Gm .* omegaFactor;
    gVec(:, 2) = con.Gb .* omegaFactor;

         % Update of the G constant if acidification is included.
         %{
        if OA == 1   % to include OA effects on coral growth rate in model
            con.G = gVec(i, :);
        end
         %}
   
    rmVec = con.a*exp(con.b*temp);
    % Allocate memory
    % The trick of setting the last element to zero interferes with code
    % generation, so use zeros.
    %gi(length(temp), 4) = 0;
    %vgi(length(temp), 4) = 0;
    gi = zeros(length(temp), 4);
    vgi = zeros(length(temp), 4);
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
        if i+1 == superMonth  % XXX - superMonth is a month, but this is an index???
            % Reset super symbiont genotype to its "super" value.
            gi(i+1,1:2)  =  gi(i,1:2) + dt .* dgi(1:2);  % Symbiont genotype at t=i (Euler)
            gi(i+1,3:end)  =  gi(1,3:end);  % Symbiont genotype at t=1 (Euler)
        else
            gi(i+1,:)  =  gi(i,:) + dt .* dgi;  % Symbiont genotype at t=i (Euler)
        end
    end
    % Faster outside the loop because it vectorizes:
    % 1x4 variables cause trouble in mex generation: candidates include: con.EnvVx, dgi, dvgi, gi0, MutVx,
    % SelVx, vgi0.  Actually in this line are: con.EnvVx, and SelVx.
    %ri = (1- (vgi + con.EnvVx + (min(0, gi - temp)).^2) ./ (2*SelVx)) .* exp(con.b*min(0, temp - gi)) .* rmVec;
    % Rewrite as a 4-time for loop to see if it makes MATLAB coder happy (it does):
    ri = zeros(length(vgi), 4);
    for j = 1:4
        ri(:, j) = (1- (vgi(:, j) + con.EnvVx(j) + (min(0, gi(:, j) - temp)).^2) ./ (2*SelVx(j))) .* exp(con.b*min(0, temp - gi(:, j))) .* rmVec;
    end

    
end
