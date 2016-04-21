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
## @deftypefn {Function File} @var{str} =  planeSurfGeo (@var{id}, @var{nloop},@var{loops})
## Generates a string for Gmsh Plane Surface format.
##
## @var{id} is the plane surface's identification number.
## @var{nloop} is the number of loops defining the surface.
## @var{loops} contain the identification numbers of all the line loops defining
## the surface. The first line loop defines the exterior boundary of the surface;
## all other line loops define holes in the surface. A line loop defining a hole
## should not have any lines in common with the exterior line loop (in which case
## it is not a hole, and the two surfaces should be defined separately).
## Likewise, a line loop defining a hole should not have any lines in common with
## another line loop defining a hole in the same surface (in which case the two
## line loops should be combined).
##
## @end deftypefn

function str = planeSurfGeo(id,nloop,loops)
    substr = repmat(',%d',1,nloop-1);
    str = sprintf(['Plane Surface(%d) = {%d' substr '};\n'],id,loops);
end
