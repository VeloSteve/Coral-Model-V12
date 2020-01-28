function [psw2] = compute_psw2(pswInputs, sst)

    %% PROPORTIONALITY CONSTANT CALCULATIONS this grid cell.
    % By doing this in a function rather than reading from a file we remove the
    % change that a set of psw2 inputs is used with the wrong SST data.
    % E = exp(0.063.*SSThistReef)
    % max(pMin,min(pMax,(mean(E)./var(E)).^exponent/divisor))
    psw2 = max(pswInputs(1),min(pswInputs(2),(mean(exp(0.063.*sst))./var(exp(0.063.*sst))).^pswInputs(3)/pswInputs(4)));
end