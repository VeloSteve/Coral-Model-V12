classdef modelLogicalParameter < modelParameter
    %modelLogicalParameter A value which controls a model option in an on/off fashion.
    %   Logical inputs are accepted more flexibly than the other types, with
    %   integer 1, logical 1, or true for true and integer 0, logical 0, or
    %   false for false.  The true and false options should be specified as
    %   such, not as strings in quotes.  Unlike in general MATLAB logic,
    %   other nonzero numerical values are not accepted.
    
    properties
        default logical
        minimum logical
        maximum logical
        value logical
    end
    
    methods
        function p = modelLogicalParameter(cat, n, type, def)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 4
                error('Logical parameters must be defined with a category, name, type, and default.');
            end
            % The two parameters sent to the superclass are mostly
            % handled there.
            p@modelParameter(cat, n, type);
            if ~strcmp(type, 'logical')
                error('Integer parameters must be specified by name as integers.');
            end
            if islogical(def)
                p.default = def;
            elseif isinteger(def)
                if def == 0
                    p.default = false;
                elseif def == 1
                    p.default = true;
                else
                    error('Logical inputs in numerical form must be 0 or 1.');
                end
            else
                error('Default must be numeric or a MATLAB logical.')
            end
            p.value = p.default;
        end
        
        
        function obj = set(obj, v)
            if islogical(v)
                obj.value = v;
            else
                error('%s can only be set to a logical value!', obj.name);
            end
        end
        
        function [v] = get(obj)
            v = obj.value;
            fprintf('mLP returning %s %d\n', v, v);
        end
        
        function vs = asString(obj)
            if obj.value
                vs = 'true';
            else
                vs = 'false';
            end
        end
    end
end


