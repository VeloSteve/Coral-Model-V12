function [queueMax] = parallelSetup(n)
    % Cases: n undefined - use existing pool
    %        n = existing pool size - use exising pool
    %        n = 0 - leave existing pool alone (if any). Don't use it.
    %        n != existing pool size - delete any old pool and create one
    if nargin == 0
        % User wants to use whatever exists.
        pool = gcp('nocreate'); % Maximum number of threads for PDF creation.
        if isempty(pool)
            threads = 0;
            multiThread = false;
        else
            threads = pool.NumWorkers;
            multiThread = true;
        end
        fprintf('Using existing pool size with %d threads.\n', threads);
        poolReady = true;
    elseif n <= 1
        % User wants no parallel threads.
        threads = 0;
        multiThread = false;
        poolReady = true;
    else
        % User specified a number of threads.  This will fail if more are
        % asked for than the value in Parallel Preferences.
        pool = gcp('nocreate');
        if isempty(pool)
            threads = n;
            multiThread = true;
            poolReady = false;
        elseif n == pool.NumWorkers
            threads = n;
            multiThread = true;
            poolReady = true;
        else
            threads = n;
            multiThread = true;
            poolReady = false;
            delete(gcp('nocreate'));
        end 
    end
    % Start a pool if needed, and notify in most cases.
    if multiThread && ~poolReady
        pool = parpool(threads);
        fprintf('Running with up to %d worker threads.\n', pool.NumWorkers);
    elseif nargin == 0 && ~multiThread
        fprintf('Multithreaded computation is off.');
    end
    queueMax = threads;
    
    if multiThread
        % I'm not sure whether this line does anything.  Check some time.
        queue =  parallel.FevalFuture.empty;
        % Call plot function with no arguments.  If the workers have been used
        % before this clears their variables.  If not it gets the plot routine
        % loaded onto them.
        spmd
            Plot_One_Reef();
            % not currently used graphCompare();
        end
    end
    
end