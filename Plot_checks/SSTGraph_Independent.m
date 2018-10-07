%% SST Graph

%% SET WORKING DIRECTORY AND PATH 
timerStart = tic;
Computer = 0; % 1=office; 2=laptop; 3=Steve; 4=Steve laptop; 0 = autodetect
[basePath, outputPath, sstPath, matPath, Computer] = useComputer(Computer);
Data = 1;

% DEFINE CLIMATE CHANGE SCENARIO (from normalized GFDL-ESM2M; J Dunne)
%RCP = 'rcp85'; % options; 'rcp26', 'rcp45', 'rcp60', 'rcp85', 'control', 'control400'



%% LOAD JOHN'S NORMALIZED SSTS FROM EARTH SYSTEM CLIMATE MODEL OR HADISST
% Extract SSTs for a ALL reef grid cells
scenario = 0;
Tquant(2880, 5, 4) = 0.0;
for RCP = {'rcp85', 'rcp60', 'rcp45', 'rcp26'}
    scenario = scenario + 1;
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, matPath, Data, RCP);
    Tquant(:, :, scenario) = quantile(SST, [0.1 0.45 0.5 0.55 0.9], 1)';
end
% We don't want the internal time representation, but also don't need fully
% formatted dates.  Make a range of year values.
% Incoming values are days from an arbitrary past date.
    %lastYear = str2double(datestr(TIME(end), 'yyyy'));
%t = datetime(TIME, 'ConvertFrom', 'datenum');


%t = [t'; flipud(t')];

t = [TIME'; flipud(TIME')];
       
figureSST = figure('Name','SST Cases');

% Create axes
axes1 = axes('Parent',figureSST);
hold(axes1,'on');

transparency = 0.5;
q1 = 2;
q2 = 4;

scenario = 0;
rcpName = {'RCP 8.5', 'RCP 6.0', 'RCP 4.5', 'RCP 2.6'};
col = [1 .2 .2; 0.95 0.95 0; .5 1 .5; .5 .5 1.0];
for scenario = 4:-1:1
    bot = Tquant(:, q1, scenario);
    top = Tquant(:, q2, scenario);
    bot = trailingAverageFilt(bot, 24, true);
    top = trailingAverageFilt(top, 24, true);

    patch('Parent',axes1,'DisplayName',rcpName{scenario},'YData',[top; flipud(bot)],...
        'XData',t,...
        'FaceAlpha',transparency,...
        'LineStyle','none',...
        'FaceColor',col(scenario, :));
end

% Create multiple lines using matrix input to plot
%{
plot1 = plot(X1,YMatrix1);
set(plot1(1),'DisplayName','Massive coral','Color',[1 0 0]);
set(plot1(2),'DisplayName','Branching coral','Color',[0 0 1]);
%}

% Create xlabel
xlabel({'Year'});

% Create title
title('Sea Surface Temperature by RCP Scenario for central 10% of reefs','FontWeight','bold');

% Create ylabel
ylabel('Mean Annual SST, C');

% Uncomment the following line to preserve the X-limits of the axes
xlim(axes1,[675700 767011]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',14,'XTick',[675700 693962 712224 730486 748749 767011],...
    'XTickLabel',{'1850','1900','1950','2000','2050','2100'});

% Set the remaining axes properties
set(axes1,'FontSize',14);
% Create legend
legend1 = legend(axes1,'show');
%set(legend1,...
%    'Position',[0.392272766767302 0.35970390099993 0.134089389747584 0.207646171013633],...
%    'FontSize',13);
set(legend1,'FontSize',13,'Location','best');



     