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
            
            % Bookkeeping
            addOne(p, modelCharParameter('codeBase', 'string', 'D:/GitHub/Coral-Model-V12/'));
            addOne(p, modelCharParameter('sharedData', 'string', 'D:/GitHub/Coral-Model-Data/'));
            addOne(p, modelCharParameter('outputBase', 'string', 'D:/CoralTest/V12Test/'));
            % Model constants and psw2 values for each case.
            addOne(p, modelCharParameter('matPath', 'string', 'D:/GitHub/Coral-Model-V12/mat_files/'));
            % ESM2M_SSTR_JD data
            addOne(p, modelCharParameter('sstPath', 'string', 'D:/GitHub/Coral-Model-Data/ProjectionsPaper/'));
            % DHM and Omega data
            addOne(p, modelCharParameter('sgPath', 'string', 'D:/GitHub/Coral-Model-Data/SymbiontGenetics/mat_files/'));
            % Mapping code - not ours, so don't publish the repository.
            addOne(p, modelCharParameter('m_mapPath', 'string', 'D:/GitHub/m_map/'));
            addOne(p, modelCharParameter('GUIBase', 'string', 'C:/'));
            
            % Science
            addOne(p, modelCharParameter('RCP', 'string', 'rcp85', {'rcp26', 'rcp45', 'rcp60', 'rcp 85'}));
            addOne(p, modelCharParameter('dataset', 'string', 'ESM2M', {'ESM2M', 'HadISST'}));
            addOne(p, modelLogicalParameter('OA', 'logical', false));
            addOne(p, modelLogicalParameter('E', 'logical', false));
            addOne(p, modelIntParameter('superStart', 'integer', 2035, 1861, 2100));
            addOne(p, modelIntParameter('superMode', 'integer', 0, 0, 6));
            addOne(p, modelDoubleParameter('superAdvantage', 'double', 0.0, 0.0, 10.0));

            
            % Computing
            % TODO everyx can be  a string or integer in V11!  Redefine it?
            addOne(p, modelCharParameter('architecture', 'string','PC', {'PC', 'Mac', 'Linux'}));
            addOne(p, modelIntParameter('everyx', 'integer', 1, 1, 1925));
            addOne(p, modelCharParameter('specialSubset', 'string', 'no', {'no', 'eq', 'lo', 'hi', 'keyOnly'}));
            pc = parcluster('local');
            maxW = pc.NumWorkers;
            addOne(p, modelIntParameter('useThreads', 'integer', 2, 1, maxW));
            addOne(p, modelLogicalParameter('skipPostProcessing', 'logical', false));
            addOne(p, modelLogicalParameter('doProgressBar', 'logical', false));
            
            % Output options
            addOne(p, modelIntParameter('keyReefs', 'integer', 5, 1, 1925));
            addOne(p, modelLogicalParameter('newMortYears', 'logical', false));
            addOne(p, modelLogicalParameter('doCoralCoverFigure', 'logical', true));
            addOne(p, modelLogicalParameter('allPDFs', 'logical', false));
            addOne(p, modelLogicalParameter('doPlots', 'logical', true));
            addOne(p, modelLogicalParameter('doCoralCoverFigure', 'logical', true));
            addOne(p, modelLogicalParameter('doCoralCoverMaps', 'logical', true));
            addOne(p, modelLogicalParameter('doGenotypeFigure', 'logical', false));
            addOne(p, modelLogicalParameter('doGrowthRateFigure', 'logical', false));
            addOne(p, modelLogicalParameter('doDetailedStressStats', 'logical', false));
            addOne(p, modelLogicalParameter('saveVarianceStats', 'logical', false));
            
            % All allowed parameters are now defined.  If arguments are
            % given set parameters from there.  This provides validation.
            if nargin == 0
                % okay, use defaults
            elseif nargin ~= 2
                error('ParameterDictionary constructor requires zero or two arguments.');
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
                    error('Only inputs of type ''file'' or ''json'' are supported.');
                end
            end
        end
        
        function obj = set(obj, name, value)
            % SET Set a value for an existing parameter

            % MATLAB will raise an error if there's no existing value called
            % "name" of if the type can't be matched.
            p = obj.params(name);
            if isnumeric(value)
                fprintf('PD setting %s to %d\n', name, value);
            else
                fprintf('PD setting %s to %s\n', name, value);
            end
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
              p.value = val;
              fprintf('Set parameter object %s to %d\n', name, val);
              addOne(obj, p);
            end
        end
               
        function dName = getDirectoryName(obj, suffix)
            % Returns a string suitable for naming an output directory.
            format shortg; c = clock;
            dateString = strcat(num2str(c(1)),num2str(c(2),'%02u'),num2str(c(3),'%02u')); % today's date stamp
            s = obj.getStruct();  % Could get variables one-by-one, but this seems easier.
            modelChoices = strcat(s.dataset,s.RCP,'.E',num2str(s.E), ...
                '.OA',num2str(s.OA), '_sM',num2str(s.superMode),'_sA', ...
                num2str(s.superAdvantage), '_',dateString);
            dName = strcat(s.outputBase, modelChoices, suffix);
        end
        

        
    end
end

