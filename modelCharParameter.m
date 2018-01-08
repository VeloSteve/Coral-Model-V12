classdef modelCharParameter < modelParameter
    %modelParameter A value which controls a model option in the form MATLAB calls a character array and everyone else calls a string.  In MATLAB they are different.
    %   Every parameter should be defined as an instance of this class so
    %   important information about that parameter is available.  Example
    %   parameters include output directories, evolution on/off, super
    %   symbiont options, and number of worker threads.
    
    properties
        default char
        possible  % If this is char, it seems to force all strings to the same length!
        value char
    end
    
    methods
        function p = modelCharParameter(cat, n, type, def, poss)
            %modelParameter Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 4
                error('String parameters must be defined with a category, name, type, and default; a cell array of allowed values is optional.');
            end
            % The two parameters sent to the superclass are mostly
            % handled there.
            p@modelParameter(cat, n, type);
            if ~strcmp(type, 'string')
                error('String parameters must be specified by name as strings.');
            end
            if ischar(def)
                p.default = def;
                p.value = def;
            else
                error('Default must be a string.')
            end
            if nargin == 5
                if iscellstr(poss)
                    p.possible = poss;    
                else
                    error('Allowed strings must be supplied in a cell array of strings (character arrays)');
                end
            end
        end
        
        
        function obj = set(obj, v)
            if ischar(v)
                if ~isempty(obj.possible) && any(strcmp(obj.possible, v))
                    obj.value = v;
                elseif isempty(obj.possible)
                    % No constraints on this parameter.
                    obj.value = v;
                else
                    error('Value %s is not in the list of possible values of %s.', v, obj.name);
                end
            else
                error('You can not set a string for %s to %s\n', obj.name, v);
            end
        end
        
        function [v] = get(obj)
            v = obj.value;
            % fprintf('mCP returning %s for %s \n', v, obj.name);
        end
    end
end


