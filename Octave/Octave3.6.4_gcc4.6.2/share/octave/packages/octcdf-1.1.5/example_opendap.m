%% Copyright (C) 2005 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

% Example for loading a dataset from an OPeNDAP server

nc = netcdf('http://hycom.coaps.fsu.edu/thredds/dodsC/atl_ops','r');

lat = nc{'Latitude'}(:);
lon = nc{'Longitude'}(:);
time = nc{'MT'}(end);

disp(['SSH forecast for part of the North Atlantic for ' datestr(datenum(1900,12,31) + time)]);

%
% Select the SSH for part of the North Atlantic
% 

i = find(-92 < lon & lon < -51);
j = find(23 < lat & lat < 45);   

x = lon(i);
y = lat(j);

% download data

ssh = nc{'ssh'}(end,j,i);

fillval = nc{'ssh'}._FillValue;
ssh(ssh == fillval) = NaN;

% With autonan, i.e. every _FillValue is replaced by a NaN
% nv = ncautonan(nc{'ssh'},1);
% ssh = nv(end,j,i);

ssh = squeeze(ssh);

close(nc);

colormap(hsv);
axis xy
iamgesc(ssh); 

% or with yapso
% pcolor(ssh);

