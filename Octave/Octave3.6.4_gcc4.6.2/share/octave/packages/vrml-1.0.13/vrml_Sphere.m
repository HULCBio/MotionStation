## Copyright (C) 2010-2012 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_Sphere (radius) - VRML code for a sphere 

function s = vrml_Sphere (sz)

if nargin < 1,       sz = []; end

if !isempty (sz)
  assert (numel (sz) == 1);
  ssz = sprintf ("\n  radius %f\n",sz);
else
  ssz = "";
end

s = ["Sphere {",ssz,"}\n"];

