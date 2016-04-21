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

##  s = vrml_material (dc,ec,tr) - Returns a "material" vrml node
##
## dc : 3x1 : diffuseColor
## ec : 3x1 : emissiveColor
##   or 1x1 : use dc as emissiveColor if ec is true.             Default = 0
## tr : 1x1 : transparency                                       Default = 0

function s = vrml_material (dc, ec, tran,DEF)

if nargin < 1, dc = [0.3 0.4 0.9] ; # Default color
elseif prod (size (dc)) != 3,
  error ("dc should have length 3 (it is %i x %i)",size (dc));
end

emit = 1;

if nargin < 2, ec = 0; end
if nargin < 3, tran = 0; end
if nargin < 4, DEF = ""; end

if prod (size (ec)) == 1 && !isnan (ec) , emit = ec ; ec = dc ; end
if isnan (tran)
  tran = 0;
end

if emit && !isnan (ec)
  se = sprintf ("              emissiveColor %8.3g %8.3g %8.3g\n",ec);
else
  se = "";
end
if tran && ! isnan (tran)
  st = sprintf ("              transparency %8.3g\n",tran);
else
  st = "";
end

if isempty (DEF), sd = "";
else              sd = ["DEF ",DEF];
end

s = sprintf (["            material ",sd," Material {\n",\
	      se,st,\
	      "              diffuseColor  %8.3g %8.3g %8.3g \n",\
	      "          }\n"],\
	     dc);
endfunction

