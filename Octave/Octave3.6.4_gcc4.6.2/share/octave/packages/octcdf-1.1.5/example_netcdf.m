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

% Example for creating and reading a netcdf file


% create some variables to store them in a netcdf file

latitude = -90:1:90;
longitude = -179:1:180;
[y,x] = meshgrid(pi/180 * latitude,pi/180 * longitude);
temp = cos(2*x) .* cos(y);

%---------------------------------------%
%                                       %
% write data to a netcdf file           %
%                                       %
%---------------------------------------%

% create netcdf file called example.nc

nc = netcdf('example.nc','c');

% define the dimension longitude and latitude of size
% 360 and 181 respectively.

nc('longitude') = 360;
nc('latitude') = 181;

% coordinate variable longitude

nc{'longitude'} = ncdouble('longitude');              % create a variable longitude of type double with 
                                                      % 360 elements (dimension longitude).
nc{'longitude'}(:) = longitude;                       % store the octave variable longitude in the netcdf file
nc{'longitude'}.units = 'degrees_east';                % define a string attribute of the variable longitude

% coordinate variable latitude

nc{'latitude'} = ncdouble('latitude');;               % create a variable latitude of type double with 
                                                      % 181 elements (dimension latitude).                
nc{'latitude'}(:) = latitude;                         % store the octave variable latitude in the netcdf file
nc{'latitude'}.units = 'degrees_north';                % define a string attribute of the variable latitude

% variable temp

nc{'temp'} = ncdouble('latitude','longitude');        % create a variable temp of type double of the size 360x181 
                                                      % (dimension longitude and latitude).    
nc{'temp'}(:) = temp;                                 % store the octave variable temp in the netcdf file
nc{'temp'}.long_name = 'Temperature';                 
nc{'temp'}.units = 'degree Celsius';                  % define a string attribute of the variable
nc{'temp'}.valid_range = [-10 40];                    % define a vector of doubles attribute of the variable

                                                      % define a global string attribute
nc.history = 'netcdf file created by example_netcdf.m in octave';
nc.title = 'sample file';

close(nc)                                             % close netcdf file and all changes are written to disk


disp(['example.nc file created. You might now inspect this file with the shell command "ncdump -h example.nc"']);


%---------------------------------------%
%                                       %
% read data from a netcdf file          %
%                                       %
%---------------------------------------%

nc = netcdf('example.nc','r');                       % open netcdf file example.nc in read-only

n = nc('longitude');                                 % get the length of the dimension longitude

temp = nc{'temp'}(:);                                % retrieve the netcdf variable temp
temp_units = nc{'temp'}.units;                       % retrieve the attribute units of variable temp
temp_valid_range = nc{'temp'}.valid_range;           % retrieve the attribute valid_range of variable temp

global_history = nc.history;                         % retrieve the global attribute history
