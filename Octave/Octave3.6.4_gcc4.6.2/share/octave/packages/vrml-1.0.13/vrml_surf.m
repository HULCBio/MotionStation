## Copyright (C) 2002-2009 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_surf (x, y, z [, options] ) - code for a VRML surface
## s = vrml_surf (z [, options] )
##
## Returns vrml97 code for a Shape -> IndexedFaceSet node representing a
## surface passing through the given points.
##
## x : RxC or C  : X coordinates of the points on the surface
## y : RxC or R  : Y "                                      "
## z : RxC       : Z "                                      "
##
## s :   string  : The code
##
## If x and y are omitted, they are assumed to be linspace(-1,1,C or R).
## Points presenting one or more 'inf' or 'nan' coordinates are ignored.
##
## Options :
##
## "col" , col  : 3      : RGB Color,                default = [0.3,0.4,0.9]
##             or 3x(R*C): Color of vertices (vrml colorPerVertex is TRUE).
##             or 3x((R-1)*(C-1))
##                       : Color of facets
##             or 1      : Reflectivity (equivalent to [col,col,col] in RGB)
##             or R x C  : Reflectivity of vertices
##             or 1x(R*C)
##             or (R-1)x(C-1)
##             or (R-1)*(C-1)
##                       : Reflectivity of facets.
##
##        RGB and reflectivity values should be in the [0,1] interval.
##
## "checker", c : 1x2 : Color as a checker. If c(1) is positive, checker has
##            c(1) rows. If it is negative, each checker row is c(1) facets
##            high c(2) likewise determines width of checker columns.
## "checker", c : 1x1 : Same as [c,c].
##
## "zcol", zc   : 3xN : Specify a colormap. The color of each vertex is
##            interpolated according to its height (z).
##
## "zgray"      : Black-to-white colormap. Same as "zcol", [0 1;0 1;0 1].
##
## "zrb"        : Red-to-blue. Same as "zcol", [0 7 10;0 0 2;7 19 2]/10.
##
## "steps"      : Represent surface as a piecewise constant Z = f(X,Y) function
##
## "bars"       : Represent surface as a bar plot
##
## "tran", tran : 1x1    : Transparency,                        default = 0
##
## "creaseAngle", a
##              : 1      : vrml creaseAngle The browser may smoothe the fold
##                         between facets forming an angle less than a.
##                                                              default = 0
## "smooth"           : same as "creaseAngle",pi.
## "tex", texFile 
##
## See also: vmesh(), vrml_faces(), test_moving_surf()

function s = vrml_surf (x, y, z,varargin)

if (nargin <= 1) || ischar(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));
  ## ones(R,1)*[1:C] ;
  ## yy = ## [1:R]'*ones(1,C) ;
  ##if     nargin >=3,
  ##  s = vrml_surf ( xx, yy, zz, y, z, varargin{:} );
  ##  return
  ##elseif nargin >=2,
  ##  s = vrml_surf ( xx, yy, zz, y, varargin{:} );
  ##  return
  ##end
  if nargin >= 3
    varargin = {y, z, varargin{:}};
  elseif nargin >= 2
    varargin = {y, varargin{:}};
  end

  x = xx ; y = yy ; z = zz ;
end

defaultCol = [0.3; 0.4; 0.9];

				# Read options
				# Default values

upper = 1;			# Do "upper" triangulation of square grid
tran = 0 ;			# Transparency
col = defaultCol ;		# Color
checker = 0;			# Checkered coloring
colorPerVertex = 1;		# Color vertices or faces
zrb = zgray = zcol = 0;		# Color by elevation
emit = 0;			# emissiveColor or diffuse only
smooth = creaseAngle = nan ;
steps = 0;
bars = 0;
tex = 0;
bwid = -1;
DEFcoord = DEFcol = "";		# Give a name to VRML objects

if numel (varargin)

  op1 = " tran col creaseAngle emit colorPerVertex checker DEFcoord DEFcol zcol bwid tex ";
  op0 = " smooth zgray zrb steps bars " ;

  default = tars (tran, col, creaseAngle, emit, colorPerVertex, steps, bars, \
		  bwid, DEFcoord, DEFcol, zcol, smooth, checker, zgray, zrb, tex);

  s = read_options (varargin,"op0",op0,"op1",op1,"default",default);
  
  tran=            s.tran;
  col=             s.col;
  creaseAngle=     s.creaseAngle;
  emit=            s.emit;
  colorPerVertex=  s.colorPerVertex;
  DEFcoord=        s.DEFcoord;
  DEFcol=          s.DEFcol;
  zcol=            s.zcol;
  smooth=          s.smooth;
  steps=           s.steps;
  bars=            s.bars;
  bwid=            s.bwid;
  tex=             s.tex;
  if bwid >= 0
    bars = 1;
  end
  checker=         s.checker;
  zgray=           s.zgray;
  zrb=             s.zrb;
end
## keyboard
if ! isnan (smooth), creaseAngle = pi ; end

[R,C] = size(z);
if any (size (x) == 1), x = ones(R,1)*x(:)' ; end
if any (size (y) == 1), y = y(:)*ones(1,C)  ; end

if bars

  if  bwid < 0
    bwid = 2/3;
  end
  brad = bwid/2;

  R4 = 4*R;
  C4 = 4*C;
  x2 = y2 = z2 = zeros (R4,C4);

  x2(:,1) = x2(:,2) = kron ((1+brad)*x(:,1) - brad*x(:,2), [1;1;1;1]);
  x2(:,C4-1) = x2(:,C4) = kron ((1+brad)*x(:,C) - brad*x(:,C-1), [1;1;1;1]);
  x2(:,5:4:C4) =  x2(:,6:4:C4) = kron ((1-brad)*x(:,2:C) + brad*x(:,1:C-1), [1;1;1;1]);
  x2(:,3:4:C4-4) =  x2(:,4:4:C4-4) = kron ((1-brad)*x(:,1:C-1)+brad*x(:,2:C), [1;1;1;1]);

  y2(1,:) = y2(2,:) = kron ((1+brad)*y(1,:) - brad*y(2,:), [1 1 1 1]);
  y2(R4-1,:) = y2(R4,:) = kron ((1+brad)*y(R,:) - brad*y(R-1,:), [1 1 1 1]);
  y2(5:4:R4,:) =  y2(6:4:R4,:) = kron ((1-brad)*y(2:R,:) + brad*y(1:R-1,:), [1 1 1 1]);
  y2(3:4:R4-4,:) =  y2(4:4:R4-4,:) = kron ((1-brad)*y(1:R-1,:) + brad*y(2:R,:), [1 1 1 1]);
  
  z2([2:4:R4;3:4:R4],[2:4:C4;3:4:C4]) = kron(z,ones(2));

  x = x2;
  y = y2;
  z = z2;
  R = R4;
  C = C4;

  if numel (size (col)) == 2 && all (size (col) == size (defaultCol)) && all (col == defaultCol)
    col = [col, 0.8*col, 0.9*col];
  end
  if numel (col) == 3
    col = col(:);
    topCol = col;
    botCol = col;
    sideCol = [col,col,col,col];
  elseif numel (col) == 6
    col = col(:);
    topCol = col(1:3);
    botCol = col(1:3);
    sideCol = col(4:6)*ones(1,4);
  elseif numel (col) == 9
    col = col(:);
    topCol = col(1:3);
    botCol = col(7:9);
    sideCol = col(4:6)*ones(1,4);
  end
  col = ones(3, R-1, C-1);
  for i=1:3
    col(i,2:4:R-1,2:4:C-1) = topCol(i);
    col(i,4:4:R-1,:) = botCol(i);
    col(i,:,4:4:C-1) = botCol(i);
    col(i,3:4:R-1,2:4:C-1) = sideCol(i,1);
    col(i,2:4:R-1,1:4:C-1) = sideCol(i,2);
    col(i,1:4:R-1,2:4:C-1) = sideCol(i,3);
    col(i,2:4:R-1,3:4:C-1) = sideCol(i,2);
  end    
  iOnFloor = find (! z(1:R-1,1:C-1));
  if ! isempty (iOnFloor)
    ## keyboard
    col(3*(iOnFloor-1)+1) = botCol(1);
    col(3*(iOnFloor-1)+2) = botCol(2);
    col(3*(iOnFloor-1)+3) = botCol(3);
  end

elseif steps			# Constant by parts

				# Intermediate coordinates  (R+1) x (C+1)
  x2 = (x([1,1:R],[1,1:C]) + x([1,1:R],[1:C,C])) / 2; 
  y2 = (y([1,1:R],[1:C,C]) + y([1:R,R],[1:C,C])) / 2;  

				# Extend extremities so all patches have same size
  x2(1,:) = 2*x2(1,:) - x2(2,:); 
  x2(:,1) = 2*x2(:,1) - x2(:,2); 
  x2(R+1,:) = 2*x2(R+1,:) - x2(R,:);
  x2(:,C+1) = 2*x2(:,C+1) - x2(:,C); 

  y2(1,:) = 2*y2(1,:) - y2(2,:); 
  y2(:,1) = 2*y2(:,1) - y2(:,2); 
  y2(R+1,:) = 2*y2(R+1,:) - y2(R,:);
  y2(:,C+1) = 2*y2(:,C+1) - y2(:,C); 

				# Duplicate intermediate values 2R x 2C
  ii = [1,([1;1]*(2:R))(:)',R+1];
  jj = [1,([1;1]*(2:C))(:)',C+1];

  x2 = x2(ii,jj);
  y2 = y2(ii,jj);

  z2 = z([1;1]*(1:R),[1;1]*(1:C));;
  x = x2;
  y = y2;
  z = z2;

  if checker
    col = checker_color (checker, col, 2*R,2*C);
  end
  if numel (col) == R*C
    col = [1;1;1]*col(:)';
  end
  if numel (col) == 3*R*C
    col = reshape (col, 3,R,C);
    col2 = zeros (3,2*R-1,2*C-1);
    col2(1,:,:) = defaultCol(1);
    col2(2,:,:) = defaultCol(2);
    col2(3,:,:) = defaultCol(3);
    col2(:,1:2:end,1:2:end) = col;
    col = reshape (col2,3,(2*R-1)*(2*C-1));
  end

  R *= 2;
  C *= 2;
end

pts = [x(:)';y(:)';z(:)'];

keepp = all (!isnan(pts) & finite(pts)) ;
keepip = find (keepp);
if tex
  [texX,texY] = meshgrid (linspace (0,1,C), linspace (0,1,R));
  texXY = [texX(:)'; texY(:)'];
end

trgs = zeros(3,2*(R-1)*(C-1)) ;

## Points are numbered as
##
## 1  R+1 .. (C-1)*R+1
## 2  R+2         :
## :   :          :
## R  2*R ..     C*R
##


## (x,y), (x,y+1), (x+1,y)  i.e. n, n+1, n+R

if !upper			# Do regular triangulation
  ## Triangles are numbered as :
  ##
  ## X = (R-1)*(C-1)
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|-R+1/|
  ## | 1 / | R / |   / |   / |R*C/ |
  ## |  /  |  /  |  /  |  /  |  /  |
  ## | /X+1| /X+R| /   | /   | /   |
  ## |/    |/    |/    |/    |/    |
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|    /|
  ## | 2 / |R+2/ |   / |   / |   / |
  ## |  /  |  /  |  /  |  /  |  /  |
  ## | /   | /   | /   | /   | /   |
  ## |/    |/    |/    |/    |/    |
  ## +-----+-----+-----+-----+-----+
  ##    :           :           :
  ##    :           :           :
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|    /|
  ## |R-1/ |2*R/ |   / |   / |C*R/ |
  ## |  /  |-1/  |  /  |  /  |  /  |
  ## | /X+R| /   | /   | /   | /C*R|
  ## |/    |/    |/    |/    |/ X+ |
  ## +-----+-----+-----+-----+-----+
  
  tmp = 1:(R-1)*(C-1);

  trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(3,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
  
  tmp += (R-1)*(C-1);
  
  trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
  trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(3,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

else				# Do "upper" triangulation
  
  ##  Each triangle is      +-----+     +-----+
  ##  the highest of either |    /| or  |\    |
  ##                  	    |   / |     | \   |
  ##                  	    |  /  |     |  \  |
  ##                  	    | /   |     |   \ |
  ##                  	    |/    |     |    \|
  ##                        +-----+     +-----+


  tmp = 1:(R-1)*(C-1);
  tmp2 = reshape(1:R*C,R,C);
  foo1 = z(1:R-1,1:C-1) + z(2:R,2:C);
  foo2 = z(2:R,1:C-1) + z(1:R-1,2:C);
  tmp3 = (!isnan(foo1) & (isnan (foo2) | foo1 > foo2))(:)';

  trgs(1,tmp) = tmp2(1:R-1,1:C-1)(:)';
  trgs(2,tmp) = tmp2(2:R,1:C-1)(:)';
  trgs(3,tmp) = trgs(1,tmp) + R + tmp3 ;
  tmp += (R-1)*(C-1);
  trgs(1,tmp) = tmp2(1:R-1,2:C)(:)';
  trgs(2,tmp) = tmp2(2:R,2:C)(:)';
  trgs(3,tmp) = trgs(1,tmp) - R + 1 - tmp3 ;
end				# EOF "upper" triangulation

#trgs = trgs(:,find(rem(1:R-1,2)'*rem(1:C-1,2)));


if length (col) == 1		# Convert graylevel to RGB
  col = [1 1 1]*col;

elseif any (prod (size (col)) == [R*C,(R-1)*(C-1)])
  col = [1;1;1]*col(:)';
end

if zgray || zrb || any (zcol(:)) # Treat zgray zrb and zcol options
  zx = max (z(keepip));
  zn = min (z(keepip));
  if     zgray, zcol = [0 0 0; 1 1 1]';
  elseif zrb  , zcol = [0 0 0.7; 0.5 0 0.8; 1 0 0]';
  end

  ci = 1 + floor (cw = (columns (zcol)-1) * (z(keepip) - zn)/(zx - zn));
  cw =  cw - ci + 1;
  ii = find (ci >= columns (zcol));
  if ! isempty (ii), ci(ii) = columns (zcol) - 1; cw(ii) = 1; end
  col = zeros (3,R*C);
  col(:,keepip) = \
      zcol(:,ci) .* ([1;1;1]*(1-cw)) + zcol(:,ci+1) .* ([1;1;1]*cw);

end				# EOF zgray zrb and zcol options


if checker && numel (col) <= 6
  if isnan (checker), checker = 10; end
  if length (checker) == 1, checker = [checker, checker]; end
  
  col = checker_color (checker, col, R,C);

  if 0
    if checker(1) > 0, checker(1) = - (C-1)/checker(1); end
    if checker(2) > 0, checker(2) = - (R-1)/checker(2); end
    
    checker *= -1;
    colx = 2 * (rem (0:C-2,2*checker(1)) < checker(1)) - 1;
    coly = 2 * (rem (0:R-2,2*checker(2)) < checker(2)) - 1;
    icol = 1 + ((coly'*colx) > 0);
				# Keep at most 1st 2 colors of col for the
				# checker
    if prod (size (col)) == 2,
      col = [1;1;1]*col;
    elseif  prod (size (col)) < 6, # Can't be < 3 because of previous code
      col = col(1:3)(:);
      if all (col >= 1-eps), col = [col [0;0;0]];	# Black and White
      else                   col = [col [1;1;1]];	# X and White
      end
    end
    col = reshape (col(:),3,2);
    col = col(:,icol);
  end
end				# EOF if checker


if prod (size (col)) == 3*(R-1)*(C-1),
  colorPerVertex = 0;
end

if ! colorPerVertex
  if prod (size (col)) == 3*(R-1)*(C-1)
    col = reshape (col,3, (R-1)*(C-1));
    col = [col, col];
  else
    printf(["vrml_surf : ",\
	    " colorPerVertex==0, (R-1)*(C-1)==%i, but col has size [%i,%i]\n"],\
     R*C,size (col));
  end

end

if ! all(keepp),

				# Try to toggle some triangles to fill in
				# holes
  if ! upper
    nt = (R-1)*(C-1) ;
    tmp = ! reshape(keepp(trgs),3,2*nt);
    tmp = all( tmp == kron([0,0;0,1;1,0],ones(1,nt)) );
    trgs(3,     find (    tmp(1:nt)   & rem (trgs(3,1:nt),R)) )++ ;
    trgs(2, nt+ find ( tmp(nt+1:2*nt) & (rem (trgs(3,nt+1:2*nt),R)!=1)) )-- ;
    
				# Remove whatever can't be kept
    keept = all (reshape(keepp(trgs),3,2*(R-1)*(C-1)));
  else
    tmp = reshape (keepp,R,C);
    keept = \
	all (reshape (tmp(trgs(1:2,:)),2,2*(R-1)*(C-1))) & \
	[(tmp(1:R-1,2:C) | tmp(2:R,2:C))(:)', \
	 (tmp(1:R-1,1:C-1) | tmp(2:R,1:C-1))(:)'] ;
  end

  keepit = find (keept);

  renum = cumsum (keepp);

  pts = pts (:,keepip);
  trgs = reshape(renum (trgs (:,keepit)), 3, columns(keepit));

  if prod (size (col)) == 6*(R-1)*(C-1)	
    col = col(:,keepit);
				# Coherence check : colorPerVertex == 0
    if colorPerVertex
      error ("Col has size 3*(R-1)*(C-1), but colorPerVertex == 1");
    end

  elseif prod (size (col)) == 3*R*C 
    col = col(:,keepip);

				# Coherence check : colorPerVertex == 1
    if ! colorPerVertex
      error ("Col has size 3*R*C, but colorPerVertex == 0");
    end
  end

end
## printf ("Calling vrml_faces\n");
if !tex
  s = vrml_faces (pts, trgs, "col", col,\
		  "colorPerVertex",colorPerVertex,\
		  "creaseAngle", creaseAngle,\
		  "tran", tran, "emit", emit,\
		  "DEFcoord",DEFcoord,"DEFcol",DEFcol);
else
   texXY = texXY(:,keepip);
#   texXY(:,[1:5,232:236])
#   pts(:,[1:5,232:236])
#   trgs(:,1:20)
#  [texXY;  pts]
#  trgs
#  texXY(:,trgs(:))
#   R, C
#  keyboard
  s = vrml_faces (pts, trgs,\
		  "tran", tran, "tex", tex, "tcoord", texXY,\
		  "DEFcoord",DEFcoord,"DEFcol",DEFcol);
end  
## printf ("Done\n");
## R=5; C=11;
## x = ones(R,1)*[1:C]; y = [1:R]'*ones(1,C);
## zz = z = sin(x)+(2*y/R-1).^2 ;
## ## Punch some holes
## holes = ind2sub ([R,C],[3,3,3,1,2,3,2,3;1,2,3,5,7,7,9,10]')
## z(holes) = nan
## save_vrml("tmp.wrl",vrml_surf(x,y,z+1))
## save_vrml("tmp.wrl",vrml_surf(z,"col",[0.5,0,0],"tran",0.5),vrml_surf(z+1))

endfunction

