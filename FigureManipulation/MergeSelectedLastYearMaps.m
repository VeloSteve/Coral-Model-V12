rcps = [ 4.5 8.5];
letters = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'];
inputPath = 'D:/GoogleDrive/Coral_Model_Steve/_Paper Versions/Figures/LastYearHealthy/';
num = 0;
for eee = 0:1
    for rcp = rcps
        num = num + 1;
        % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
        n = strcat(inputPath, 'ESM2Mrcp', num2str(rcp*10), '.E', num2str(eee), '.OA0_NF1_20170923_LastHealthyBothTypesV2');
        p1 = open(strcat(n,'.fig'));
        pax(num) = gca;
        figureHandles(num) = p1;
    end
end
panels = num;
% use this to get the color scale of one of the plots:
%cmap = colormap(pax(1));
% or this to load from a file
addpath('..');
cmap = customScale();

yearRange = [2000 2100];
ticks = [2000 2050 2100];

figure('color', 'w');
num = 0;
for eee = 0:1
    for rcp = rcps
        num = num + 1;
        P = subplot(panels/2,2,num);
        copyobj(get(pax(num),'children'),P);
        %n = strrep(names{i}, '_', ' ');
        axis off;
        set(P,'FontSize',14);
        caxis(yearRange);  % Limit and make consistent
        colormap(cmap); %(flipud(jet)
        title(strcat('(', letters(num), ') RCP ', num2str(rcp), ' E=',num2str(eee)));
        close(figureHandles(num));
    end
end

colorbar('Ticks',ticks,...
    'Limits',yearRange,...
    'Color',[0.15 0.15 0.15],...
    'FontSize',14);
colorbar('Position',...
    [0.505268996018406 0.329506314580941 0.0221852468108709 0.340987370838117],...
    'Ticks',ticks,...
    'Limits',yearRange,...
    'Color',[0.15 0.15 0.15],...
    'FontSize',14);
