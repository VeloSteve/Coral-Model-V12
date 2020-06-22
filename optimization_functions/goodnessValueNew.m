function [goodness, pg, bleach] = goodnessValueNew(bleachingTarget, percentGone, b8510)
    % Look at variables for "goodness". We optimize for a low value.

    % Reefs gone by 1950
    pg = percentGone(5, 1);
   
    bleach = b8510;
    bleachDiff = abs(bleachingTarget - bleach);
    
    %% New experimental value - how well does new model match old?

  
    % Runs for 10/28 used factors of 4/1/1.
    % Trying higher bleachDiff factor since 10% target runs are only going
    % to about 5 with those values.
    %goodness = 4.0 * empirical + 1.0 * pg + 16.0 * bleachDiff;
    % This line was used through 2018 and 2019
    %goodness = 1.0 * empirical + 4.0 * pg + 8.0 * bleachDiff; 
    % Ignore old empirical results, since model details have
    % changed. Jan 2020.
    goodness = 4.0 * pg + 8.0 * bleachDiff; 
    %goodness = pg + 2.0 * bleachDiff; 
    fprintf('pg = %d, bleaching = %d, goodness = %f\n', pg, bleach, goodness);
end
