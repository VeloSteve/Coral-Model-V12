function whereIs(r, ESM2M_reefs_JD)
    size(ESM2M_reefs_JD)
    lat = ESM2M_reefs_JD(r,2);
    lon = ESM2M_reefs_JD(r,1)
    fprintf('For reef %d, Lat = %f, Lon = %f\n', r, lat, lon);
    ns = 'S';
    if lat >= 0
        ns = 'N';
    end
    ew = 'W';
    if lon >= 0
        ew = 'E';
    end
    fprintf("%5.2f%s %5.2f%s\n", abs(lat), ns, abs(lon), ew);

end