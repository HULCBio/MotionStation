## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
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

##       v = vrml_ellipsoid (moment, col) - Ellipsoid 
##
## moment : 3x3 : Define elipsoid by x'*moment*x = 1
##  or      3   :  use diag(moment)
##  or      1   :  use diag(moment([1,1,1]))   default : eye(3)
##
## col    : 3   : Color                        default : [0.3 0.4 0.9]
##

function v = vrml_ellipsoid(moment, col)


if nargin<2  || isempty (col) || isnan (col), col = [0.3 0.4 0.9];
else
  error ("vrml_ellipsoid : col has size %d x %d. This won't do\n",size(col));
  ## keyboard
end
col = col' ;


if nargin<1 || isempty (moment),  moment = eye(3),
elseif all (size (moment) == 3), # Do nothing
elseif prod( size (moment)) == 3, moment = diag (moment);
elseif length (moment) == 1,      moment = moment*eye(3);
else 
  error ("vrml_ellipsoid : moment has size %d x %d. This won't do\n",size(moment));
  ## keyboard
end

[u,d,v] = svd (moment);
d = diag(d);
d(find(d)) = 1 ./ nze (d) ;

[r,a] = rotparams (u');

v = sprintf (["Transform {\n",\
              "  translation  0 0 0\n",\
	      "  rotation     %8.3g %8.3g %8.3g %8.3g\n",\
	      "  scale        %8.3g %8.3g %8.3g\n",\
              "  children [\n",\
              "    Shape {\n",\
              "      appearance  Appearance {\n",\
              "        material Material {\n",\
	      "          diffuseColor  %8.3g %8.3g %8.3g\n",\
	      "          emissiveColor %8.3g %8.3g %8.3g\n",\
	      "        }\n",\
              "      }\n",\
              "      geometry Sphere {}\n",\
              "    }\n",\
              "  ]\n",\
              "}\n",\
              ],\
	     r,a,\
	     d,\
	     col,\
	     col/20);

endfunction
## Example
## d0 = sort (1+2*rand(1,3));
## d0 = 1:3;
## rv = randn (1,3); 
## uu = rotv (rv);
## dd = diag (1./d0);
## mm = uu*dd*uu';
## vrml_browse ([vrml_frame ([0,0,0],uu',"col",eye(3),"scale",2*d0), vrml_ellipsoid(mm)]);
