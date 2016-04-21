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

## s = vmesh (x, y, z [, options] ) - Visualize a 3D surface
## s = vmesh (z [, options] )
##
## Visualizes a 3D surface. Returns the VRML code.
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
## Options : (all options of vrml_surf may be used too)
##
## "col" , col  : 3      : RGB Color,                Default = [0.3,0.4,0.9]
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
##                      c(1) rows. If it is negative, each checker row is
##                      c(1) facets high. c(2) does the same for columns.
##             or 1x1 : Same as [c,c].
##
## "zgray"            : Color varies from black for lowest point to white
##                      for highest.
##
## "zrb"              : Color varies from blue for lowest point to red for
##                      highest.
##
## "zcol", zcol : Mx3 : Color is linearly interpolated between the RGB
##                      values specified by the rows of zcol.
##
## "steps"            : Represent surface as a piecewise constant Z = f(X,Y)
##                      function
##
## "bars"             : Represent surface as a bar plot
## "bwid"             : Bar width, relative to point separation. Default = 2/3
##
## "level", l   : 1xN : Display one or more horizontal translucent plane(s)
##
##                        z == l(i)   (1 <= i <= length(l))
## 
## "lcol", lc   : Nx3 : Color of the plane(s).          Default = [.7 .7 .7]
## "ltran",lt   : Nx1 : Transparency of the plane(s).   Default =        0.3
## "tex", texFile
##
## "normalize"  :       Normalize z to [-1,1]
##
## See also: vrml_surf(), vrml_faces(), demo("vmesh")

function s = vmesh (x, y, z, varargin)

level =     [];
lcol =      [7 7 7]/10;
ltran =     0.3;
normalize = 0;

if (nargin <= 1) || ischar(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R)); 
  
  if nargin >= 3
    varargin = {y, z, varargin{:}};
  elseif nargin >= 2
    varargin = {y, varargin{:}};
  end
##  if     nargin >=3,
##    s = vmesh ( xx, yy, zz, y, z, varargin{:} );
##    if ! nargout,  clear s; end;  return
##  elseif nargin >=2,
##    s = vmesh ( xx, yy, zz, y, varargin{:} );
##    if ! nargout,  clear s; end;  return
##  end
  x = xx ; y = yy ; z = zz ;
end

frame = 1;

## surf_args = list (x,y,z);	# Arguments that'll be passed to vrml_surf
surf_args = {x,y,z};	# Arguments that'll be passed to vrml_surf

if numel (varargin)

  op1 = [" tran col checker creaseAngle emit colorPerVertex tex zcol  frame ",\
	 " level lcol ltran bwid "];
  op0 = " smooth zgray zrb normalize steps bars ";

  df = tars (level, lcol, ltran, normalize, frame);

  opts = read_options (varargin,"op0",op0,"op1",op1,"default",df);

				# Identify options for vrml_surf()
#   all_surf_opts  = list ("tran", "col", "checker", "creaseAngle", "emit", \
# 			 "colorPerVertex", "smooth", "tex",\
# 			 "zgray","zrb","zcol");
  all_surf_opts  = {"tran", "col", "checker", "creaseAngle", "emit", \
		    "colorPerVertex", "smooth", "steps", "bars", "bwid", "tex",\
		    "zgray","zrb","zcol"};

  for i = 1:length(all_surf_opts)
    optname = all_surf_opts{i};
    if isfield (opts, optname)
      ## surf_args = append (surf_args, list (optname));
      surf_args{length(surf_args)+1} = optname;
      if index (op1,[" ",optname," "])
	## surf_args = append (surf_args, list(opts.(optname)));
	surf_args{length(surf_args)+1} = opts.(optname);
      end
    end
  end
  lcol  =     opts.lcol;
  level =     opts.level;
  ltran =     opts.ltran;
  frame =     opts.frame;
  normalize = opts.normalize;
end

if normalize
  x -= nanmean (x(:));
  y -= nanmean (y(:));
  z -= nanmean (z(:));

  datascl = nanmax (abs([z(:);y(:);x(:)]));

  x /= datascl;
  y /= datascl;
  z /= datascl;
				# Put back z in surf_args
  surf_args{1} = x;
  surf_args{2} = y;
  surf_args{3} = z;
end

s = vrml_surf (surf_args{:});

if numel (x) == columns (z)
  x = ones(rows(z),1) * x(:)';
else
  assert (numel (x) == numel (z));
end
if numel (y) == rows (z)
  y = y(:) * ones(1,columns(z));
else
  assert (numel (y) == numel (z));
end

pts = [x(:)';y(:)';z(:)'];
ii = find (all (isfinite (pts)));
pt2 = pts(:,ii); x2 = x(ii); y2 = y(ii); z2 = z(ii);

## Add a point light

# scl = max (max(pt2') - min(pt2'));

# lpos = [min(x2) - 0.5*scl, mean(y2), max(z2)+scl]
# pl1 = vrml_PointLight ("location", lpos, "intensity", 0.7);

# lpos = [mean(x2), min(y2) - 0.5*scl, max(z2)+scl]
# pl2 = vrml_PointLight ("location", lpos, "intensity", 0.7);

# pl = [pl1 pl2];

pl = [vrml_DirectionalLight("direction",[-1,-1,-1],"intensity",0.75),\
      vrml_DirectionalLight("direction",[-1, 1,-1],"intensity",0.5),\
      vrml_DirectionalLight("direction",[ 1,-1,-1],"intensity",0.5),\
      vrml_DirectionalLight("direction",[ 1, 1,-1],"intensity",0.33),\
      vrml_DirectionalLight("direction",[ 0, 0, 1],"intensity",0.5)];

#  distance = max ([max (x(:)) - min (x(:)),\
#  		 max (y(:)) - min (y(:)),\
#  		 max (z(:)) - min (z(:))])
#  vp = vrml_Viewpoint  ("orientation", [1 0 0 -pi/6],\
#  		      "position",    distance*[0 0 5]);

minpts = min (pt2');
maxpts = max (pt2');
medpts = (minpts + maxpts)/2;
ptssz  = (maxpts - minpts);
ptssz  = max (ptssz, max (ptssz/10));

if frame, fr = vrml_frame (minpts-ptssz/10,\
			   "scale", ptssz * 1.2, "col",(ones(3)+eye(3))/2);
else      fr = "";
end

sbg = vrml_Background ("skyColor", [0.5 0.5 0.6]);

slevel = "";
if ! isempty (level)
  level = level(:)';		# Make a row
  nlev = length (level);
  
  xmin = min (x(:)); xmax = max (x(:));
  ymin = min (y(:)); ymax = max (y(:));

  if any (size (lcol) != [nlev,3])
    nlc = prod (szlc = size (lcol));
				# Transpose colors
    if all (szlc == [3,nlev]), lcol = lcol'; 
				# Single gray level
    elseif nlc == 1          , lcol = lcol * ones (nlev,3);
				# nlev gray levels
    elseif nlc == nlev       , lcol = lcol(:)*[1 1 1];
    elseif nlc == 3          , lcol = ones(nlev,1)*lcol(:)';
    else error ("lcol has size %i x %i",szlc);
    end
  end
  if prod (size (ltran)) == 1    , ltran = ltran*ones(1,nlev); end
  
  for i = 1:nlev
    slevel = [slevel, \
	      vrml_parallelogram([xmin     xmin     xmax     xmax;\
				  ymin     ymax     ymax     ymin;\
				  level(i) level(i) level(i) level(i)],\
				 "col",lcol(i,:),"tran",ltran(i))];
  end
end

s = [pl, sbg, s , fr, slevel];



if ! nargout,  
  vrml_browse (s);
  clear s; 
end

%!demo
%! % Test the vmesh and vrml_browse functions with the test_vmesh script
%! R = 41; C = 26; 
%! [x,y] = meshgrid (linspace (-8+eps,8+eps,C), linspace (-8+eps,8+eps,R));
%! z = sin (sqrt (x.^2 + y.^2)) ./ (sqrt (x.^2 + y.^2));
%! vmesh (z);
%! printf ("Press a key.\n"); pause;
%! 
%! ############## The same surface, with holes (NaN's) in it. ###############
%! z(3,3) = nan;		# Bore a hole
%!  				# Bore more holes
%! z(1+floor(rand(1,5+R*C/30)*R*C)) = nan;
%! vmesh (z);
%! printf ("Press a key.\n"); pause;
%!
%! ###### The same surface, with checkered stripes - 'checker' option ######
%! vmesh (z,"checker",-[6,5]);
%! printf ("Press a key.\n"); pause;
%! 
%! ##### With z-dependent coloring - 'zrb', 'zgray' and'zcol' options. #####
%! vmesh (z,"zrb");
%! printf ("That's it!\n");




## %! test_vmesh

return

endfunction


