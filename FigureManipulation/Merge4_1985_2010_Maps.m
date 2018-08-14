rcps = [ 4.5 8.5];
count = length(rcps);
titles = { ...
    '(a) RCP 4.5 E=0', ...
    '(b) RCP 8.5 E=0', ...
    '(c) RCP 4.5 E=1', ...
    '(d) RCP 8.5 E=1'};
inputPath = 'C:/Users/Steve/Google Drive/Coral_Model_Steve/_Paper Versions/Figures/85-2010_Maps/';
for eee = 0:1
for i = 1:count
    % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
    n = strcat(inputPath, 'ESM2Mrcp', num2str(rcps(i)*10), '.E', num2str(eee), '.OA0_NF1_20171007_MortEvents8510Map');
    p1 = open(strcat(n,'.fig'));
    pax(2*eee+i) = gca;
end
end
cmap = colormap(pax(1));

figure('color', 'w');
for eee = 0:1
for i = 1:count
    P = subplot(2,2,eee*2+i);
    copyobj(get(pax(2*eee+i),'children'),P);
    %n = strrep(names{i}, '_', ' ');
    axis off;
    set(P,'FontSize',14);
    caxis([0 8]);  % Limit and make consistent
    colormap(cmap); %(flipud(jet)
    title(titles{2*eee+i});
end
end

colorbar('Ticks',[0 2 4 6 8],...
    'Limits',[0 8],...
    'Color',[0.15 0.15 0.15]);
colorbar('Position',...
    [0.505268996018406 0.329506314580941 0.0221852468108709 0.340987370838117],...
    'Ticks',[0 2 4 6 8],...
    'Limits',[0 8],...
    'Color',[0.15 0.15 0.15]);