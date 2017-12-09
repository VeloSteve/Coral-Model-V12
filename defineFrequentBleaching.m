% Frequent bleaching is defined (for now) as any time when there have been
% two or more coral bleaching events in the last 10 years.  Each coral type
% is treated separately.
% fb is as 3-D logical array indicating frequent bleaching.
function [fb] = defineFrequentBleaching(bleachEvents) 
    % Array dims are (reefs, years, coral type)

    % Sum the 10 years by offsetting the array.
    nc = size(bleachEvents, 3);
    s = zeros(size(bleachEvents));
    for c = 1:nc
        for i = 1:10
            s(:, i+1:end, c) = s(:, i+1:end, c) + bleachEvents(:, 1:end-i, c);
        end
    end
    fb = s>1;
end
