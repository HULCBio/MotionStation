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

##       s = vrml_thick_surf (x, y, z [, options] )
##       s = vrml_thick_surf (z [, options] )
##
## Returns vrml97 code for a Shape -> IndexedFaceSet node representing a
## surface passing through the given points.
##
## The surface may look smoother than that returned by  vrml_surf,  but it
## has twice as many facets.
##
## x : RxC or C  : X coordinates of the points on the surface
## y : RxC or R  : Y "                                      "
## z : RxC       : Z "                                      "
##
## s :   string  : The code
##
## If x and y are omitted, they are assumed to be 1:C and 1:R, resp
## Points presenting one or more 'inf' or 'nan' coordinates are ignored.
##
## Options :
##
## "col" , col  : 3   : Color,                      default = [0.3,0.4,0.9]
##             or 3xP : color of vertices (vrml colorPerVertex is TRUE).
## 
## "tran", tran : 1x1 : Transparency,                           default = 0
##
## "creaseAngle", a 
##              :  1  : vrml creaseAngle value. The browser may smoothe the
##                      crease between facets whose angle is less than a.
##                                                              default = 0
## "smooth"           : same as "creaseAngle",pi.

function s = vrml_thick_surf (x, y, z, varargin)

				# Default values
tran = 0 ;
col = [0.3, 0.4, 0.9] ;
smooth = creaseAngle = nan ;
nargs = nargin();

if (nargs <= 1) || ischar(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  xx = ones(R,1)*[1:C] ;
  yy = [1:R]'*ones(1,C) ;
  if     nargs >=3,

    s = vrml_surf ( xx, yy, zz, y, z, varargin{:} );
    return
  elseif nargs >=2,

    s = vrml_surf ( xx, yy, zz, y, varargin{:} );
    return
  end
  x = xx ; y = yy ; z = zz ;
end

				# Read options
filename = "vrml_thick_surf" ;
verbose = 0 ;

if nargs > 3,

  opt1 = " tran col creaseAngle " ;
  opt0 = " smooth " ;

  nargs -= 3 ;

  read_options_old ;
end

if ! isnan (smooth), creaseAngle = pi ; end
[R,C] = size(z);
if any (size (x) == 1), x = ones(R,1)*x(:)' ; end
if any (size (y) == 1), y = y(:)*ones(1,C)  ; end

pts = [x(:)';y(:)';z(:)'];

keepp = all (!isnan(pts) & finite(pts)) ;

trgs = zeros(3,4*(R-1)*(C-1)) ;

tmp = 1:(R-1)*(C-1);

## Points are numbered as
##
## 1  R+1 .. (C-1)*R+1
## 2  R+2         :
## :   :          :
## R  2*R ..     C*R
##

## Triangles are numbered as :
## 
## X = (R-1)*(C-1)
## _______________________________
## |    /|    /|    /|    /|-R+1/|
## | 1 / |R+1/ |   / |   / |R*C/ |
## |  /  |  /  |  /  |  /  |  /  |
## | /X+1| /X+R| /   | /   | /   |
## |/    |/    |/    |/    |/    |
## -------------------------------
## |    /|    /|    /|    /|    /|
## | 2 / |R+2/ |   / |   / |   / |
## |  /  |  /  |  /  |  /  |  /  |
## | /   | /   | /   | /   | /   |
## |/    |/    |/    |/    |/    |
## -------------------------------
##    :           :           :
##    :           :           :
## -------------------------------
## |    /|    /|    /|    /|    /|
## | R / |2*R/ |   / |   / |C*R/ |
## |  /  |  /  |  /  |  /  |  /  |
## | /X+R| /   | /   | /   | /C*R|
## |/    |/    |/    |/    |/ X+ |
## -------------------------------

## (x,y), (x,y+1), (x+1,y)  i.e. n, n+1, n+R

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(3,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

## (x+1,y), (x,y+1), (x+1,y+1)  i.e. n+R, n+1, n+R+1
tmp += (R-1)*(C-1);

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(3,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

## (x,y), (x+1,y+1), (x+1,y)  i.e. n, n+1, n+R+1
tmp += (R-1)*(C-1);

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(2,tmp) = ([2:R  ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
trgs(3,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

## (x,y), (x,y+1), (x+1,y+1)  i.e. n, n+1, n+R+1
tmp += (R-1)*(C-1);

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(3,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';


if ! all(keepp),

  keept = all (reshape(keepp(trgs),3,4*(R-1)*(C-1)));
  ## keept = all (keepp(trgs)) ;
  keepip = find (keepp);
  keepit = find (keept);
  renum = cumsum (keepp);

  pts = pts (:,keepip) ;
  trgs = reshape(renum (trgs (:,keepit)), 3, columns(keepit));

end
s = vrml_faces (pts, trgs, "col", col, "tran", tran, "creaseAngle", creaseAngle);

## x=-1:0.1:1;y=(x=ones(columns(x),1)*x)';
## r = sqrt (x.^2+y.^2); c = cos(2*pi*r.^2)./(2+r.^2);
## Punch some holes
## holes = ind2sub (size (c), [7,7,9,10,15,16;8,9,10,11,14,14]')
## c(holes) = nan;
##    vrml_browse ("tmp.wrl",vrml_thick_surf (x, y, c))
## or save_vrml ("tmp.wrl", vrml_thick_surf (x, y, c)) 
endfunction

