%% This saves the most recent figure (still visible) using the name and
%  file type given.  It's meant to be used interactively.  The built-in save
%  functions change the figure and lose resolution.
function saveCurrentFigure(name, e)
    if nargin == 2
        ext = strcat('.', e);
    else
        ext = '.png';
    end
    img = getframe(gcf);
    imwrite(img.cdata, [name, ext]);
end