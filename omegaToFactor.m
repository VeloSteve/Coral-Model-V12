function [f] = omegaToFactor(a)
    % This calculates the fraction to be multiplied by the G constant when acidification is included.
    % see Chan NCS, Connolly SR. 2013. Sensitivity of coral calcification to ocean acidification: A meta-analysis. Glob Change Biol. 19:282–290.
    % Note that G is (in Baskett 2009):
    %       cm growth rate massive: 1 yr%1, branching: 10 yr%1 Huston (1985)
    %       The table references Huston(985), in which I don't see any clear source of these values.
    
    % Most values are between 1 and 4, so just apply the equation to every
    % point first.  Some will be overwritten.

    % Old format, same slope, but SQUARE the result.  This may be
    % justified by Lough & Barnes 2000, where linear extension is
    % proportional to calcification rate.  We are working in terms
    % of area, which is squared.
    f = (1-(4-a)*0.15).^2;

    % Special cases - f = 0 for omega at 1 or below and 1 for >= 4
    f(a <= 1) = 0.0;
    f(a >= 4) = 1.0;


end


