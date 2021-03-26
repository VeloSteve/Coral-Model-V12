addpath("..");
% support call from multi-plot script
if (exist('runOutputs', 'var') == 1) && (length(runOutputs) > 0)
    base = runOutputs;
else
    base = 'C:\CoralTest\Mar2021_E221_0.025-1.5-0.46_Target10\';
    %base = 'D:\CoralTest\Feb2021_adustRi2.5_2.5_X-2_y_0.40_leveled\';
end
% Choice of RCP/adaptation is NOT controlled by the external script at this point.
if (exist('runLabel', 'var') == 1) && (length(runLabel) > 0)
    topText = "RCP 4.5, E=0, Shuffling. " + runLabel;
else
    topText = 'RCP 4.5, E=0, Shuffling.  E221, y=0.46, Target 10';
end
eventsFile = 'ColdEvents_rcp45E=0OA=0Adv=1.mat';
coverFile = 'CoralArea_rcp45E=0OA=0Adv=1.mat';

load(strcat(base, eventsFile));
load(strcat(base, coverFile), 'C_area');
if ~exist('collectSelV', 'var')
    % Full version of eventsFile was not available.
    error('ColdEvents file must include the collect* variables.  Run serially with saveReefParams = true.');
end

% Reef locations are in the second column of ESM2M_reef_JD
load('../ClimateData/ESM2M_reefs_JD.mat');

fh = figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [0.5, 0.5, 13, 13]);
% Make places for up to 6 axes, referenced in ha
[ha, pos] = tight_subplot(3, 3, 0.1, 0.07, 0.07);
axesNum = 1;

cold = squeeze(sum(coldEvents, 2));

axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(cold(:, 1), collectSelV(:, 1));
xlabel("Number of cold events");
ylabel("SelV");
title("Mounding Coral");

% This text is placed relative to the plot above, but meant for all
yAbove = ylim;
text(5, yAbove(2)+(yAbove(2)-yAbove(1))/5, topText, ...
    'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');


axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(cold(:, 2), collectSelV(:, 2));
xlabel("Number of cold events");
ylabel("SelV");
title("Branching Coral");

% now we also have psw2.
% What is the range?  What min psw2 would keep SelV above 2?
fprintf("psw2 min %6.2f, median %6.2f, max %6.2f\n", min(collectpsw2),median(collectpsw2), ...
    max(collectpsw2));
make2(:, 1) = collectpsw2' * 2 ./ collectSelV(:, 1);
make2(:, 2) = collectpsw2' * 2 ./ collectSelV(:, 2);

% Argh - too much fancy indexing.
for i = 1:1925
    if collectSelV(i, 1) > 2
        make2(i, 1) = 0;
    end
    if collectSelV(i, 2) > 2
        make2(i, 2) = 0;
    end
end
idx = find(make2 > 0);

sstVar(:, 1) = collectSelV(:,1) ./ collectpsw2(1, :)' / 1.25;
sstVar(:, 2) = collectSelV(:,2) ./ collectpsw2(1, :)';
fprintf("SelV quartiles  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectSelV(:, 1), [0 0.25 0.5 0.75 1.0]));
fprintf("psw2 quartiles  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectpsw2(1, :), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) mound  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(sstVar(:, 1), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) branch %6.3f %6.3f %6.3f %6.3f %6.3f (expect same as above)\n", quantile(sstVar(:, 2), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) code   %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectVar, [0 0.25 0.5 0.75 1.0]));
fprintf("pseudocode: SelV = [1.25 1] * psw2 * var(SST)\n");

fprintf("Values of psw2 min which could keep SelV over 2.\n");
fprintf("For all: %6.3f\n", max(max(make2(idx))));
fprintf("Quartiles %6.3f %6.3f %6.3f \n", quantile(make2(idx), [0.25 0.5 0.75]));


axes(ha(axesNum)); axesNum = axesNum + 1;
coldSum = squeeze(sum(sum(coldEvents,3), 2));
idx = find(coldSum == 0);
scatter(collectVar(1, idx), collectSelV(idx,1), 6, [0 0 0]);
hold on;
idx = find(coldSum == 1);
scatter(collectVar(idx), collectSelV(idx,1), 5, [0 1 0]);
idx = find(coldSum > 1 & coldSum < 5);
scatter(collectVar(idx), collectSelV(idx,1), 4, [0 1 1]);
idx = find(coldSum >= 5);
scatter(collectVar(idx), collectSelV(idx,1), 3, [1 0 0])
xlabel("SST variance");
ylabel("Mounding SelV");
lgd = legend("Black = 0", "Green = 1", "Cyan = 2-4", "Red > 4", "Location", "southeast");
title(lgd, "Cold Events");

axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(collectVar, collectpsw2(:));
xlabel("SST variance");
ylabel("psw2");

axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(collectSelV(:, 1), collectpsw2);
xlabel("Mounding SelV");
ylabel("psw2");

% Now try to compare SelV to mortality, using low cover as a proxy.
% Pick 1950
c = squeeze(C_area(1950-1860, :, :));
c = sum(c, 2);
axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(collectSelV(:, 1), c);
xlabel("Mounding SelV");
ylabel("Cover");

% CWB vs latitude.  Match colors to the SelV/SST variance plot.
axes(ha(axesNum)); axesNum = axesNum + 1;
idx = find(coldSum == 0);
scatter(coldSum(idx), ESM2M_reefs_JD(idx, 2), 6, [0 0 0]);
hold on;
idx = find(coldSum == 1);
scatter(coldSum(idx), ESM2M_reefs_JD(idx, 2), 5, [0 1 0]);
idx = find(coldSum > 1 & coldSum < 5);
scatter(coldSum(idx), ESM2M_reefs_JD(idx, 2), 4, [0 1 1]);
idx = find(coldSum >= 5);
scatter(coldSum(idx), ESM2M_reefs_JD(idx, 2), 3, [1 0 0]);
xlabel("Cold Events");
ylabel("Latitude");
legend("Black = 0", "Green = 1", "Cyan = 2-4", "Red > 4", "Location", "northeast");

% CWB vs location.  Match colors to the SelV/SST variance plot.
axes(ha(axesNum)); axesNum = axesNum + 1;
idx = find(coldSum == 0);
long360 = ESM2M_reefs_JD(:, 1);
long360(long360<0) = long360(long360<0) + 360.0;
scatter(long360(idx), ESM2M_reefs_JD(idx, 2), 6, [0 0 0]);
hold on;
idx = find(coldSum == 1);
scatter(long360(idx), ESM2M_reefs_JD(idx, 2), 5, [0 1 0]);
idx = find(coldSum > 1 & coldSum < 5);
scatter(long360(idx), ESM2M_reefs_JD(idx, 2), 4, [0 1 1]);
idx = find(coldSum >= 5);
scatter(long360(idx), ESM2M_reefs_JD(idx, 2), 3, [1 0 0]);
xlabel("Longitude");
ylabel("Latitude");
legend("Black = 0", "Green = 1", "Cyan = 2-4", "Red > 4", "Location", "southeast");

% SelV vs latitude
axes(ha(axesNum)); axesNum = axesNum + 1;
scatter(collectSelV(:, 1), ESM2M_reefs_JD(:, 2));
xlabel("Mounding SelV");
ylabel("Latitude");


if (exist('figureDir', 'var') == 1) && ~isempty(figureDir)
    fullName = strcat(figureDir, "SelV_Cover_CWB_scatter");
    savefig(strcat(fullName, '.fig'));
    %saveas(fh, strcat(fullName, ".png"));
    addpath('..');
    saveCurrentFigure(fullName);
else
    % A little odd - don't save the figures, but give the text file a place to
    % go.
    figureDir = "C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Target10_attempt\";
end

% This could be a separate script, but it is related.  Get warm/cold bleaching
% stats for all cases, and for possibly more than one time span.
outfile = strcat(figureDir, 'BleachingPercent.txt');
fid = fopen(outfile,'w');

%% 1985 to 2100 counts
fprintf(fid, 'RCP   E S Years              Mounding                      Branching                    Either\n');
fprintf(fid, '                        Warm   Cold   Total  Cold%%  Warm   Cold   Total  Cold%%  Warm   Cold   Total  Cold%%\n');
years = [1985, 2100];
vals = zeros(1, 12);
for eee = ['0' '1']
    for adv = {'0' '1'}
        for rrr = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};

            eventsFile = strcat(base, 'ColdEvents_', rrr, 'E=', eee, ...
                'OA=0Adv=', adv, '.mat');
            load(eventsFile{1}, 'bleachEvents', 'coldEvents');
            warmEvents = bleachEvents - coldEvents;
            iL = years(1) - 1860;
            iH = years(2) - 1860;
            % Mounding only
            vals(1) = sum(warmEvents(:, iL:iH, 1), 'all');
            vals(2) = sum(coldEvents(:, iL:iH, 1), 'all');
            vals(3) = sum(bleachEvents(:, iL:iH, 1), 'all');
            vals(4) = 100 * vals(2) / vals(3);
            % Branching only
            vals(5) = sum(warmEvents(:, iL:iH, 2), 'all');
            vals(6) = sum(coldEvents(:, iL:iH, 2), 'all');
            vals(7) = sum(bleachEvents(:, iL:iH, 2), 'all');
            vals(8) = 100 * vals(6) / vals(7);
            % Both coral types
            vals( 9) = sum(warmEvents(:, iL:iH, :), 'all');
            vals(10) = sum(coldEvents(:, iL:iH, :), 'all');
            vals(11) = sum(bleachEvents(:, iL:iH, :), 'all');
            vals(12) = 100 * vals(6) / vals(7);
            fprintf(fid, '%s %s %s %d - %d %6d %6d %6d %6.1f %6d %6d %6d %6.1f %6d %6d %6d %6.1f\n', ...
                rrr{1}, eee, adv{1}, years(1), years(2), vals);

        end
        fprintf(fid, '\n');
    end
end

%% 1861 to 2001 Frequency
years = [1861, 2001];
fprintf(fid, "\nAnnual frequency of bleaching, as percent, Historical\n");
fprintf(fid, 'RCP   E S Years              Mounding               Branching              Either\n');
fprintf(fid, '                        Warm   Cold   Total    Warm   Cold   Total    Warm   Cold   Total  \n');
possible = (years(2) - years(1) + 1) * 1925;
for eee = ['0' '1']
    for adv = {'0' '1'}
        for rrr = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
            vals = zeros(1, 9);
            eventsFile = strcat(base, 'ColdEvents_', rrr, 'E=', eee, ...
                'OA=0Adv=', adv, '.mat');
            load(eventsFile{1}, 'bleachEvents', 'coldEvents');
            warmEvents = bleachEvents - coldEvents;
            iL = years(1) - 1860;
            iH = years(2) - 1860;
            % Mounding only
            vals(1) = sum(warmEvents(:, iL:iH, 1), 'all');
            vals(2) = sum(coldEvents(:, iL:iH, 1), 'all');
            vals(3) = sum(bleachEvents(:, iL:iH, 1), 'all');
            % Branching only
            vals(4) = sum(warmEvents(:, iL:iH, 2), 'all');
            vals(5) = sum(coldEvents(:, iL:iH, 2), 'all');
            vals(6) = sum(bleachEvents(:, iL:iH, 2), 'all');
            % Both coral types
            vals(7) = sum(warmEvents(:, iL:iH, :), 'all');
            vals(8) = sum(coldEvents(:, iL:iH, :), 'all');
            vals(9) = sum(bleachEvents(:, iL:iH, :), 'all');
            vals = 100.0 * vals / possible;
            fprintf(fid, '%s %s %s %d - %d %6.3f %6.3f %6.3f   %6.3f %6.3f %6.3f   %6.3f %6.3f %6.3f\n', ...
                rrr{1}, eee, adv{1}, years(1), years(2), vals);

        end
        fprintf(fid, '\n');
    end
end

%% 2001 to 2100 Frequency
years = [2001, 2100];
fprintf(fid, "\nAnnual frequency of bleaching, as percent, Modern\n");
fprintf(fid, 'RCP   E S Years             Mounding               Branching              Either\n');
fprintf(fid, '                       Warm   Cold   Total    Warm   Cold   Total    Warm   Cold   Total  \n');
possible = (years(2) - years(1) + 1) * 1925;
for eee = ['0' '1']
    for adv = {'0' '1'}
        for rrr = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
            vals = zeros(1, 9);
            eventsFile = strcat(base, 'ColdEvents_', rrr, 'E=', eee, ...
                'OA=0Adv=', adv, '.mat');
            load(eventsFile{1}, 'bleachEvents', 'coldEvents');
            warmEvents = bleachEvents - coldEvents;
            iL = years(1) - 1860;
            iH = years(2) - 1860;
            % Mounding only
            vals(1) = sum(warmEvents(:, iL:iH, 1), 'all');
            vals(2) = sum(coldEvents(:, iL:iH, 1), 'all');
            vals(3) = sum(bleachEvents(:, iL:iH, 1), 'all');
            % Branching only
            vals(4) = sum(warmEvents(:, iL:iH, 2), 'all');
            vals(5) = sum(coldEvents(:, iL:iH, 2), 'all');
            vals(6) = sum(bleachEvents(:, iL:iH, 2), 'all');
            % Both coral types
            vals(7) = sum(warmEvents(:, iL:iH, :), 'all');
            vals(8) = sum(coldEvents(:, iL:iH, :), 'all');
            vals(9) = sum(bleachEvents(:, iL:iH, :), 'all');
            vals = 100.0 * vals / possible;
            fprintf(fid, '%s %s %s %d - %d %6.3f %6.3f %6.3f   %6.3f %6.3f %6.3f   %6.3f %6.3f %6.3f\n', ...
                rrr{1}, eee, adv{1}, years(1), years(2), vals);

        end
        fprintf(fid, '\n');
    end
end

fclose(fid);
