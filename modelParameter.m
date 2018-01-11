classdef modelParameter
    %modelParameter A value which controls a model option.
    %   Every parameter should be defined as an instance of this class so
    %   important information about that parameter is available.  Example
    %   parameters include output directories, evolution on/off, super
    %   symbiont options, and number of worker threads.
    
    properties
        category char
        name char
        dataType char
        needsMinMax logical
        nullAllowed logical
    end
    
    methods
        function obj = modelParameter(cat, name, type)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin ~= 3
                error('Parameters must be defined with a name and type.');
            end
            
            % False for everything except keyReefs, at least at first:
            obj.nullAllowed = false;
            
            % Accept either a character array or a string for each input.
            if ischar(name)
                obj.name = name;
            else
                error('Parameters must be given a text (string) name.');
            end
            if ischar(cat)
                obj.category = cat;
            else
                error('Parameters must be given a text (string) category.');
            end

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
        
        function vs = asString(obj)
            % Returns the value as a string - non-char parameters should
            % override this.
            vs = obj.value;
        end
    end
end

