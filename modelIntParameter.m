classdef modelIntParameter < modelParameter
    %modelParameter A value which controls a model option.
    %   Every parameter should be defined as an instance of this class so
    %   important information about that parameter is available.  Example
    %   parameters include output directories, evolution on/off, super
    %   symbiont options, and number of worker threads.
    
    properties
        default int32
        minimum int32
        maximum int32
        value int32
    end
    
    methods
        function p = modelIntParameter(n, type, def, min, max)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 5
                error('Integer parameters must be defined with a name, type, default, min, and max.');
            end
            % The two parameters sent to the superclass are mostly
            % handled there.
            p@modelParameter(n, type);
            if ~strcmp(type, 'integer')
                error('Integer parameters must be specified by name as integers.');
            end
            % Note that typed constants are doubles even if a whole number
            % is typed.  Instead of isinteger, check for whole numbers
            % using rem (remainder);
            if rem(def, 1) == 0 && rem(min, 1) == 0 && rem(max, 1) == 0
                p.default = def;
                p.minimum = min;
                p.maximum = max;
            else
                error('Default, min, and max must be numeric')
            end
        end
        
        
        function set(obj, v)
            if isinteger(v)
                if v >= obj.min && v <= obj.max
                    obj.value = v;
                else
                    error('Value of %s must be between %d and %d.  %d is not.', obj.name, obj.min, obj.max, v);
                end
            else
                error('You can not set an integer to a non-integer value.');
            end
        end
    end
end


