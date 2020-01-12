%% Overlay two 4-panel figures to show both E=0 and E=1 on one figure.
close all;
clear;
e1_144 = 'SDC_144_ESM2Mrcp85_-18_-150_prop0.94_E1.fig';
e0_144 = 'SDC_144_ESM2Mrcp85_-18_-150_prop1.01_E0.fig';
e1_610 = 'SDC_610_ESM2Mrcp85_27_53_prop0.29_E1.fig';
e0_610 = 'SDC_610_ESM2Mrcp85_27_53_prop0.31_E0.fig';
e1_1463 = 'SDC_1463_ESM2Mrcp85_-2_136_prop1.50_E1.fig';
e0_1463 = 'SDC_1463_ESM2Mrcp85_-2_136_prop1.50_E0.fig';
baseDir = 'D:\Library\MyDocs\Biology Study\_LoganLab\Paper2017\December2019Versions\PlotsForFigS4\';

overlayPlots(e0_144, e1_144, baseDir);
overlayPlots(e0_610, e1_610, baseDir);
overlayPlots(e0_1463, e1_1463, baseDir);

function overlayPlots(fn1, fn2, baseDir) 
    % Open files and copy the upper right lines.
    p1 = open(strcat(baseDir, fn1));
    axList1 = findall(gcf, 'type', 'axes');
    ax1TR = axList1(2); % top right axes
    lines1 = findall(ax1TR, 'type', 'line');
    bran1 = lines1(1);
    mass1 = lines1(2);
    mass1.Color = [1, 0.6, 1];
    bran1.Color = [0.6, 0.6, 0.8];
    mass1.DisplayName = 'Massive, E=0';
    bran1.DisplayName = 'Branching, E=0';
    lines1(1).LineWidth = 1.5;
    lines1(2).LineWidth = 1.5;

    p2 = open(strcat(baseDir, fn2));
    axList2 = findall(gcf, 'type', 'axes');
    ax2TR = axList2(2); % top right axes
    lines2 = findall(ax2TR, 'type', 'line');
    lines2(1).DisplayName = 'Branching, E=1';
    lines2(2).DisplayName = 'Massive, E=1';
    lines2(1).LineWidth = 1.5;
    lines2(2).LineWidth = 1.5;
    copyobj(lines2(1), ax1TR);
    copyobj(lines2(2), ax1TR);

    clear lines1 bran1 mass1 lines2 ax2TR ax1TR;
    % With the same files, copy the lower left lines.
    % Oddly, the indexes of 1 and 2 above must 
    % become 3 and 4 here.  Two lines of zeros?
    figure(p1);
    ax1BL = axList1(3); % bottom left axes
    lines1 = findall(ax1BL, 'type', 'line');
    bran1 = lines1(3);
    mass1 = lines1(4);
    mass1.Color = [1, 1, 0];
    bran1.Color = [0.1, 1, 0.1];
    mass1.DisplayName = 'Massive, E=0';
    bran1.DisplayName = 'Branching, E=0';
    mass1.LineWidth = 1;
    bran1.LineWidth = 1;

    figure(p2);
    ax2BL = axList2(3); % bottom left axes
    lines2 = findall(ax2BL, 'type', 'line');
    lines2(3).Color = [0, 0.7, 0];
    lines2(4).Color = [0.6, 0.6, 0];
    lines2(3).DisplayName = 'Branching, E=1';
    lines2(4).DisplayName = 'Massive, E=1';
    lines2(3).LineWidth = 1;
    lines2(4).LineWidth = 1;
    copyobj(lines2(3), ax1BL);
    copyobj(lines2(4), ax1BL);

    close(p2)
    
    savefig(strcat(strcat(baseDir, fn1, 'Overlay'), '.fig'));
end