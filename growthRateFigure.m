function growthRateFigure(fullDir, suffix, yearStr, k, temp, fullYearRange, gi, vgi, ssi, con, SelVx, RCP)
    % To compare native and enhanced symbionts, take gi and vgi
    % values just past the start point ssi and the plot above and below
    % the two genotypes for massive only.
        % vgi - 2D array, the same size as S and C, with symbiont variance.
        % gi  - Symbiont mean genotype over time
    
    if ssi >= length(vgi)
        sEnd = length(vgi);
        vg(1) = vgi(sEnd, 1);
        vg(2) = vgi(sEnd, 3);
        g(1) = gi(sEnd, 1);
        g(2) = gi(sEnd, 3);
        t0 = temp(sEnd);
    else
        vg(1) = vgi(ssi+1, 1);
        vg(2) = vgi(ssi+1, 3);
        g(1) = gi(ssi+1, 1);
        g(2) = gi(ssi+1, 3);
        t0 = temp(ssi+1);
    end
    
    tMin = 15; %20;
    tMax = 35; %32;
    growthScale = [0.0 0.6];
    growthTicks = [0.0 0.2 0.4 0.6];

    % Get temperature range for 3 years leading up to the time of the graph
    % and for 1900 to 1950.
    historicRange = getTRange(1900, 1950, temp, fullYearRange);
    y = str2double(yearStr);
    recentRange = getTRange(y-3, y, temp, fullYearRange);

    points = 200;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    rates = NaN(points, 2);
    rates2009 = NaN(points, 2);
    tGTZ = nan;
    tLTZ = nan;
    for j = 1:points
        % Last term of Baskett 2009 eq. 3:
        rm  = con.a*exp(con.b*temps(j)) ; % maximum possible growth rate at optimal temp
        T = temps(j);
        % As used in Spring 2017 code:
        r = (1- (vg + con.EnvVx(1:2:3) + (min(0, g - T)).^2) ./ (2*SelVx(1:2:3))) .* exp(con.b*min(0, T - g)) * rm;
        %r2014 = (1- (vg + con.EnvVx(1:2:3) + (min(0, g - T)).^2) ./ (2*SelVx(1:2:3))) * rm ;% Prevents cold water bleaching
        % Baskett 2009 eq. 3
        r2009 = (1- (vg + con.EnvVx(1:2:3) + (g - T).^2) ./ (2*SelVx(1:2:3))) * rm ;% Prevents cold water bleaching
        %rEpp = rm;
        rates(j, :) = r;
        %rates2014(j, :) = r2014;
        rates2009(j, :) = r2009;
        %ratesEpp(j, :) = rEpp;
        % Save T at which growth curve drops to zero.
        if isnan(tGTZ) && r(1) > 0
            tGTZ = T;
        elseif ~isnan(tGTZ) && isnan(tLTZ) && r(1) < 0
            tLTZ = T;
        end
    end
    
    specs = {'-k', '-m', ':c', '--m', '-b', ':b', '-.k'};

    figHandle = figure(4000+k);
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 1000 783]);
    %axes1 = axes;

    % Shade area for historic temperatures.
    ty = [growthScale fliplr(growthScale)];
    tx = repelem(historicRange, 2);


    plot(temps, rates(:,1), specs{1}); %, gi(:,2)); %, gi(:,3), gi(:,4));
    hold on;
    plot(temps, rates2009(:,1), specs{5});
    plot([g(1) g(1)], [min(min(rates)) max(max(rates))], ':k');  % current optimum
    %plot([g(2) g(2)], [min(min(rates)) max(max(rates))], '-.k');
    % replaced by shaded areas
    % plot([t0 t0], [min(min(rates)) max(max(rates))], '--k');  % current actual T
    
    patch('DisplayName', 'Historic T Range', 'YData', ty, 'XData', tx, 'FaceAlpha', 0.2, 'LineStyle', 'none', 'FaceColor', [.75 .75 .75])
    % Shade area for recent temperatures.
    ty = [growthScale fliplr(growthScale)];
    tx = repelem(recentRange, 2);
    patch('DisplayName', 'Recent T Range', 'YData', ty, 'XData', tx, 'FaceAlpha', 0.2, 'LineStyle', 'none', 'FaceColor', [1.0 .7 .7])

    set(gca, 'FontSize', 21);
    t = sprintf('Growth rate vs T for Reef %d in %s, RCP = %3.1f', k, yearStr, str2double(extractAfter(RCP, 'rcp'))/10.0);
    title(t);
    xlabel('Temperature (C)');
    ylabel('Growth Rate');
    %set(axes1,'FontSize',21);
    legend({'symbiont growth', 'Baskett 2009', 'Adapted T', 'Historic Range', 'Recent Range'}, ...
        'Location', 'best', 'FontSize',18);

    xlim([tMin tMax]);
    % Now just use a fixed y range
    ylim(growthScale);
    yticks(growthTicks);
    
    % TODO: probably don't want to keep this...
    if isnan(tLTZ)
        oh = 'NeverReachedZero';
    else
        overheat = recentRange(2) - tLTZ;
        if overheat < 0.0
            oh = strcat('M', num2str(abs(overheat),'%5.3f'));
        else
            oh = strcat('P', num2str(overheat, '%5.3f'));
        end
    end
        
    hold off;
    print(figHandle, '-dpdf', '-r200', '-bestfit', strcat(fullDir, oh, 'GrowthCurve', suffix, '.pdf'));
    savefig(figHandle, strcat(fullDir, 'GrowthCurve', suffix, '.fig'));
end

% Find the low and high temperature for the given range of years.  This
% makes the assumption that the temperature array is linearly spaced from
% January 1 in yearRange(1) to December 31 in yearRange(2).
function [range] = getTRange(y1, y2, temp, yearRange)
  % Get indexes
  spy = length(temp) / (yearRange(2) - yearRange(1));
  i1 = round(max(1, (y1 - yearRange(1)) * spy));
  i2 = round(min(length(temp), (y2 - yearRange(1)) * spy));
  low = min(temp(i1:i2));
  high = max(temp(i1:i2));
  range = [low high];
end
%{
To find T range for a time period
Find the numerical date:
datenum('2035-01-01')
datenum('2035-12-31')
then manually look up that value in TIME.  The indexes there will be the
indexes in SST for that date range.

To shade background for a T range:
ty = [-0.5 1 1 -0.5];
tx = [20.796 20.796 33.94 33.94];
patch('DisplayName', '2034 T Range', 'YData', ty, 'XData', tx, 'FaceAlpha', 0.2, 'LineStyle', 'none', 'FaceColor', [.8 .8 .8])
%}