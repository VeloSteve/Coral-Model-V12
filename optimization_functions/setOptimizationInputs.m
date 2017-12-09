function [possible] = setOptimizationInputs(index, possible, steps)
    % each entry in "possible" has these fields:
    % 1 - name, not used here
    % 2 - min
    % 3 - max
    % 4 - range
    % 5 - new value - keep as default if steps=1
    for i = 1:4
        v = possible{i};
        if steps(i) > 1
            v{5} = v{2} + (index(i)-1)*v{4}/(steps(i)-1);
        end
        possible{i} = v;
    end
    %{
    for i = 1:4
        v = possible{i};
        if steps(i) > 1
            inputSet(i) = v.min + (index(i)-1)*v.range/(steps(i)-1);
        else
            inputSet(i) = v.min;
        end
    end
    %}
end