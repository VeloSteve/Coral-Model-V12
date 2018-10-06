function coralCoverFigure(C_yearly, coralSymConstants, startYear, years, RCP, E, OA, superMode, ...
    superAdvantage, fullMapDir)
    % New dominance graph
    % Get stats based on C_yearly - try getting quantiles per row.
    % C_yearly has year/reef/coral type
    % C_quant will have year/quantiles/coraltype
    %C_quant = quantile(C_yearly, [0.1 0.25 0.5 0.75 0.9], 2);
    % 5% to 95% is more standard:
    C_quant = quantile(C_yearly, [0.05 0.25 0.5 0.75 0.95], 2);
    % Normalize
    C_quant(:, :, 1) =  100 * C_quant(:, :, 1) / coralSymConstants.KCm;
    C_quant(:, :, 2) =  100 * C_quant(:, :, 2) / coralSymConstants.KCb;
    % Create vertexes around area to shade, running left to right and
    % then right to left.
    % 5% and 95%
    span = (startYear:startYear+years-1)';

    if superMode == 0 || superMode == 5 || superMode >= 7
        suffix = sprintf('_%s_E%dOA%d_SymStrategy%dAdv%0.2fC', RCP, E, OA, superMode, superAdvantage);
    else
        suffix = sprintf('_%s_E%dOA%d_SymStrategy%d', RCP, E, OA, superMode);
    end
    coralCoverPlot(fullMapDir, suffix, [span;flipud(span)], ...           % x values for areas
        [C_quant(:,1,1);flipud(C_quant(:,5,1))], ...    % wide quantiles, massive
        [C_quant(:,1,2);flipud(C_quant(:,5,2))], ...    % wide quantiles, branching
        [C_quant(:,2,1);flipud(C_quant(:,4,1))], ...    % narrow quantiles, massive
        [C_quant(:,2,2);flipud(C_quant(:,4,2))], ...    % narrow quantiles, branching
        span, squeeze(C_quant(:, 3, 1:2)));             % values for lines
    
    % Create a second plot showing just the global mean cover.  Put the 2100
    % value on as text as an easy reference for table-building.
    % average across all reefs
    C_mean = mean(C_yearly, 2); 
    % Scale each coral type
    C_mean(:, 1) =  100 * C_mean(:, 1) / coralSymConstants.KCm;
    C_mean(:, 2) =  100 * C_mean(:, 2) / coralSymConstants.KCb;
    meanCoverPlot(fullMapDir, suffix, span, squeeze(C_mean));
end

function meanCoverPlot(fullDir, suffix, year, cover)
    % Create figure
    figure1 = figure('Name','Mean Global Coral Cover');

    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
       
    plot1 = plot(year, cover);
    set(plot1(1),'DisplayName','Massive coral','Color',[1 0 0]);
    set(plot1(2),'DisplayName','Branching coral','Color',[0 0 1]);
    plot2 = plot(year, sum(cover, 2));
    set(plot2,'DisplayName','Total','Color',[0 0 0]);


    % Create xlabel
    xlabel({'Year'});

    % Create title
    title('Global Mean Coral Cover','FontWeight','bold');

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
        saveas(gcf, strcat(fullDir, 'MeanCoralCover', suffix), 'fig');
    else
        fprintf('Saving coral cover as fig file.');
        savefig(strcat(fullDir, 'MeanCoralCover', suffix, '.fig'));
    end
end

function coralCoverPlot(fullDir, suffix, XData1, YData1, YData2, YData3, YData4, X1, YMatrix1)
%CREATEFIGURE(YDATA1, XDATA1, YDATA2, YDATA3, YDATA4, X1, YMATRIX1)
    %  YDATA1:  patch ydata
    %  XDATA1:  patch xdata
    %  YDATA2:  patch ydata
    %  YDATA3:  patch ydata
    %  YDATA4:  patch ydata
    %  X1:  vector of x data
    %  YMATRIX1:  matrix of y data

    %  Auto-generated by MATLAB on 03-Feb-2017 15:39:08

    % Create figure
    figure1 = figure('Name','Global Coral Cover');

    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');

    transparency = 0.2;
    % Create patch for massive, 5-95
    patch('Parent',axes1,'DisplayName','5th - 95th percentile','YData',YData1,...
        'XData',XData1,...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',[1 0.8 0.8]);

    % Create patch for branching, 5-95
    patch('Parent',axes1,'DisplayName','5th - 95th percentile','YData',YData2,...
        'XData',XData1,...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',[0.75 0.75 1]);

    % Create patch for massive, 25-75
    patch('Parent',axes1,'DisplayName','25th - 75th percentile','YData',YData3,...
        'XData',XData1,...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',[1 0.5 0.5]);

    % Create patch for massive, 25-75
    patch('Parent',axes1,'DisplayName','25th - 75th percentile','YData',YData4,...
        'XData',XData1,...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',[0.45 0.45 1]);

    % Create multiple lines using matrix input to plot
    plot1 = plot(X1,YMatrix1);
    set(plot1(1),'DisplayName','Massive coral','Color',[1 0 0]);
    set(plot1(2),'DisplayName','Branching coral','Color',[0 0 1]);

    % Create xlabel
    xlabel({'Year'});

    % Create title
    title('Global Coral Cover','FontWeight','bold');

    % Create ylabel
    ylabel('Percent of Carrying Capacity, K');

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
% XXX not supported in GUI!    print('-dpdf', '-r200', strcat(fullDir, 'GlobalCoralCover', suffix, '.pdf'));
    if verLessThan('matlab', '8.2')
        saveas(gcf, strcat(fullDir, 'GlobalCoralCover', suffix), 'fig');
    else
        fprintf('Saving coral cover as fig file.');
        savefig(strcat(fullDir, 'GlobalCoralCover', suffix, '.fig'));
    end

end
