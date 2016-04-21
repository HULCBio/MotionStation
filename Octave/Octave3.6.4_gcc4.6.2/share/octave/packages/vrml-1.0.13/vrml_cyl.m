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

##       s = vrml_cyl(x,...) 
##
## Makes a cylinder that links x(:,1) to x(:,2) 
## 
## Options : 
##
## "tran", transparency    : Transparency                  default = 0
## "col" , col             : Color           default = [ 0.3 0.4 0.9 ]
## "rad" , radius          : Radius of segments         default = 0.05
## "balls"                 : Add balls to extremities
## "brad"                  : Radius of balls             default = rad
## "emit", bool            : Use or not emissiveColor
## "noemit"                : Same as emit,0
## "arrow"                 : Last segment is an arrow 
## "hcol", hcol            : Set color of the head of the arrow.
##                                                       default = col

function s = vrml_cyl (x,varargin) 	#  pos 2.1.39 

rad = 0.05 ;
tran = 0 ;
col = [0.3;0.4;0.9] ;
hcol = nan;
brad = nan;

verbose = 0 ;
balls = 0 ;
emit = 0;
noemit = nan;
arrow = 0; 

if nargin > 1
  op1 = " rad tran col hcol brad emit " ;
  op0 = " verbose balls noemit arrow " ;

  df = tars (rad, tran, col, hcol, verbose, balls, noemit, arrow, brad, \
	    emit);


  s = read_options (varargin, "op1",op1,"op0",op0, "default",df); # pos 2.1.39

  rad=     s.rad;
  tran=    s.tran;
  col=     s.col;
  hcol=    s.hcol;
  emit=    s.emit;
  verbose= s.verbose;
  balls=   s.balls;
  noemit=  s.noemit;
  arrow=   s.arrow;
  brad=    s.brad;
end

if isnan (brad), brad = rad; end
if !isnan (noemit), emit = ! noemit; end
if !isnan (hcol), arrow = 1; end

s = "" ;

N = columns (x);

				# Make col 3xN
if prod (size (col)) == 3, col = col(:); col = col(:, ones(1,N)); end
if emit, emitcol = col; else emitcol = nan(1,N); end
if prod (size (tran)) == 1, tran = tran(ones(1,N)); end
tran(find (tran==0)) = nan ;

for i = 2:N
  d = x(:,i)-x(:,i-1) ;
  n = norm(d) ;
  if n,
    d = d/n ;

    ax = cross([0,1,0],d') ;
    an = norm (ax) ;
    if abs(an)>eps, ax = ax/an ; else ax = [1,0,0] ; end
    an = acos(d(2)) ;

    t = mean (x(:,[i,i-1])')' ;

    if ! arrow || i != N

      smat = vrml_material (col(:,i-1), emitcol(:,i-1), tran(i-1));
				# Do a cylinder
      s = [s,sprintf(["Transform {\n",\
		      "  translation %8.3f %8.3f %8.3f\n",\
		      "  children [\n",\
		      "    Transform {\n",\
		      "      rotation    %8.3f %8.3f %8.3f %8.3f\n",\
		      "      children [\n",\
		      "        Shape {\n",\
		      "          appearance Appearance {\n",\
		      "              %s",\
		      "          }\n",\
		      "          geometry Cylinder {\n",\
		      "            height %8.3f\n",\
		      "            radius %8.3f\n",\
		      "          }\n",\
		      "        }\n",\
		      "      ]\n",\
		      "    }\n",\
		      "  ]\n",\
		      "}\n"],\
		     t,\
		     ax,an,\
		     smat,\
		     n,\
		     rad)];
    else
      t = x(:,i-1) ;
      if isnan (hcol), hcol = col(:,i); end
      arrowcol = [col(:,i) hcol(1:3)(:)];
      s = [s,\
	   vrml_transfo(vrml_arrow ([n,nan,2*rad/n,rad/n],arrowcol,emit),\
		        t, ax*an)];
    end
  end
end

if balls,
  ## "balls on"
  s = [s, vrml_points(x,"balls","col",col, "rad",brad,"emit",emit)];
elseif columns(x)>2,
				# Make a rounded junction
  s = [s, vrml_points(x(:,2:columns(x)-1),"balls","col",col,"rad",rad, \
		      "emit", emit)];
end


endfunction

