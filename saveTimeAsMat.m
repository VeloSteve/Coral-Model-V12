function [] = saveTimeAsMat( matName, time)
%Attempt to save a mat file, which can't be done directly in a parfor loop.
    save(matName, 'time');
end

