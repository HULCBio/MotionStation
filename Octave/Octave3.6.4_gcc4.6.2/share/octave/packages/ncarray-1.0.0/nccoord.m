% Coordinates of a NetCDF variable.
%
% coord = nccoord(filename,varname)
% get coordinates of the variable varname in the
% netcdf file called filename. The netcdf is assumed to 
% follow the CF convention.
% coord is an array of structures with the field 'name'
% for the variable name and 'dims' with a cell-array of the
% netcdf dimensions.

% Author: Alexander Barth (barth.alexander@gmail.com)

function [dims,coord] = nccoord(filename,varname)

finfo = ncinfo(filename);
vinfo = ncinfo(filename,varname);

% determine coordinates
% using CF convention

dims = vinfo.Dimensions;

% create empty coord array with the fields name and dims
coord = struct('name',{},'dims',{});

% check the coordinate attribute
index = strmatch('coordinates',{vinfo.Attributes(:).Name});
if ~isempty(index)
    tmp = strsplit(vinfo.Attributes(index).Value,' ');
    
    for i=1:length(tmp)
        coord = addcoord(coord,tmp{i},finfo);
    end
end

% check for coordinate dimensions
for i=1:length(dims)
    % check if variable with the same name than the dimension exist
    index = strmatch(dims{i},{finfo.Variables(:).Name});
    if ~isempty(index)
        coord = addcoord(coord,dims{i},finfo);
    end
end


end

function coord = addcoord(coord,name,finfo)

% check if coordinate is aleady in the list
if isempty(strmatch(name,{coord(:).name}))
    
    % check if name is variable
    index = strmatch(name,{finfo.Variables(:).Name});
    if ~isempty(index)
        c.name = name;
        c.dims = finfo.Variables(index).Dimensions;
        
        coord(end+1) = c;
    end
end

end


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

