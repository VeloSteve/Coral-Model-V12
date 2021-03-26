function printResultPSW(pswResults)
    %PRINTRESULTPSW Print all previous and new PSW results.
    % This is used by AllNewPSW2, but is also useful to manually check the
    % stored array.  Load pswResults from the 9D file in mat_files, change to
    % this directory, and run the function.
    DefineCaseOptions
    pMinIndexes = find(~isnan(pswResults(:,:,:,:,:,:,:,:,1)));
    countCase = 0; objMax = 0; bMin = 20; bMax = 0; mMin = 20; mMax = 0;
    fprintf(" E   OA  RCP    Mode  Adv    Penalty Start  Target pMin    pMax   y      s        obj      bleach   mort\n");
    for idx = 1:length(pMinIndexes)
        i = pMinIndexes(idx);
        [i1,i2,i3,i4,i5,i6,i7,i8,i9] = ind2sub(size(pswResults), i);
        resultSet = squeeze(pswResults(i1, i2, i3, i4, i5, i6, i7, i8, :));  % squeeze removes singleton dimensions.
        fprintf('%2d  %2d   %5s %2d   %6.2f %6.2f    %4d %6.2f  %6.3f %6.2f %6.2f %8.4f %8.4f %8.4f %8.4f\n', ...
            fullE(i1), fullOA(i2), fullRCP{i3}, fullSuperMode(i4), fullAdvantage(i5), fullGrowthPenalty(i6), fullStartYear(i7), fullBleachTarget(i8), resultSet(:));
        if i3 ~= 5
            countCase = countCase + 1;
            objMax = max(objMax, resultSet(5));
            bMin = min(bMin, resultSet(6));
            bMax = max(bMax, resultSet(6));
            mMin = min(mMin, resultSet(7));
            mMax = max(mMax, resultSet(7));
        end
    end
    fprintf("%d rows\n", length(pMinIndexes));
    fprintf("Max objective: %6.2f Bleaching %8.4f to %8.4f  Mortality %8.4f to %8.4f\n", ...
        objMax, bMin, bMax, mMin, mMax);
end

