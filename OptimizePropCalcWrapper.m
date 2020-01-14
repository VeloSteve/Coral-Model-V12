wrapTimerStart = tic;

% Call OptimizePropCalc several times, attempting to zoom in on the best value.
targetSet = 3.0;
RCPset = 'rcp26';
useLowerS = 3;
useUpperS = 5;
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