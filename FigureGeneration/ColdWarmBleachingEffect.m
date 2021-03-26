%%
%  Question: does cold water bleaching (CWB) have a different effect on
%  subsequent coral cover than warm water bleaching?
%
%  Approach: For each bleaching event in one run, save the coral cover 2 months
%  before, at bleaching, and 4 months after.  Choose 2 points (say 2 months before and 4
%  after) to compute a percent change.  Make a histogram showing the effects of
%  each, and possibly do other stats.
clear;
global S C time detailEvents temp saveTo fnPrefix idStuff

% [36, 46, 106, 144, 402, 420, 1239]
detailEvents = false;
%reefList = [36, 46, 106, 144, 225, 238, 402, 420, 1239];
reefList = [36, 46, 106, 144, 402, 420, 1239];
%reefList = [106];
runDate = "20210220";
%base= 'D:\CoralTest\Feb2021_CurveE221_Target5_NewColdDef_floor-0.15repeat\';
base= 'D:\CoralTest\Feb2021_adjustRi1.5_1.8\';
rcpList = {'rcp45'};
target = 5;
curve = 'adjustRi1.5_1.8';
%saveTo = 'C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Target5_E221_floor-0.15\';
%saveTo = 'C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Target5_E221_floor-20\';
saveTo = "";
fnPrefix = "From2020_";
firstYearChecked = 2020;

binEdges = [0:0.1:0.8 0.9:0.02:1.1 1.2:0.1:2.0];

%deltaTList = {'0', '1'}; 
deltaTList = {'0.0' '1.0'}; 
eList = [0 1];
close all
clear coldSummary hotSummary
fprintf("Bleaching events from %d onward.\n", firstYearChecked);
for rrr = rcpList
    rcp = rrr{1};
    for e = eList
        for adv = deltaTList
            fprintf("For %s, E=%d, Shuffling advantage = %s\n", rcp, e, adv{1});
            % Below we get cold and warm events for specific reefs, but first do
            % some calculations based on all reefs.
            fn = strcat(base, 'ColdEvents_', rcp, 'E=', num2str(e), 'OA=0Adv=', adv{1}(1), '.mat');
            load(fn, 'bleachEvents', 'coldEvents'); % 1925x240x2
            iCheck = firstYearChecked - 1860;
            coldChecked = sum(sum(sum(coldEvents(:, iCheck:end, :))));
            allChecked = sum(sum(sum(bleachEvents(:, iCheck:end, :))));
            clear coldEvents bleachEvents
            fprintf("For all reefs, there are %d cold and %d total events starting in %d, %5.1f percent cwb.\n", ...
                coldChecked, allChecked, firstYearChecked, 100*coldChecked/allChecked);
            for reef = reefList
                nHot = 1;
                nCold = 1;

                % ESM2M.rcp26.E0.OA0.sM9.sA0.0.20210214_maps
                dn = strcat('ESM2M.', rcp, '.E', num2str(e), '.OA0.sM9.sA', adv{1}, '.', runDate, '_maps\');
                fn = strcat(base, dn, 'DetailedSC_Reef' , num2str(reef), '.mat');
                load(fn, 'C', 'S', 'bleachEvent', 'coldEvent', 'time', 'temp');  % 23040x2, 23040x4, 240x2, 240x2, 23040x1
                idStuff = strcat('ColdWarmEffect_Reef', num2str(reef), "_", rcp, 'E=', num2str(e), 'OA=0Adv=', adv{1}, 'Target=', num2str(target), 'Curve=', curve);


                hotEvent = bleachEvent - coldEvent;
                % Treat symbionts as totals for each coral type.  S becomes 23040x2,
                % the same as C.
                S(:, 1) = S(:, 1) + S(:, 3);
                S(:, 2) = S(:, 2) + S(:, 4);
                S(:, 3:4) = [];

                % Use ix, iy, and i as indexes into the yearly arrays.
                % Use j to index the timestep arrays.
                hotSummary = summarize(reef, hotEvent, "Warm ", firstYearChecked);

                % Same for cold events
                coldSummary = summarize(reef, coldEvent, "Cold ", firstYearChecked);
                
                fprintf("Reef %d has ", reef);
                if isempty(coldSummary)
                    fprintf("0 cold events.  ");
                else
                    fprintf("%d cold events, %6.2f cover ratio.  ", ...
                        size(coldSummary, 1), mean(coldSummary(:, 8)));
                end
                if isempty(hotSummary)
                    fprintf("0 hot events.\n");
                else
                    fprintf("%d hot events, %6.2f cover ratio.\n", ...
                        size(hotSummary, 1), mean(hotSummary(:, 8)));
                end
                
                fh = figure();

                xLeft = 10.0;
                xRight = -10.0;
                if ~isempty(coldSummary)
                    histogram(coldSummary(:, 8), binEdges, 'FaceColor', 'blue', 'FaceAlpha', 0.4, 'DisplayName', 'Cold');
                    xLeft = min(xLeft, floor(10*min(coldSummary(:, 8)))/10.0);
                    xRight = max(xRight, ceil(10*max(coldSummary(:, 8)))/10.0);
                end
                hold on;
                if ~isempty(hotSummary)
                    histogram(hotSummary(:, 8), binEdges, 'FaceColor', 'red', 'FaceAlpha', 0.4, 'DisplayName', 'Warm');
                    xLeft = min(xLeft, floor(10*min(hotSummary(:, 8)))/10.0);
                    xRight = max(xRight, ceil(10*max(hotSummary(:, 8)))/10.0);
                end
                %xlim([0.6 1.2]);
                xlabel("Fraction of  cover 4 months after vs. 2 months before");
                ylabel("Event count");
                if xLeft == xRight
                    xLeft = xLeft - 0.1;
                    xRight = xRight + 0.1;
                end
                xlim([xLeft xRight]);
                ylim auto
                title("Before/After Reef " + num2str(reef) + " Curve " + curve);
                legend("Location", "best");
                if saveTo ~= ""
                    saveas(fh, strcat(saveTo, fnPrefix, idStuff, ".png"));
                end
                clear coldSummary hotSummary;
            end
        end
    end
end

function [summary] = summarize(reef, eventSet, hotCold, firstYear) 
    global S C time detailEvents temp saveTo fnPrefix idStuff
    KC = [74125000,1.0250e+08];
    KS = [3000000,4000000];
    ppm = 8; % timestep points per month
    jBack = 2 * ppm;
    jAhead = 4 * ppm;
    % Find and summarize hot or cold
    [ix, iy] = find(eventSet); % ix is year, 1 to 240
    count = 1;
    summary = [];
    if isempty(ix)
        return;
    end
    if detailEvents
        mkdir(strcat(saveTo, 'DiagnosticReef', num2str(reef), "\"));
    end
    for i = 1:length(ix)
        year = 1860 + ix(i);
        type = iy(i);
        jStart = 1 + (ix(i)-1) * 12 * ppm;
        jEnd = ix(i) * 12 * ppm;
        [sMin, jMin] = min(S(jStart:jEnd, type));
        % jMin is the index within the subset. Add jStart to index the full
        % arrays.
        jMin = jStart + jMin - 1;
        coverBefore = C(jMin - jBack, type);
        coverNow = C(jMin, type);
        coverAfter = C(jMin + jAhead, type);
        % Gather everything about this event
        if year >= firstYear
            summary(count, :) = [jMin, time(jMin), year, sMin, coverBefore, coverNow, coverAfter, coverAfter/coverBefore, type];
            count = count + 1;

            if detailEvents

                
                fh = figure('Units', 'inches', 'Position', [1, 6, 6,6]);
                diagRange = max(1, jStart - 2 * 96):min(jEnd + 2 * 96, length(S));

                plot(time(diagRange),S(diagRange, type)./(KS(type)*C(diagRange, type)), ...
                    '-g', 'DisplayName', 'Symbiont');
                ylabel("%K, Population " + num2str(type));
                hold on;
                plot(time(diagRange),C(diagRange, type)/KC(type), ...
                    '-r', 'DisplayName', 'Coral');

                plot([time(jMin-16) time(jMin-16)], [0 1], '-k', 'DisplayName', 'Minus 2 mo'); 
                plot([time(jMin+32) time(jMin+32)], [0 1], '-k', 'DisplayName', 'Plus 4 mo'); 
                yyaxis right
                plot(time(diagRange), temp(diagRange), '-b', 'DisplayName', 'SST' );
                ylabel("SST(C) " + num2str(type));

                legend()
                title(hotCold + num2str(year) + ", Reef " + num2str(reef));
                datetick('x','keeplimits');

                if saveTo ~= ""
                    saveas(fh, strcat(saveTo, 'DiagnosticReef', num2str(reef), "\", ...
                        fnPrefix, idStuff, "_", num2str(i), ".png"));
                end
            end
        end
    end
end