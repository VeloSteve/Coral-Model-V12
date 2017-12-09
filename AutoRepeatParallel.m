%% Repeatedly run the model for all cases at once.
%
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
eee = 0:1; % evolution
ooo = 0:1; % acidification

% Here the function is called as a string.  Just hand-type the setup for
% now.  Choose one of the arguments which as an even number of values and
% cut it in half.  For the first try I'm using ooo.

% THIS WORKS:
eval('!matlab -r "AutoRepeatModel(''Set 1'', {''rcp26'', ''rcp45'', ''rcp60'', ''rcp85''}, [0 1], 0)" & ');
% Pause was not effective because the runs tend to synchronize anyway.
%pause(18); %Offset the two runs so it's less likely they'll be in serial parts of the code at the same time.
%eval('!matlab -r "AutoRepeatModel(''Set 2'', {''rcp26'', ''rcp45'', ''rcp60'', ''rcp85''}, [0 1], 1)" & ');
AutoRepeatModel('Set 2', {'rcp26', 'rcp45', 'rcp60', 'rcp85'}, [0 1], 1);


%{
 also this, but there's no benefit to 4 at once.
eval('!matlab -r "AutoRepeatModel(''Set 1'', {''rcp26'', ''rcp45'', ''rcp60'', ''rcp85''}, 0, 0)" & ');
pause(5); 
eval('!matlab -r "AutoRepeatModel(''Set 2'', {''rcp26'', ''rcp45'', ''rcp60'', ''rcp85''}, 1, 0)" & ');
pause(5); 
eval('!matlab -r "AutoRepeatModel(''Set 3'', {''rcp26'', ''rcp45'', ''rcp60'', ''rcp85''}, 0, 1)" & ');
pause(5); %Offset the two runs so it's less likely they'll be in serial parts of the code at the same time.
AutoRepeatModel('Set 4', {'rcp26', 'rcp45', 'rcp60', 'rcp85'}, 1, 1);
%}

fprintf('All sets of automated runs are finished (not necessarily - check background matlab instance).\n');
