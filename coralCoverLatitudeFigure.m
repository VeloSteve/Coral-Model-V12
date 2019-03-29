function coralCoverLatitudeFigure(C_yearly, coralSymConstants, startYear, years, RCP, E, OA, superMode, ...
    superAdvantage, fullMapDir, thisRun, allLatLon)
    % Plot coral cover over time in three latitudinal bands.  This is based on
    % coralCoverFigure, but drops the percentile bins to use just mean cover.
    %
    % Latitude bands as defined in Stats_Tables:
    latitude = allLatLon(thisRun, 2);
    eqLim = 7;
    loLim = 15;
    indEq = find(abs(latitude) <= eqLim);
    indLo = find((abs(latitude) > eqLim) & (abs(latitude) <= loLim));
    indHi = find(abs(latitude) > loLim);
    
    % C_yearly averaged within each band
    % C_yearly has year/reef/coral type
    % C_mean will have year/latitude bin/coraltype
    C_mean(:, 1, :) = mean(C_yearly(:, indEq, :), 2); 
    C_mean(:, 2, :) = mean(C_yearly(:, indLo, :), 2); 
    C_mean(:, 3, :) = mean(C_yearly(:, indHi, :), 2); 
    C_mean(:, :, 1) =  100 * C_mean(:, :, 1) / coralSymConstants.KCm;
    C_mean(:, :, 2) =  100 * C_mean(:, :, 2) / coralSymConstants.KCb;
    
    % Now collapse types to just cover (must be after the KC scaling)
    C_mean = sum(C_mean,3);
    
    if superMode == 0 || superMode == 5 || superMode == 7
        suffix = sprintf('_%s_E%dOA%d_SymStrategy%dAdv%0.2fC', RCP, E, OA, superMode, superAdvantage);
    else
        suffix = sprintf('_%s_E%dOA%d_SymStrategy%d', RCP, E, OA, superMode);
    end
    shortID = sprintf(' %s E%d OA%d', RCP, E, OA);
    titleTag = sprintf(' %s E=%d', RCP, E);
    span = (startYear:startYear+years-1)';
    latCoverPlot(fullMapDir, suffix, span, C_mean, shortID, titleTag);
end

function latCoverPlot(fullDir, suffix, year, cover, shortID, titleTag)
    % cover has (year, latitude bin)
    % Create figure
    figure1 = figure('Name',strcat('Mean Coral Cover by Latitude', shortID));

    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
       
    plot1 = plot(year, cover);
    set(plot1(1),'DisplayName','Equatorial','Color',[1 0 0]);
    set(plot1(2),'DisplayName','Mid latitude','Color',[0 0.5 0.5]);
    set(plot1(3),'DisplayName','High latitude','Color',[0 0 1]);
    % If this is wanted, need to calculate the global mean before flattening
    % the arrays.
    %plot2 = plot(year, sum(cover, 2));
    %set(plot2,'DisplayName','Global mean','Color',[0 0 0]);


    % Create xlabel
    xlabel({'Year'});

    % Create title
    title(strcat('Mean Coral Cover by Latitude', titleTag),'FontWeight','bold');

    % Create ylabel
    ylabel('Percent of Carrying Capacity, K');
    
    % Final note.
    % txt = strcat(sprintf('Global mean\n = %5.1f', sum(cover(end, :))), '\rightarrow');
    % text(year(end), sum(cover(end, :)), txt, 'HorizontalAlignment', 'right')
    txt = sprintf('%5.1f', sum(cover(end, :)));
    text(1+year(end), sum(cover(end, :)), txt, 'HorizontalAlignment', 'left', 'FontSize', 13)

    % Uncomment the following line to preserve the X-limits of the axes
    % xlim(axes1,[1860 2100]);
    box(axes1,'on');
    % Set the remaining axes properties
    set(axes1,'FontSize',14);
    % Create legend
    legend1 = legend(axes1,'show', 'Location', 'west');
    %set(legend1,...
    %    'Position',[0.392272766767302 0.35970390099993 0.134089389747584 0.207646171013633],...
    %    'FontSize',13);
    set(legend1,'FontSize',13);
    ylim([0 100]);
    if verLessThan('matlab', '8.2')
        saveas(gcf, strcat(fullDir, 'CoverByLatitude', suffix), 'fig');
    else
        % fprintf('Saving coral cover as fig file.');
        savefig(strcat(fullDir, 'CoverByLatitude', suffix, '.fig'));
    end
end

