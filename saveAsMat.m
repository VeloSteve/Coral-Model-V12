function [] = saveAsMat( matName, C, S, time, temp)
%Attempt to save a mat file, which can't be done directly in a parfor loop.
    save(matName, 'C', 'S', 'time', 'temp');
end

