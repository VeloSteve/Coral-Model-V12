%% Make Maps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evolutionary model for coral cover (from Baskett et al. 2009)     %
% modified by Cheryl Logan (clogan@csumb.edu)                       %
% last updated: 1-6-15                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = MapsSymbiontYears(fullDir, modelChoices, filePrefix, years, Reefs_latlon )
% Add paths and load mortality statistics
%load(strcat('~/Dropbox/Matlab/SymbiontGenetics/',filename,'/201616_testNF_1925reefs.mat'),'Mort_stats')
format shortg;
% filename = '201616_figs'; %filename = strcat(dateString,'_figs'); mkdir(filename); % location to save files
% map %% NOTE: worldmap doesn't seem to be working on work computer


%% Make map of last mortality event recorded

%Try different treatments for zero (no introduction) locations:
%years(years==0) = NaN; % omit values
years(years==0) = 2200; % set above scale (will be white)


figure();
m_proj('miller'); % , 'lon', 155.0); - offsets map, but drops some data!
m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
m_grid('box','fancy','linestyle','none','backcolor',[.9 .99 1], 'fontsize', 11, 'xticklabels', [], 'yticklabels', []);
% Get last full-reef mortality events:

[LONG,LAT] = m_ll2xy(Reefs_latlon(:, 1), Reefs_latlon(:,2)); hold on % convert reef points to M-Map lat long
%caxis([min(years), max(years)]);
caxis([2000, 2100]);  % Limit and make consistent
scat = scatter(LONG, LAT, 5, years); %[.7 .7 .7]) % plot reefs  onto map

colormap(hot); %(flipud(jet))
%colorbar
colorbar('Ticks',[2000 2020 2040 2060 2080 2100],...
    'Limits',[2000 2100],...
    'Color',[0.15 0.15 0.15]);
title(strcat(modelChoices,'. Year Enhanced Symbionts are Introduced'))
print('-dpdf', '-r200', strcat(fullDir, filePrefix,'_SymbiontIntro','.pdf'));
savefig(strcat(fullDir, filePrefix,'_SymbiontIntro', '.fig'));

hold off;

end