function genotypeFigure(fullDir, suffix, k, time, gi, ssi)
    specs = {'-c', '-g', '-m', '-y', '--r', '--b'};

    f = figure(1000+k);
    plot(time, gi(:,1), specs{1}); %, gi(:,2)); %, gi(:,3), gi(:,4));
    hold on;
    plot(time, gi(:,2), specs{2});
    gi(1:ssi, 3) = NaN;
    gi(1:ssi, 4) = NaN;
    plot(time, gi(:,3), specs{3});
    plot(time, gi(:,4), specs{4});
    datetick('x', 'keeplimits');
    t = sprintf('Genotype history for reef %d', k);
    title(t);
    legend({'native, massive', 'native, branching', 'enhanced, massive', ...
        'enhanced, branching'}, 'Location', 'best');
    hold off;
    print(f, '-dpdf', '-r200', strcat(fullDir, 'GenotypeHistory', suffix, '.pdf'));
    savefig(f, strcat(fullDir, 'GenotypeHistory', suffix, '.fig'));
end