function [cMap] = customScale()
    load('RedGreenYearsMap.mat');
    % customRGMap shifts through orange and yellow near the center.
    % customRGShift moves this shift to later years for more resolution
    % there.
    % customOrangeBlue is more friendly to colorblind viewers, but probably
    % isn't great on a blue ocean color.
    % OrangeBlueLANL is direct from https://datascience.lanl.gov/data/colormaps/AsymmetricBlueOrangeDivergent-W5.xml
    % OrangeBlueLANLMod  is a guess made before the one above, and avoiding
    % white.
    cMap = OrangeBlueLANLMod; %customRGMap;
    %{
    % Map code posted by Stephen Cobeldick at https://www.mathworks.com/matlabcentral/fileexchange/25536-red-blue-colormap
    m = 20;
    n = fix(m/2);
    x = n~=(m/2); 
    b = [(0:1:n-1)/n,ones(1,n+x)]; 
    g = [(0:1:n-1)/n/2,ones(1,x),(n-1:-1:0)/n/2]; % Extra "/2" so light blue doesn't fade into ocean blue
    r = [ones(1,n+x),(n-1:-1:0)/n]; 
    cMap = [r(:),g(:),b(:)];
    %}
end
