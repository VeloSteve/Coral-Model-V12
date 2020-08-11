function growthRateCurveSummary()
    % This script is for visualizing the growth curve with representative
    % values to understand each term better
    % This particular version is cut down to just the final (July 2020) curves
    % for Figure S1.
    g0 = 25.0;
    SelVx = 3.4627; % for massive: 2.7702;
    b = 0.0633;
    a = 1.0768/12; %0.0879;
    vg = .0025;
    EnvVx = 0.0114;
    advantage = 1;
    g2 = g0 + advantage; % for heat tolerant symbiont; could be 0.5,1 or 1.5C advantage
    
    % Range to plot
    tMin = 15;
    tMax = 30;
    growthScale = [0 0.5];

    points = 300;
    temps = linspace(tMin, tMax, points);
    % The equation in the loop is exactly the one in timeIteration, other
    % than variable naming.
    
    % From timeIteration, June 19 2020:
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(2, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(2, temp(i) - gi(i,:))) * rm;
    % The new E221 curve:
    % ri(i,:) = (1- (vgi(i,:) + con.EnvVx + (min(2, gi(i,:) - temp(i))).^2) ./ (2*SelVx)) .* exp(con.b*min(0, temp(i) - gi(i,:) + 2)) * rm;

    % The curve plotted is known as E221, essentially the same as in the work
    % originally submitted, but with a correction.
    % 
    
    %% Now we can generate the curves from lists of inputs.
    % The values in mmx are
    % 1) M1 The value in the first min function.
    % 2) M2 The value in the "extra exponential", original an argument to "min",
    %    now a value added to gi.
    % 3) X a multiplier on the "b" growth constant meant to steepen the curve
    %    left of optimum.
    % 4) B to select optional equation forms, currently the +1 advantage for
    % shuffling.
    mmx = [[2 2 1 0]; [2 2 1 1]];
    labels = {'Symbiont Growth', 'Tolerant Symbiont'};
    styles = {'-k', '-b',  '--k', '--b', '.r', '.k'};   
    
    %%
    rates = NaN(points, size(mmx, 1));
    for j = 1:points
        T = temps(j);
        % Last term of Baskett 2009 eq. 3:
        rm  = a*exp(b*T); % maximum possible growth rate at optimal temp CK
        for curve = 1:size(mmx,1)
            M1 = mmx(curve, 1);  % These could be used directly in the
            M2 = mmx(curve, 2);  % equations, but this keeps them more readable.
            X = mmx(curve, 3);
            B = mmx(curve, 4);
            if B == 0
                g = g0;
            else
                g = g2;
            end
            mainPart = 1- (vg + EnvVx + min(M1, g - T).^2) ./ (2*SelVx);
            extraExp = exp(X * b*min(0, T - g + M2));
            rates(j, curve) = mainPart * extraExp * rm;
        end
    end
    

    figHandle = figure();
    set(figHandle, 'color', 'w', 'OuterPosition',[60 269 550 550]);
    %axes1 = axes;

    for curve = 1:size(mmx, 1)
        plot(temps, rates(:,curve), styles{curve}, 'LineWidth', 3, 'DisplayName', labels{curve}); % rate with 2 min
        hold on;
    end


    % optimum
    %plot([g g], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g1m)');
    %plot([g2 g2], growthScale, 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'mean genotype (g2m)');
    plot(g0,growthScale(1),'ko', 'DisplayName', 'Adapted T');
    %plot(g2,.15,'kx','DisplayName', 'mean genotype (2)');

    legend('Location', 'NorthWest', 'FontSize', 12);
    ylim(growthScale);   
    xlim([tMin tMax]);    
    ylabel('Symbiont Growth Rate');
    xlabel('Temperature (C)');
    
    set(gca,'FontSize',14,'YTick',[0 0.25 0.5]);


    hold off;
    
    % Save figure using -cmyk colors using print function
    %print('-dpdf', 'SymGrowthCurve_071020.pdf', '-cmyk', '-bestfit');
    %print('-dpng', 'SymGrowthCurve_071020.png', '-cmyk');
end



