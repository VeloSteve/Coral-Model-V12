function [ output_args ] = ProgressUpdater( bar, w, v )
    % Update the progress bar base on one of the parallel sets.
    % After testing, expand to multiple bars, one per set.
    fn = strcat('gui_scratch/Prog_', num2str(w));
    if nargin == 3
        bar.Value = v;
        if v == 0
                pf = fopen(fn, 'w');
                fprintf(pf, '%d', 0);
                fclose(pf);
        end
    else
        data = csvread(fn);
        bar.Value = data;
    end
    

end

