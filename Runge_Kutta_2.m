%#codegen
%% 2nd ORDER RUNGE-KUTTA for two variables with limits to prevent cold water bleaching.

% Runge-Kutta is a temporal discretization to approximate solutions for 
% ordinary differential equations


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% 12-1-15                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Snew, Cnew] = Runge_Kutta_2_min0_160914(Sold, Cold, i, dt, ri, ...
                            rm, temp, vgi, gi, SelVx, C_seed, S_seed, con)
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
        % KSx - symbiont carrying capacities from Baskett 2009
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

    Sn    = con.Sn;
    KSx   = con.KSx;
    G     = con.G;
    KS    = con.KS;
    KC    = con.KC;
    A     = con.A;
    Mu    = con.Mu;
    um    = con.um;
    a     = con.a;
    b     = con.b;
    EnvVx = con.EnvVx;

    %{
    Sm = Sold(1);            % Sum of all symbionts on massive corals
    Sb = Sold(2);            % Sum of all symbionts on branching corals
    SA = [Sm Sb];           % Symbionts sum matrix for coral calcs
    if Sn > 1
        SAx = repmat(SA,1,Sn);  % Symbionts sum matrix for symbiont calcs
    else
        SAx = SA;
    end
    %}
    
    %%
    % Note that storage order with two symbionts per coral time is
    % massive1, branching1, massive2, branching2
    % where we'll typically treat "1" as the wild or common symbiont type
    % and "2" as an introduced or other alternate type.
    %%
    
    Sm = sum(Sold(1:2:end));  % Sum symbionts in massives
    Sb = sum(Sold(2:2:end));  % Sum symbionts in branching
    SA = [Sm Sb];
    % SAx = Sold(1, :);  % replaced 1/30/2017 with line below
    SAx = repmat(SA, 1, 2);
    
    C1 = [Cold(2) Cold(1)];   % [branch mass]
    C2 = [Cold(1) Cold(2)];   % [mass branch]
    
    % Baskett 2009 equations 4 and 5.  k1 indicates the derivative at t sub i
    dSk1 = dt .* Sold ./ (KSx .* Cold) .* (ri(i,:) .* KSx .* Cold - rm .* SAx ) ;  %Change in symbiont pops %OK
    dCk1 = dt .* (C2 .* (G .* SA./ (KS .* C2).* (KC-A .* C1-C2)./KC - Mu ./(1+um .* SA./(KS .* C2))) ); %Change in coral pops %OK
    
    % Until 2/17/2017 the dSk1 array was being indexed as a 2D array, but
    % it's just 1 x number of symbionts!
    dSm = sum(dSk1(1:2:end));
    dSb = sum(dSk1(2:2:end));
    %dSm = dSk1(1,1); % change in sum of all symbionts on massive corals
    %dSb = dSk1(1,2); % change in sum of all symbionts on branching corals
    % not used. dS  = [dSm dSb];           % change in sum of all symbionts matrix for coral calcs
    
    ctemp = temp(i)+temp(i+1);    % current temp step
    rmk2  = a*exp(b*0.5*(ctemp)); % maximum possible growth rate at optimal temp at t=i+0.5
    
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
    rik2   = (1- (vgi(i,:) + EnvVx + (min(0, gi(i,:) - 0.5*ctemp)).^2) ./ (2*SelVx)) .* exp(b*min(0, ctemp - gi(i,:))) * rmk2; 

    
    hCm = max(Cold(1)+0.5*dCk1(1,1), C_seed(1));  % Massive corals at t=i+0.5
    hCb = max(Cold(2)+0.5*dCk1(1,2), C_seed(2));  % Branching corals at t=i+0.5
    hC2 = [hCm hCb];             % Coral pop matrix for coral calcs at t=i+0.5
    if Sn > 1
        hCx = repmat(hC2,1,Sn);      % Coral pop matrix for symbiont calcs at t=i+0.5
    else
        hCx = hC2;
    end
    hC1 = [hCb hCm];             % [branch mass]
    
    %{
    % Old code assumes seeds are the same for all symbionts.  Change to use
    % unique values.  Also note that hSAx was never used!
    hSm  = max(Sm+0.5*dSm, S_seed);       % sum of all symbionts on massive corals at t=i+0.5
    hSb  = max(Sb+0.5*dSb, S_seed);       % sum of all symbionts on branching corals at t=i+0.5
    hSA  = [hSm hSb];        % Symbionts sum matrix for coral calcs at t=i+0.5
    if Sn > 1
        hSAx = repmat(hSA,1,Sn); % Symbionts sum matrix for symbionts calcs at t=i+0.5
    else
        hSAx = hSA;
    end
    %}
    % Sm, Sb, dSm, and dSb are scalars representing the sum of all
    % symbionts for massive or branching and for the initial values and
    % t+1/2 deltas.  S_seed was a scalar, but is now a 1x4 vector for the
    % case of 2 corals and 2 symbionts.  We just want sums, since the coral
    % is treated as 2 copies of the same thing.
    hSm  = max(Sm+0.5*dSm, max(S_seed(1), S_seed(3)));       % sum of all symbionts on massive corals at t=i+0.5
    hSb  = max(Sb+0.5*dSb, max(S_seed(2), S_seed(4)));       % sum of all symbionts on branching corals at t=i+0.5
    hSA  = [hSm hSb];        % Symbionts sum matrix for coral calcs at t=i+0.5
    
    
    dSk2 = dt*(Sold+0.5*dSk1) ./ (KSx.*hCx) .* (rik2.* KSx.*hCx - rmk2 * (SAx+0.5*dSk1) ); %Change in symbiont pops at t=i+0.5 %OK
    dCk2 = dt* (hC2.*(G.*hSA./(KS.*hC2).*(KC-A.*hC1-hC2)./KC-Mu./(1+um.*hSA./(KS.*hC2)))); %Change in coral pops at t=i+0.5
    %{
    if i< 962 && mod(i, 12) == 1
        fprintf('dSk1 = %7.2d %7.2d %7.2d %7.2d   dSk2 = %7.2d %7.2d %7.2d %7.2d\n', dSk1, dSk2);
    end
    %}
    Snew = max(Sold + dSk2, S_seed);              % Symbiont pops at t=i+1
% dCk2 has one row, two columns
% C_seed is also a 2x1 array.
    Cnew = max(Cold + repmat(dCk2,1,Sn), repmat(C_seed, 1, Sn)); % Coral pops at t=i+1

end
