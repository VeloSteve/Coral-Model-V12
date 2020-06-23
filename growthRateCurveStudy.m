function growthRateCurveStudy()
    % This script is for visualizing the growth curve with representative
    % values to understand each term better
    g = 24.7;
    SelVx = 3.4627; % for massive: 2.7702;
    b = 0.0633;
    a = 1.0768/12; %0.0879;
    vg = .0025;
    EnvVx = 0.0114;
    
    % Curve is offset to the right of the adapted temperature because the
    % Norberg-Eppley exponential keeps rising.  The delta is
    offset = (-1 + sqrt(1+ b*b*2*SelVx))/b;
   

    tMin = 15; %20;
    tMax = 35; %32;
    growthScale = [-0.5 1.2];

    points = 300;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    
    % From timeIteration, June 19 2020:
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(2, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(2, temp(i) - gi(i,:))) * rm;
    
    rates = NaN(points, 5);
    terms = NaN(points, 8);
    rates2009 = NaN(points, 2);
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp CK
        terms(j, 1) = rm;
        extraExp = exp(b*min(0, T - g));
        extraExp2 = exp(b*min(2, T - g));
        terms(j, 2) = extraExp;
        terms(j, 6) = extraExp2;
        mainPart =  1- (vg + EnvVx + min(0, g - T).^2) ./ (2*SelVx);
        mainPart2 = 1- (vg + EnvVx + min(2, g - T).^2) ./ (2*SelVx);
        mainPart3 = 1- (vg + EnvVx + min(2, g - T)*(g-T)) ./ (2*SelVx);
        terms(j, 3) = mainPart; 
        terms(j, 7) = mainPart2;
        terms(j, 8) = mainPart3;
        mainNoMin = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx));
        terms(j, 4) = mainNoMin;
        % As used in Spring 2017 code:
        r = mainPart .* extraExp * rm;
        r2 = mainPart2 .* extraExp2 * rm;
        r3 = mainPart2 .* extraExp * rm; % TRY - extra exponential NOT shifted up 2 deg.
        r4 = mainPart3 * rm; % Try different main, no extra.  6/22/2020
        
        mainPartOffset =  1- (vg + EnvVx + min(2, g - T - offset).^2) ./ (2*SelVx);
        rmOffset = a*exp(b*(T + offset)); % maximum possible growth rate at optimal temp CK
        extraExpOffset = exp(b*min(0, T + offset - g));
        r5 = mainPartOffset * rmOffset * extraExpOffset;
        
        % Baskett 2009 eq. 3
        r2009 = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching
        rates(j, 1) = r;
        rates(j, 2) = r2;
        rates(j, 3) = r3;
        rates(j, 4) = r4;
        rates(j, 5) = r5;
        rates2009(j, :) = r2009;
        
        %terms(j, 5) = extraExpDbl;
    end
    
    %specs = {'-k', '-m', '-g', 'om', '-b', '-r', '-.k', '-.m', '-.g'};
    % Use dots for Baskett, line for current (2 min), circles for 0 min
    % black = growth (all terms)
    % green = Eppley term
    % magenta = new exponential
    % blue = main eq. with no exponentials (but possibly a minimum)

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 1200 1000]);
    %axes1 = axes;

    xlim([tMin tMax]);

    plot(temps, rates(:,1), 'ok', 'DisplayName', 'Growth, 0 min');
    hold on;
    plot(temps, rates(:,2), '-k', 'LineWidth', 2, 'DisplayName', 'Growth, 2 min'); % rate with 2 min
    plot(temps, rates(:,3), '+k', 'DisplayName', 'Growth, 2/0 min'); % rate with 2 min in main function, zero in exponential
    plot(temps, rates(:,4), '-.k', 'DisplayName', 'Growth, 2 min * no min'); % rate with 2 min AND no min in main function, no extra exp.
    plot(temps, rates(:,5), 'xk', 'DisplayName', 'Growth, 2/0 min, offset'); % 2/0 but offset to have max growth at g
    plot(temps, rates2009(:,1), '--k', 'LineWidth', 1, 'DisplayName', 'Growth, Baskett 2009');

    plot(temps, terms(:, 1), '-g', 'LineWidth', 1, 'DisplayName', 'fixed exponential'); % rm
    plot(temps, terms(:, 2), 'om', 'LineWidth', 1, 'DisplayName', 'new exp, 0 min'); % extraExp, 0 min
    plot(temps, terms(:, 6), '-m', 'LineWidth', 1, 'DisplayName', 'new exp, 2 min'); % extraExp, 2 min
    plot(temps, terms(:, 4), '--b', 'LineWidth', 1, 'DisplayName', 'main part, no min'); % mainNoMin no min
    plot(temps, terms(:, 3), 'ob', 'LineWidth', 1, 'DisplayName', 'main part, 0 min'); % mainPart  0 min
    plot(temps, terms(:, 7), '-b', 'LineWidth', 1, 'DisplayName', 'main part, 2 min'); % mainPart2 2 min
    plot(temps, terms(:, 8), '-.b', 'LineWidth', 1, 'DisplayName', 'main part, 2 min * no min'); % mainPart2 2 min * no main (instead of squared)
    
    % optimum
    plot([g g], growthScale, '-y', 'DisplayName', 'adapted temperature');
    


    set(gca, 'FontSize', 21);
    t = sprintf('Growth rate terms vs T');
    title(t);
    xlabel('Temperature (C)');
    ylabel('Growth Rate');
    %set(axes1,'FontSize',21);
    %legend({'symbiont growth 0 min', 'symbiont growth 2 min', 'Baskett 2009', 'rm term', ...
    %    'new exp term', 'main equation', 'main no min', 'main 2 min', 'new exp 2 min'}, ...
    %    'Location', 'best', 'FontSize',18);
    legend('Location', 'best', 'FontSize', 16);
    % Further explanation of legend items:
    % 'symbiont growth 0' - growth equation as used from Spring 2017
    % 'symbiont growth 2' - growth equation as used in the submitted paper
    % 'Baskett 2009' - from Baskett et al. 2009
    % 'rm term' - just the exponential term used in all versions (Eppley?)
    % 'new exp term' - the new exponential term with zero minimum
    % 'main equation' - three terms summed, before they are multiplied by an exponential
    % 'main no min' - the same three terms, but with no minimum function in the third part (as in Baskett)
    % 'new exp 2b' - the new exponential, 2 minimum

    % Now just use a fixed y range
    ylim(growthScale);
        
    hold off;
end

