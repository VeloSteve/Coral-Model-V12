% Grab the data from the maps
lastYears(2, 2, 2, 1925) = 0;
rcps = [ 4.5 8.5];
for eee = [0 1]
    for adv = [0 1]
        for rrr = [1 2]
            rcp = rcps(rrr);
            % ESM2Mrcp26.E0.OA0_NF1_20170726_LastHealthyBothTypes.fig
            n = strcat('ESM2M.rcp', num2str(rcp*10), '.E', num2str(eee), '.OA0.sM9.sA', num2str(adv), '.0_LastHealthyBothTypesV2');
            fprintf('Opening map %s\n', n);
            fh = open(strcat(n,'.fig'));
            scat = findobj(gca, 'Type', 'Scatter');
            lastYears(eee+1, adv+1, rrr, : ) = get(scat, 'CData');
        end
    end
end
dataOrder = "First 3 indices are evolution on/off, shuffling on/off, and RCP 4.5 or 8.5";
save('lastYearData.mat', 'dataOrder', 'lastYears');