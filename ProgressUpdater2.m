function [ ] = ProgressUpdater2( ax, nw, v )
    % Update the progress bar base on one of the parallel sets.
    % After testing, expand to multiple bars, one per set.
    vals = zeros(1, nw);
    x = zeros(1, nw);
    for i = 1:nw
        x(i) = i;
        fn = strcat('gui_scratch/Prog_', num2str(i));
        if nargin == 3
            vals(i) = v;
            if v == 0
                    pf = fopen(fn, 'w');
                    fprintf(pf, '%d', 0);
                    fclose(pf);
            end
        else
            data = csvread(fn);
            vals(i) = data;
        end
    end
    %fprintf('nargin = %d, nw = %d, vals(1) = %d\n', nargin, nw, vals(1));
    bar(ax, x, vals);
    % ticks change and need to be reset here!
    ax.XTick = 0:nw+1;

    pause(0.1);

end

