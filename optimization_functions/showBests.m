function [sBelow, sAbove] = showBests(cumResult, possible, steps)
% get rid of singleton dimensions
%foo = squeeze(cumResult);
% find indexes of nonzeros
idx = find(~isnan(cumResult));
vals = cumResult(~isnan(cumResult));
% sort together
[vals, sortIdx] = sort(vals);
idxSorted = idx(sortIdx);
% Now work with just the top 10, and find indexes and values.
fprintf('Ten best optimization results across all runs:\n');
best10 = idxSorted(1:min(10, length(idxSorted)));
belowDone = false;
aboveDone = false;
for iii = 1:length(best10)
    i = best10(iii);
    [a, b, c, d] = ind2sub(size(cumResult), i);
    % baz will contain an array of 4 cells.  Inside, each has an array with the value
    % we want at index 5.
    baz = setOptimizationInputs([a b c d], possible, steps);
    for j = 4:-1:1
        vName{j} = baz{j}{1};
        vVal(j) = baz{j}(5);
    end
    if iii == 1
        sBelow = vVal{4};
        sAbove = vVal{4};
    else
        if ~belowDone && vVal{4} < sBelow
            sBelow = vVal{4};
            belowDone = true;
        end
        if ~aboveDone && vVal{4} > sAbove
            sAbove = vVal{4};
            aboveDone = true;
        end
    end
    
    fprintf('At %2d %2d %2d %2d obj = %8.4f, inputs %s = %8.4f, %s = %8.4f, %s = %8.4f, %s = %8.4f\n', ...
        a, b, c, d, cumResult(i), ...
        vName{1}, vVal{1}, vName{2}, vVal{2}, vName{3}, vVal{3}, vName{4}, vVal{4});
end
end

