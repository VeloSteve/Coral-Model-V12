function [ longMort ] = getFiveYearMortality( mState, startYear )
%getFiveYearMortality Return a list of the years in which each reef begins 
% five or more years of mortality.
% Incoming array is (reefs x years x coral types +1)
maxReef = size(mState, 1);
ms = mState(:, :, size(mState, 3));
longMort = zeros(maxReef, 1);
for k = 1:maxReef
    v = ms(k, :);
    av = trailingAverageFilt(v, 5);
    ind = find(av >= 1, 1);
    if ~isempty(ind)
        longMort(k) = ind + startYear - 1;
    end
end
end

