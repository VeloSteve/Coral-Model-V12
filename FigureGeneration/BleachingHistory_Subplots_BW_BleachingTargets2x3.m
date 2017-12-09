function BHSCO()
topNote = ''; % {'5% Bleaching Target for 1985-2010', 'Original OA Factor CUBED'};

figure('color', 'w');
set(gcf, 'Units', 'inches', 'Position', [1, 0.0, 11, 17]);

% Make subplots across, each for one rcp scenario.
% Working down, subplots will be for each bleaching target from small to
% large.
% Within each plot, have lines for E=0/1 and OA=0/1
rcpList = {'rcp45', 'rcp85'};
rcpName = {'RCP 4.5', 'RCP 8.5'};
colorIndex = [2 4]; % Use 1:4 when all RCP values are used.

targets = [3 5 10];
    
legText = {};
legCount = 1;
for t = 1:length(targets)
    relPath = strcat('D:\GoogleDrive\Coral_Model_Steve\_Paper Versions\Figures\Survival4Panel\bleaching_Target_', num2str(targets(t)), '_SquaredOAFactor\');

    for i = 1:length(rcpList)
        rrr = rcpList{i};
        sp = (t-1)*length(rcpList)+i;
        subplot(length(targets), length(rcpList), sp);
        cases = [];
        hFile = '';
        for eee = 0:1
            for ooo = 1:-1:0           
                if ~(eee == 0 && ooo == 1)  % Skip one curve
                    hFile = strcat(relPath, 'BleachingHistory', rrr, 'E=', num2str(eee), 'OA=', num2str(ooo), '.mat');
                    load(hFile, 'yForPlot');
                    cases = [cases; yForPlot];
                    legText{legCount} = strcat('E = ', num2str(eee), ' OA = ', num2str(ooo));
                    legCount = legCount + 1;
                end
            end
        end
        % x values are the same for all. Use the latest file;
        load(hFile, 'xForPlot');
        oneSubplot(xForPlot, cases, legText, rcpName{i}, i==1 && t==1);

        if i == 1 && t == ceil(length(targets)/2)
            yHandle = ylabel({'Percent of  ''damaged'' coral reefs globally', ' ', ['Target ', num2str((targets(t))), '%']},'FontSize',22);
            %set(yHandle, 'Position', [1925 -10 0])
        elseif i == 1
            ylabel(['Target ', num2str((targets(t))), '%'], 'FontSize', 22);
        end

    end
end

% Add a text box at top center if text is provided.
if ~isempty(topNote)
    ann = annotation(gcf,'textbox',...
        [0.5 0.5 0.2 0.08],...
        'String',topNote,...
        'FontSize',20,...
        'FitBoxToText','on');
    loc = ann.Position;
    % Shift to top center
    newLoc = loc;
    newLoc(1) = 0.47 - loc(3)/2;  % 0.47 roughly centers - could calculate from subplot locations.
    newLoc(2) = 0.98 - loc(4);
    ann.Position = newLoc;
end
end

function oneSubplot(X, Yset, legText, tText, useLeg) 


    base = [0 0 0];
    light = [0.5 0.5 0.5];

    col{1} = base;    % XXX - NOTE that this line is hidden for now.
    col{2} = base;

    col{3} = light;
    col{4} = light;
    
    % Create multiple lines using matrix input to plot
    plot1 = plot(X,Yset(:, :));
    for i = size(Yset, 1):-1:1
        set(plot1(i),...
            'DisplayName',legText{i}, ...
            'Color', col{i}, ...
            'LineWidth', 2);
        if i == 2 || i == 4
            set(plot1(i), 'LineStyle', '--');
        end     
    end
    if nargin == 7
        % Add the Logan GCB line
        hold on;
        plot2 = plot(extraX, extraY);
        set(plot2,...
            'DisplayName','Logan et al. 2014', ...
            'Color', [0 0 0], ...
            'LineWidth', 2);
        hold off;
    end

    % Create xlabel
    xlabel('Year','FontSize',13.2);

    % Create title
    title(tText, 'FontSize', 22);


    xlim([1950 2100]);
    ylim([0 105]);
    box('on');
    grid('on');
    % Set the remaining axes properties
    set(gca, 'FontSize',22,'XTick',[ 1950 2000 2050 2100 ],...
        'YTick',[0  50  100]);
    % Create legend
    if useLeg
        legend1 = legend('show');
        set(legend1,'Location','northwest','FontSize',20);
    end


    
end