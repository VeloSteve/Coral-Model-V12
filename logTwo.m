%% Echo to both the console and a file.  The first call to this function
%  should specify the file handle of that file.  Subsequent calls take the
%  same arguments as fprintf and send them on to that function.  One
%  warning: like fprintf this can not be used to print a single numeric
% value without a format.
function logTwo(varargin)
    persistent h;
    if length(varargin) == 1
        % could be the file handle
        tst = varargin{1};
        if isnumeric(tst)
            if tst == -1
                error('Single variable must be a file handle.  This one is invalid.');
            end
            % Good handle, probably
            fprintf('logTwo setting handle to %d\n', tst);
            h = tst;
            return;
        end
        % should be something printable
    end
    % print to both the console and the file at handle h.
    fprintf(varargin{:});
    fprintf(h, varargin{:});
    
end
        