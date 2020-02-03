%% SET WORKING DIRECTORY AND PATH
clear all;  % persistent variables are used, so it's best to clear functions
close all;

addpath('d:\GitHub\Coral-Model-V12');
addpath('d:\GitHub\Coral-Model-V12\FigureGeneration');
addpath('D:/GitHub/m_map/');
sstPath = "D:/GitHub/Coral-Model-V12/ClimateData/";

% The calls below will generate all the maps no matter what you specify, but
% this list defines which will be combined in the final output figure.  Select
% integer to indicate the maps you want as listed in the comment block below.
selectedMaps = [9:24]; % all options
% selectedMaps = [9:16]; % an example using a subset.

% Shorthand for the map choices below: 1900 means all the years 1861 to 1900.
% 2050 means the years from 2050 to 2080.  All calculations are based on taking
% the hottest month of each year on each reef.
% Next 4 are RCP 4.5, looking at T and Delta T
% 9 = 1900 average
% 10 = 2050 average
% 11 = 2050-1900 delta
% 12 = 10% largest and smallest changes for this set.
%
% Next 4 are RCP 8.5, looking at T and Delta T
% 13 = 1900 average
% 14 = 2050 average
% 15 = 2050-1900 delta
% 16 = 10% largest and smallest changes for this set.
%
% Next 4 are RCP 4.5, looking at standard deviation
% 17 = 1900 average
% 18 = 2050 average
% 19 = 2050-1900 delta
% 20 = 10% largest and smallest changes for this set.
%
% Next 4 are RCP 8.5, looking at standard deviation
% 21 = 1900 average
% 22 = 2050 average
% 23 = 2050-1900 delta
% 24 = 10% largest and smallest changes for this set.


%% Generate all maps
if ~isempty(intersect(selectedMaps, [9:12])); HotMonthSSTChangeMaps_45; end;
if ~isempty(intersect(selectedMaps, [13:16])); HotMonthSSTChangeMaps_85; end;
if ~isempty(intersect(selectedMaps, [17:20])); HotMonthSST_SD_ChangeMaps_45; end;
if ~isempty(intersect(selectedMaps, [21:24])); HotMonthSST_SD_ChangeMaps_85; end;
% Fast maps 9 to 16 for testing only: DummyMaps;
%% Build a figure from the selected maps.
example = figure(selectedMaps(1));
ax = gca;
example.Units = 'pixels';
pos = example.Position;
% Screen grab gives 1440x386, about the same as pos, which is 1440x384.
% So why doesn't the title fit in a subplot?
% The actual map fills the subplots with no space for the title or other marks.
heightOne = pos(4);
heightAll = heightOne * size(selectedMaps, 2);
width = pos(3);

% Build figure letters to be used later.
letters = char(97:122);
for i = 1:26
    panel{i} = ['(' letters(i) ') '];
end

% But MATLAB won't draw a figure bigger than the screen!  Scale it to fit the
% screen, and later it can be "printed" to save it at the required resolution.
actualPixels = get(0, 'ScreenSize');
maxH = actualPixels(4);
if heightAll > maxH
    figRatio = maxH / heightAll;
else
    figRatio = 1.0;
end

posCombo = [5 0 width*figRatio heightAll*figRatio];

combo = figure('Units', 'pixels', 'Position', posCombo);
% Nh, Nw, gap, marg_h, marg_w
[ha, pos] = tight_subplot(size(selectedMaps, 2), 1, 0, [0.0 0.05]);

% tight_subplot(4, 1, [0.0, 0.0], [0.0, 0.0], [0.0 0.05]);


%panel = [{'(a) '}, {'(b) '}, {'(c) '}, {'(d) '},{'(e) '}, {'(f) '}, {'(g) '}, ...
%         {'(h) '}, {'(b) '}, {'(c) '}, {'(d) '},{'(e) '}, {'(f) '}, {'(g) '}];

num = 0;
for i = selectedMaps
    num = num + 1;
    % Old axes
    figure(i);
    figOld = gcf;
    axOld = gca;
    tText = get(axOld.Title);
    title(strcat(panel(num), tText.String));

    % Shrink all fonts before copying to old figure.  figRatio should scale
    % the font with the overall reduction, and the additional factor helps keep
    % long titles from being wider than the plot itself.
    supersizeme(figRatio * 0.9); 
    
    % Make a subplot current.
    axes(ha(num)); %#ok<LAXES>
    %copyobj(get(axOld,'children'), gca);
    %copyobj(axOld.Title, gca)
    
    cb = findall(figOld, 'type', 'colorbar');
    axcp = copyobj([cb, axOld], combo);
    moveTo = get(ha(num), 'Position');
    moveTo(3) = moveTo(3) * 0.95;
    moveTo(4) = moveTo(4) * 0.8;
    set(axcp(2), 'Position', moveTo);
    moveTo(1) = moveTo(1) + moveTo(3);
    moveTo(3) = cb.Position(3);
    set(axcp(1), 'Position', moveTo);
    
    ppp = axcp(2).Title.Position
    ppp(1) = -2.8;
    axcp(2).Title.HorizontalAlignment = 'left';
    axcp(2).Title.Position = ppp
    
    axis off;
    close(figOld);
    
 
end
combo.Color = [1 1 1];

typDPI = 96;
scaleDPI = typDPI/figRatio;
fprintf("To print as wide as the original figures, scale using\n print(gcf, '-r%d', '-dpng', 'test.png')\n", scaleDPI)
print(gcf, strcat('-r', num2str(scaleDPI)), '-dpng', 'combinedSSTMaps.png');
