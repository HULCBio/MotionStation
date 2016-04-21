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
## @deftypefn {Function File} @var{str} =  lineLoopGeo (@var{id}, @var{nl}, @var{lns})
## Generates a string for Gmsh Line Loop format.
##
## The third elementary entity is the surface. In order to define a
## simple rectangular surface from defined lines, a
## line loop has first to be defined. A line loop is a list of
## connected lines, a sign being associated with each line (depending
## on the orientation of the line). @var{id} is an indentifier for the loop.
## @var{nl} is the number of lines in the loop. @var{lns} is the list of lines.
##
## @end deftypefn

function str = lineLoopGeo(id,nl,lns)
    substr = repmat(',%d',1,nl-1);
    str = sprintf(['Line Loop(%d) = {%d' substr '};\n'],id,lns);
end
