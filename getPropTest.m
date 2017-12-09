% getPropTest selects the correct psw2 column based on a 5% bleaching
% target.  Choose the correct match according to the E and RCP values.
function [propTest] = getPropTest(E, RCP, bleachTarget)
    % Default is to run after optimization for a bleaching target of
    % 5% between 1985 and 2010.  The argument can ask for other values.
    if nargin < 3
        bleachTarget = 5;
    end
    % If we get to the end with this == 0, there's either a known missing
    % value or a logic error.
    propTest = 0;
    switch bleachTarget
        case 5
            if E == 0
                switch RCP
                    case 'rcp26'
                        propTest = 20;
                    case 'control400'
                        propTest = 20;
                    case 'rcp85'
                        propTest = 21;
                    case 'rcp45'
                        propTest = 24;
                    case 'rcp60'
                        propTest = 25;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            elseif E == 1
                switch RCP
                    case 'rcp26'
                        propTest = 22;
                    case 'control400'
                        propTest = 22;
                    case 'rcp85'
                        propTest = 23;
                    case 'rcp45'
                        propTest = 26;
                    case 'rcp60'
                        propTest = 27;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            end
        case 10
            if E == 0
                switch RCP
                    case 'rcp26'
                        propTest = 2;
                    case 'control400'
                        propTest = 2;
                    case 'rcp45'
                        propTest = 4;
                    case 'rcp60'
                        propTest = 6;
                    case 'rcp85'
                        propTest = 8;                        
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            elseif E == 1
                switch RCP
                    case 'rcp26'
                        propTest = 3;
                    case 'control400'
                        propTest = 3;
                    case 'rcp45'
                        propTest = 5;
                    case 'rcp60'
                        propTest = 7;
                    case 'rcp85'
                        propTest = 9; 
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            end 
        case 3
            if E == 0
                switch RCP
                    case 'rcp26'
                        propTest = 10;
                    case 'control400'
                        propTest = 10;
                    case 'rcp45'
                        propTest = 12;
                    case 'rcp60'
                        propTest = 14;
                    case 'rcp85'
                        propTest = 16;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            elseif E == 1
                switch RCP
                    case 'rcp26'
                        propTest = 11;
                    case 'control400'
                        propTest = 11;
                    case 'rcp45'
                        propTest = 13;
                    case 'rcp60'
                        propTest = 15;
                    case 'rcp85'
                        propTest = 17;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            end 
        case 15
            error('15% Bleaching target is unreachable under current assumptions!');
            %{
            if E == 0
                switch RCP
                    case 'rcp26'
                        propTest = 28;
                    case 'control400'
                        propTest = 28;
                    case 'rcp45'
                        propTest = 30;
                    case 'rcp60'
                        propTest = 32;
                    case 'rcp85'
                        propTest = 34;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            elseif E == 1
                switch RCP
                    case 'rcp26'
                        propTest = 29;
                    case 'control400'
                        propTest = 29;
                    case 'rcp45'
                        propTest = 31;
                    case 'rcp60'
                        propTest = 33;
                    case 'rcp85'
                        propTest = 35;
                    otherwise
                        error('No RCP match for E=%d, bleaching target %d', E, bleachTarget);
                end
            end 
            %}
        otherwise
            error('No psw2 values have been defined for a bleaching target of %d.\n', bleachingTarget);
    end
    if propTest == 0
        error('No propTest value is defined for E = %d and RCP = %s at a bleaching target of %d\n', ...
            E, RCP, bleachTarget);
    end
    return;
end
