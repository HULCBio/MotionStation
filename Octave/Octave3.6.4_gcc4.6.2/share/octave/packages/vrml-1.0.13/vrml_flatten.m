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

## s = vrml_flatten (x [, d, w, col]) - A planar surface containing x
##
## If the points  x  are not coplanar (or not in the affine plane {y|d'*y==w}),
## the surface will not contain the points, but rather their projections on
## the plane {y|d'*y==w}.
## 
## x   : 3 x P  : 3D points
## d   : 3      : normal to plane    | Default : given by best_dir()
## w   : 1      : intercept of plane |
## col : 3      : RGB color            Default : [0.3,0.4,0.9]
##
## s   : string : vrml code representing the planar surface

function s = vrml_flatten (x, d, w, col)


if     nargin <= 3 || isnan (col),  col = [0.3,0.4,0.9];  end
if     nargin <= 1 || isnan (d),    [d,w] = best_dir (x); 
elseif nargin <= 2 || isnan (w),    w = mean (d'*x); end
if   ! nargin,       error ("vrml_flatten : no arguments given"); end 

y = bound_convex (d,w,x);
Q = columns (y);
faces = [ones(1,Q-2); 2:Q-1; 3:Q];


s = vrml_faces (y, faces, "col",col);
endfunction

