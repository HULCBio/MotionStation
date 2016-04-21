## Copyright (C) 2010 Etienne Grossmann <etienne@egdn.net>
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

##  s = vrml_Viewpoint (...)   - Vrml Viewpoint node
##  
##  s is a string of the form :
##  ------------------------------------------------------------------
## Viewpoint { 
##    eventIn      SFBool     set_bind
##    exposedField SFFloat    fieldOfView    0.785398  # (0,pi)
##    exposedField SFBool     jump           TRUE
##    exposedField SFRotation orientation    0 0 1 0   # [-1,1],(-pi,pi)
##    exposedField SFVec3f    position       0 0 10    # (-,)
##    field        SFString   description    ""
##    eventOut     SFTime     bindTime
##    eventOut     SFBool     isBound
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## Example : s = vrml_Viewpoint ("location",[0 0 1]);
##
## See also : vrml_DirectionalLight

function s = vrml_Viewpoint (varargin)

if mod(nargin,2) != 0, print_usage; end

h = struct (varargin{:});
 
tpl = struct ("fieldOfView",      "%8.3f",\
	      "jump",             "%s",\
	      "orientation",      "%8.3f %8.3f %8.3f %8.3f",\
	      "orientation0",     "%8.3f %8.3f %8.3f %8.3f",\
	      "position",         "%8.3f %8.3f %8.3f",\
	      "description",      "\"%s\"",\
	      "DEF",              "");
DEF = "";
defaultPos = [0 0 10];

for [val,key]  = h
  if ! isfield (tpl, key)
    error (sprintf ("vrml_Viewpoint : unknown field '%s'",key));
  end
end
if isfield (h, "DEF")
  DEF = h.DEF;
  h = rmfield (h, "DEF");
end

if isfield (h, "orientation0")

  o = h.orientation0;
  if numel (o) == 3
    o = [o(:)'/norm(o), norm(o)];
  elseif numel (o) == 4
    o(4) = sign(o(4)) * rem (abs (o(4)), pi);
    o = [o(1:3)(:)'/norm(o(1:3)), o(4)];
  else
    error ("Option 'orientation0' has size %i, should be 3 or 4", numel(o));
  endif
  
  if isfield (h, "position")
    p = h.position(:);
  else
    p = defaultPos(:);
  end

  h = rmfield (h, "orientation0");

  h.orientation = o;
  h.position = rotv (o(1:3), o(4))' * p;  

elseif isfield (h, "orientation")

  o = h.orientation;
  if numel (o) == 3
    o = [o(:)'/norm(o), norm(o)];
  elseif numel (o) == 4
    o(4) = sign(o(4)) * rem (abs (o(4)), pi);
    o = [o(1:3)(:)'/norm(o(1:3)), o(4)];
  else
    error ("Option 'orientation' has size %i, should be 3 or 4", numel(o));
  endif
  h.orientation = o;
end

if isfield (h, "position") && numel (h.position) != 3
  error ("Option 'position' has size %i, should be 3", numel (h.position));
endif

if isfield (h, "jump")
  if h.jump
    h.jump = "TRUE";
  else
    h.jump = "FALSE";
  endif
endif

body = "";
for [val, key] = h
  body = [body,\
	  sprintf("   %-20s   %s\n",key, \
		  sprintf (getfield (tpl,key), val))];
end

s = sprintf ("Viewpoint {\n%s}\n", body);
if !isempty (DEF)
  s = ["DEF ", DEF," ",s];
end 
endfunction

