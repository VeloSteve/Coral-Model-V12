%% Test parallel performance by running the main program with all possible numbers of workers.
% Note that maxthreads should not be larger than set in preferences, or
% this just repeats the largest allowed number for those cases.
maxTestThreads = 12;
minTestThreads = 0;
fullRepeats = 11;
perf = zeros(maxTestThreads+1, fullRepeats);
for iParTest = maxTestThreads:-1:minTestThreads
    %perf(iParTest+1, rep, 1) = iParTest;
    delete(gcp('nocreate')); % always start with a fresh pool (or none)
    disp('Starting pool in ParallelTest');
    if iParTest > 0
        pool = parpool(iParTest);
    end   
    disp('Done setting pool in ParallelTest');
    for rep = 1:fullRepeats
        tTime = tic;
        useTestThreads = iParTest; % make this the argument to parallelSetup
        A_Coral_Model_170118
        perf(iParTest+1, rep) = toc(tTime);
        %perf(iParTest+1, rep, 3) = elapsed;
        clearvars -except pool iParTest minTestThreads maxTestThreads perf rep fullRepeats
        % wait 15 seconds to reduce possible effects of processor heating.
        fprintf('Cool ');
        pause(12);
        fprintf(' it.');
    end
end
disp(perf)
disp('Performance test complete. Note that while Matlab arrays are 1-indexed, the first row contains 0-processor data.  Number of workers is the row number minus 1.');