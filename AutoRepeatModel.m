% Run the model for the specified cases at once.
function autoRepeatModel(callName, rcpList, eList, oList)
    %  Variables from the supported set have defaults in the main code, but
    %  it's best to set them all here to avoid surprises.
    timeAutoRuns = tic;
    % First those we aren't changing in this run:
    scriptVars.superMode = 0;
    scriptVars.superAdvantage = 0.0;

    % Now all the cases
    autoRunCount = 0;
    for ooo = oList  % 0:1
        for eee = eList  %0:1
            for rrr = rcpList
                scriptVars.E = eee;
                scriptVars.OA = ooo;
                scriptVars.RCP = rrr{1};
                autoRunCount = autoRunCount + 1;
                fprintf('Starting model with E = %d, OA = %d, RCP %s\n', eee, ooo, rrr{1});
                try
                    A_Coral_Model_170118
                catch err
                    if strcmp(err.message, 'Undefined function or variable ''Bleaching_85_10''.')
                        disp('Continuing after coral model crash after mapping.');
                    else
                        rethrow(err); %some other unexpected error. Better stop
                    end
                end
            end
        end
    end
    disp('All cases are complete.');
    % If this isn't done, the next one-off model run will mysteriously pick
    % up values from the last iteration here!
    clearvars scriptVars

    deltaT = toc(timeAutoRuns);
    fprintf('All %d auto-repeat runs for %s finished in %7.1f seconds.\n', autoRunCount, callName, deltaT);

end
