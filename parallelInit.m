function [parSwitch, queueMax, chunkSize, toDoPart] = parallelInit(queueMax, toDo)
    queueMax = max(1, queueMax);
    % No point in having more threads than reefs.
    queueMax = min(queueMax, length(toDo));
    parSwitch = queueMax;
    % Split the toDo list into one nearly equal chunk per thread.
    % NOTE: chunkSize is the max, but some chunks will be smaller when the
    % reefs don't divide evenly.
    chunkSize = ceil(length(toDo)/queueMax);
    toDoPart = cell(queueMax);
    if queueMax > 1
        % This messy-looking code checks how to divide up the reefs after each
        % chunk, so 13 reefs on 4 processors (for example) come out in chunks of
        % 4, 3, 3, and 3 rather than 4, 4, 4, and 1.
        left = length(toDo);
        r1 = 1;
        r2 = chunkSize;
        for i = 1:queueMax
            %fprintf('Parallel chunk with %d reefs from %d to %d\n', (r2-r1+1), toDo(r1), toDo(r2));
            toDoPart{i} = toDo(r1:r2);
            left = left - (1+r2-r1);
            r1 = r2 + 1;
            newSize = ceil(left/(queueMax-i));
            r2 = r1 + newSize - 1;
        end
    else
        % Running a worker is slower if there's only one chunk of work.
        % disp('Pool size zero.');
        parSwitch = 0;
        toDoPart{1} = toDo;
    end
end