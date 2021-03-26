if (exist('runOutputs', 'var') == 1) && (length(runOutputs) > 0)
    base = runOutputs;
else
    % Set manually if not provided
    base = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\';
end
if ~exist('runID', 'var')
    runID = 'SimplerL2.6_0.5-1.5-0.32';
    runLabel ='SimplerL 2.7, min=0.5, y=0.32, Target=5';
end
if (exist('figureDir', 'var') == 1) && (length(figureDir) > 0)
    saveTo = figureDir;
else
    saveTo = 'C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\adjustRi2.6_2.6_y0.32_NOlevel_min0.35\';
end



rcpList = {'rcp85'}; %{'rcp26', 'rcp45', 'rcp60', 'rcp85'};
target = 5;
startFrom = 1861; % default 1861
fnPrefix = "";

%deltaTList = {'0', '1'}; 
deltaTList = {'0', '1'}; 
eList = [0 1];
for rrr = rcpList
    rcp = rrr{1};
    for e = eList
        for adv = deltaTList
            fn = strcat(base, 'ColdEvents_', rcp, 'E=', num2str(e), 'OA=0Adv=', adv{1}, '.mat');
            load(fn, 'bleachEvents', 'coldEvents');
            
            % First is mainly for titles, second for file names.
            labelStuff = rcp + " E=" + num2str(e) + " OA=0 Adv=" + adv{1} + " Target=" + num2str(target) + "Curve = " + runLabel + " StartFrom=" + num2str(startFrom);
            fnStuff = strcat(rcp, 'E=', num2str(e), 'OA=0Adv=', adv{1}, 'Target=', num2str(target), 'Curve=', runID, 'StartFrom=',num2str(startFrom));

            if true
                fnPrefix = "Full_";
                fh = figure();
                yRange = [startFrom-1860:240];
                plot(startFrom:2100, sum(sum(coldEvents(:, yRange, :), 1),3), 'DisplayName', 'Cold')
                hold on;
                hotEvents = bleachEvents - coldEvents;
                plot(startFrom:2100, sum(sum(hotEvents(:, yRange, :), 1),3), 'DisplayName', 'Hot')
                ylabel("Bleaching Events per Year");
                xlabel("Year");
                title("Bleaching "  + labelStuff);
                legend()
                ylim([0 700]);

            end

            if false
                normTime = true;
                if normTime
                    %fnPrefix = "1985-2010";
                    %range = 1985:2010;                    
                    fnPrefix = "1985-2020";
                    range = 1985:2020;
                else
                    fnPrefix = "Ratio_";
                    range = startFrom:2100;
                end
                ir = range - 1861 + 1;
                cold = sum(sum(coldEvents(:, ir, :), 1),3);
                both = sum(sum(bleachEvents(:, ir, :), 1),3);
                fh = figure();
                plot(range, cold, 'DisplayName', 'Cold')
                hold on;
                plot(range, both, 'DisplayName', 'Total')
                ylim([0, 600]);
                ylabel("Bleaching Events per Year");
                xlabel("Year");
                yyaxis right
                %r = sum(sum(coldEvents, 1),3)./sum(sum(bleachEvents, 1),3)
                r = cold ./ both;
                r(isnan(r)) = 1.0;

                idx = find(both==0);
                r(idx) = 0.0;
                plot(range, r, 'DisplayName', 'Cold Ratio')
                ylim([0.0, 1.0]);
                ylabel("Fraction of Cold Water Events");

                if normTime
                    % Calculate percent of possible events, as in calibration.
                    bothPct = 100 * sum(both) / (1925 * (2010-1985+1));
                    coldPct = 100 * sum(cold) / (1925 * (2010-1985+1));
                    title({"Bleaching " + labelStuff, ...
                        "Both = " + num2str(bothPct) +  "% Cold = " + num2str(coldPct) + "%"});
                else
                    title("Bleaching " + labelStuff);
                end
                legend()

            end
            if saveTo ~= ""
                fullName = strcat(saveTo, fnPrefix, fnStuff);
                %saveas(fh, strcat(fullName, ".png"));
                savefig(strcat(fullName, '.fig'));
                addpath('..');
                saveCurrentFigure(fullName);
            end
        end
    end
end