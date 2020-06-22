%% The code to find new optimal inputs for psw2 calculations became overly
%  complicated.  Rather than try to clean it up, this is a fresh start.
% 
% Key points:
% - Set model parameters by manipulating and passing a ParameterDictionary
%   rather than relying on manual modifications of modelVars.txt
% - Every model or setting variation which changes historical reef behavior will
%   require a separate result.
% - For each result, the model will be run enough times to find the minimum of
%   an objective function which balances 1985-2010 bleaching, not creating dead
%   reef in that period, and perhaps making psw2 similar to specific reefs from
%   Baskett et al. (2009).
% - Save results with "answers" and quality information for review after a batch
%   of cases is complete.
% - Final parameters will be stored in a n-dimensional array where n is the
%   number of different parameters which can be changed.  The array is likely
%   to be sparse, as not all cases are needed.  It also has the potential to be
%   huge, but note that a) many dimensions are of size 2, for example evolution
%   is on or off; b) MATLAB has approaches for handling huge sparse arrays
%   should it become necessary.

% Possible big performance wins:
%  - Cut off runs after 2010, saving about 90/240 (3/8) of the run time.
%  - Start each run at the "s" value from the last run or a similar starting
%    point.
%  - Stop based on convergence rather than a fixed number of passes. (even more
%    valuable when starting with a good guess)
%  - Use a built in optimization approach from MATLAB.

OptTimerStart = tic;

%% Obtain a ParameterDictionary as a starting point.
addpath('..');
[~, pd] = getInputStructure('D:\GitHub\Coral-Model-V12\modelVars.txt');
pd.set('optimizerMode', true);

%% Define possible variations
% Values are E, OA, RCP, superMode, advantage, growth penalty, start, bleachTarget
% List all values we expect to use in the forseeable future, but note that
% values and entire parameters are occasionally added.
%
% Don't change these lightly, as they define array locations for s values.
% Any change requires discarding or manually resizing the array in the
% stored *.mat file.
fullE = [true, false];
fullOA = [true, false];
fullRCP = {'rcp26', 'rcp45', 'rcp60', 'rcp85', 'mean '};  
fullSuperMode = 0:9;
fullAdvantage = [0, 0.5, 1.0, 1.5, 2.0];
fullGrowthPenalty = [0, 0.25, 0.5];
fullStartYear = [1861, 2100];
fullBleachTarget = [3, 5, 10];

%% Edit only this section!

% Start small!
useE = [0 1];
useOA = [0 1];
useRCP = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
useSuperMode = 9;
useAdvantage = [0 0.5 1.0 1.5]; %[0.0 0.5 1.0 1.5];
useGrowthPenalty = [0.5];
useStartYear = [1861];
useBleachTarget = [3 5 10];

% XXX Just for testing:
% pd.set('everyx', 1);

% There are 3 ways to treat old results.
% 1) Discard all and start over.
% 2) Run only the specified cases which have NaN entries.
% 3) Run all specified cases, overwriting any existing results.
% TODO: clean up logic in next dozen lines or so.
% TODO: record how many passes were made in case we want to do
%       a rough pass and followups.
% TODO: verify each option.  3 is verified to replace old values.
oldTreatment = 2;

%% Recover old results or create a new empty array
if oldTreatment == 1
%   Values are pMin, pMax, y, s, objectiveFunction, bleachingResult, percentGone
    dummyResult = [0.25, 1.5, 0.46, 5.0, 12.1, 5.001, 0.0];
    pswResults = NaN(length(fullE), length(fullOA), length(fullRCP), ...
        length(fullSuperMode), length(fullAdvantage), length(fullGrowthPenalty), ...
        length(fullStartYear), length(fullBleachTarget), length(dummyResult));
else
    try
        load('Optimize_checkpoint.mat', 'pswResults');
    catch
        %   Values are pMin, pMax, y, s, objectiveFunction, bleachingResult, percentGone
        dummyResult = [0.25, 1.5, 0.46, 5.0, 12.1, 5.001, 0.0];
        pswResults = NaN(length(fullE), length(fullOA), length(fullRCP), ...
            length(fullSuperMode), length(fullAdvantage), length(fullGrowthPenalty), ...
            length(fullStartYear), length(fullBleachTarget), length(dummyResult));
    end
    
end


%% Run all the required cases, adding to an array of results

% Use triple letters for parameters and double letters for their location in the
% full* arrays and the pswResults array.
caseCount = 0;
for ooo = useOA 
    pd.set('OA', ooo==1);
    oo = find(fullOA==ooo);
    for mmm = useSuperMode
        pd.set('superMode', double(mmm));
        mm = find(fullSuperMode == mmm);
        for aaa = useAdvantage
            pd.set('superAdvantage', aaa);
            aa = find(fullAdvantage == aaa);
            for ppp = useGrowthPenalty
                pd.set('superGrowthPenalty', ppp);
                pp = find(fullGrowthPenalty == ppp);
                for yyy = useStartYear
                    pd.set('superStart', yyy);
                    yy = find(fullStartYear == yyy);
                    for ttt = useBleachTarget
                        pd.set('bleachingTarget', ttt);
                        tt = find(fullBleachTarget == ttt);       
                        for eee = useE
                            pd.set('E', eee==1);
                            ee = find(fullE==eee);                            
                            for rrr = useRCP
                                pd.set('RCP', rrr{1});
                                % Index rcp by 1 to 4, regardless of the number
                                % of cases run at this time:
                                isMatch = cellfun(@(x)isequal(x,rrr{1}),fullRCP);
                                rr = find(isMatch);
                                

                                % oldTreatment 2 is the only one which skips
                                % runs.  It does so if there is already a
                                % result.
                                if oldTreatment ~= 2 || isnan(pswResults(ee,oo,rr,mm,aa,pp,yy,tt,1))
                                    caseCount = caseCount + 1;
                                    fprintf("Optimizing for case %d, Target = %d, E = %d, OA = %d, RCP = %s, advantage = %d\n", ...
                                        caseCount, ttt, eee, ooo, rrr{1}, aaa);
                                    [quality, parameters] = RunPSWCases(pd);
                                    pswResults(ee,oo,rr,mm,aa,pp,yy,tt,:) = [parameters, quality];
                                    save('Optimize_checkpoint.mat', 'pswResults');
                                else
                                    fprintf("    Skipping completed case\n");
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% Calculate average across all RCP scenarios for all cases which are complete
%  for all 4. This is likely to be redundant for restart runs, but it's fast
%  and probably better than risking a failure to update results with another
%  approach.
%  Try pulling out just the rcp26/pMin slice, getting all the other indexes, and then
%  going back to the full array.
% Find just the points corresponding to rcp26, pMin.
slice = squeeze(pswResults(:,:,1,:,:,:,:,:,1));
sliceIdx = find(~isnan(slice));
for idx = 1:length(sliceIdx)
    i = sliceIdx(idx);
    % Get the indexes, but labeled for the full array.
    [i1,i2,i4,i5,i6,i7,i8] = ind2sub(size(slice), i);
    % See if the "s" value is defined for all rcp cases
    if ~isnan(pswResults(i1, i2, 1, i4, i5, i6, i7, i8, 4)) && ...
       ~isnan(pswResults(i1, i2, 2, i4, i5, i6, i7, i8, 4)) && ...
       ~isnan(pswResults(i1, i2, 3, i4, i5, i6, i7, i8, 4)) && ...
       ~isnan(pswResults(i1, i2, 4, i4, i5, i6, i7, i8, 4))
        % Average s values (last index = 4)
        pswResults(i1, i2, 5, i4, i5, i6, i7, i8, 4) = ...
            mean(pswResults(i1, i2, 1:4, i4, i5, i6, i7, i8, 4));
        % Copy any one value of last index 1:3 (inputs)
        pswResults(i1, i2, 5, i4, i5, i6, i7, i8, 1:3)  = ...
            pswResults(i1, i2, 1, i4, i5, i6, i7, i8, 1:3);        
        % Averaged obj, bleach, and mort don't make much sense.
        pswResults(i1, i2, 5, i4, i5, i6, i7, i8, 5:7)  = 0.0;
    end
end

%% Print the results, both to examine them and to verify that we are storing and
% retrieving correctly.
pMinIndexes = find(~isnan(pswResults(:,:,:,:,:,:,:,:,1)));
fprintf(" E   OA  RCP    Mode  Adv    Penalty Target pMin    pMax   y      s        obj      bleach   mort\n");
for idx = 1:length(pMinIndexes)
    i = pMinIndexes(idx);
    [i1,i2,i3,i4,i5,i6,i7,i8,i9] = ind2sub(size(pswResults), i);
    resultSet = squeeze(pswResults(i1, i2, i3, i4, i5, i6, i7, i8, :));  % squeeze removes singleton dimensions.
    fprintf('%2d  %2d   %s %2d   %6.2f %6.2f  %6.2f  %6.3f %6.2f %6.2f %8.4f %8.4f %8.4f %8.4f\n', ...
        fullE(i1), fullOA(i2), fullRCP{i3}, fullSuperMode(i4), fullAdvantage(i5), fullGrowthPenalty(i6), fullBleachTarget(i8), resultSet(:));
end

fprintf('Completed optimization of %d cases in %7.1f seconds.\n', caseCount, toc(OptTimerStart));