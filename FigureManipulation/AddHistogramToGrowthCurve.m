% The output directory for all RCP and adaptation combinations.
%dataPath = 'D://CoralTest/Feb2021_CurveE221_Target3_NewColdDef_E221_floor0/';
dataPath = 'D://CoralTest/Feb2021_CurveE221_Target5_NewColdDef_riFloor0.0/';
% Reef
reef = 46;
% Case
E = 0;
Adv = '1.0';
RCP = 'rcp26';          % rcp26, for example.
rundate = '20210208';   % yyyymmdd as text

% Build the directory name
% e.g. ESM2M.rcp85.E1.OA0.sM9.sA1.0.20210209_maps/
dn = strcat(dataPath, 'ESM2M.', RCP, '.E', num2str(E), '.OA0.sM9.sA', ...
    Adv, '.', rundate, '_maps/');

% And finally the file name, which unfortunately is a bit redundant.
% e.g. GrowthCurve_rcp85_E1_SymStrategy9_Reef106.fig
fn = strcat('GrowthCurve_', RCP, '_E', num2str(E), '_SymStrategy9_Reef', ...
    num2str(reef), '.fig');

% Get temperatures
addpath('../ClimateData');
addpath('../FigureGeneration'); % for getTemps
[~, ~, T] = getTemps(RCP, 'month', 0, 0, reef);


h = open(strcat(dn, fn));
% Thicken lines
lines = findall(h, 'type', 'line');
for lll = lines
    set(lll, 'linewidth', 2);
end
hold on;
yyaxis right;
histogram(T, 15:0.5:35, 'DisplayName', 'SST Distribution', ...
    'FaceAlpha', 0.2, 'EdgeAlpha', 0.5);
ylabel('Months (1861 to 2100)');
legend('Location', 'NorthWest')


