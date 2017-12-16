function [ps, pd] = getInputStructure(parameters)
%GETINPUTSTRUCTURE Get all program inputs as a structure.
%
% getInputStructure(parameters)
%
% parameters can be a JSON string or a ParameterDictionary object. If
% neither is found, this function reads a file called
% LastChanceParameters.txt.  The file option is only meant to allow the
% program to be tested when a proper calling script is not yet in place.
%
% See also: PARAMETERDICTIONARY

    if isa(parameters, 'ParameterDictionary')
        ps = parameters.getStruct();
        pd = parameters;
    else
        % If it's not a ParameterDictionary, see if it's a JSON string.
        try ps = jsondecode(parameters)
            % TODO: store this in a ParameterDictionary so inputs are
            % validated.
            disp('Got input values from a JSON string.');
            json = parameters;
        catch ME
            if (strcmp(ME.identifier,'MATLAB:json:ExpectedValue'))
                % Not a valid JSON string.  Try initializing from a file.
                fh = fopen('LastChanceParameters.txt');
                if fh == -1
                    error('Failed to open LastChanceParameters.txt');
                end
                json = '';
                while ~feof(fh)
                    line = strtrim(fgets(fh));
                    if ~strncmp(line, '%', 1)
                        json = strcat(json, line);
                    end
                end
                fprintf('Decoding %s\n', json);

                try ps = jsondecode(json)
                    disp('Got input values from LastChanceParameters.txt');
                catch ME
                    disp('Invalid input in LastChanceParameters.txt !');
                    rethrow(ME);
                end
            else
                % Some other error.  Don't try to handle it here.
                rethrow(ME)
            end
        end
        pd = ParameterDictionary('json', json);
    end
    % keyReefs seems to come out of the JSON as a column vector even if it
    % goes in as a row.  This may be wrong, but for now just force it to be
    % what we need.
    ps.keyReefs = reshape(ps.keyReefs, 1, []);
end

