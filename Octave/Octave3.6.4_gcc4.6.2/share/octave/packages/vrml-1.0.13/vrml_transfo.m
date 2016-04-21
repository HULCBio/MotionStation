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

##       v = vrml_transfo(s,t,r,c,d)
##  
## s : string of vrml code.
## t : 3      Translation                          default : [0,0,0]
## r : 3x3    Rotation matrix, or                  default : eye(3)
##     3      Scaled rotation axis.
## c : 3 or 1 Scale                                default : 1
## d : string DEF name                             default : ''
##
## v : string v is s, enclosed in a Transform {} vrml node with
##     rotation, translation and scale params given by r, t and c.
##

function v = vrml_transfo(s,t,r,c,DEF)

## Hint : if s is "%s", you may later do v2 = sprintf (v,s2) which should be
##        equal to  vrml_transfo (s2,etc)

verbose = 0;
## 
t0 = [0;0;0];
r0 = [1,0,0,0];
c0 = [1;1;1];
if nargin<2 || isnan (t), t = t0; end # Default translation
if nargin<3 || isnan (r), r = r0; end # Default rotation
if nargin<4 || isnan (c), c = c0; end # Default scale
if nargin<5, DEF = ""; end

if verbose > 1
  if nargin > 1, printf ("vrml_transfo : t   = %s\n",sprintf ("%f ",t)); end
  if nargin > 2, printf ("vrml_transfo : r   = %s\n",sprintf ("%f ",r)); end
  if nargin > 3, printf ("vrml_transfo : c   = %s\n",sprintf ("%f ",c)); end
  if nargin > 4, printf ("vrml_transfo : DEF = %s\n",DEF); end
end
t = t(:);
c = c(:);
## if nargin<4, s = "%s" ; end

if prod(size(t)) != 3, error("t has %i elements, not 3",prod(size(t))); end


if prod(size(c))==1, c = [c;c;c]; end

if all(size(r) == 3)
  if abs (det (r) - 1) > sqrt (eps), r2 = orth (r);
  else                               r2 = r;
  end
  [axis,ang] = rotparams (r2);
elseif prod(size(r)) == 4
  ang = r(4);
  axis = r(1:3);
elseif prod(size(r)) == 3
  ang = norm(r);
  if abs(ang)>eps, 
    axis = r/ang;
  else
    axis = [0,1,0]; ang = 0;
  end
else
  error ("vrml_transfo : rotation should have size 3x3, 3 or 4\n");
end
if verbose,
  printf (["vrml_transfo : %8.3f %8.3f %8.3f %8.3f\n",\
	   "               %8.3f %8.3f %8.3f\n"],\
	  axis,ang,t);
  printf ("length of string is %i\n",prod(size(s)));
end

				# Indent s by 4
if length (s) && strcmp(s(prod(size(s))),"\n") # chomp
  s = s(1:prod(size(s))-1) ;
end
## strrep is slow, as if it copied everything by hand. So don't indent.
#  mytic() ;
#  s = ["    ",strrep(s,"\n","\n    ")] ;
#  mytic()
if verbose, printf ("   done indenting s\n"); end

sr = st = ss = sd = "";
if abs (ang) > sqrt (eps)
  sr = sprintf ("  rotation    %8.3f %8.3f %8.3f %8.3f\n",axis,ang);
end
if any (abs (t - t0)>sqrt (eps))
  st = sprintf ("  translation %8.3f %8.3f %8.3f\n",t);
end
if any (abs (c - c0)>sqrt (eps))
  ss = sprintf ("  scale       %8.3f %8.3f %8.3f\n",c);
end
if !isempty (DEF), sd = ["DEF ",DEF," "]; end 

v = sprintf([sd,"Transform {\n",sr,st,ss,\
	     "  children [\n%s\n",\
	     "           ]\n",\
	     "}\n",\
	     ],\
	    s) ;
## keyboard

endfunction

