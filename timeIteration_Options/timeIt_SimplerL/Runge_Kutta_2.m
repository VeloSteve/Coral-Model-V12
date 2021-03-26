%#codegen
%% 2nd ORDER RUNGE-KUTTA for two variables with limits to prevent cold water bleaching.

% Runge-Kutta is a temporal discretization to approximate solutions for 
% ordinary differential equations


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% 12-1-15                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Snew, Cnew] = Runge_Kutta_2(Sold, Cold, i, dt, ri, ...
                            rm, temp, vgi, gi, SelVx, C_seed, S_seed, con, ...
                            alpha, KCx, Mu, um, KSx, G, expTune, adjustAllRi)

	% Inputs:
    % Sold - symbiont populations - "S old" the i'th row of the S array
    % Cold - coral populations - "C old" the i'th row of the C array
    % i - time step in the calling for loop
    % dt - timestep set in Interp_data.m
    % ri - values set for each time step to prevent cold water bleaching
    % rm - maximum growth rate
    % temp - temperatures initialized by Interp_data
    % vgi - 2D array, the same size as S and C, with symbiont variance.
    % gi  - Symbiont mean genotype over time
    % SelVx - Selectional variance matrix for coral calcs
    % C_seed and S_seed - minimum values for coral and symbiont density.
    % Constants from the "con" structure, called coralSymConstants in the
    % main program.  
    % con is the only optional variable, speeding calls when it is not
    % needed.
        % Sn - number of symbionts modeled
        % KSx - symbiont carrying capacities from Baskett 2009, repeated for
        % each population.
        % G  - constants from the Coral_Sym_constants file  ?
        % KS - same symbiont capacities as KSx   XXX
        % KC - coral carrying capacities from Baskett 2009
        % A - competition coefficients from Baskett 2009
        % Mu - constants from the Coral_Sym_constants file - basal mortality
        % um - symbiont influence on mortality from Baskett 2009    
        % a   - linear growth rate, 1/12 of the value in Baskett 2009
        % b   - exponential growth constant from Baskett 2009 (not divided by 12)
        % EnvV - environmental variance from Baskett 2009
        % EnvVx - EnvV copied once per symbiont type

    %Sn    = con.Sn;
    %KS    = con.KS;
    %KC    = con.KC;
    A     = con.A;
    a     = con.a;
    b     = con.b;
    EnvVx = con.EnvVx;
    % Warning: these 5 still exist in the con struct, but are now resized in
    % timeIteration and passed separately.
    % KSx   = con.KSx;
    % KCx   = con.KCx;
    % Mu    = con.Mu;
    % um    = con.um;
    % G     = con.G;

   
    %%
    % Note that storage order with two symbionts per coral time is
    % massive1, branching1, massive2, branching2
    % where we'll typically treat "1" as the wild or common symbiont type
    % and "2" as an introduced or other alternate type.
    %%
    
    % TODO this should create a per-coral sum since symbionts in different
    % corals don't compete with eachother.
    if size(Sold, 2) > size(Cold, 2)
        multForS = size(Sold, 2) / size(Cold, 2);
        Sm = sum(Sold(1:2:end));  % Sum symbionts in massives
        Sb = sum(Sold(2:2:end));  % Sum symbionts in branching
        SA = [Sm Sb];
    else
        multForS = 1;
        SA = Sold;
    end
    % SA has the right size for the coral calculation, but for 
    % SAx = Sold(1, :);  % replaced 1/30/2017 with line below
    % also wrong. 1/3/2020 SAx = repmat(SA, 1, 2);
    
  
    % New 2020: Get a carrying capacity for each symbiont, even if there are
    % more symbionts than corals.
    % Typically there are either 1 or 2 symbionts per coral population, but
    % always an integer multiple.  This is used in several places.
    %currentKS = repmat(KSx .* Cold, 1, multForS);
    % Since C 3 and 4 are basically junk in mode zero, don't use the values.
    % This will need work if the number of symbionts changes.
    % Just use 2 copies of the first 4 corals!
    currentKS = repmat(KSx(1:2) .* Cold(1:2), 1, 2);
    SAs = repmat(SA, 1, multForS);
    
    % Baskett 2009 equations 4 and 5.  k1 indicates the derivative at t sub i
    dSk1 = dt .* Sold ./ currentKS .* (ri(i,:) .*currentKS - rm .* SAs ) ;  %Change in symbiont pops %OK
    % The dot-product used here works for 2 corals, but for we need a proper
    % matrix multiplication.
    % Also, dimension everything to match the actual number of corals.
    % dCk1 = dt .* (C2 .* (G .* SA./ (KS .* C2).* (KC-A .* C1-C2)./KC - Mu ./(1+um .* SA./(KS .* C2))) ); %Change in coral pops %OK
    dCk1 = dt .* (Cold .* (G .* SA./ (KSx .* Cold).* (KCx-(alpha*Cold')')./KCx - Mu ./(1+um .* SA./(KSx .* Cold))) ); %Change in coral pops %OK
      
    ctemp = temp(i)+temp(i+1);    % current temp at half step (times 2)
    ctemp2 = ctemp / 2.0;
    rmk2  = a*exp(b*ctemp2); % maximum possible growth rate at optimal temp at t=i+0.5
    
    %%
    % Note that this line is analagous to the one for ri in timeIteration,
    % so it should be modified in sync with it!
    %rik2  =   (1- (vgi(i,:) + EnvVx + (min(0, gi(i,:) - 0.5*ctemp)).^2)./(2*SelVx)) * rmk2; % symbiont average growth rate at t=i+0.5
    % modified rik2 above to prevent cold water bleaching Prevents cold water bleaching
    % Test without the mod, 2/1/2017
    %rik2  =   (1- (vgi(i,:) + EnvVx + (gi(i,:) - 0.5*ctemp).^2)./(2*SelVx)) * rmk2; % symbiont average growth rate at t=i+0.5
    % And with partial mod to limit:
    %rik2  =   (1- (vgi(i,:) + EnvVx + (min(1.0, gi(i,:) - 0.5*ctemp)).^2)./(2*SelVx)) * rmk2; % symbiont average growth rate at t=i+0.5
    % Try decreasing growth rate in cooler water based on Eppley
    % equation per John/Simon/Cheryl 2/8/2017.
    % Jan 2020: ctemp needs to be divided by 2 in BOTH places to get the average!
    %rik2   = (1- (vgi(i,:) + EnvVx + (min(0, gi(i,:) - 0.5*ctemp)).^2) ./ (2*SelVx)) .* exp(b*min(0, ctemp/2.0 - gi(i,:))) * rmk2; 
    % XXX Test: partial mod to see the effect:
    %rik2   = (1- (vgi(i,:) + EnvVx + (min(2, gi(i,:) - 0.5*ctemp)).^2) ./ (2*SelVx)) .* exp(b*min(2, ctemp/2.0 - gi(i,:))) * rmk2; 
    % June 2020: min function used 2 inside to avert cold water bleaching, but
    % the "extra exponential" uses 0 so we don't shift the curve for temperatures above gi
    % July 10, 2020: back to 0 in both minima.
    % rik2   = (1- (vgi(i,:) + EnvVx + (min(0, gi(i,:) - 0.5*ctemp)).^2) ./ (2*SelVx)) .* exp(b*min(0, ctemp/2.0 - gi(i,:))) * rmk2; 
    % July 12: curve D.
    %rik2   = (1- (vgi(i,:) + EnvVx + (min(min1, gi(i,:) - 0.5*ctemp)).^2 ) ./ (2*SelVx)) .* exp(expTune*b*min(min2, ctemp/2.0 - gi(i,:))) * rmk2; 
    % July 15: The extra exponential was formed incorrectly for when the curve break
    % was not at temp = gi.  Fixed.
    
    % Replace the passed min1 and min2 with Cheryl's new approach 18 Feb 2021
    % min1 = sqrt(abs(adjustAllRi.*SelVx - vgi(i, :) - con.EnvVx));
    % And a simplified version, also replacing min1 and min2 with L  3 Mar 2021
    L = sqrt(adjustAllRi.*SelVx);
    min2Fn = min(0, ctemp2 - gi(i,:) + L);
    rik2   = (1- (vgi(i,:) + EnvVx + (min(L, gi(i,:) - ctemp2)).^2 ) ./ (2*SelVx)) .* exp(expTune*b*min2Fn) .* rmk2; 
    % This line puts a floor under the growth curve to the left of peak. It
    % was not successful in improving the relationship between cold and warm
    % bleaching and mortality.  (Tested February 2021.)
    % rik2((ctemp2 < gi(i, :)) & (rik2 < riFloor)) = riFloor;


    % Coral population at t = t + dt/2
    hC = max(Cold + 0.5*dCk1, C_seed);    
    
    % Symbiont populations at t = t + dt/2
    hS = max(Sold + 0.5*dSk1, S_seed); 
    if size(Sold, 2) > size(Cold, 2)
        hSm = sum(Sold(1:2:end));  % Sum symbionts in massives
        hSb = sum(Sold(2:2:end));  % Sum symbionts in branching
        hSA = [hSm hSb];
    else
        hSA = hS;
    end
    
    %currentKS = repmat(KSx .* hC, 1, multForS);
    currentKS = repmat(KSx(1:2) .* hC(1:2), 1, 2);

    hSAs = repmat(hSA, 1, multForS);


    dSk2 = dt*(Sold+0.5*dSk1) ./ currentKS .* (rik2.* currentKS - rmk2 .* (hSAs+0.5*dSk1) ); %Change in symbiont pops at t=i+0.5 %OK
    dCk2 = dt* (hC.*(G.*hSA./(KSx.*hC).*(KCx-(alpha*hC')')./KCx-Mu./(1+um.*hSA./(KSx.*hC)))); %Change in coral pops at t=i+0.5

    Snew = max(Sold + dSk2, S_seed);              % Symbiont pops at t=i+1
% dCk2 has one row, two columns
% C_seed is also a 2x1 array.
    %Cnew = max(Cold + dCk2, C_seed); % Coral pops at t=i+1
    % Experiment with just blanking out C 3,4
    Cnew = zeros(size(Cold), 'like', Cold);
    Cnew(1:2) = max(Cold(1:2) + dCk2(1:2), C_seed(1:2)); % Coral pops at t=i+1

if false
    if size(Cold,2) == 4
        fprintf('Cold %+11.3e %+11.3e %+11.3e %+11.3e\n', Cold);
        fprintf('dCk1 %+11.3e %+11.3e %+11.3e %+11.3e\n', dCk1);
        fprintf('hC   %+11.3e %+11.3e %+11.3e %+11.3e\n', hC);
        fprintf('dCk2 %+11.3e %+11.3e %+11.3e %+11.3e\n', dCk2);
        fprintf('Cnew %+11.3e %+11.3e %+11.3e %+11.3e\n\n', Cnew);
    else
        fprintf('Cold %+11.3e %+11.3e\n', Cold);
        fprintf('dCk1 %+11.3e %+11.3e\n', dCk1);
        fprintf('hC   %+11.3e %+11.3e\n', hC);
        fprintf('dCk2 %+11.3e %+11.3e\n', dCk2);
        fprintf('Cnew %+11.3e %+11.3e\n\n', Cnew);
    end
    fprintf('Sold %+11.3e %+11.3e %+11.3e %+11.3e\n', Sold);
    fprintf('dSk1 %+11.3e %+11.3e %+11.3e %+11.3e\n', dSk1);
    fprintf('dSk2 %+11.3e %+11.3e %+11.3e %+11.3e\n', dSk2);
    fprintf('Snew %+11.3e %+11.3e %+11.3e %+11.3e\n\n', Snew);    
end
end
