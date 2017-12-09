classdef ParameterDictionary
    % ParameterDictionary Define all variable input parameters here including
    %their datatypes, allowed, and current values.
    %   This function serves as both a text and programmatic reference to all
    %   parameters to the model.  Every parameter given should have a match
    %   here.  The defaults defined here should be rarely changed and
    %   considered code modifications.  Any other change should be applied from
    %   the outside by a script or GUI.
    %
    %   Since this is just a wrapper around a Map, subclassing containers.Map
    %   seems like the right thing to do, but it's a known problem that this
    %   doesn't work well.  
    
    %{"RCP":"rcp85","OA":1,"E":true,"everyx":1,"useTestThreads":5,"doProgressBar":true,"keyReefs":[],
    %    "superStart":2035,"superMode":0,"superAdvantage":0,"newMortYears":false,"doCoralCoverFigure":false,"superSym":"None"}
    %%
    properties
        params
    end
    
    %%
    methods (Access = 'private')
        function obj = addOne(obj, p)
            obj.params(char(p.name)) = p;
        end
    end
    %%
    methods
        % Set up all allowed model parameters.  The model*Parameter calls
        % use arguments (name, type, default, min, max), (name, type
        % default), or (name, type, default, allowed values) depending on
        % type.
        function p = ParameterDictionary()
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
            
            % Science
            addOne(p, modelCharParameter('RCP', 'string', 'rcp85', {'rcp26', 'rcp45', 'rcp60', 'rcp 85'}));
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

        end
        
        % Set an existing value.  New values may not be added "on the fly".
        function obj = set(obj, name, value)
            % MATLAB will raise an error if there's not existing value called
            % name.
            p = obj.params(name);
            p.set(value);
        end   
        
        % Put all parameters into a structure.  This may be used directly,
        % but is also used by getJSON.
        function str = getStruct(obj)
            % Put all parameters into a single structure.
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
        
        % Turn all parameters into a JSON string.  No particular order is
        % enforced - only the names matter.
        function s = getJSON(obj)
            str = getStruct(obj);
            s = jsonencode(str);
        end
        
        
        % Accept a JSON string and set variables with matching name.
        % It's an error to send a variable not defined in the dictionary.
        function setFromJSON(obj, s)
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
            
    end
end

