rcps = [ 2.6 4.5 6.0 8.5];
eee = 1;
count = length(rcps);
titles = { ...
    strcat('(a) RCP 2.6 E=',num2str(eee)), ...
    strcat('(b) RCP 4.5 E=',num2str(eee)), ...
    strcat('(c) RCP 6.0 E=',num2str(eee)), ...
    strcat('(d) RCP 8.5 E=',num2str(eee))};
inputPath = 'D:/GoogleDrive/Coral_Model_Steve/_Paper Versions/Figures/LastYearHealthy/';
for i = 1:count
    % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
    n = strcat(inputPath, 'ESM2Mrcp', num2str(rcps(i)*10), '.E', num2str(eee), '.OA0_NF1_20170727_LastHealthyBothTypesV2');
    p1 = open(strcat(n,'.fig'));
    pax(i) = gca;
end
cmap = colormap(pax(1));

figure('color', 'w');
for i = 1:count
    P = subplot(2,2,i);
    copyobj(get(pax(i),'children'),P);
    %n = strrep(names{i}, '_', ' ');
    axis off;
    set(P,'FontSize',14);
    caxis([1950, 2100]);  % Limit and make consistent
    colormap(cmap); %(flipud(jet)
    title(titles{i});
end

colorbar('Ticks',[1950 2000 2050 2100],...
    'Limits',[2050 2100],...
    'Color',[0.15 0.15 0.15]);
colorbar('Position',...
    [0.505268996018406 0.329506314580941 0.0221852468108709 0.340987370838117],...
    'Ticks',[1950 2000 2050 2100],...
    'Limits',[1950 2100],...
    'Color',[0.15 0.15 0.15]);