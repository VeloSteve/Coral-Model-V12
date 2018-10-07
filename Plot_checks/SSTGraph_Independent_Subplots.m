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
Tquant(2880, 7, 4) = 0.0;
for RCP = {'rcp85', 'rcp60', 'rcp45', 'rcp26'}
    scenario = scenario + 1;
    [SST, ~, TIME, startYear] = GetSST_norm_GFDL_ESM2M(sstPath, matPath, Data, RCP);
    Tquant(:, 1:7, scenario) = quantile(SST, [0.0 0.1 0.45 0.5 0.55 0.9 1.0], 1)';
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
%axes1 = axes('Parent',figureSST);
%hold(axes1,'on');

transparency = 0.5;
qn1 = 3;
qn2 = 5;
qw1 = 2;
qw2 = 6;
qa1 = 1;
qa2 = 7;

scenario = 0;
rcpName = {'RCP 8.5', 'RCP 6.0', 'RCP 4.5', 'RCP 2.6'};
colA = [1 .85 .85; 1 0.95 0.88; .9 1 .9; .9 .9 1.0];
colW = [1 .7 .7;   1 0.9 0.8; .8 1 .8; .8 .8 1.0];
colN = [1 0 0;     1 0.8 0;     0 1 0; 0 0 1];
for scenario = 4:-1:1
    bot = Tquant(:, qa1, scenario);
    top = Tquant(:, qa2, scenario);
    bot = trailingAverageFilt(bot, 24, true);
    top = trailingAverageFilt(top, 24, true);

    sp = subplot(4, 1, scenario);
    patch('Parent',sp,'DisplayName','all reefs','YData',[top; flipud(bot)],...
        'XData',t,...
        'LineStyle','none',...
        'FaceColor',colA(scenario, :));
    
    bot = Tquant(:, qw1, scenario);
    top = Tquant(:, qw2, scenario);
    bot = trailingAverageFilt(bot, 24, true);
    top = trailingAverageFilt(top, 24, true);

    sp = subplot(4, 1, scenario);
    patch('Parent',sp,'DisplayName',' central 80% of reefs','YData',[top; flipud(bot)],...
        'XData',t,...
        'LineStyle','none',...
        'FaceColor',colW(scenario, :));
    
    bot = Tquant(:, qn1, scenario);
    top = Tquant(:, qn2, scenario);
    bot = trailingAverageFilt(bot, 24, true);
    top = trailingAverageFilt(top, 24, true);
    patch('Parent',sp,'DisplayName', ' central 10% of reefs','YData',[top; flipud(bot)],...
        'XData',t,...
        'LineStyle','none',...
        'FaceColor',colN(scenario, :));

    % Create multiple lines using matrix input to plot
    %{
    plot1 = plot(X1,YMatrix1);
    set(plot1(1),'DisplayName','Massive coral','Color',[1 0 0]);
    set(plot1(2),'DisplayName','Branching coral','Color',[0 0 1]);
    %}

    % Create xlabel
    xlabel({'Year'});

    % Create title
    title(strcat(rcpName{scenario}, ' Sea Surface Temperature'),'FontWeight','bold');

    % Create ylabel
    ylabel('Mean Annual SST, C');
    ylim(sp, [16 36]);
    
    % Uncomment the following line to preserve the X-limits of the axes
    xlim(sp,[679352 767011]);
    box(sp,'on');
    % Set the remaining axes properties
    set(sp,'FontSize',14,'XTick',[679352 693962 712224 730486 748749 767011],...
        'XTickLabel',{'1860','1900','1950','2000','2050','2100'});

    % Set the remaining axes properties
    set(sp,'FontSize',14);
    % Create legend
    legend1 = legend(sp,'show');
    %set(legend1,...
    %    'Position',[0.392272766767302 0.35970390099993 0.134089389747584 0.207646171013633],...
    %    'FontSize',13);
    set(legend1,'FontSize',13,'Location','best');

end
% Create textbox
annotation(figureSST,'textbox',...
    [0.545547872340426 0.0109689213893967 0.406579787234043 0.030164533820841],...
    'String',{'Plots show a 24-month trailing average of monthly predicted temperatures.'},...
    'FitBoxToText','off');
     