## Copyright (C) 2002-2012 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_arrow (sz, col)     - Arrow pointing in "y" direction
##
## INPUT :
## -------
## Arguments are optional. NaN's are replaced by default values.
##                                                         <default>
## sz = [len, alen, dc, dr] has size 1, 2, 3 or 4, where
##
##   len  : total length                                   <1>
##   alen : If positive: length of cone/total length       <1/4>
##          If negative: -(length of cone)
##   dc   : If positive: diameter of cone base/total len   <1/16>
##          If negative: -(diameter of cone) 
##   dr   : If positive: diameter of rod/total length      <min(dc, len/32)>
##          If negative: -(diameter of rod) 
##
## col    : 3 or 3x2 : Color of body and cone              <[0.3 0.4 0.9]>
##
## OUTPUT :
## --------
## s      : string   : vrml representation of an arrow (a rod and a cone)

function v = vrml_arrow (sz, col, emit)

if nargin < 3, emit = 1; end

if nargin<2  || isempty (col),    col = [0.3 0.4 0.9;0.3 0.4 0.9];
elseif prod (size (col)) == 3,    col = [1;1]*col(:)';
elseif all (size (col) == [3,2]), col = col';
elseif any (size (col) != [2,3]),
  error("vrml_arrow : col has size %dx%d (should be 3 or 3x2)\n",size(col));
  ## keyboard
end
col = col' ;

s0 = [1, 1/4, 1/16, 1/32];
				# Get absolute size
if nargin<1 || isempty (sz) || isnan (sz),  sz = s0 ;
elseif length (sz) == 4,      sz = [sz(1),sz(2),sz(3),sz(4)];
elseif length (sz) == 3,      sz = [sz(1),sz(2),sz(3),s0(4)];
elseif length (sz) == 2,      sz = [sz(1),sz(2),s0(3),s0(4)];
elseif length (sz) == 1,      sz = [sz(1),s0(2),s0(3),s0(4)];
else 
  error ("vrml_arrow : sz has size %dx%d. (should be in 1-4)\n", size(sz));
  ## keyboard
end

assert (sz(1) > 0)

if !isempty (tmp = find(isnan(sz))), sz(tmp) = s0(tmp) ; end

for i = 2:4
  if sz(i) >= 0
	sz(i) *= sz(1);
  else
	sz(i) = -sz(i);
  endif
endfor

				# Do material nodes
smat1 = vrml_material (col(:,1), emit);
smat2 = vrml_material (col(:,2), emit);

v = sprintf (["Group {\n",\
              "  children [\n",\
              "    Transform {\n",\
              "      translation  %8.3g %8.3g %8.3g\n",\
              "      children [\n",\
              "        Shape {\n",\
              "          appearance Appearance {\n",\
	      smat1,\
	      "          }\n"\
              "          geometry Cylinder {\n",\
	      "            radius %8.3g\n",\
	      "            height %8.3g\n",\
	      "          }\n",\
              "        }\n",\
              "      ]\n",\
              "    }\n",\
              "    Transform {\n",\
              "      translation  %8.3g %8.3g %8.3g\n",\
              "      children [\n",\
              "        Shape {\n",\
              "          appearance Appearance {\n",\
	      smat2,\
              "          }\n",\
              "          geometry Cone { \n",\
              "            bottomRadius  %8.3g \n",\
              "            height  %8.3g\n",\
              "          }\n",\
              "        }\n",\
              "      ]\n",\
              "    }\n",\
              "  ]\n",\
              "}\n"],\
	     [0,(sz(1)-sz(2))/2,0],\
	     sz(4),\
	     sz(1)-sz(2),\
	     [0,sz(2)/2+sz(1)-sz(2),0],\
	     sz(3),\
	     sz(2));
endfunction

