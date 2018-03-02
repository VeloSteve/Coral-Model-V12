% Read Hughes et al. 2018 reefs and correlate with our reef cells.

% Get the 100 reefs
%[reefTable, txt, raw] =
[hughesNum, hughesTxt, hughesTable] = xlsread('Hughes100Reefs.xlsx',  'Clean for Export');
hughesLat = hughesNum(2:101, 4);
hughesLon = hughesNum(2:101, 5);
hughesArea = hughesNum(2:101, 6);

% Now get our cell centroids
addpath('d:\GitHub\Coral-Model-V12');
Computer = 0;
[basePath, outputPath, sstPath, SGPath, matPath, Computer, defaultThreads] ...
    = useComputer(Computer);
load(strcat(sstPath, 'ESM2M_SSTR_JD.mat'), 'ESM2M_reefs_JD');
Reefs_latlon = ESM2M_reefs_JD; clear ESM2M_reefs_JD;

% Pre-sorting might make this a lot faster, but this only has to run once.

% For each of our cells find the closest cell in hughesTable
rc = 1925;
far = 19;
closestHughesReef(rc) = 0;
hughesRegion{rc} = '';
hughesLocation{rc} = '';
hughesDist(rc) = 0;
d = zeros(1, rc);
for k = 1:rc
    % Watch out - "latlon" has lon before lat!
    lat = Reefs_latlon(k, 2);   
    lon = Reefs_latlon(k, 1);
    d = sqrt((hughesLat-lat).^2 + (hughesLon-lon).^2);
    [dist, minAt] = min(d);
    hughesDist(k) = dist;
    %{
    if dist > far
        fprintf('Our reef %d is %d degrees from the nearest (%d) in Hughes.\n',k, dist, minAt);
    end
    %}
    closestHughesReef(k) = minAt;
    hughesRegion(k) = hughesTxt(minAt+1, 2);
    hughesLocation(k) = hughesTxt(minAt+1, 3);
end
auCells = find(strcmp(hughesRegion,'AuA'));
ioCells = find(strcmp(hughesRegion,'IO-ME'));
pCells = find(strcmp(hughesRegion,'Pac'));
aCells = find(strcmp(hughesRegion,'WAtl'));
farCells = find(hughesDist > far);

% Above, the regional cell lists include the "far" cells, but now remove them.
auCells = setdiff(auCells, farCells);
ioCells = setdiff(ioCells, farCells);
pCells = setdiff(pCells, farCells);
aCells = setdiff(aCells, farCells);

% And correct manually for a few cells near Panama.
% These are labeled Pacific but actually are on the Caribbean side
panamaErrors = [314 324 336];

pCells = setdiff(pCells, panamaErrors);
aCells = unique([aCells panamaErrors]);

% For reference, how many reefs does Hughes have in each region?  And ours?
hAu = length(find(strcmp(hughesTxt(:, 2), 'AuA')));
hIo = length(find(strcmp(hughesTxt(:, 2), 'IO-ME')));
hPa = length(find(strcmp(hughesTxt(:, 2), 'Pac')));
hAt = length(find(strcmp(hughesTxt(:, 2), 'WAtl')));
fprintf('Number of reefs in each region:\n       Hughes  Logan\n AuA   %d %8d\n IO-ME %d %8d\n Pac   %d %8d\n WAtl  %d %8d\n Far     %8d\n', ...
    hAu, length(auCells), hIo, length(ioCells), hPa, length(pCells), hAt, length(aCells), length(farCells));

assert(length(auCells)+length(ioCells)+length(pCells)+length(aCells)+length(farCells) == rc, ...
    'Length of the four region lists plus the excluded farCells should equal the total number of reef cells.');
assert(length(unique([auCells ioCells pCells aCells farCells])) == rc, ...
    'Every reef should be in exactly one region, or intentionally excluded.');
  
% Now do the inverse - for each hughes reef, what is our closest cell?
closestCellToHughes(100) = 0;
for h = 1:100
    % Watch out - "latlon" has lon before lat!
    lat = hughesLat(h);   
    lon = hughesLon(h);
    dsq = (Reefs_latlon(:,2)-lat).^2 + (Reefs_latlon(:,1)-lon).^2;
    [mDist, minAt] = min(dsq);
    closestCellToHughes(h) = minAt;
end
% NOTE - this results in one duplicate.  Our reef 1679 is closest to Hughes'
% 11 and 12.
% These are
% Our #, our lat, lon,      Hughes #, Hughes lat, lon
% 1679   -30.5,    153.5    11        -30,    153.3
% 1679   -30.5,    15.5     12        -30.5,  153.1
% Pretty close...

% Now we can also get the subsets which are the best match to the actual
% locations used in Hughes.
 auMatch = intersect(auCells, closestCellToHughes);
 ioMatch = intersect(ioCells, closestCellToHughes);
 pMatch = intersect(pCells, closestCellToHughes);
 aMatch = intersect(aCells, closestCellToHughes);

 save(strcat(outputPath, 'HughesRegionLists.mat'), ...
      'auCells', 'ioCells', 'pCells', 'aCells', 'closestHughesReef', ...
      'hughesRegion', 'hughesLocation', 'closestCellToHughes');
  
  % Arbitrary values for plotting regions in color.
  pVals = zeros(1, rc);
  pVals(auCells) = 1;
  pVals(ioCells) = 2;
  pVals(pCells) = 3;
  pVals(aCells) = 4;
  pVals(farCells) = hughesDist(farCells);
  oneMap(2000, Reefs_latlon(:, 1), Reefs_latlon(:, 2), pVals, parula, ...
      sprintf('Black cells are not within %d degrees of a Hughes reef', far), ...
      hughesLat, hughesLon, hughesArea);
  
  %% Now, try to duplicate Hughes graph S2B from their data, just to be sure I
  %  understand how they did it.  Column 7 in the xlsx file is 1980.  Column 43
  %  is 2016.
  % Yes, it's ugly!
  %bleachFlags = strcmp('M', hughesTxt) | strcmp('S', hughesTxt);
  bleachFlags = strcmp('S', hughesTxt);
  iAU = find(strcmp(hughesTxt(:, 2), 'AuA'));
  iIo = find(strcmp(hughesTxt(:, 2), 'IO-ME'));
  iP = find(strcmp(hughesTxt(:, 2), 'Pac'));
  iA = find(strcmp(hughesTxt(:, 2), 'WAtl'));
  justAu = bleachFlags(iAU, 7:43);
  justIo = bleachFlags(iIo, 7:43);
  justP = bleachFlags(iP, 7:43);
  justA = bleachFlags(iA, 7:43);
  bleachAu = zeros(43-7+1);
  bleachIo = zeros(43-7+1);
  bleachP = zeros(43-7+1);
  bleachA = zeros(43-7+1);
  bleachAu(1) = sum(justAu(:, 1));
  bleachIo(1) = sum(justIo(:, 1));
  bleachP(1) = sum(justP(:, 1));
  bleachA(1) = sum(justA(:, 1));
  for y = 2:43-7+1
      bleachAu(y) = bleachAu(y-1) + sum(justAu(:, y));
      bleachIo(y) = bleachIo(y-1) + sum(justIo(:, y));
      bleachP(y) = bleachP(y-1) + sum(justP(:, y));
      bleachA(y) = bleachA(y-1) + sum(justA(:, y));
  end
  hughesPlot(bleachAu, 1980, 'Australasia', 0);
  hughesPlot(bleachIo, 1980, 'Indian Ocean/Middle East', 0);
  hughesPlot(bleachP, 1980, 'Pacific', 0);
  hughesPlot(bleachA, 1980, 'West Atlantic', 0);
% Conclusion: yes, these match the graphis in the paper supplement.

%% Now, try combining Hughes cells which match one of ours
% This will have a lot in common with some of the code above, but keep in
% separate for clarity.
% Goal: when several Hughes reefs match one of our cells, that could give a
% higher bleaching count for the Hughes approach.  Identify and combine the counts from those
% reefs.
% For each of our cells, fold in any matching Hughes cells.
% As above column 7 in bleachFlags is 2016.
aggSum(rc, 2016-1980+1) = 0;
hasMatch(rc) = false;
iCounted = [];
for k = 1:rc
   % Watch out - "latlon" has lon before lat!
    lat = Reefs_latlon(k, 2);   
    lon = Reefs_latlon(k, 1);
    iLat = find(abs(hughesLat-lat) <= 0.5);
    iLon = find(abs(hughesLon-lon) <= 0.5);
    iMatch = intersect(iLat, iLon);
    % Don't recount!
    iMatch = setdiff(iMatch, iCounted);
    % An update what has been counted.
    iCounted = union(iCounted, iMatch);
    hasMatch(k) = ~isempty(iMatch);
    for c = 7:7+2016-1980
        aggSum(k, c-6) = sum(bleachFlags(1+iMatch, c));
    end
end
fprintf('In 1925 reef cells, %d have matches with Hughes et al. reefs.\n', sum(hasMatch));
fprintf('In 100 reefs, %d have matches with Logan cells.\n', length(iCounted));
% Only 71 of the Hughes reefs have matches in Logan cells!
% # 2 at -20,153 is 231 km^2 in the coral sea, and in Google Earth it's over 100 km to
% the nearest feature that looks likely to contain a reef.
% # 4 at -11.5, 145.3 is 9319 km^2, northern GBR, and has many reefs close enough
%   to be included. A number of our cells overlap the specified area, but none
%   have a centroid within 1/2 degree.
% # 5 is 75 km from the coast of Australia, with an area of 6872 km^2.  If that
% area were circular, it would have a radius of 47 km.

% Working with Logan cells, use auCells, etc. for indexing.
justAu = aggSum(auCells, :);
justIo = aggSum(ioCells, :);
justP = aggSum(pCells, :);
justA = aggSum(aCells, :);
  bleachAu = zeros(43-7+1);
  bleachIo = zeros(43-7+1);
  bleachP = zeros(43-7+1);
  bleachA = zeros(43-7+1);
  bleachAu(1) = nnz(justAu(:, 1));
  bleachIo(1) = nnz(justIo(:, 1));
  bleachP(1) = nnz(justP(:, 1));
  bleachA(1) = nnz(justA(:, 1));
  for y = 2:43-7+1
      bleachAu(y) = bleachAu(y-1) + nnz(justAu(:, y));
      bleachIo(y) = bleachIo(y-1) + nnz(justIo(:, y));
      bleachP(y) = bleachP(y-1) + nnz(justP(:, y));
      bleachA(y) = bleachA(y-1) + nnz(justA(:, y));
  end
hughesPlot(bleachAu, 1980, 'Clumped Australasia', 0);
hughesPlot(bleachIo, 1980, 'Clumped Indian Ocean/Middle East', 0);
hughesPlot(bleachP, 1980, 'Clumped Pacific', 0);

hughesPlot(bleachA, 1980, 'Clumped West Atlantic', 0);

  
  %%
  %{
  Some results in text form, for easy cut and paste before a more automated way
  is built:
  closestCellToHughes: [1601,1664,1579,1512,1640,991,1738,1680,961,1053,1679,1679,956,1496,804,994,1197,915,935,1267,1093,1232,813,1402,1342,831,1630,1108,1758,1176,807,928,1181,851,762,1086,1148,657,553,473,706,516,622,583,695,636,566,477,502,488,624,572,471,720,493,615,71,335,1540,103,275,321,1913,144,240,1525,126,70,1845,1903,1702,1785,1458,282,313,1811,57,1818,343,445,258,422,402,420,301,348,284,329,398,399,311,224,265,339,261,283,411,419,440,409]
  hughesRegion: {'Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','WAtl','WAtl','WAtl','WAtl','Pac','Pac','Pac','Pac','Pac','WAtl','WAtl','WAtl','Pac','Pac','Pac','Pac','WAtl','WAtl','Pac','Pac','Pac','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','WAtl','Pac','WAtl','WAtl','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','Pac','Pac','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','WAtl','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','IO-ME','IO-ME','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','AuA','AuA','AuA','AuA','AuA','Pac','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','AuA','AuA','AuA','AuA','Pac','AuA','AuA','Pac','AuA','AuA','Pac','Pac','AuA','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','AuA','AuA','Pac','Pac','Pac','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','AuA','AuA','AuA','AuA','AuA','AuA','AuA','Pac','Pac','AuA','AuA','AuA','AuA','Pac','Pac','AuA','AuA','AuA','AuA','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','AuA','AuA','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac','Pac'}
  auCells: [730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,764,765,766,767,768,769,770,771,772,773,774,775,776,777,778,779,780,781,782,783,784,785,786,787,788,789,790,791,792,793,794,795,796,797,798,799,800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,830,831,832,833,834,835,836,837,838,839,840,841,842,843,844,845,846,847,848,849,850,853,854,855,856,857,858,859,860,861,862,863,864,865,866,867,868,869,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891,892,893,894,895,896,897,898,899,900,901,902,903,904,905,906,907,908,909,910,911,912,913,914,915,916,917,918,919,920,921,922,923,924,925,926,927,928,929,930,931,932,933,934,935,936,937,938,939,940,941,942,943,944,945,946,947,948,949,950,951,952,953,954,955,956,957,958,959,960,961,962,963,964,965,966,967,968,969,970,971,972,973,974,975,976,977,978,979,980,981,982,983,984,985,986,987,988,989,990,991,992,993,994,995,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071,1072,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131,1132,1133,1134,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164,1165,1166,1167,1168,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1185,1186,1187,1188,1189,1190,1191,1192,1193,1194,1195,1196,1197,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1215,1216,1217,1218,1219,1229,1230,1231,1232,1233,1234,1235,1236,1237,1238,1239,1240,1241,1242,1243,1244,1245,1246,1247,1248,1249,1250,1251,1252,1253,1254,1261,1262,1263,1264,1265,1266,1267,1268,1269,1270,1271,1272,1273,1274,1277,1278,1279,1280,1281,1282,1283,1284,1285,1286,1287,1288,1289,1290,1291,1292,1293,1294,1295,1296,1297,1298,1299,1300,1301,1303,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,1316,1317,1318,1319,1320,1321,1322,1323,1324,1325,1326,1327,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343,1344,1345,1346,1347,1348,1349,1350,1351,1352,1353,1354,1355,1356,1357,1358,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1372,1373,1374,1375,1376,1377,1378,1379,1380,1381,1382,1383,1385,1386,1387,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398,1399,1400,1401,1402,1405,1406,1407,1408,1409,1410,1411,1412,1413,1414,1415,1416,1417,1418,1419,1420,1421,1422,1426,1427,1428,1431,1432,1433,1434,1435,1436,1437,1438,1441,1442,1443,1444,1445,1447,1448,1449,1450,1451,1460,1461,1462,1468,1469,1470,1471,1472,1473,1474,1477,1478,1479,1480,1482,1483,1485,1486,1489,1492,1493,1494,1495,1496,1497,1499,1500,1501,1502,1503,1504,1505,1506,1510,1511,1512,1513,1514,1515,1516,1517,1518,1519,1520,1526,1527,1528,1529,1530,1531,1532,1533,1534,1535,1543,1544,1545,1546,1547,1548,1549,1550,1551,1552,1553,1554,1555,1560,1561,1562,1563,1564,1565,1566,1567,1568,1569,1570,1571,1572,1573,1574,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587,1588,1589,1590,1596,1597,1598,1599,1600,1601,1602,1603,1604,1605,1606,1607,1608,1609,1610,1611,1612,1620,1621,1622,1623,1624,1625,1626,1627,1628,1629,1630,1631,1632,1633,1634,1635,1638,1639,1640,1641,1642,1643,1644,1645,1646,1647,1648,1649,1650,1651,1652,1653,1654,1655,1659,1660,1661,1662,1663,1664,1665,1666,1667,1668,1669,1670,1671,1672,1673,1674,1675,1679,1680,1681,1682,1683,1684,1685,1686,1687,1688,1689,1690,1694,1695,1696,1697,1698,1699,1700,1701,1705,1706,1707,1708,1709,1710,1711,1712,1713,1714,1716,1717,1718,1719,1720,1721,1722,1723,1724,1725,1729,1730,1731,1732,1733,1734,1735,1736,1738,1739,1744,1745,1746,1747,1748,1749,1750,1751,1752,1753,1755,1756,1757,1758,1759,1760,1761,1764,1765,1766,1767,1770,1771,1772,1773,1789,1790]
  ioCells:[470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,762,763,851,852,1054,1086,1087,1088,1119,1120,1121,1146,1147,1148,1149,1150,1151,1179,1180,1181,1182,1183,1184,1220,1221,1222,1223,1224,1225,1226,1227,1228,1255,1256,1257,1258,1259,1260,1275,1276,1302,1328,1359,1360,1361,1384,1403,1404,1429,1430]
  pCells: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,225,230,231,232,233,234,238,239,240,241,244,245,246,247,248,254,255,263,264,270,272,275,282,294,295,313,321,322,323,335,1423,1424,1425,1439,1440,1446,1452,1453,1454,1455,1456,1457,1458,1459,1463,1464,1465,1466,1467,1475,1476,1481,1484,1487,1488,1490,1491,1498,1507,1508,1509,1521,1522,1523,1524,1525,1536,1537,1538,1539,1540,1541,1542,1556,1557,1558,1559,1575,1576,1577,1591,1592,1593,1594,1595,1613,1614,1615,1616,1617,1618,1619,1636,1637,1656,1657,1658,1676,1677,1678,1691,1692,1693,1702,1703,1704,1715,1726,1727,1728,1737,1740,1741,1742,1743,1754,1762,1763,1768,1769,1774,1775,1776,1777,1778,1779,1780,1781,1782,1783,1784,1785,1786,1787,1788,1791,1792,1793,1794,1795,1796,1797,1798,1799,1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,1810,1811,1812,1813,1814,1815,1816,1817,1818,1819,1820,1821,1822,1823,1824,1825,1826,1827,1828,1829,1830,1831,1832,1833,1834,1835,1836,1837,1838,1839,1840,1841,1842,1843,1844,1845,1846,1847,1848,1849,1850,1851,1852,1853,1854,1855,1856,1857,1858,1859,1860,1861,1862,1863,1864,1865,1866,1867,1868,1869,1870,1871,1872,1873,1874,1875,1876,1877,1878,1879,1880,1881,1882,1883,1884,1885,1886,1887,1888,1889,1890,1891,1892,1893,1894,1895,1896,1897,1898,1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925]
  aCells: [217,218,219,220,221,222,223,224,226,227,228,229,235,236,237,242,243,249,250,251,252,253,256,257,258,259,260,261,262,265,266,267,268,269,271,273,274,276,277,278,279,280,281,283,284,285,286,287,288,289,290,291,292,293,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,314,315,316,317,318,319,320,324,325,326,327,328,329,330,331,332,333,334,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445]
  
  Cells which best match the Hughes cells in each region:
auMatch [804,807,813,831,915,928,935,956,961,991,994,1053,1093,1108,1176,1197,1232,1267,1342,1402,1496,1512,1579,1601,1630,1640,1664,1679,1680,1738,1758]
ioMatch [471,473,477,488,493,502,516,553,566,572,583,615,622,624,636,657,695,706,720,762,851,1086,1148,1181]
pMatch  [57,70,71,103,126,144,240,275,282,313,321,335,1458,1525,1540,1702,1785,1811,1818,1845,1903,1913]
aMatch  [224,258,261,265,283,284,301,311,329,339,343,348,398,399,402,409,411,419,420,422,440,445]
  
      Number of reefs in each region:
           Hughes  Logan
     AuA   32      906
     IO-ME 24      310
     Pac   22      480
     WAtl  22      199
     Far           30
  %}
  
  %% Plot a map
  function [] = oneMap(n, lons, lats, values, cMap, t, hLat, hLon, hArea)
    f = figure(n);

        clf;
        % first pass only:
        %m_proj('miller'); % , 'longitude', 155); % - offsets map, but drops some data!
        m_proj('miller', 'lat',[-40 40],'long',[20 340]); % [0 360] for world, but no reefs from -28.5 to +32 longitude
        m_coast('patch',[0.7 0.7 0.7],'edgecolor','none');
        m_grid('box','off','linestyle','none','backcolor',[.9 .99 1], ...
            'xticklabels', [], 'yticklabels', [], 'ytick', 0, 'xtick', 0);

    hold on;
    idx = find(lons < 0);
    lons(idx) = lons(idx) + 360; % for shifted map (0 to 360 rather than -180 to 180)
    % Terrible kludge: add an extra lat/lon set to get scale and the delete them
    % afterwards!
    lons(end+1) = lons(end) + 1;
    lats(end+1) = lats(end) + 1;
    [LONG,LAT] = m_ll2xy(lons,lats); % convert reef points to M-Map lat long
    oneDegLat = LAT(end) - LAT(end-1);
    oneDegLon = LONG(end) - LONG(end-1);
    oneDeg = (oneDegLat + oneDegLon) / 2.0;
    fprintf('Lat/Lon degrees scale to %d and %d\n', oneDegLat, oneDegLon);
    LONG = LONG(1:end-1);
    LAT = LAT(1:end-1);
    
   
    % Draw reefs with homes in solid colors, far reefs on a color scale.

    % With identified regions:
    ind = find(values == 1);
    scatter(LONG(ind),LAT(ind),5, [1 0 0]) ;
    hold on;
    ind = find(values == 2);
    scatter(LONG(ind),LAT(ind),5, [0 1 0]) ;
    ind = find(values == 3);
    scatter(LONG(ind),LAT(ind),5, [0 .5 1]) ;
    ind = find(values == 4);
    scatter(LONG(ind),LAT(ind),5, [1 1 0]) ;
    % Far from Hughes:
    ind = find(values > 5);
    %scatter(LONG(ind),LAT(ind),5, values(ind), 'filled') ;
    % Easier to see with all fixed colors
    scatter(LONG(ind),LAT(ind), 7, [0 0 0], 'filled') ;

    
    % Temporarily, add rectangles for the Hughes, et al. regions
    %            Au/Asia,     Indian,    Pacific,   Atlantic
    cornerLon = [ 98.6 160.6  32.5 123.0 134.5 -77.4 -93.8 -59.5];
    cornerLat = [-31.5  32.5 -28.4  27.3 -21.5 25.5   9.3  32.2];
    idx = find(cornerLon < 0);
    cornerLon(idx) = cornerLon(idx) + 360; % for shifted map (0 to 360 rather than -180 to 180)
    [cLon, cLat] = m_ll2xy(cornerLon, cornerLat);
    for i = 1:4
        % Position is x, y, width, height.
        rectangle('Position', [cLon(i*2-1),  cLat(i*2-1), cLon(i*2)-cLon(i*2-1), cLat(i*2)-cLat(i*2-1)], ...
            'EdgeColor', [0 0 0]    );
    end
    
    % Also add circles of the size of each Hughes reef, but not that their reefs
    % are probably neither circular nor rectangular.
    % Near the equator, assume that 1 degree squared is 100 km.
    % Some areas are not given, and come through as NaN.  Set to 1 arbitrarily.
    hArea(isnan(hArea)) = 1.0;
    radius = sqrt(hArea/3.14159)/100; % in degrees
    radius = radius * oneDeg; % in map units
    % Note +360 to match shifted map.
    idx = find(hLon < 0);
    hLon(idx) = hLon(idx) + 360;
    [hLONG,hLAT] = m_ll2xy(hLon, hLat); % convert reef points to M-Map lat long

    
    for i = 1:length(hArea)
        rectangle('Position', [hLONG(i)-radius(i), hLAT(i)-radius(i), 2*radius(i), 2*radius(i)], ...
            'EdgeColor', [0 0 1], 'Curvature', [0.8 0.8]);
    end

    
    aaa = gca;
    aaa.FontSize = 24;
    title(t)
    

    hold off;
end
