classdef modelDoubleParameter < modelParameter
    %modelParameter A value which controls a model option.
    %   Every parameter should be defined as an instance of this class so
    %   important information about that parameter is available.  Example
    %   parameters include output directories, evolution on/off, super
    %   symbiont options, and number of worker threads.
    
    properties
        default double
        minimum double
        maximum double
        value double
    end
    
    methods
        function p = modelDoubleParameter(n, type, def, min, max)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 5
                error('Double parameters must be defined with a name, type, default, min, and max.');
            end
            % The two parameters sent to the superclass are mostly
            % handled there.
            p@modelParameter(n, type);
            if ~strcmp(type, 'double')
                error('Double parameters must be specified by name as double.');
            end
            if isfloat(def) && isfloat(min) && isfloat(max)
                p.default = def;
                p.value = def;
                p.minimum = min;
                p.maximum = max;
            else
                error('Default, min, and max must be numeric')
            end
        end
        
        
        function obj = set(obj, v)
            if isfloat(v)
                if v >= obj.minimum && v <= obj.maximum
                    obj.value = v;
                else
                    error('Value of %s must be between %f and %f.  %f is not.', obj.name, obj.min, obj.max, v);
                end
            else
                error('You can not set a double to the given value.');
            end
        end
        
        function [v] = get(obj)
            v = obj.value;
            fprintf('mDP returning %s %d\n', v, v);
        end
    end
end


