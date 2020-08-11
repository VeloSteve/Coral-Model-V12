function [] = saveGiAsMat( matName, gi, vgi)
%Attempt to save a mat file, which can't be done directly in a parfor loop.
    if nargin == 3
        save(matName, 'gi', 'vgi');
    elseif nargin == 2
        save(matName, 'gi');
    else
        error('saveGiAsMat requires a filename, gi, and optionally vgi');
    end
end

