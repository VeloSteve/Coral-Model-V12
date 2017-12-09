nnz(~isnan(cumResult))
foo = squeeze(cumResult);
% TEMPORARY:
%foo(:, :, 11:19) = 20;

% for axis swapping: 
%foo = permute(foo,[2 3 1]);
% Values for color scaling.
% NaNs show up as darkest, below the actual oLowest value.
% Smaller subtracted value makes lowest value darker, giving more range but
% possible confusion with untested points.
oLowest = round(min(foo(:)) - 0.2, 2); % - 0.01;
% Worst calculated values show up as yellow.
% Large addition makes values farther from optimum distinct.  Small gives more resolution close to optimum.
oHighest = oLowest + 2.1; % + 0.05; 
oRows = 3;
oColumns = 5; % 5 for 13 steps
oStartI = 1;
oSteps = 13;
oEndI = min(oSteps, oStartI + oRows*oColumns - 2);
figure(13)
for i = oStartI:oEndI
    subplot(oRows,oColumns,i - oStartI + 1); 
    bar = squeeze(foo(:, :, i));
    %bar = foo;
    %surf(bar);
    %contourf(bar);
    oPlot = image(bar,'CDataMapping','scaled');
    
    %Version without permutation:
    title(sprintf('Divisor %i of %i (range 2-5)', i, oSteps));
    %ylabel('Bleach frac (0.05 to 0.2)');
    ylabel('Max psw2');
    xlabel('Exponent (0.3 to 0.50)');
    
    % Version with [2 3 1] permutation:
    %{
    title(sprintf('Lower limit %i of 19 (range .35-.40)', i));
    ylabel('Exponent (0.25 to 0.50)');
    xlabel('Divisor (4 to 7)');
    %}
    caxis([oLowest oHighest]);
    %zlim([18 19]);
end
subplot(oRows, oColumns,oRows*oColumns);
title(sprintf('Scale from %6.2f to %6.2f', oLowest, oHighest));
caxis([oLowest oHighest]);
colorbar();
