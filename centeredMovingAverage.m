function out = centeredMovingAverage(x, n)
% Calculates a moving average of the values in vector x, over n points, where n
% is odd.
% Within n/2 points of each end of the vector, the mask is shrunk so that
% values are still centered, but the effecive "n" value shrinks.

% This could be done in a more "Matlab like" way, but as a first pass I'm
% going to write this crudely (but maybe more clearly).

    %pad the array so that all of the adding can
    % be done with no concern for endpoints.  Then only the divisors need to be
    % special.
    %half = idivide(int32(n)/int32(2), 'floor');
    assert(mod(n, 2) == 1, 'Centered moving average requires an odd n value.');
    
    half = floor(n/2);
    
    out = zeros(1, length(x));
    padx = zeros(1, length(x)+ 2*half);
    padx(half+1:end-half) = x;
    for i = 1:n
        out(1:end) = out(1:end) + padx(i:end-n+i);
    end
    
    % Sums are complete, now divide
    % Center
    out(1+half:end-half) = out(1+half:end-half)/n;
    % Ends
    for i = 1:half
        out(1+half-i) = out(1+half-i)/(n-i);
        out(end-half+i) = out(end-half+i)/(n-i);
    end
       

end


