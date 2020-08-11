% This file is used to define the case options supported during optimization AND
% at model run time.  By defining them in a single file we ensure that they stay
% in sync PROVIDED that when this file is changed all of the 9D array files are
% deleted and rebuilt.

% Don't change these lightly, as they define array locations for s values.
% Any change requires discarding or manually resizing the array in the
% stored *.mat file.
fullE = [true, false];
fullOA = [true, false];
fullRCP = {'rcp26', 'rcp45', 'rcp60', 'rcp85', 'mean'};  
fullSuperMode = 0:9;
fullAdvantage = [0, 0.5, 1.0, 1.5, 2.0];
fullGrowthPenalty = [0, 0.25, 0.5];
fullStartYear = [1861, 2101];
fullBleachTarget = [3, 5, 10];
