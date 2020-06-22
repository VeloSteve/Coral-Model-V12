%% PROPORTIONALITY CONSTANT PARAMETERS
% are saved where the model will see them.  This replaces a more complicated
% script which had to actually load the climatology.  Now the solver does that 
% and calculates the psw2 values from parameters saved here.



%% Store optimizer inputs from propInputValues 
pswInputs(:,1) = propInputValues';

%% XXX TODO Don't forget to create averaged sets across all RCP values once
%  a full set of values is available.


%% Save new psw2 values
thisPath = pwd;
cd('../mat_files/');
save('Optimize_psw2_temp.mat', 'pswInputs'); %% CAL 10-3-16 based on hist SSTs!
cd(thisPath);
