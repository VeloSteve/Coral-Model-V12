function [oldPar] = updateIfGiven(oldPar, par)
    % isfield(Sim,'Date')
    fields = fieldnames(par);
    for i=1:numel(fields)
        oldPar.(fields{i}) = par.(fields{i});
    end
end
