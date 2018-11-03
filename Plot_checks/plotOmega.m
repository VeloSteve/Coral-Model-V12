% Plot Omega
% time from 0 to 2880:
tStep = 2800;
showFactor = 1;
figure();

m_proj('miller');
m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
hold on;
m_grid('box','fancy','linestyle','none','backcolor',[.9 .99 1], 'xticklabels', [], 'yticklabels', []);
[LONG2,LAT2] = m_ll2xy(Reefs_latlon(:,1), Reefs_latlon(:,2));
om = Omega_all(:, tStep);
if showFactor == 1
    %om = (1-(4-Omega_all(:, tStep))*0.15);
    om = omegaToFactor(om);
end
scatter(LONG2, LAT2, 5, om)
colorbar
if showFactor
    % Smallest factor possible is 0.55 (or zero if omega < 1), but
    % 0.7 seems to be close to a lower bound for rcp 6.0.  Also, the 
    % value doesn't go above 0.88, at least for RCP 8.5.
    % For RCP 6.0 and 8.5, quantiles are:
    % [ .01   .05    .25     .5    .75    .95    .99]
    % 0.72   0.75   0.79   0.80   0.83   0.85   0.94
    % 0.66   0.68   0.72   0.74   0.76   0.79   0.88
    caxis([.7 .9]);
else
    caxis([2 4]); %#ok<UNRCH>
end
quantile(om, [ .01 .05 .25 .5 .75 .95 .99])
