% This is adapted from gi_AllDelta_PlusTimeNearGi_binVar, but modified to run
% all 4 adaptation combinations and make a bar graph of the binned results
% averaged between 2020 and 2060.  Code to support the original graphs will be
% removed.
tic
addpath('../FigureGeneration'); % for getting temperatures

reefCount = 1925; % lower than 1925 for testing only!
E = 1;
adv = 1.0;


caseNames = {'RCP 4.5', 'RCP 8.5'};
rcpNames = {'rcp45', 'rcp85'};
cases = size(caseNames, 2);




% Save the bars where rows contain the three bins for one adaptation, and there
% are 4 rows for the adaptations as computed.  Each RCP has a separate figure
% now.
bars(4, 3) = 0;
for d = 1:cases
    fprintf("\n== Bins for %s ==\n", caseNames{d});
    for E = 0:1
        for adv = 0:1
            adapt = E*2 + adv + 1;
            fprintf("Adaptation case %d\n", adapt);
            %dirList = {['D:/CoralTest/Dec2020_CurveE221_Target5/ESM2M.rcp26.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20201210_maps/gi/'], ...
            %    ['D:/CoralTest/Dec2020_CurveE221_Target5/ESM2M.rcp45.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20201210_maps/gi/'], ...
            %    ['D:/CoralTest/Dec2020_CurveE221_Target5/ESM2M.rcp60.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20201210_maps/gi/'], ...
            %    ['D:/CoralTest/Dec2020_CurveE221_Target5/ESM2M.rcp85.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20201210_maps/gi/']};
            dirList = {['C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp26.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20210309_maps/gi/'], ...
                ['C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp45.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20210309_maps/gi/'], ...
                ['C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp60.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20210309_maps/gi/'], ...
                ['C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5/ESM2M.rcp85.E' num2str(E, '%1d') '.OA0.sM9.sA' num2str(adv, '%2.1f') '.20210309_maps/gi/']};

            bars(adapt, :) = oneCase(reefCount, dirList{d}, rcpNames{d});

        end
    end
    fh = figure();
    set(fh, 'Units', 'inches', 'Position', [d+0.5, d+0.5, 13.5, 7], 'Color', 'w');
    bar(bars);
    ah = gca;
    ah.FontSize = 20;
    if reefCount == 1925
        title(caseNames{d});
    else
        title(['WARNING: only a subset of reefs!!!', caseNames{d}]);
    end

    ylim([0 100]);
    ylabel('% time within +/- 1\sigma of gi between 2020-2060'); %, 'FontSize', 24);
    ah.XTickLabel = ["No Adaptation", "Shuffling", "Evolution", "Evolution & Shuffling"];
    legend('Low Variation', 'Medium Variation', 'High Variation',  'Location', 'northwest');

end


toc

%%
function vals = oneCase(reefCount, dir, rcp)
    % Each filename looks like gi_Reef0000.mat, with 0000 replaced by the left
    % 0-padded reef number.  The contents are gi, vgi.  To save space, time is in a
    % separate mat file, times.mat, containing time.
    
    load(strcat(dir, 'time.mat'), 'time');
    allGi(reefCount, 4, size(time, 1)) = single(0);  % size array by setting the last element.
    fprintf('Loading gi for all reefs.\n');
    for k = 1:reefCount
        load(strcat(dir, 'gi_Reef', num2str(k, '%04d'), '.mat'), 'gi');
        for j = 1:4
            allGi(k, j, :) = gi(:, j);
%            allVgi(k, j, :) = vgi(:, j);
        end
    end
    clearvars gi vgi;

    % While gi is still in raw form, compare to monthly SST
    % Get the global T history
    fprintf("Loading SST\n");
    addpath('..'); % for GetSST_norm...
    sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";
    dataset = "ESM2M";
    [SSTMonthly, ~, TIME, ~] = GetSST_norm_GFDL_ESM2M(sstPath, dataset, rcp);
    % If using a subset of reefs for testing, truncate to match
    SSTMonthly = SSTMonthly(1:reefCount, :);
    % Get SST variability for each reef
    initYear = '2001'; % as in the model
    initSSTIndex = findDateIndex(strcat('14-Dec-', initYear), strcat('16-Dec-',initYear), TIME);
    deviation = std(SSTMonthly(:, 1:initSSTIndex), 0, 2);
    % Make bins
    splits = quantile(deviation, [0.333333 0.666667]);
    fprintf('Splitting bins at standard deviations %f and %f\n', splits);
    bin1 = find(deviation < splits(1)); % Low variation
    bin3 = find(deviation > splits(2)); % High variation
    bin2 = setdiff(1:reefCount, bin1);
    bin2 = setdiff(bin2, bin3)'; % Medium variation


    fprintf("Computing gi to SST deltas.\n");
    % gi is in time steps. Average over each month.
    factor = 8.0;
    % decimate wants a vector, so loop over reef and symbiont type.
    allGiMonthly(reefCount, 4, size(TIME, 2)) = 0.0;
    okVgi = allGiMonthly; % to initialize
    for k = 1:reefCount
        for j = 1:size(allGi, 2)
            % decimate also wants the input vector to be double.
            allGiMonthly(k, j, :)  = decimate(cast(squeeze( allGi(k, j, :)), 'double'), factor, 'fir');
            % Now just use a fixed +- 0.5 C
            okVgi(k, j, :) = ...
                (squeeze(SSTMonthly(k, :)') < (squeeze(allGiMonthly(k, j, :)) + deviation(k))) ...
              & (squeeze(SSTMonthly(k, :)') > (squeeze(allGiMonthly(k, j, :)) - deviation(k))); 
 

        end
    end
    % Originally mounding and branching were kept separate.  Now fold them
    % together.  
    okEither(:, :) = okVgi(:, 1, :) | okVgi(:, 3, :) | okVgi(:, 2, :) | okVgi(:, 4, :);
    fprintf("Averaging to years\n");
    % Use yearly averages.
    timeEitherOK = reshape(okEither, reefCount, 12, []);
    timeEitherOK = 100*squeeze(sum(timeEitherOK, 2))/12.0;
    % Average reefs in 3 bins
    okSets(1, :) = squeeze(sum(timeEitherOK(bin1, :), 1))/length(bin1);
    okSets(2, :) = squeeze(sum(timeEitherOK(bin2, :), 1))/length(bin2);
    okSets(3, :) = squeeze(sum(timeEitherOK(bin3, :), 1))/length(bin3);
    % Also average those values across just 2020-2060

    i2020 = 2020-1860;
    i2060 = 2060-1860;
    vals(3) = 0.0;
    for i = 1:3
        vals(i) = mean(okSets(i, i2020:i2060));
    end
end

