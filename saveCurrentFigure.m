%% This saves the most recent figure (still visible) using the name and
%  file type given.  It's meant to be used interactively.  The built-in save
%  functions change the figure and lose resolution.
function saveCurrentFigure(name, e, quality)
    if nargin >= 2
        ext = strcat('.', e);
    else
        ext = '.png';
    end
    if nargin < 3
        quality = 0.75;
    end
    img = getframe(gcf);
    
    if isstring(name)
        name = char(name);
    end
        
    if strcmp(ext, '.jpg')
        imwrite(img.cdata, [name, ext], 'Quality', quality);
    else
        imwrite(img.cdata, [name, ext]);
    end
    
    % export_fig is from MATLAB's file exchange, and some options are dependent
    % on GhostScript.
    % Use it to produce high-quality vector outputs.
    name = replace(name, '\', '/'); % export_fig chokes on backslashes
    try 
        export_fig([name 'EF'], '-painters', '-pdf', '-dALLOWPSTRANSPARENCY')
        % Creates a huge eps file, which won't import to Word on my system...
        % addpath("D:\Library\Downloads\Adobe\xpdf-tools-win-4.03\xpdf-tools-win-4.03\bin64");
        % export_fig([name 'EF'], '-painters', '-eps', '-dALLOWPSTRANSPARENCY')
        % This is more usable, but the pdf option seems to be enough.
        % export_fig([name 'EF'], '-painters', '-emf', '-dALLOWPSTRANSPARENCY')       
    catch ME
        % The default warning when output can't be written is long and doesn't
        % point to the most common case (at least for me) which is:
        fprintf("Is a previous copy of the file open for viewing?\n");
        rethrow(ME);
    end

    % saveas can save to vector formats, but is inferior to export_fig.  Note
    % that a new export function in MATLAB 2021a, exportgraphics, has not been
    % tested in this project.
end