% Table 1 in the paper required numbers from the console output of many
% different runs, which was tedious.  This reads the save console.txt files and
% pulls out the required values.
%
% The directory containing all relevant cases for bleaching target 5 and the
% latest runs intended for publication.
%dir = "d:/CoralTest/July2020_CurveE221_Target5_NoCoralBleaching/";
%datestr = "20200721"; % yyyymmdd, assuming all were run on the same day.

dir = "D:\CoralTest\July2020_CurveE221_Target5_TempForFigures\MortalityBasedOnMax_FixRecoveryBug\";
datestr = "20200730"; % yyyymmdd, assuming all were run on the same day.

% The table is organized in rows for each RCP.  Each row has sections for
% E=0, Adv=0; E=1; Adv=1; and E=1,Adv=1 in that order.  Within each section
% the values for % coral cover, % not bleached, and % heat sensitive are listed.
rcpList = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
deltaTList = [0 1.0]; % [0.0, 1.0];
eList = [0, 1];

% rows
for rrr = rcpList
    % section 1
    E = 0; DT = 0;
    fprintf("For " + rrr + " ");
    sub = "ESM2M." + rrr + ".E" + num2str(E) + ".OA0.sM9.sA" + ...
            num2str(DT, "%3.1f") + "." + datestr + "_maps/";
    getItems(dir + sub); 
    
    E = 1; DT = 0;
    sub = "ESM2M." + rrr + ".E" + num2str(E) + ".OA0.sM9.sA" + ...
            num2str(DT, "%3.1f") + "." + datestr + "_maps/";
    getItems(dir + sub); 
    
    E = 0; DT = 1;
    sub = "ESM2M." + rrr + ".E" + num2str(E) + ".OA0.sM9.sA" + ...
            num2str(DT, "%3.1f") + "." + datestr + "_maps/";
    getItems(dir + sub); 
        
    E = 1; DT = 1;
    sub = "ESM2M." + rrr + ".E" + num2str(E) + ".OA0.sM9.sA" + ...
            num2str(DT, "%3.1f") + "." + datestr + "_maps/";
    getItems(dir + sub); 
    fprintf("\n");
end

function getItems(dir) 
    % Find the required lines. This is not a very general function, and the first
    % line is marked bye "All Reefs" which appears more than once.  Expect to
    % modify the code if the number of output tables is changed.
    fid = fopen(dir + "console.txt"); % open the file
    AllFound = 0;
    data = {};
    while ~feof(fid) % loop over the following until the end of the file is reached.
        line = fgets(fid); % read in one line
        if strfind(line,'All Reefs') % if that line contains 'p', set the first index to 1
            AllFound = AllFound+1;
        end
        if AllFound == 6
            % We are near the end of the file and just need to pull values from
            % this and the next 3 lines.
            % In the first line we need the last floating point number, which is
            % followed by 1925 and some whitespace.
            allFloats = regexp(line, '\d+\.\d+', 'match'); 
            healthy2100 = round(100.0 - str2double(allFloats{end}));
            % Get coral cover
            line = fgets(fid); % read in one line
            globalCover = round(str2double(regexp(line, '\d+\.\d+', 'match')));
            % Ignore reefs < 10%
            line = fgets(fid); %#ok<NASGU> % read in one line
            % Get percent dominated by branching.
            line = fgets(fid); % read in one line
            pctBranching = round(100*str2double(regexp(line, '\d+\.\d+', 'match')));
            % Note that the order in the file is not the order in the table.
            fprintf("%3d %3d %3d ", globalCover, healthy2100, pctBranching);
            % Other lines follow.  We can ignore them.
            fclose(fid);
            return;
        end
    end
    fprintf("ERROR: reached end of console.txt without finding All Reefs 6 times.\n");
    fclose(fid);
end

% The 4 key lines being parsed above:
%{
All Reefs    2.65    7.06    4.26    3.69    4.42    3.22    2.49    3.74    3.69    5.14    5.66    4.68    3.27    3.12    2.75    4.42    4.10    2.23    9.56    8.62    4.00    3.22    3.27   10.96   12.36   10.86    9.40    8.68    8.47    3.43    3.69    5.19    6.29    5.66    3.48    3.53    2.29    1.66    3.17    2.75    2.96    8.26    7.22    4.21    3.64   11.95   11.32    9.92    9.14    9.19   10.18    9.82    6.81    4.78    9.77    8.16    5.61    4.05    8.88    7.12   12.62    9.71    7.32    8.83   10.44    8.94   13.09   12.05   12.36   10.44    9.77    7.69    6.70    6.08    5.61    6.86    5.61    4.10    4.68    8.73    4.47    3.01    2.60    2.81    6.55    4.26    3.90    3.74   11.38   12.42   11.74    6.08    8.83    8.31    8.21    5.51    6.75    8.00    8.05   10.81    7.01    4.21    4.83    5.14    4.99   13.92   11.43   10.81   11.32    8.42    4.00   13.82   12.05   11.74   11.27   11.84    7.84    6.96    6.86    7.27   14.18   10.44    6.03    8.52    6.18    5.04    3.69    6.34   12.00   15.43   13.04   12.68    9.51    8.73    6.34    8.83    6.44    6.96    5.71    4.00    8.78    7.43    4.42    4.21    7.27    6.08    4.57    9.40   10.44   10.18    9.04    9.87    7.38    6.44    7.43    6.70    7.53    8.47    8.47         1925             
Global average percent coral cover: 68.8 
Percent of reefs with less than 10 pct cover:  2.5 
Fraction of reefs dominated by branching coral:  0.604
%}