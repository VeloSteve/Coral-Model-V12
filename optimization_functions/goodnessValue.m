function [goodness, pg, bleach] = goodnessValue(bleachingTarget, psw2_new, percentGone, C_seed, rtr, b8510)
    % Look at variables for "goodness". We optimize for a low value.
    % Baskett 2009 gives values of
    % "0.9 for Moorea and Curac¸ao; 0.8 for St. John, U.S. Virgin Islands;
    % 0.7 for all Australian sites; and 1.3 for Ko Phuket, Thailand."
    % For now check just Ko Phuket, number 793
    ko = abs(psw2_new(793) - 1.3);
    % St. John is at 18.35, -64.75  Reef 420 is at [-64.50,18.31]
    vi = abs(psw2_new(420) - 0.8);
    % Moorea is reef 144.
    mo = abs(psw2_new(144) - 0.9);
    add = (psw2_new(793) <= psw2_new(144)) + (psw2_new(144) <= psw2_new(420));  % penalty if out of order.
    empirical = add + ko*ko + vi*vi + mo*mo;
    % just try:
    %empirical = 16.0 * ko*ko;
    % Reefs gone by 1950
    % Technically these should be averaged weighting by the number of
    % reefs, but it's not important since the target is zero and so usually
    % no more than one column is nonzero.
    % pg = percentGone{2,2} + percentGone{3,2} + percentGone{4,2};
    % Now that there's a summary row, use it:
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
    fprintf('Diffs: ko = %f, vi = %f, mo = %f, empirical = %f, pg = %d, bleaching = %d, goodness = %f\n', ko, vi, mo, empirical, pg, bleach, goodness);
end
