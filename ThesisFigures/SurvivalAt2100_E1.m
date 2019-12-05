% Goal:
% Get the coral cover value in the year 2100 for each advantage value and
% plot it versus advantage.  Repeat for all 4 climate scenarios.


close all;

titles = { ...
    'RCP 2.6', ...
    'RCP 4.5', ...
    'RCP 6.0', ...
    'RCP 8.5'
    };

lineColor = {[1 0.5 0], 'r', 'b', 'm'};

scenario = {'26', '45', '60', '85'};

fig = figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 0.1, 13, 18]);


% Start by getting the final cover value for each case in a given scenario.
% Typical directory name:
% ESM2M.rcp26.E1.OA0.sM0.sA0.625.20190521_maps

% Get all suitable directories
nS = length(scenario);
for i = 1:nS
    % The next 8 or so lines are based on a response by Image Analyst at
    % https://www.mathworks.com/matlabcentral/answers/166629-is-there-any-way-to-list-all-folders-only-in-the-level-directly-below-a-selected-directory
    % Get a list of all files and folders in this folder.
    files = dir(strcat('D:/CoralTest/V12-thesis/ESM2M.rcp', scenario{i}, '*22_maps'));
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subFolders = files(dirFlags);
    % 
    % Print folder names to command window.
    
    for k = 1 : length(subFolders)
        fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
        fName{k} = subFolders(k).name;
        tString = subFolders(k).name;
        idx = 3 + strfind(tString, '.sA');  % location of number after .sA
        idate = strfind(tString, '.20190522') - 1;
        tString = extractBetween(tString, idx, idate);
        fprintf('  t advantage is %s\n', tString{1});
        tAdvantage(k) = str2double(tString{1});
        
        % Finally, get the cover value from console.txt in each directory.
        console = fileread(strcat('D:/CoralTest/V12-thesis/', subFolders(k).name, '/console.txt'));
        lines = regexp(console, '[^\n]*Global average percent coral*[^\n]*', 'match');
        if length(lines) ~= 1
            fprintf('Error: console.txt should have exactly one cover line. Got %d\n', length(lines));
            return;
        end
        parts = split(lines{1}, ':');
        finalCover(k) = str2double(parts{2});
    end
    
    % The temperature advantages came out in order on the first test, but
    % make sure.
    [tAdvantage, tOrder] = sort(tAdvantage);
    fName = fName(tOrder);
    finalCover = finalCover(tOrder);
    
    plot(tAdvantage, finalCover, 'Color', lineColor{i}, 'LineWidth', 2);
    hold on;
end





    
    %n = strrep(names{i}, '_', ' ');
    %title(titles{i});
    ylabel('%K');

    %xlim([1850 2100]);
    %set(gca, 'XTick', [1850 1900 1950 2000 2050 2100]);
    set(gca, 'FontSize',22);
    




%leg = legend('show');
leg = legend(titles);
set(leg,...
    'Location','southeast',...
    'FontSize',18);
    % 'Position',[0.858 0.489 0.140 0.162],...

