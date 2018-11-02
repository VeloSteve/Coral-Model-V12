function [ps, pd] = getInputStructure(parameters)
%GETINPUTSTRUCTURE Get all program inputs as a structure.
%
% getInputStructure(parameters)
%
% parameters can be a JSON string, a parameterDictionary object, or a file name. If
% neither is found, this function reads a file called
% LastChanceParameters.txt.  The file option is only meant to allow the
% program to be tested when a proper calling script is not yet in place.
%
% See also: PARAMETERDICTIONARY

    if isa(parameters, 'parameterDictionary')
        ps = parameters.getStruct();
        pd = parameters;
    else
        % If it's not a ParameterDictionary, see if it's a JSON string.
        try ps = jsondecode(parameters);
            % That worked as a test, but use the PD constructor
            % so inputs are validated.
            pd = parameterDictionary('json', parameters);
            disp('Got input values from a JSON string.');
        catch ME
            if (strcmp(ME.identifier,'MATLAB:json:ExpectedValue'))
                % Not a valid JSON string.  Try initializing from a file.
                fh = fopen(parameters, 'r');
                if fh == -1
                    error('Failed to open file %s', parameters);
                end
                json = '';
                while ~feof(fh)
                    line = strtrim(fgets(fh));
                    if ~strncmp(line, '%', 1)
                        json = strcat(json, line);
                    end
                end
                fclose(fh);
                fprintf('Decoding %s\n', json);
                
                try ps = jsondecode(json);
                    % As above, now repeat with the PD constructor.
                    pd = parameterDictionary('json', json);
                    disp('Got input values from specified file.');
                catch ME
                    disp('Invalid input in specified file!');
                    rethrow(ME);
                end
            else
                % Some other error.  Don't try to handle it here.
                rethrow(ME)
            end
        end
        % keyReefs seems to come out of the JSON as a column vector even if it
        % goes in as a row.  This may be wrong, but for now just force it to be
        % what we need.
        ps = pd.getStruct();
    end

end

