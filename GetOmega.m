function [Omega_all] = GetOmega(omegaPath, RCP)
    % Get Omega for a ALL reef grid cells
    % The regular expression expects the letters 'rcp' followed by 2-digit
    % number.  2.6, 4.5, 6.0, and 8.5 are valid.  Some others will be
    % incorrectly accepted, but most wrong values will be rejected.
    assert(regexp(RCP, 'rcp[2468][056]') == 1, 'Error: RCP value in GetOmega does not match an option.');
    load(strcat(omegaPath, 'Omega_', RCP, '.mat'),'Omega_all');
end