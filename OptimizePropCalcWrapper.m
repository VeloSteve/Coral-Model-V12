wrapTimerStart = tic;

% Call OptimizePropCalc several times, attempting to zoom in on the best value.
targetSet = 10.0;
RCPset = 'rcp85';
useLowerS = 7;
useUpperS = 9;
passes = 3;

for www = 1:passes  
    if www > 1
        useLowerS = sBelow;
        useUpperS = sAbove;
    end
    fprintf("\n===== Pass %d with range %9.4f, %9.4f =====\n", www, useLowerS, useUpperS);
    OptimizePropCalc
    % Now variables from the run should be accessible (it's a script, not a
    % function).
end

fprintf('Completed %d passes in %7.1f seconds.\n', passes, toc(wrapTimerStart));