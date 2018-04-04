function out = centeredMovingAverage(x, n, method)
% Calculates a moving average of the values in vector x, over n points, where n
% is odd.
% Within n/2 points of each end of the vector, the mask is shrunk so that
% values are still centered, but the effecive "n" value shrinks.
% method is optional.  The default is 'rectangle', giving equal weight
% to all n points.  The only other option so far is 'hamming', which uses coefficents
% as defined here https://en.wikipedia.org/wiki/Window_function#Hamming_window

% This could be done in a more "Matlab like" way, but as a first pass I'm
% going to write this crudely (but maybe more clearly).

    %pad the array so that all of the adding can
    % be done with no concern for endpoints.  Then only the divisors need to be
    % special.
    %half = idivide(int32(n)/int32(2), 'floor');
    assert(mod(n, 2) == 1, 'Centered moving average requires an odd n value.');
    
    if nargin == 3
        alg = method;
    else
        alg = 'rectangle';
    end
    
    half = floor(n/2);
    %{
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
    %}
    % REWRITE below to accommodate more than one window type.
    out = zeros(1, length(x));
    weight = zeros(n, 1);
    if strcmp(alg, 'hamming')
        disp('Hamming smoothing.')
        cFactor = 2 * pi() / (n-1);
        for i = 0:n-1
            weight(i+1) = 0.54 - 0.46 * cos(i*cFactor);
        end
        divisor = sum(weight); % should be 1, but this is safe.
    elseif strcmp(alg, 'rectangle')
        disp('Rectangular smoothing.')
        weight = ones(n, 1);
        divisor = n;
    else
        error("Moving average supports only 'rectangle' and 'hamming'.");
    end
    
    % Use the full window where possible
    left = (n+1)/2;
    right = length(x)-left+1;
    for i = 1:n
        out(left:right) = out(left:right) + weight(i)*x(i:length(x)-n+i);
    end
    out(left:right) = out(left:right)/divisor;
    % Now do the ends, which have a partial window.
    % j is the point we're averaging for.
    for j = 1:left-1
        div = 0;
        flip = length(x) - j + 1;
        % i is the position in the weight array
        for i = left+1-j:n
            div = div + weight(i);
            shift = left-j;
            out(j) = out(j) + weight(i)*x(i-shift);
            out(flip) = out(flip) + weight(i)*x(length(x)+1-(i-shift));
        end
        out(j) = out(j)/div;
        out(flip) = out(flip)/div;
    end
end


