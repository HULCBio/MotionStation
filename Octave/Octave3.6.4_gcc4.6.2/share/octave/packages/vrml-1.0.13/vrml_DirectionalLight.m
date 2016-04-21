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

##  s = vrml_DirectionalLight (...)   - Vrml DirectionalLight node
##
##  s is a string of the form :
##  ------------------------------------------------------------------
##  DirectionalLight { 
##    exposedField SFFloat ambientIntensity  0        # [0,1]
##    exposedField SFColor color             1 1 1    # [0,1]
##    exposedField SFVec3f direction         0 0 -1   # (-,)
##    exposedField SFFloat intensity         1        # [0,1]
##    exposedField SFBool  on                TRUE 
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## See also : vrml_PointLight

function s = vrml_DirectionalLight (varargin) # pos 2.1.39


hash = struct ();
for k=1:2:nargin,
   hash = setfield(hash,varargin{k:k+1}); 
end

tpl = struct ("ambientIntensity", "%8.3f",\
	      "intensity",        "%8.3f",\
	      "direction",        "%8.3f",\
	      "on",               "%s",\
	      "color",            "%8.3f %8.3f %8.3f");

body = "";
for [val,key] = hash,

  if !(isnumeric(val) && isnan (val)),

				# Check validity of field
    if !isfield (tpl, key)
      error (sprintf ("vrml_PointLight : unknown field '%s'",key));
    end

    body = [body,\
	    sprintf("   %-20s   %s\n",key,
		     sprintf(getfield (tpl,key), val))];
  end
end
s = sprintf ("DirectionalLight { \n%s}\n", body);
endfunction

