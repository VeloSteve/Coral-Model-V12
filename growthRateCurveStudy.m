function growthRateCurveStudy()
    % This script is for visualizing the growth curve with representative
    % values to understand each term better
    g = 24.7;
    SelVx = 2.8;
    b = 0.0633;
    a = 0.0879;
    vg = .0025;
    EnvVx = 0.0114;
    
   

    tMin = 15; %20;
    tMax = 35; %32;
    growthScale = [-0.5 1.2];

    points = 100;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    
    rates = NaN(points, 2);
    terms = NaN(points, 5);
    rates2009 = NaN(points, 2);
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp
        terms(j, 1) = rm;
        extraExp = exp(b*min(0, T - g));
        terms(j, 2) = extraExp;
        mainPart = (1- (vg + EnvVx + (min(0, g - T)).^2) ./ (2*SelVx));
        terms(j, 3) = mainPart; 
        mainNoMin = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx));
        terms(j, 4) = mainNoMin;
        % As used in Spring 2017 code:
        r = mainPart .* extraExp * rm;
        % Baskett 2009 eq. 3
        r2009 = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching
        rates(j, :) = r;
        rates2009(j, :) = r2009;
        
        extraExpDbl = exp(2*b*min(0, T - g));
        terms(j, 5) = extraExpDbl;
    end
    
    specs = {'-k', '-m', '-g', 'om', '-b', '-r', '-.k'};

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 1000 783]);
    %axes1 = axes;

    xlim([tMin tMax]);

    plot(temps, rates(:,1), specs{1}); %, gi(:,2)); %, gi(:,3), gi(:,4));
    hold on;
    plot(temps, rates2009(:,1), specs{5}, 'LineWidth', 1);
    plot(temps, terms(:, 1), specs{2}, 'LineWidth', 1);
    plot(temps, terms(:, 2), specs{3}, 'LineWidth', 1);
    plot(temps, terms(:, 3), specs{4}, 'LineWidth', 1);
    plot(temps, terms(:, 4), specs{6}, 'LineWidth', 1);
    plot(temps, terms(:, 5), specs{7}, 'LineWidth', 1);
    

    


    set(gca, 'FontSize', 21);
    t = sprintf('Growth rate terms vs T');
    title(t);
    xlabel('Temperature (C)');
    ylabel('Growth Rate');
    %set(axes1,'FontSize',21);
    legend({'symbiont growth', 'Baskett 2009', 'rm term', 'new exp term', 'main equation', 'main no min', 'new exp 2b'}, ...
        'Location', 'best', 'FontSize',18);

    % Now just use a fixed y range
    ylim(growthScale);
        
    hold off;
end

