## Copyright (C) 2007-2010 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_parallelogram (bnds,...)
##
## bnds = [xmin, ymin, zmin; xmax, ymax, zmax]
##
## OPTIONS :
## ---------
## col,   c : 3x1 : Color of surface
## emit,  e : 1   :
## tran,  t : 1   :
##
## border,b : 1   :
## bocol, c : 3   :
## boemit,e : 1   :
## borad, r : 1   :
##
## balls, b : 1   :
## bcol,  c : 3   :
## bemit, e : 1   :
## brad,  r : 1   :

function s = vrml_parallelepiped (bnds, varargin)

col = [0.3,0.4,0.9];
emit = 0;
tran = 0;
balls = 0;
border = 0;
bcol = btran = bemit = brad = borad = bocol = boemit = nan;

if !isnumeric (bnds)
  error ("bnds must be a 2 x 3 matrix, not a %s",typeinfo(bnds));
endif
if prod (size (bnds)) != 6
  error ("bnds must be 2 x 3, not %s",sprintf("%i x ",size(bnds))(1:end-3));
endif
if nargin > 1
  op1 = " col emit tran balls border bcol btran bemit brad borad bocol boemit ";
  df = tars (col,emit,tran,balls,border,bcol,btran,bemit,brad,borad,bocol,boemit);
  s = read_options (varargin, "op1",op1, "default",df);
  col=s.col; emit=s.emit; tran=s.tran; balls=s.balls; border=s.border;
  bcol = s.bcol; btran = s.btran; bemit = s.bemit; brad = s.brad;
  borad = s.borad; bocol = s.bocol; boemit = s.boemit;
end

if ! isnan (bcol) ||! isnan (brad) || ! isnan (bemit), balls = 1; end
if balls
 if isnan (bcol), bcol = col; end
 if isnan (btran), btran = tran; end
 if isnan (brad)
   brad = (max (abs (diff(bnds))))/20; 
 end
end

x = [bnds([1 2 2 1 1 2 2 1],1)';\
     bnds([1 1 2 2 1 1 2 2],2)';\
     bnds([1 1 1 1 2 2 2 2],3)'];

faces = [1 2 3 4;\
	 5 6 7 8;\
	 1 2 6 5;\
	 2 3 7 6;\
	 3 4 8 7;\
	 4 1 5 8]';

				# The facet
s = vrml_faces (x,faces,"col",col, "tran", tran,"emit",emit);

				# Decoration : balls on vertices
if balls
  if isnan (bemit), bemit = emit; end
  s = [s,vrml_points(x,"balls","rad",brad,"col",bcol,"tran",btran,"emit",bemit)];
end

				# Decoration : border

if ! isnan (bocol) ||! isnan (borad) || ! isnan (boemit), border = 1; end
if border
  if isnan (borad)
    borad = (norm (x(:,1)-x(:,2))+ norm(x(:,1)-x(:,2)))/80;
  end
  if isnan (boemit)
    if isnan (bemit), boemit = emit; else boemit = bemit; end
  end
  if isnan (bocol), bocol = col; end
    
  if !balls			# Make pretty junctions of cylinders
    s = [s,\
	 vrml_cyl(x(:,[1:columns(x),1]),"rad",borad,"emit",boemit,"col",col),\
	 vrml_points(x(:,1),"balls","rad",borad,"emit",boemit,"col",col)];
  else				# but only if balls don't cover them
    s = [s,vrml_cyl(x(:,[1:columns(x),1]),"rad",borad,"emit",boemit)];
  end

end

endfunction

