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

##  s = vrml_PointLight (...)   - Vrml PointLight node
##  
##  s is a string of the form :
##  ------------------------------------------------------------------
##  PointLight { 
##    exposedField SFFloat ambientIntensity  0       ## [0,1]
##    exposedField SFVec3f attenuation       1 0 0   ## [0,inf)
##    exposedField SFColor color             1 1 1   ## [0,1]
##    exposedField SFFloat intensity         1       ## [0,1]
##    exposedField SFVec3f location          0 0 0   ## (-inf,inf)
##    exposedField SFBool  on                TRUE 
##    exposedField SFFloat radius            100     ## [0,inf)
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## Example : s = vrml_PointLight ("location",[0 0 1]);
##
## See also : vrml_DirectionalLight

function s = vrml_PointLight (varargin)

if mod(nargin,2) != 0, print_usage; end
h = struct (varargin{:});

tpl = struct ("ambientIntensity", "%8.3f",\
	      "intensity",        "%8.3f",\
	      "radius",           "%8.3f",\
	      "on",               "%s",\
	      "attenuation",      "%8.3f %8.3f %8.3f",\
	      "color",            "%8.3f %8.3f %8.3f",\
	      "location",         "%8.3f %8.3f %8.3f");

body = "";
for [val,key] = h,

    if strcmp (key, "DEF")
      continue;
    elseif !(isnumeric(val) && isnan (val))

				# Check validity of field
    if ! isfield (tpl, key)
      error (sprintf ("vrml_PointLight : unknown field '%s'",key));
    end


    body = [body,\
	    sprintf("   %-20s   %s\n",key, \
		    sprintf (getfield (tpl,key), val))];
  end
end
s = sprintf ("PointLight {\n%s}\n", body);
if isfield (h,"DEF") && !isempty (h.DEF)
  s = ["DEF ",h.DEF," ",s];
end 
endfunction

