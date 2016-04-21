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
## @deftypefn {Function File} @var{str} =  ruledSurfGeo (@var{id}, @var{nloop}, @var{loops}, @var{centerid})
## Generates a string for Gmsh Ruled Surface format.
##
## Creates a ruled surface with identifier @var{id}, i.e., a surface that can be
## interpolated using transfinite interpolation. @var{nloop} indicates the number
## of loops that define the surface. @var{loops} should contain the identification
## number of a line loop composed of either three or four elementary lines.
## @var{centerid} is the identification number of the center of the sphere, this
## forces the surface to be a spherical patch.
##
## @end deftypefn

function str = ruledSurfGeo(id,nloop,loops,centerid)
    substr = repmat(',%d',1,nloop-1);

    if ~isempty(centerid)
        str = sprintf(['Ruled Surface(%d) = {%d' substr '} In Sphere {%d};\n'], ...
                                                                 id,loops,centerid);
    else
        error('data2geo:Error',"The id of the centers shouldn't be empty");
    end

end
