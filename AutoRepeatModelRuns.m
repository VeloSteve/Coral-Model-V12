%% Repeatedly run the model for all cases at once.

% Read the default inputs as a starting point.
parameters = 'C:\Users\Steve\Google Drive\Coral_Model_Steve\GUIState_AndRunHistory\modelVars.txt';
[~, pd] = getInputStructure(parameters);

% Each use of this script will require some editing, since the selection of
% cases can change any of a large set of variables.
% On 2/26/2018 we need two different symbiont introduction strategies
% with 3 different temperature deltas and 4 different rcp cases.

% 80 runs:
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
deltaTList = [0.0, 1.0];
modeList = [0, 7];  % 0 7



% the two strategies are
% 1) Basic mode zero introduction in 2035.
% 2) Dynamic advantage mode 7.

% Now all the cases
timeAutoRuns = tic;
autoRunCount = 0;
for ooo = 1:1  % 0:1
    for eee = 0:1  %0:1
        for rrr = rcpList
            for ttt = deltaTList
                for mmm = modeList
                    % We modes 0 AND 7 are the same when the advantage is zero, so skip one.
                    if ~(ttt == 0.0 && mmm == 7)
                        pd.set('E', eee == 1);
                        pd.set('OA', ooo == 1);
                        pd.set('RCP', rrr{1});
                        pd.set('superMode', double(mmm));
                        pd.set('superAdvantage', ttt);
                        if mmm == 7
                            pd.set('superStart', 1861);
                        else
                            pd.set('superStart', 2035);
                        end        
                        autoRunCount = autoRunCount + 1;
                        fprintf('Starting model with E = %d, OA = %d, RCP %s, superMode %d, superAdvantage %d\n', ...
                            eee, ooo, rrr{1}, mmm, ttt);
                        fprintf('   and keyReefs = %d', pd.get('keyReefs'))

                        A_Coral_Model(pd)
                    end
                end
            end
        end
    end
end
fprintf('All %d cases are complete.', autoRunCount);
% If this isn't done, the next one-off model run will mysteriously pick
% up values from the last iteration here!
clearvars scriptVars

deltaT = toc(timeAutoRuns);
fprintf('All %d automated runs finished in %7.1f seconds.\n', autoRunCount, deltaT);
