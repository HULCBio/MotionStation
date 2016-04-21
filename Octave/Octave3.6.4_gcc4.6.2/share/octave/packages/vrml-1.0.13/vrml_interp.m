## Copyright (C) 2005-2012 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_interp (typ, val,...)

function s = vrml_interp (typ, val, varargin)

key = [];
DEF = "";
if nargin < 1, help vrml_interp; return; end
if nargin < 2
  val = [];
elseif nargin > 2
  op1 = " key DEF ";
  df = tars (key, DEF);
  s = read_options (varargin, "op1", op1, "default", df);
  [key, DEF] = getfields (s, "key", "DEF");
end


persistent nname = struct ("col"        , "Color",
		       "Color"      , "Color",
		       "coord"      , "Coordinate",
		       "Coordinate" , "Coordinate",
		       "normal"     , "Normal",
		       "Normal"     , "Normal",
		       "orient"     , "Orientation",
		       "Orientation", "Orientation",
		       "pos"        , "Position",
		       "Position"   , "Position",
		       "scal"       , "Scalar",
		       "Scalar"     , "Scalar");
if isfield (nname, typ)
  typs = nname.(typ);
elseif ischar(typ)
#  e2 = leval ("sprintf",\
#	      append (list("    '%s'\n"), fieldnames (nname)));
  e2 = sprintf("    '%s'\n", fieldnames (nname){:});
  error ("vrml_interp : Unknown type '%s'. Should be in:\n%s",typ,e2);
else
#  e2 = leval ("sprintf",\
#	      append (list("    '%s;\n"), fieldnames (nname)));
  e2 = sprintf("    '%s'\n", fieldnames (nname){:});
  error ("vrml_interp : typ should be a string in:\n%s",typ,e2);
end

if isempty (val)
  vs = "";
else 
  vs = sprintf ("%8.5f, ", val);
  vs = sprintf ("    keyValue [ %s ]\n", vs(1:length(vs)-2));
end
if isempty (key)
  ks = "";
else              
  ks = sprintf ("%8.5f, ", key);
  ks = sprintf ("    key [ %s ]\n", ks(1:length(ks)-2));
end
if length (DEF),  defs = ["DEF ",DEF," "];
else              defs = "";
end 

s = [defs,typs,"Interpolator {\n", vs, ks,"}\n"];endfunction

