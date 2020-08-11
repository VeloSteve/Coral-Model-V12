function growthRateCurveStudyReduced()
    % This script is for visualizing the growth curve with representative
    % values to understand each term better
    g = 25.0;
    SelVx = 3.4627; % for massive: 2.7702;
    b = 0.0633;
    a = 1.0768/12; %0.0879;
    vg = .0025;
    EnvVx = 0.0114;
    advantage = 1;
    g2 = g + advantage; % for heat tolerant symbiont; could be 0.5,1 or 1.5C advantage

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
    
    % From John, March 31 2016:
    % ri(i,:) = (1- (vgi(i,:) + EnvV + (min(0, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) * rm
    
    rates = NaN(points, 7);
    rates2009 = NaN(points);
    
    % Get offset => 0.5 * difference in peak growth rate between sym 1 and sym 2 when g=T
    T=25;
    rm  = a*exp(b*T);
    peakgrowth_1 = [1- (vg + EnvVx + min(0, g - T).^2) ./ (2*SelVx)] .* exp(b*min(0, T - g)) * rm; %symbiont 1
    peakgrowth_2 = [1- (vg + EnvVx + min(0, g2 - T).^2) ./ (2*SelVx)] .* exp(b*min(0, T - g2)) * rm; %symbiont 2
    offset = (peakgrowth_1 - peakgrowth_2)*.5; % offset shifts heat tolerant sym curve down 
        
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp CK
        
        extraExp = exp(b*min(0, T - g));
        extraExp2 = exp(b*min(2, T - g));
        extraExp3 = exp(b*min(0, T - g2)); % for heat tolerant symbiont
        extraExpM2 = exp(2*b*min(0, T - g));
        extraExpM3 = exp(3*b*min(0, T - g));

        
        mainPart2 = 1- (vg + EnvVx + min(2, g - T).^2) ./ (2*SelVx); % submitted version
        mainPart3 = 1- (vg + EnvVx + min(0, g - T).^2) ./ (2*SelVx); % John's original eqn to prevent cold-water bleaching 
        mainPart4 = 1- (vg + EnvVx + min(0, g2 - T).^2) ./ (2*SelVx); % John's original eqn for heat tolerant symbiont
        mainPart5 = 1- (vg + EnvVx + min(0.5, g - T).*(g-T)) ./ (2*SelVx); % Split minimum for steeper cold-side drop
        mainPart6 = 1- (vg + EnvVx + min(0.5, g - T).^2) ./ (2*SelVx); % John's original eqn to prevent cold-water bleaching 

        % As used in Spring 2017 code:
        r2 = mainPart2 * extraExp2 * rm;
        % Try shifting down the left side with a multiplier in the extra
        % exponential.
        r3 = mainPart3 * extraExpM2 * rm;
        % Set both minima to zero.
        r4 = mainPart3 * extraExp * rm;        
        % Try 3 multiplier.
        r5 = mainPart3 * extraExpM3 * rm;
        
        %offset is the difference in growth rate between the peak growth
        %rate when g=T


        
        % Baskett 2009 eq. 3
        r2009 = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching
        
        rates(j, 2) = r2;
        rates(j, 3) = r3;
        rates(j, 4) = r4;
        rates(j, 5) = r5;

        rates2009(j) = r2009;
    end
    

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 550 550]);
    %axes1 = axes;

    xlim([tMin tMax]);

    plot(temps, rates2009(:,1), '-k', 'LineWidth', 6, 'DisplayName', 'Growth, Baskett et al. 2009');
    hold on;
    plot(temps, rates(:,2), '-r', 'LineWidth', 4, 'DisplayName', 'Growth, as submitted'); % rate with 2 min
    plot(temps, rates(:,3), '-c', 'LineWidth', 2, 'DisplayName', 'Growth, Mult 2'); % rate with 2 min in main function, zero in exponential
    plot(temps, rates(:,4), '-g', 'LineWidth', 2, 'DisplayName', 'Growth, 0 min'); % rate with 2 min in main function, zero in exponential
    plot(temps, rates(:,5), '-b', 'LineWidth', 2, 'DisplayName', 'Growth, Mult 3'); % rate with 2 min in main function, zero in exponential

    % optimum
    %plot([g g], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g1m)');
    %plot([g2 g2], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g2m)');
    plot(g,.15,'ko', 'DisplayName', 'mean genotype (1)');
    %plot(g2,.15,'kx','DisplayName', 'mean genotype (2)');

    set(gca, 'FontSize', 21);
    t = sprintf('Growth rate vs T');
    % title(t);
    %xlabel('Environmental Temperature (C)');
    %ylabel('Symbiont Growth Rate');
    %set(axes1,'FontSize',21);
    %legend({'symbiont growth 0 min', 'symbiont growth 2 min', 'Baskett 2009', 'rm term', ...
    %    'new exp term', 'main equation', 'main no min', 'main 2 min', 'new exp 2 min'}, ...
    %    'Location', 'best', 'FontSize',18);
    legend('Location', 'NorthWest', 'FontSize', 10);
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
    %ylim(growthScale);
    ylim([.0 .5]);   
    xlim([18 29]);    
    %ylim([-0.5, 1.2]);   
    %xlim([15, 35]);  
    %set(gca,'xticklabel',[]) % to remove axis labels for figure
    %set(gca,'yticklabel',[]) % to remove axis labels for figure
    hold off;
    
    % Save figure using -cmyk colors using print function
    print('-dpdf', 'SymGrowthCurve_071020.pdf', '-cmyk', '-bestfit');
    print('-dpng', 'SymGrowthCurve_071020.png', '-cmyk');
end



