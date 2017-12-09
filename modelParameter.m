classdef modelParameter
    %modelParameter A value which controls a model option.
    %   Every parameter should be defined as an instance of this class so
    %   important information about that parameter is available.  Example
    %   parameters include output directories, evolution on/off, super
    %   symbiont options, and number of worker threads.
    
    properties
        name char
        dataType char
        needsMinMax logical
    end
    
    methods
        function obj = modelParameter(n, type)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin ~= 2
                error('Parameters must be defined with a name and type.');
            end
            % Accept either a character array or a string.
            if ischar(n)
                obj.name = n;
            else
                error('Parameters must be given a text (string) name.');
            end
            % and here.

            if ischar(type)
                obj.dataType = type;
                obj.needsMinMax = false;
                switch obj.dataType
                    case 'integer'
                        obj.needsMinMax = true;
                    case 'logical'
                    case 'double'
                        obj.needsMinMax = true;
                    case 'string'
                    otherwise
                        error('Parameter type must be integer, logical, double, or string.');         
                end
        
            else
                error('Parameter type must be a string, and one of integer, logical, double, or string.');         
            end
        end
                

    end
end

