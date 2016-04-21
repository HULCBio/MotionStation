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
## @deftypefn {Function File} @var{str} = lineGeo (@var{n}, @var{pi}, @var{pj})
## Generates a string for Gmsh Line format.
##
## Curves are Gmsh's second type of elementery entities, and,
## amongst curves, straight lines are the simplest. A straight line is
## defined by a list of point numbers. The initial point @var{pi}, the final
## point @var{pj}. @var{n} is an indetifier for the line.
##
## @end deftypefn

function str = lineGeo(n,i,j)
    str = sprintf('Line(%d) = {%d,%d};\n',n,i,j);
end
