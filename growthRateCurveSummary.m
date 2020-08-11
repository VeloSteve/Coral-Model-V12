function growthRateCurveSummary()
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
    
    % Constants for Kingsolver modified Gaussian
    euler = exp(1);
    widthLow = 1; % Need values.  Related to our variance?
    widthHigh = 1; 
    

    % Range to plot
    tMin = 18;
    tMax = 29;
    growthScale = [0 0.6];

    points = 300;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    
    % From timeIteration, June 19 2020:
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(2, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(2, temp(i) - gi(i,:))) * rm;
    
    % From John, March 31 2016:
    % ri(i,:) = (1- (vgi(i,:) + EnvV + (min(0, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) * rm
    

    
    % The growth curves all have a lot in common.  Try to express the
    % differences in terms of the parameters that change.
    % Start from 
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(M1, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) ...
    %        .* exp(X*con.b*min(M2, temp(i) - gi(i,:))) ...
    %        * rm;
    %
    % The values previously changed in separate copies of the equation have now
    % been replaced by M1, M2, and X.
    % There is also term B, named for case B.  It can select special forms
    %   of the equation:
    %   1 = curve B, with min * no min
    %   2 = flipped logic in extra exponential to kick in at T < g.
    % Now we can define the curve options in terms of these.
    % The Baskett curve is different enough to code separately.
    % M1  M2  X  B Name
    % 2   2   1  0 As submitted
    % 2   0   1  0 A
    % 2*  0   1  1 B (in this case the minimum is applied to only half of the squared term)
    % 0   0   1  0 C
    % 0   0   2  0 D  (the X value is still under consideration)
    % 
    
    %% Now we can generate the curves from lists of inputs.
    %  Only these 3 lines are changed below.
    %mmx = [[2 2 1 0]; [2 0 1 0]; [2 0 1 1]; [0, 0, 1, 0]; [0 0 2 0]; [0 0 3 0]; [1 1 1 2]; [2 2 1 2]];
    %labels = {'Submitted', 'A', 'B', 'C=D0', 'D2', 'D3', '1 Deg', 'Neg Min'};
    %styles = {'-r', '-g', '-b', '--k', '--r', '--g', '--b', '.r'};    
    mmx = [[2 2 1 0]; [2 0 1 0];  [0, 0, 1, 0]; [2 2 2 2]; [2 2 1 2]; [1 1 2 2]];
    labels = {'Submitted', 'A',  'C=D0',  '2, X2', 'Neg Min', '1, X2'};
    styles = {'-r', '-g',  '--k', '--b', '.r', '.k'};
      
    %%
    T=25;
    rm  = a*exp(b*T);
    M1 = 1;
    M2 = 1;
    peakgrowth_1 = [1- (vg + EnvVx + min(1, g - T).^2) ./ (2*SelVx)] .* exp(b*min(0, T - g + M2)) * rm; %symbiont 1
    peakgrowth_2 = [1- (vg + EnvVx + min(1, g2 - T).^2) ./ (2*SelVx)] .* exp(b*min(0, T - g2 + M2)) * rm; %symbiont 2
    offset = (peakgrowth_1 - peakgrowth_2)*.5; % offset shifts heat tolerant sym curve down 
    
    % Try another offset calculation, solving both equations at their T=g
    % points, but using rm values at those points.
    peakgrowth_main = [1- (vg + EnvVx) ./ (2*SelVx)]; % same for both
    rm_1 = a*exp(b*g);
    rm_2 = a*exp(b*g2);
    offsetb = peakgrowth_main * (rm_2 - rm_1); % offset shifts heat tolerant sym curve down 
    
    
    %%
    rates = NaN(points, size(mmx, 1));
    rates2009 = NaN(points);
    ratesKingsolver = NaN(points);
    ratesHot = NaN(points);
    ratesHotB = NaN(points);
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp CK
        for curve = 1:size(mmx,1)
            M1 = mmx(curve, 1);  % These could be used directly in the
            M2 = mmx(curve, 2);  % equations, but this keeps them more readable.
            X = mmx(curve, 3);
            B = mmx(curve, 4);
            if B == 1
                mainPart = 1- (vg + EnvVx + min(M1, g - T)*(g-T)) ./ (2*SelVx);              
            else
                mainPart = 1- (vg + EnvVx + min(M1, g - T).^2) ./ (2*SelVx);
            end
            if B == 2
                extraExp = exp(X * b*min(0, T - g + M2));
            else
                extraExp = exp(X * b*min(M2, T - g));
            end
            rates(j, curve) = mainPart * extraExp * rm;
        end
        % Baskett 2009 eq. 3
        rates2009(j) = (1- (vg + EnvVx + (g - T).^2) ./ (2*SelVx)) * rm ;% Prevents cold water bleaching
        ratesKingsolver(j) = rm /70000000 * exp(-euler*(widthLow*(T-g)-6)-widthHigh*(T-g)^2);
        % Semi-hardwired hot adapted curve.
        M1 = 1;
        M2 = 1;
        mainPart = 1- (vg + EnvVx + min(M1, g2 - T).^2) ./ (2*SelVx);
        extraExp = exp(X * b*min(0, T - g2 + M2));

        ratesHot(j) = mainPart * extraExp * rm; % - offset;
        ratesHotB(j) = mainPart * extraExp * rm - offsetb;
    end
    

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 550 550]);
    %axes1 = axes;

    xlim([tMin tMax]);

    plot(temps, rates2009(:,1), '-k', 'LineWidth', 6, 'DisplayName', 'Baskett et al. 2009');
    hold on;
    for curve = 1:size(mmx, 1)
        plot(temps, rates(:,curve), styles{curve}, 'LineWidth', 3, 'DisplayName', labels{curve}); % rate with 2 min
    end
    plot(temps, ratesKingsolver(:,1), '-m', 'LineWidth', 2, 'DisplayName', 'Kingsolver and Wood 2016');
    plot(temps, ratesHot(:,1), '-c', 'LineWidth', 2, 'DisplayName', 'g2, no offset');
    plot(temps, ratesHotB(:,1), '.c', 'LineWidth', 2, 'DisplayName', 'Offset V2');


    % optimum
    %plot([g g], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g1m)');
    %plot([g2 g2], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g2m)');
    plot(g,growthScale(1),'ko', 'DisplayName', 'mean genotype (1)');
    %plot(g2,.15,'kx','DisplayName', 'mean genotype (2)');

    legend('Location', 'NorthWest', 'FontSize', 10);
    ylim(growthScale);   
    xlim([tMin tMax]);    

    hold off;
    
    % Save figure using -cmyk colors using print function
    %print('-dpdf', 'SymGrowthCurve_071020.pdf', '-cmyk', '-bestfit');
    %print('-dpng', 'SymGrowthCurve_071020.png', '-cmyk');
end



