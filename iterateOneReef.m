function [S, C, gi, vgi, origEvolved, bleachStateTemp, optProp] = iterateOneReef(iteratorHandle, timeSteps, S_start, C_start, dt, ...
                        temp, OA, omega, vgi, gi, MutVx, SelVx_noPSW, C_seed, S_seed, suppressSI, ...
                        superSeedFraction, superMode, superAdvantage, oneShot, ...
                        bleachStateTemp, bleachParams, coralSymConstants, startYear, TIME)
% iterateOneReef Try proportionality constants until a bleaching target
% is met.
%
% To calibrate to the Donner database, each reef will be tested against actual
% or statistically estimated bleaching data.  The proportionality constant which
% best matches the data will be stored and used in later global runs.
% 
% The function call below works as in the main A_Coral_Model program, but
% instead of using a fixed psw value from a *.mat file, this function tries
% different psw multipliers to try to find an optimum.  There is some fuzziness,
% since there will normally be some range of psw values which matche the target
% bleaching value.  An attempt will be made to pick a value near the middle of
% the range, while realizing that there is no exact answer.

prints = 0;

minP = 0.36;
maxP = 1.35;
target = 3; % XXX get this from the Donner database!
steps = 7;

% Values used repeatedly, normally only outside the parallel loop in normal
% runs:
i1985 = 1985 - startYear + 1;
i2010 = 2010 - startYear + 1;

% pass 1, steps calculations across the min/max range.
% Assume that large psw leads to less bleaching, and small to more, but CHECK
% THIS at some point.
tryThese = linspace(minP, maxP, steps);
tooBig = steps;
tooSmall = 1;
for i = 1:length(tryThese)
    SelVx = SelVx_noPSW * tryThese(i);
    [S, C, gi, vgi, origEvolved, bleachStateTemp] = iteratorHandle(timeSteps, S_start, C_start, dt, ...
               temp, OA, omega, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSI, ...
               superSeedFraction, superMode, superAdvantage, oneShot, ...
               bleachStateTemp, bleachParams, coralSymConstants);
           
    % get stats as in the main model, but for just one reef:
    [ ~, ~, ~, bleachEventOneReef, ~, ~ ] = ...
    Clean_Bleach_Stats(C, S, C_seed, S_seed, dt, TIME, bleachParams, coralSymConstants);
    % count bleaching events from 1985 to 2010.
    events = nnz(bleachEventOneReef(i1985:i2010, :));
    if prints fprintf('Pass 1. With psw = %6.3f, events = %d\n', tryThese(i), events); end;
    if events < target
        tooBig = min(i, tooBig);
    elseif events > target
        tooSmall = max(i, tooSmall);
    end
end



% Are only the end values not ideal? If so there's a huge "okay" zone and no
% point in fine-tuning.
if tooSmall == 1 && tooBig == steps
    optProp = (minP + maxP) / 2.0;
    return;
end

% See if we are up against min and max at one end.  If so check the end
% interval
% Are all values giving too much bleaching?
if tooSmall == steps
    minP = tryThese(4);
elseif tooBig == 1
    maxP = tryThese(2);
else
    % There are two different "not right" values
    minP = tryThese(tooSmall);
    maxP = tryThese(tooBig);
end
fprintf('\n New min/max %6.3f to %6.3f\n', minP, maxP);

% Second pass, if conditions above didn't exit.
tryThese = linspace(minP, maxP, steps);
tooBig = steps;
tooSmall = 1;
for i = 1:length(tryThese)
    SelVx = SelVx_noPSW * tryThese(i);
    [S, C, gi, vgi, origEvolved, bleachStateTemp] = iteratorHandle(timeSteps, S_start, C_start, dt, ...
               temp, OA, omega, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSI, ...
               superSeedFraction, superMode, superAdvantage, oneShot, ...
               bleachStateTemp, bleachParams, coralSymConstants);
           
    % get stats as in the main model, but for just one reef:
    [ ~, ~, ~, bleachEventOneReef, ~, ~ ] = ...
    Clean_Bleach_Stats(C, S, C_seed, S_seed, dt, TIME, bleachParams, coralSymConstants);
    % count bleaching events from 1985 to 2010.
    events = nnz(bleachEventOneReef(i1985:i2010, :));
    if prints fprintf('Pass 2. With psw = %6.3f, events = %d\n', tryThese(i), events); end;
    if events < target
        tooBig = min(i, tooBig);
    elseif events > target
        tooSmall = max(i, tooSmall);
    end
end

% See if we are up against min and max at one end.  If so check the end
% interval
% Are all values giving too much bleaching?
if tooSmall == steps
    minP = tryThese(4);
elseif tooBig == 1
    maxP = tryThese(2);
else
    % There are two different "not right" values
    minP = tryThese(tooSmall);
    maxP = tryThese(tooBig);
end
fprintf('\n New min/max %6.3f to %6.3f\n', minP, maxP);

% Third pass, if conditions above didn't exit.
tryThese = linspace(minP, maxP, steps);
tooBig = steps;
tooSmall = 1;
for i = 1:length(tryThese)
    SelVx = SelVx_noPSW * tryThese(i);
    [S, C, gi, vgi, origEvolved, bleachStateTemp] = iteratorHandle(timeSteps, S_start, C_start, dt, ...
               temp, OA, omega, vgi, gi, MutVx, SelVx, C_seed, S_seed, suppressSI, ...
               superSeedFraction, superMode, superAdvantage, oneShot, ...
               bleachStateTemp, bleachParams, coralSymConstants);
           
    % get stats as in the main model, but for just one reef:
    [ ~, ~, ~, bleachEventOneReef, ~, ~ ] = ...
    Clean_Bleach_Stats(C, S, C_seed, S_seed, dt, TIME, bleachParams, coralSymConstants);
    % count bleaching events from 1985 to 2010.
    events = nnz(bleachEventOneReef(i1985:i2010, :));
    if prints fprintf('Pass 3. With psw = %6.3f, events = %d\n', tryThese(i), events); end;
    if events < target
        tooBig = min(i, tooBig);
    elseif events > target
        tooSmall = max(i, tooSmall);
    end
end

% Are all values giving too much bleaching?
if tooSmall == steps
    minP = tryThese(4);
elseif tooBig == 1
    maxP = tryThese(2);
else
    % There are two different "not right" values
    minP = tryThese(tooSmall);
    maxP = tryThese(tooBig);
end

% We could keep iterating, but just use the middle of the range:
fprintf('Averaging %6.3f and %6.3f \n', minP, maxP);
optProp = (minP + maxP) / 2.0;

end

