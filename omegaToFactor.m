function [f] = omegaToFactor(a)
    % This calculates the fraction to be multiplied by the G constant when acidification is included.
    % see Chan NCS, Connolly SR. 2013. Sensitivity of coral calcification to ocean acidification: A meta-analysis. Glob Change Biol. 19:282–290.
    % Note that G is (in Baskett 2009):
    %       cm growth rate massive: 1 yr%1, branching: 10 yr%1 Huston (1985)
    %       The table references Huston(985), in which I don't see any clear source of these values.
    
    % Most values are between 1 and 4, so just apply the equation to every
    % point first.  Some will be overwritten.
    version = 3;
    switch version
        case 0
            f = 1-(4-a)*0.15;
            
            % Special cases - f = 0 for omega at 1 or below and 1 for >= 4
            f(a <= 1) = 0.0;
            f(a >= 4) = 1.0;
            

        case 1
            % Try an idea from John Dunne, 8/10/2017 to see if there's more effect.
            % Quote:
            % an alternative function, also consistent with the Chan and Connolly
            % analysis, wherein
            % f = max(0,min(1,(omega-omin)/(omega-omin+ko)*(4-omin+ko)/(4-omin)
            % where omin is 0.6 to be consistent with the significant calcification
            % below omega=1 and ko=3 to reproduce the change in slope between he
            % low and high studies.
            omin = 0.6;
            ko = 3.0;
            f = max(0,min(1,(a-omin)./(a-omin+ko)*(4-omin+ko)/(4-omin) ));
        case 2
            % Old format, but variable slope (base is 0.15)
            f = (1-(4-a)*0.30);
            f(a <= 1) = 0.0;
            f(a >= 4) = 1.0;
        case 3
            % Old format, same slope, but SQUARE the result.  This may be
            % justified by Lough & Barnes 2000, where linear extension is
            % proportional to calcification rate.  We are working in terms
            % of area, which is squared.
            f = (1-(4-a)*0.15).^2;
            
            % Special cases - f = 0 for omega at 1 or below and 1 for >= 4
            f(a <= 1) = 0.0;
            f(a >= 4) = 1.0;
        otherwise
            error('Invalid Omega factor option');
    end
end

% for reference, the old code looked like this in V5-V9:
%{
    if Omega_all(k,i) >= 4
        G = [Gm Gb];
    elseif Omega_all(k,i) <= 1
        G = [0 0];
    else
        G = [Gm Gb] - [Gm Gb]*(4-Omega_all(k,i))*0.15;
        %G = omega/(omega+2.65)/3.517*(3.517+2.65)*100;
    end
%}
