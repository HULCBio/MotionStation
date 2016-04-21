% Create an array that represent a concatenated NetCDF variables.
%
% C = ncCatArray(dim,filenames,varname)
% C = ncCatArray(dim,pattern,varname)
% C = ncCatArray(dim,filenamefun,varname,range)
%
% create a concatenated array from variables (varname) in a list of
% netcdf files along dimension dim.Individual elements can be accessed by
% subscribs, e.g. C(2,3) and the corrsponding subset of the appropriate file is loaded
%
% This list of netcdf files can be specified as a cell array (filenames),
% shell wildcard pattern (e.g. file_*.nc) or a function handle
% filenamefun. In this later case, this i-th filename is
% filenamefun(range(i)).
%
% Example:
%
% data = ncCatArray(3,{'file-20120708.nc','file-20120709.nc'},'SST')
%
% data = ncCatArray(3,'file-*.nc','SST')
%
% data = ncCatArray(3,@(t) ['file-' datestr(t,'yyyymmdd') '.nc'],...
%              datenum(2012,07,08):datenum(2012,07,09));
%
% Note: in Octave the glob function is used to determine files matching the
% shell wildcard pattern, while in Matlab rdir is used. The function rdir
% is available from Matlab exchange under BSD license
% (http://www.mathworks.com/matlabcentral/fileexchange/19550).
%
% see also cache_decompress, ncArray
% Web: http://modb.oce.ulg.ac.be/mediawiki/index.php/ncArray

% Author: Alexander Barth (barth.alexander@gmail.com)
%
function data = ncCatArray(dim,pattern,varname,range)

catdimname = '_cat_dim';

if iscell(pattern)
    filenames = pattern;
    
elseif ischar(pattern)
    try
        filenames = glob(pattern);
    catch
        try
            d = rdir(pattern);
            filenames = {d(:).name};
        catch
            error(['The function rdir or glob (octave) is not available. '...
                'rdir can be installed from '...
                'http://www.mathworks.com/matlabcentral/fileexchange/19550']);
        end
    end
elseif isa(pattern, 'function_handle')
    filenames = cell(1,length(range));
    
    for i=1:length(range)
        filenames{i} = pattern(range(i));
    end
end

if nargin == 3
    range = 1:length(filenames);
end

var = arr(dim,filenames,varname);

[dims,coord] = nccoord(cached_decompress(filenames{1}),varname);

if dim > length(dims)
    % concatenate is new dimension
    dims{dim} = catdimname;
    coord(dim).dims = {catdimname};
    coord(dim).val = range;
end


for i=1:length(coord)
    % coordinates do also depend on the dimension only which we concatenate
    coord(i).val = arr(dim,filenames,coord(i).name);
    if dim > length(coord(i).dims)
        coord(i).dims{dim} = catdimname;
    end
end

data = ncArray(var,dims,coord);

end


function CA = arr(dim,filenames,varname)
arrays = cell(1,length(filenames));
for i=1:length(filenames)
    arrays{i} = ncBaseArray(filenames{i},varname);
end

CA = CatArray(dim,arrays);
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

