% Does cold lead to mortality?  Try some definitions.
inputFile = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\ColdEvents_rcp85E=0OA=0Adv=1.mat';
RCP = 'RCP 8.5'; % MUST MATCH LINE ABOVE!

yearSets = [1861 1950; 1985 2010; 2010 2100];
desc = {'(historical)', '(normalization)', '(future)'};
for n = 1:3
    years = yearSets(n, :);
    fprintf('\n%s, %d-%d %s\n', RCP, years(1), years(2), desc{n});
    %years = [1985 2010];
    %years = [2010 2100];
    idx = years(1)-1860:years(2)-1860;
    % Reload file each time, since original script discards part of the data.
    load(inputFile);
    % Cut everything down to the desired years.
    mortState = mortState(:, idx, :);
    bleachEvents = bleachEvents(:, idx, :);
    coldEvents = coldEvents(:, idx, :);
    mortEvents = zeros(size(coldEvents), 'like', coldEvents);


    % Transitions in state are mortality events.  mounding != branching
    mortEvents(:, 2:end, :) = mortState(:, 1:end-1, :) < mortState(:, 2:end, :);

    % Look at how many mortality events and cold or warm events in the leading 3
    % years (or same year).
    warmEvents = bleachEvents - coldEvents;

    % Don't keep track of reefs or morphology - just event counts.
    % Mounding (doing one at a time makes it easy to get 2D indexes)
    [mr, my] = find(mortEvents(:, :, 1));
    mCount = length(mr);
    leadingCold = zeros(mCount, 2); % Events, counts
    leadingWarm = zeros(mCount, 2);
    for i = 1:mCount
        leadingCold(i, 1) = coldEvents(mr(i), my(i), 1); % Cold events in same year
        leadingCold(i, 2) = leadingCold(i, 1) + coldEvents(mr(i), my(i)-1, 1); % plus 1 year before

        leadingWarm(i, 1) = warmEvents(mr(i), my(i), 1); % Cold events in same year
        leadingWarm(i, 2) = leadingWarm(i, 1) + warmEvents(mr(i), my(i)-1, 1); % plus 1 year before

    end
    fprintf("Of %d mortality events in Mounding corals, %d to %d\n", mCount, years(1), years(2));
    fprintf("%3.1f%% / %3.1f%% had cwb / wwb events the same year.\n", 100*sum(leadingCold(:, 1))/mCount, 100*sum(leadingWarm(:, 1))/mCount);
    fprintf("%3.1f%% / %3.1f%%  had a cwb / wwb event in 2 years.\n", 100*sum(leadingCold(:, 2)>0)/mCount, 100*sum(leadingWarm(:, 2)>0)/mCount);

    %Branching (Note that variables are re-used)
    [mr, my] = find(mortEvents(:, :, 2));
    mCount = length(mr);
    leadingCold = zeros(mCount, 2); % Events, counts
    leadingWarm = zeros(mCount, 2);
    for i = 1:mCount
        leadingCold(i, 1) = coldEvents(mr(i), my(i), 2); % Cold events in same year
        leadingCold(i, 2) = leadingCold(i, 1) + coldEvents(mr(i), my(i)-1, 2); % plus 1 year before

        leadingWarm(i, 1) = warmEvents(mr(i), my(i), 2); % Cold events in same year
        leadingWarm(i, 2) = leadingWarm(i, 1) + warmEvents(mr(i), my(i)-1, 2); % plus 1 year before

    end
    fprintf("\nOf %d mortality events in Branching corals, %d to %d\n", mCount, years(1), years(2));
    fprintf("%3.1f%% / %3.1f%% had cwb / wwb events the same year.\n", 100*sum(leadingCold(:, 1))/mCount, 100*sum(leadingWarm(:, 1))/mCount);
    fprintf("%3.1f%% / %3.1f%%  had a cwb / wwb event in 2 years.\n", 100*sum(leadingCold(:, 2)>0)/mCount, 100*sum(leadingWarm(:, 2)>0)/mCount);
end
    
