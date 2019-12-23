classdef ParameterDictionary
% ParameterDictionary All Coral Model parameters, with constraints.
%
%   This object defines all variable input parameters including their
%   datatypes with allowed and current values.  Default values are hardcoded
%   into this object.
%   The object serves as both a text and programmatic reference to all
%   parameters to the coral model.  Every parameter used should have a match
%   here.  The defaults defined here should be rarely changed and
%   considered code modifications.  Any other change should be applied from
%   the outside by a script or GUI.
%
%   Since this is just a wrapper around a Map, subclassing containers.Map
%   seems like the right thing to do, but it's a known problem that this
%   doesn't work well.

    properties %(Access=private)
        params  % a containers.Map for storing parameters
    end
    
    %%
    methods (Access = 'private')
        function obj = addOne(obj, p)
            obj.params(char(p.name)) = p;
        end
    end
    %%
    methods

        function p = ParameterDictionary(inputType, inValue)
            % Define each allowed model parameter as an object.
            % 
            % The model*Parameter calls use arguments (name, type, default,
            % min, max), (name, type default), or (name, type, default,
            % allowed values) depending on type.
            p.params = containers.Map;
            
            % Paths
            addOne(p, modelCharParameter('path', 'codeBase', 'string', 'D:/GitHub/Coral-Model-V12/'));
            addOne(p, modelCharParameter('path', 'sharedData', 'string', 'D:/GitHub/Coral-Model-Data/'));
            addOne(p, modelCharParameter('path', 'outputBase', 'string', 'D:/CoralTest/V12Test/'));
            % Model constants and psw2 values for each case.
            addOne(p, modelCharParameter('path', 'matPath', 'string', 'D:/GitHub/Coral-Model-V12/mat_files/'));
            % ESM2M_SSTR_JD data
            addOne(p, modelCharParameter('path', 'sstPath', 'string', 'D:/GitHub/Coral-Model-Data/ProjectionsPaper/'));
            % DHM and Omega data
            addOne(p, modelCharParameter('path', 'sgPath', 'string', 'D:/GitHub/Coral-Model-Data/SymbiontGenetics/mat_files/'));
            % Mapping code - not ours, so don't publish the repository.
            addOne(p, modelCharParameter('path', 'm_mapPath', 'string', 'D:/GitHub/m_map/'));
            addOne(p, modelCharParameter('path', 'GUIBase', 'string', 'C:/'));

            
            % Science
            addOne(p, modelCharParameter('science', 'RCP', 'string', 'rcp85', {'rcp26', 'rcp45', 'rcp60', 'rcp85'}));
            addOne(p, modelCharParameter('science', 'dataset', 'string', 'ESM2M', {'ESM2M', 'HadISST'}));
            addOne(p, modelLogicalParameter('science', 'OA', 'logical', false));
            addOne(p, modelLogicalParameter('science', 'E', 'logical', false));
            addOne(p, modelIntParameter('science', 'superStart', 'integer', 2035, 1861, 2100));
            addOne(p, modelIntParameter('science', 'superMode', 'integer', 0, 0, 9));
            addOne(p, modelDoubleParameter('science', 'superAdvantage', 'double', 0.0, 0.0, 10.0));
            addOne(p, modelDoubleParameter('science', 'superGrowthPenalty', 'double', 0.0, 0.0, 10.0));

            
            % Computing
            % TODO everyx can be  a string or integer in V11!  Redefine it?
            addOne(p, modelCharParameter('comp', 'architecture', 'string','PC', {'PC', 'Mac', 'Linux'}));
            addOne(p, modelIntParameter('comp', 'everyx', 'integer', 1, 1, 1925));
            addOne(p, modelCharParameter('comp', 'specialSubset', 'string', 'no', {'no', 'eq', 'lo', 'hi', 'keyOnly', 'useEveryx'}));
            pc = parcluster('local');
            maxW = pc.NumWorkers;
            addOne(p, modelIntParameter('comp', 'useThreads', 'integer', 2, 1, maxW));
            addOne(p, modelLogicalParameter('comp', 'skipPostProcessing', 'logical', false));
            addOne(p, modelLogicalParameter('comp', 'doProgressBar', 'logical', false));
            addOne(p, modelLogicalParameter('comp', 'optimizerMode', 'logical', false));
            % Model source
            addOne(p, modelCharParameter('comp', 'modelVersion', 'string', 'Needs to be set!'));
           
            % Output options
            addOne(p, modelIntParameter('output', 'keyReefs', 'integer', 5, 1, 1925, true));  % Note nullAllowed final argument.
            addOne(p, modelLogicalParameter('output', 'newMortYears', 'logical', false));
            addOne(p, modelLogicalParameter('output', 'doCoralCoverFigure', 'logical', true));
            addOne(p, modelLogicalParameter('output', 'allPDFs', 'logical', false));
            addOne(p, modelLogicalParameter('output', 'doPlots', 'logical', true));
            addOne(p, modelLogicalParameter('output', 'doCoralCoverFigure', 'logical', true));
            addOne(p, modelLogicalParameter('output', 'doCoralCoverMaps', 'logical', true));
            addOne(p, modelLogicalParameter('output', 'doGenotypeFigure', 'logical', false));
            addOne(p, modelLogicalParameter('output', 'doGrowthRateFigure', 'logical', false));
            addOne(p, modelLogicalParameter('output', 'doDetailedStressStats', 'logical', false));
            addOne(p, modelLogicalParameter('output', 'saveVarianceStats', 'logical', false));

            
            % All allowed parameters are now defined.  If arguments are
            % given set parameters from there.  This provides validation.
            if nargin == 0
                % okay, use defaults
            elseif nargin ~= 2
                error('ParameterDictionary constructor requires zero or two arguments.  The first can be ''handle'', ''file'', or ''json''.');
            else
                % Inputs specify either a file containing just a JSON
                % string on a single line, or the JSON string itself.
                if strcmp(inputType, 'handle') || strcmp(inputType, 'file')         
                    if strcmp(inputType, 'file')
                        pf = fopen(inValue, 'r');
                    else
                        pf = inValue;
                    end
                    if pf ~= -1
                        txt = fgetl(pf);
                    else
                        error('Specified parameter file did not open.');
                    end
                    p.setFromJSON(txt);
                elseif strcmp(inputType, 'json')
                    p.setFromJSON(inValue);
                else
                    error('Only inputs of type ''handle'', ''file'' or ''json'' are supported.');
                end
            end
            
            % To be sure it's not overwritten by a saved value, set the
            % model version here.
            [mp, ~, ~] = fileparts(which('ParameterDictionary'));
            dirParts = split(mp, {'/', '\'});
            sd = dirParts{end};
            format shortg; c = clock;
            dateString = strcat(num2str(c(1)),num2str(c(2),'%02u'),num2str(c(3),'%02u'));
            txt = strcat(sd, {' as of '}, dateString);
            p.set('modelVersion', txt{1});

        end
        
        function obj = set(obj, name, value)
            % SET Set a value for an existing parameter

            % MATLAB will raise an error if there's no existing value called
            % "name" of if the type can't be matched.
            p = obj.params(name);
            %{
            if isnumeric(value)
                fprintf('PD setting %s to %d\n', name, value);
            else
                fprintf('PD setting %s to %s\n', name, value);
            end
            %}
            p = p.set(value);  % Note that the object must be returned.
            % Setting the object isn't enough!  Must replace it in the
            % dictionary.
            obj.addOne(p);
        end   
        
        function val = get(obj, name)
            % GET Get a value for an existing parameter

            % MATLAB will raise an error if there's no existing value called
            % "name".
            p = obj.params(name);
            val = p.get();  % Note that the object must be returned.
       end 
        
        function str = getStruct(obj)
            % Put all parameters into a single structure.
            % This may be used directly, but is also used by getJSON.
            % This is done regardless of datatype - TODO: is that okay?
            for i = keys(obj.params)
                key = i{1};
                par = obj.params(key);
                if isempty(par.value)
                    str.(key) = par.default;
                else
                    str.(key) = par.value;
                end
            end
        end
        
        function s = getJSON(obj)
            % Return all parameters as a JSON string.
            str = getStruct(obj);
            s = jsonencode(str);
        end
        
        
        
        function setFromJSON(obj, s)
            % Accept a JSON string and set variables with matching names.
            % It's an error to send a variable not defined in the dictionary.
            str = jsondecode(s);
            fields = fieldnames(str);

            for i=1:numel(fields)
              name = fields{i};
              val = str.(name);

              % Set the value of the existing object.
              p = obj.params(name);
              % Setting p.value directly is a bug, because it bypasses error
              % and range checking!
              % p.value = val;
              p = p.set(val);
              addOne(obj, p);
              % fprintf('After set and add, value is '); disp(obj.get(name));
            end
        end
        
        function mc = getModelChoices(obj)
            s = obj.getStruct();  % Could get variables one-by-one, but this seems easier.
            mc = strcat(s.dataset, '.', s.RCP, '.E', num2str(s.E), ...
                '.OA', num2str(s.OA), '.sM', num2str(s.superMode), '.sA', ...
                num2str(s.superAdvantage));
        end
               
        function dName = getDirectoryName(obj, suffix)
            % Returns a string suitable for naming an output directory.
            % This is meant to return a name which identifies key
            % parameters of the current run.  It is not a full path.
            format shortg; c = clock;
            dateString = strcat(num2str(c(1)),num2str(c(2),'%02u'),num2str(c(3),'%02u')); % today's date stamp
            name = strcat(obj.getModelChoices(), '.', dateString);
            dName = strcat(obj.get('outputBase'), name, suffix);
        end
        
        function vars = print(obj, category)
            if nargin == 2
                filter = category;
            else
                filter = '';
            end
            
            % Parameter categories to print, in order
            cats = {'science', 'path', 'comp', 'output'};
            vars = sprintf('Category  Name                    Value \n');
            for c = 1:4
                cat = cats{c};
                if isempty(filter) || strcmp(filter, cat)
                    for i = keys(obj.params)
                        key = i{1};
                        par = obj.params(key);
                        if ~strcmp(par.category, cat)
                            continue;
                        end
                        vars = sprintf('%s%-9s %-24s %-15s \n', vars, par.category, par.name, par.asString());    
                    end
                end
            end

        end

        
    end
end

