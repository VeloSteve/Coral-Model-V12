%% INITIALIZE SYMBIONT GENOTYPE/VARIANCE, CORAL/SYMBIONT POP SIZE AND
% CARRYING CAPACITY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% 12-1-15                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vgi, gi, S, C, hist] = Init_genotype_popsize(time, ...
                                        initializationIndex, temp, con, ...
                                        E, vM, SelV, superMode, superAdvantage, ...
                                        startSymFractions, superInitRange)
    %% Initialize Symbiont Mean Genotype Dynamics and Variance (Eqns 1-2)
    % Inputs:
    % Data - which SST dataset to use
    % time - a list of all the times in the simulation
    % temp - initialized by Interp_data?
    % Sn  - number of symbionts modeled (1 as of 8/2016)
    % Cn  - number of corals modeled (2 as of 8/20160)
    % E   - 1 if evolution is on
    % vM  - mutational variance
    % a   - linear growth rate, 1/12 of the value in Baskett 2009
    % b   - exponential growth constant from Baskett 2009 (not divided by 12)
    % SelV - selectional variance
    % KCb, KCm - coral carrying capacity from Baskett 2009
    % KSb, KSm - symbiont carrying capacity from Baskett 2009
    % Outputs:
    % S, C - 2D arrays of coral population values, size to match time on
    %       the first dimension and Sn*Cn on the second.
    % vgi - 2D array, the same size as S and C, with symbiont variance.
    %       This seems to have only two distinct values (for now).
    % gi  - Symbiont mean genotype over time

    % Initialize the temperature to which symbionts are adapted (their
    % genotype).
    hist = mean(temp(1:initializationIndex)) ;    
    %fprintf('SI range %s to %s\n', datestr(time(superInitRange(1))), datestr(time(superInitRange(2))));
    switch superMode
        case {0, 5, 6, 7}
            % For case 7 the values won't really be used, but this does no harm.
            histSuper = hist + superAdvantage;
        case {1, 3}
            histSuper = mean(temp(superInitRange(1):superInitRange(2)));
            %fprintf('Igp mean changed %d initial genotype to %d starting with time %s\n', hist, histSuper, datestr(time(superInitRange(1))));
        case {2, 4}
            histSuper = max(temp(superInitRange(1):superInitRange(2)));
            %fprintf('Igp max changed %d initial genotype to %d starting with time %s\n', hist, histSuper, datestr(time(superInitRange(1))));
        otherwise
            error('Only symbiont modes 0 to 7 are supported.');
    end

    col = con.Sn * con.Cn;
    gi = NaN(length(time), col) ;  % Symbiont mean genotype over time
    gi(1,1) = hist;             % Optimally adapted symbiont on massive corals w/ hist 
    gi(1,2) = hist;             % Susceptible symbiont on branching corals w/ hist
    
    % fill all four
    if col == 4
        if isempty(histSuper)
            % won't be applied, but needs some value
            gi(1, 3:4) = 0.0;
        else
            gi(1, 3:4) = histSuper;
        end
        %fprintf('Symbionts adapted to %5.2f and %5.2f, delta = %5.2f\n', hist, histSuper, histSuper-hist);
    end
    % x = 0.1    ;                   % Degrees celcius above or below hist
    % gi(1,3) = hist+x;         % Tolerant symbiont on massive corals w/ hist+x
    % gi(1,4) = hist+x;         % Tolerant symbiont on branching corals w/ hist+x
    % gi(1,5) = hist+2*x;         % Tolerant symbiont on massive corals w/ hist+x
    % gi(1,6) = hist+2*x;         % Tolerant symbiont on branching corals w/ hist+x
    % gi(1,7) = hist+3*x;         % Tolerant symbiont on massive corals w/ hist+x
    % gi(1,8) = hist+3*x;         % Tolerant symbiont on branching corals w/ hist+x

    %Genotype Variance w (E=1) and wo Evolution (E=0)
    vgi = zeros(length(time), col) ;
    if E==1
        for y=1:col
            if mod(y,2) == 0    % if even - check whether this works when Sn and Cn are not 1 and 2.
                vgi(1,y) = (vM *SelV(2)/(con.a*exp(con.b*gi(1,2))))^0.5;   % Symbiont variance on branching corals
            else
                vgi(1,y) = (vM *SelV(1)/(con.a*exp(con.b*gi(1,1))))^0.5;   % Symbiont variance on massive corals
            end
        end
    end


    %% Initialize Coral and Symbiont Population Size and Carrying Capacity

    % Initialize coral population sizes
    C = zeros(length(time), col) ;
    for y=1:col
        if mod(y,2) == 0 % if even
            C(1,y) = con.KCb*0.8 ;   % Branching coral population size
        else
            C(1,y) = con.KCm*0.2 ;   % Massive coral population size
        end
    end

    % Initialize symbiont population sizes
    S = zeros(length(time), col) ; % Symbiont pop size over time
    % Assume that there are always two corals, but Sn can vary.
    for y=1:2:col
        % For 4 symbionts y = 1 and 3 are for massive, original symbiont type first
        % y = 2 and 4 are for branching.
        symIdx = (y+1)/2; % old or new symbiont
        S(1,y  ) = 0.9*startSymFractions(symIdx)*con.KSm*C(1,1);         % historically-adapted symbiont pop on massives
        S(1,y+1) = 0.9*startSymFractions(symIdx)*con.KSb*C(1,2);         % historically-adapted symbiont pop on branching
    end
end
    