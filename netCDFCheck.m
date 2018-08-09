ncid = netcdf.open("C:\Users\Steve\Google Drive\_Library Methods\tos_Omon_GFDL-ESM2M_rcp45_r1i1p1_200601-201012.nc")
netcdf.inqVar(ncid, 0)
ncdisp('C:\Users\Steve\Google Drive\_Library Methods\tos_Omon_GFDL-ESM2M_rcp45_r1i1p1_200601-201012.nc')

%tos = netcdf.getVar(ncid,5)
tosByName = ncread('C:\Users\Steve\Google Drive\_Library Methods\tos_Omon_GFDL-ESM2M_rcp45_r1i1p1_200601-201012.nc', 'tos');
tos_mid = tosByName(180, 100, :);
time = ncread('C:\Users\Steve\Google Drive\_Library Methods\tos_Omon_GFDL-ESM2M_rcp45_r1i1p1_200601-201012.nc', 'time');
tos = squeeze(tos_mid);
tosC = tos - 273.15
yr = time/365+2006;

plot(yr, tosC);

% Repeat with a new plot at high latitude
tos_hi = tosByName(180, 15, :);
tos_1D = squeeze(tos_hi);
tos_1DC = tos_1D - 273.15

plot(yr, tos_1DC);