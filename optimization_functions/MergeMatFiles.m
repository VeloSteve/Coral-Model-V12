%% Read and merge two mat files containing pswResults.  The intent is to use this
%  when the same algorithm is run to optimize different subsets of the possible
%  cases, perhaps on different computers.  The resulting files can then be merged
%  and used as one.

function MergeMatFiles(fn1, fn2)
    try
        load(fn1, 'pswResults');
        set1 = pswResults;
    catch
        fprintf('File %s was missing or did not contain pswResults.  Exiting.\n', fn1);
        return;
    end

    try
        load(fn2, 'pswResults');
        set2 = pswResults;
    catch
        fprintf('File %s was missing or did not contain pswResults.  Exiting.\n', fn2);
        return;
    end
    
    size1 = size(set1);
    size2 = size(set2);
    
    if size1 ~= size2
        error('Cannot merge pswResults files of different size.');
    end
    
    % Linear index of the locations where E is defined (normally 0 or 1).
    % It is used only because it is the first of the 7 result values.
    idx1 = find(~isnan(set1(:,:,:,:,:,:,:,:,1)));
    idx2 = find(~isnan(set2(:,:,:,:,:,:,:,:,1)));
    
    if ~isempty(intersect(idx1, idx2))
        error('Only merging of non-overlapping sets is currently supported.');
    end
    
    % Copy all defined items from 2 into 1
    for idx = 1:length(idx2)
        i = idx2(idx);
        % Get the individual indexes back, and ignore the 9th.
        [i1,i2,i3,i4,i5,i6,i7,i8,~] = ind2sub(size(pswResults), i);
        set1(i1, i2, i3, i4, i5, i6, i7, i8, :) = set2(i1, i2, i3, i4, i5, i6, i7, i8, :);
    end
    pswResults = set1;
    
    fprintf('Remember that the RCP mean values are in the _9D output files, but not in Optimize_checkpoint.mat\n');
    save('merged_9D.mat', 'pswResults');


    %% Print the results, both to examine them and to verify that we are storing and
    % retrieving correctly.
    printResultPSW(pswResults);

end
