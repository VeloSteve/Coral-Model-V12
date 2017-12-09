function [ ] = saveMortYears( mortState, startYear, RCP, E, OA, fullMapDir, ...
        modelChoices, filePrefix, Reefs_latlon, bleachState, maxReefs)
% Save the years in which reefs reached 5 years of mortality for use during
% mortality-dependent super symbiont addition.

    longMortYears = getFiveYearMortality(mortState, startYear);
    fn = strcat('longMortYears_', RCP, '_', num2str(E));
    save(fn, 'RCP', 'E', 'OA', 'longMortYears');
    MapsSymbiontYears(fullMapDir, modelChoices, filePrefix, longMortYears, Reefs_latlon);
    quants = [0.005 .05 .25 .5 .75 .95 0.995];
    qLong = quantile(longMortYears, quants);
    logTwo('Quantile fractions for the new longMortYears array:\n');
    logTwo('Fraction  Year\n');
    fmt = repmat('%8.3f', 1, length(quants));
    logTwo(strcat(fmt,'\n'), quants);
    fmt = repmat('%8d', 1, length(quants));
    logTwo(strcat(fmt,'\n'), qLong);

    % Same for first full-reef bleaching
    bs = bleachState(:, :, size(bleachState,3));
    firstBleachYears = zeros(maxReefs, 1);
    for k = 1:maxReefs
        ind = find(bs(k, :), 1);
        if ~isempty(ind)
            firstBleachYears(k) = ind + startYear - 1;
        end
    end
    fn = strcat('firstBleachYears_', RCP, '_', num2str(E));
    save(fn, 'RCP', 'E', 'OA', 'firstBleachYears');
    qBleach = quantile(firstBleachYears, quants);
    logTwo('Quantile fractions for the new firstBleachYears array:\n');
    logTwo('Fraction  Year\n');
    fmt = repmat('%8.3f', 1, length(quants));
    logTwo(strcat(fmt,'\n'), quants);
    fmt = repmat('%8d', 1, length(quants));
    logTwo(strcat(fmt,'\n'), qBleach);
end

