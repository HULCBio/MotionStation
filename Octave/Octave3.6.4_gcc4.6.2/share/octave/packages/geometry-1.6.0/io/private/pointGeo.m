## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{str} =  poointGeo (@var{n}, @var{xyz}, @var{l})
## Generates a string for Gmsh Point format.
##
## Gmsh's simplest `elementary entity', a `Point'. A Point is defined by a list
## of five numbers: @var{n} the identificator, @var{xyz} three coordinates (X, Y
## and Z), and a characteristic length @var{l} that sets the target element size
## at the point:
## The distribution of the mesh element sizes is then obtained by
## interpolation of these characteristic lengths throughout the
## geometry.
##
## @end deftypefn

function str = pointGeo(n,xyz,l)
    str = sprintf('Point(%d) = {%.16g,%.16g,%.16g,%.16g};\n',n,xyz,l);
end
