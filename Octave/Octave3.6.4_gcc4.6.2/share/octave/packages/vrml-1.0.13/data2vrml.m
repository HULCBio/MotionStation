## Copyright (C) 2012 Etienne Grossmann <etienne@egdn.net>
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

## s = data2vrml (typeStr, value) - Convert 'value' to VRML code of type typeStr
##
## TODO: Improve this function
##
## If typeStr is "SFBool",   then s is "TRUE" or "FALSE"
## If typeStr is "MFString", then s is sprintf ("%s", value)
## otherwise                      s is sprintf ("%f", value)
##
function s = data2vrml (typeStr, value)

if strcmp (typeStr, "SFBool")

  if value,	s = "TRUE";
  else      s = "FALSE";
  endif

elseif strcmp (typeStr, "MFSTring")

  s = sprintf ("%s", value);

else

  s = sprintf ("%f", value);

end
