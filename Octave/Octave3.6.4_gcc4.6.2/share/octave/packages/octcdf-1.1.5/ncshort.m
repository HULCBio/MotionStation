## Copyright (C) 2005 Alexander Barth
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Loadable Function} {@var{ncvar} = } ncshort(@var{dimname_1},...,@var{dimname_N})
## creates a netcdf variable of type ncshort. @var{dimname_1} is the name 
## of the 1st netcdf dimension, and so on. The return value is a netcdf
## variable object and must be affected to a netcdf file, before its content
## can be defined.
## 
## Example:
## @example
## nc = netcdf('test.nc','w');
## nc('lon') = 360;
## nc('lat') = 180;
## nc@{'var'@} =  ncshort('lon','lat');
## @end example
## A new 360 by 180 netcdf variable named 'var' of type short is 
## created in file 'test.nc'.
## @end deftypefn
## @seealso{netcdf}

## Author: Alexander Barth <barth.alexander@gmail.com>

function c = ncshort(varargin);

c = {'short' varargin{:}};

