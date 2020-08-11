function growthRateCurveStudyReduced()
    % This script is for visualizing the growth curve with representative
    % values to understand each term better
    g = 25.0;
    SelVx = 3.4627; % for massive: 2.7702;
    b = 0.0633;
    a = 1.0768/12; %0.0879;
    vg = .0025;
    EnvVx = 0.0114;

    % Range to plot
    tMin = 15; %20;
    tMax = 35; %32;
    growthScale = [-0.4 0.6];

    points = 300;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    
    % From timeIteration, June 19 2020:
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(2, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(2, temp(i) - gi(i,:))) * rm;
    
    rates = NaN(points, 3);
    rates2009 = NaN(points);
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp CK
        
        extraExp = exp(b*min(0, T - g));
        extraExp2 = exp(b*min(2, T - g));
        mainPart2 = 1- (vg + EnvVx + min(2, g - T).^2) ./ (2*SelVx);

        % As used in Spring 2017 code:
        r2 = mainPart2 .* extraExp2 * rm;
        r3 = mainPart2 .* extraExp * rm; % TRY - extra exponential NOT shifted up 2 deg.
        
        % Baskett 2009 eq. 3
        r2009 = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching
        rates(j, 2) = r2;
        rates(j, 3) = r3;

        rates2009(j) = r2009;
    end
    

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 1200 1000]);
    %axes1 = axes;

    xlim([tMin tMax]);

    plot(temps, rates2009(:,1), '-k', 'LineWidth', 6, 'DisplayName', 'Growth, Baskett et al. 2009');
    hold on;
    plot(temps, rates(:,2), '-r', 'LineWidth', 4, 'DisplayName', 'Growth, as submitted'); % rate with 2 min
    plot(temps, rates(:,3), '-c', 'LineWidth', 2, 'DisplayName', 'Growth, 2/0 min, Option A'); % rate with 2 min in main function, zero in exponential

    % optimum
    plot([g g], growthScale, '-y', 'DisplayName', 'adapted temperature');
    


    set(gca, 'FontSize', 21);
    t = sprintf('Growth rate vs T');
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

