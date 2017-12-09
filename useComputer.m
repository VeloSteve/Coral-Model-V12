function [basePath, outputPath, sstPath, SGPath, matPath, n, defaultThreads] ...
        = useComputer(n)
    % Set paths and anything else computer-specific
    % 1=office; 2=laptop; 3=Steve; 4=Steve laptop;
    
    % if n = 0 attempt to identify the computer by name.
    if n == 0
        [~, name] = system('hostname');
        name = strtrim(name); % Remove line feed or other white space.
        if strcmp(name, 'Moby')
            n = 3;
        elseif strcmp(name, 'Yoga')
            n = 4;
        else
            error('Computer name %s not recogized. Try specifying a number.', name);
        end
    end
    
    % Sadly, MatLab does not have fall-through in switch statements like
    % most languages.  Try switch anyway.
    switch n
        case 1
            defaultThreads = 0;
            cd('/Users/loga8761/');     % desktop
        case 2
            defaultThreads = 0;
            cd('/Users/cheryllogan/');  % laptop
        case 3
            %clc;
            defaultThreads = 5;
            top = 'D:/GitHub/';
            basePath = strcat(top, 'Coral-Model-V11/');
            sharedData = strcat(top, 'Coral-Model-Data/');
            %outputPath = basePath;
            outputPath = 'D:/CoralTest/V11Test/';  % C: for SSD D: for non-google directory
            %outputPath =  'D:/GoogleDrive/Coral_Model_Steve/Outputs_May8_May17/';
        case 4
            defaultThreads = 5;
            top = 'C:\Users\list.DESKTOP-6A5PUNV\Google Drive\Coral_Model_Steve\';
            basePath = strcat(top, 'SymbiontGenetics_V9_DualSymbiont/');
            outputPath = 'C:/Users/list.DESKTOP-6A5PUNV/Google Drive/Coral_Model_Steve/April17Output/';
        otherwise
            error('Specified computer number is not supported.');
    end
    if n == 1 || n == 2     
        % Cheryl's computers
        top = '/Users/loga8761/Google Drive/Research/Coral_Model_Steve/';
        sstPath = strcat(top, 'ProjectionsPaper/');
        matPath = strcat(top, 'SymbiontGenetics_V10_DualSymbiontOA/mat_files/');
        basePath = strcat(top, 'SymbiontGenetics_V10_DualSymbiontOA/');
        outputPath = strcat(basePath, 'outputs/SelVx5');
        m_mapPath = strcat(basePath, 'm_map/');
        % JSR - are the next 2 lines needed?
        addpath(genpath(strcat(top, 'mexcdf'))); % add mexcdf toolbox and subfolders
        addpath(genpath(strcat(top, 'mexcdf/snctools'))); % add snctools toolbox and subfolders
        SGPath = strcat(top, 'SymbiontGenetics/mat_files/');
    else
        % Steve's computers
        matPath = strcat(basePath, 'mat_files/');
        sstPath = strcat(sharedData, 'ProjectionsPaper/');
        m_mapPath = strcat(basePath, 'm_map/');
        SGPath = strcat(sharedData, 'SymbiontGenetics/mat_files/');
    end
    addpath(m_mapPath);
    cd(basePath);
end
