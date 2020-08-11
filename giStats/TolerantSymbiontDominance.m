% Read all the genotype information from a given directory and calculate
% required stats.  This will be memory intensive, since there's about 2G of data
% on disk per run.
% E = 0
%figList = {'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp26.E0.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
%           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp45.E0.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
%           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp60.E0.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
%           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp85.E0.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig'};
% E = 1
figList = {'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp26.E1.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp45.E1.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp60.E1.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig', ...
           'D:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/ESM2M.rcp85.E1.OA0.sM9.sA1.0.20200722_maps/SymbiontDominance.fig'};
baseColor = [0, 0, 1; 0, 1, 0; 0.9, 0.9, 0; 1, 0, 0];
cases = size(figList, 2);
caseNames = {'RCP 2.6', 'RCP 4.5', 'RCP 6.0', 'RCP 8.5'};

% Create a single figure, but use the function to add to specified subplots.
newFig = figure();
set(gcf, 'Units', 'inches', 'Position', [1, 1, 14, 6]);
subplot1 = subplot(1, 2, 1);
title("Branching Corals");
subplot2 = subplot(1, 2, 2);
title("Mounding Corals");
for d = 1:cases
    addOneCase(caseNames{d}, figList{d}, subplot1, subplot2, baseColor(d, :));
end

legend(subplot1, 'Location', 'southeast');
legend(subplot2, 'Location', 'southeast');
axes(subplot1);
xlim([1950 2100]);
ylim([0.4 1.0]);
ylabel('Fraction of Tolerant Symbionts', 'FontSize',14,'FontWeight','bold');
set(subplot1,'FontSize',14,'FontWeight','bold','XTick',...
    [1950 2000 2050 2100],'XTickLabel',...
    {'1950','2000','2050','2100'},'YTick',[0.4 0.6 0.8 1.0]);
axes(subplot2);
xlim([1950 2100]);
ylim([0.4 1.0]);
ylabel('Fraction of Tolerant Symbionts', 'FontSize',14,'FontWeight','bold');
set(subplot2,'FontSize',14,'FontWeight','bold','XTick',...
    [1950 2000 2050 2100],'XTickLabel',...
    {'1950','2000','2050','2100'},'YTick',[0.4 0.6 0.8 1.0]);

function  addOneCase(name, figFile, subplotB, subplotM, baseColor)
    % Open the old figure and extract the two curves.
    oldFig = openfig(figFile, 'new');
    oldLines = findobj(oldFig, 'Type', 'line');

    
    axes(subplotB);

    cM = copyobj(oldLines(1), subplotM);
    cB = copyobj(oldLines(2), subplotB);
    set(cM, 'DisplayName', name, 'Color', baseColor, 'LineWidth', 2.0);
    set(cB, 'DisplayName', name, 'Color', baseColor, 'LineWidth', 2.0);
    
    %{
    ylabel('Change in gi (C)');
    xlabel('Time (years)');
    xlim([time(1) time(end)])
    ylim([-0.2 1.6]);
    datetick('x', 'keeplimits', 'keepticks')
    title("Mounding");
    %}

    end
