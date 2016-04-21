function ncarray_example_file(filename,data)

nc = netcdf(filename,'c');

% dimensions

nc('x') = size(data,1);
nc('y') = size(data,2);
nc('time') = size(data,3);

% variables

nc{'lon'} = ncfloat('y','x');  % 31680 elements 
nc{'lon'}.long_name = ncchar('Longitude');
nc{'lon'}.units = ncchar('degrees_east');

nc{'lat'} = ncfloat('y','x');  % 31680 elements 
nc{'lat'}.long_name = ncchar('Latitude');
nc{'lat'}.units = ncchar('degrees_north');

nc{'time'} = ncfloat('time');  % 1 elements 
nc{'time'}.long_name = ncchar('Time');
nc{'time'}.units = ncchar('days since 1858-11-17 00:00:00 GMT');

nc{'SST'} = ncfloat('time','y','x');  % 31680 elements 
nc{'SST'}.missing_value = ncfloat(9999);
nc{'SST'}.FillValue_ = ncfloat(9999);
nc{'SST'}.units = ncchar('degC');
nc{'SST'}.long_name = ncchar('Sea Surface Temperature');
nc{'SST'}.coordinates = ncchar('lat lon');

% global attributes

nc{'SST'}(:) = permute(data,[3 2 1]);
close(nc)


% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

