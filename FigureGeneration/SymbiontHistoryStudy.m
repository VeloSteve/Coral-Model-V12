function SymbiontHistoryStudy()
% This is a rough plot for examining symbiont histories in versions of the
% model.
relPath = 'Temp_Plot_Set/';

runParams = '_ESM2M.rcp45.E0.OA0.sM9.sA1';
% currently 144, 246, 402, 420, 793, 1541 are saved
% Moorea, Galapagos, Curacao, St. John, Ko Phuket, NE Australia
%reef = 1239;  
%reefName = 'Nr Indonesia';
reef = 402;
reefName = 'Curaçao';

skipType = 2; % 0 = all corals, 1 = skip massive, 2 = skip branching

fh = figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 1.5, 19, 7.5]);

fiftyYears = 365.25*50;  % 1 unit per day in datetime form
tickStart = floor(1850*365.25);
tickEnd = floor(2100*365.25);
tickVals = tickStart:fiftyYears:tickEnd;

%% Curves based on growth curve A
    hFile = strcat(relPath, 'A', '/DetailedSC_Reef', num2str(reef), runParams, '.mat');
    load(hFile, 'S', 'time');
    if skipType ~= 1 plot(time, S(:, 1), 'color', 'y', 'DisplayName', 'A massive'); end
    hold on;
    if skipType ~= 2 plot(time, S(:, 2), 'color', 'g', 'DisplayName', 'A branching'); end
    if skipType ~= 1 plot(time, S(:, 3), 'color', [0.7, 0.7, 0], 'DisplayName', 'A massive, +1'); end
    if skipType ~= 2 plot(time, S(:, 4), 'color', [0, 0.7, 0], 'DisplayName', 'A branching, +1'); end

%% Curves based on growth curve A
    
    hFile = strcat(relPath, 'B', '/DetailedSC_Reef', num2str(reef), runParams, '.mat');
    load(hFile, 'S', 'time');
    
    if skipType ~= 1 plot(time, S(:, 1), 'color', [.6, .6, 1], 'DisplayName', 'B massive'); end % light blue
    if skipType ~= 2 plot(time, S(:, 2), 'color', [1, .4, 1], 'DisplayName', 'B branching'); end  % light magenta
    if skipType ~= 1 plot(time, S(:, 3), 'color', [0, 0, .8], 'DisplayName', 'B massive, +1'); end % dark blue
    if skipType ~= 2 plot(time, S(:, 4), 'color', [.7, 0, .7], 'DisplayName', 'B branching, +1'); end % dark magenta
    
%%
xlim([time(1) time(end)]);
set(gca,'XTick',tickVals);
datetick('x','keeplimits', 'keepticks');
legend();

line2 = 'Both coral types are included here.';
if skipType == 1
    line2 = 'Only branching corals are included here.';
elseif skipType == 1
    line2 = 'Only massive corals are included here.';
end
annotation(fh,'textbox',...
    [0.676986842105261 0.530555555555557 0.211719298245614 0.225],...
    'String',{'Darker shades are advantaged symbionts.', line2, "This is for " + reefName + " reef " + num2str(reef) + ".",'Note that this is symbiont density in the corals, so it is less','meaningful when coral cover is very low.','','The non-advantaged symbionts are practically gone after x','for curve A and x for curve B.'},...
    'FitBoxToText','off');
