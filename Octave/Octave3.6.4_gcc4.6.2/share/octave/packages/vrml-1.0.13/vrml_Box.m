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

## s = vrml_Box (sz) - Box { ... } node
##
## If sz is not given, returns Box { }
## If sz has size 1, returns   Box { <sz> <sz> <sz> }
## If sz has size 3, returns   Box { <sz(1)> <sz(2)> <sz(3)> }

function s = vrml_Box (sz)

if nargin < 1,       sz = []; end
if length (sz) == 1, sz = sz * [1 1 1]; end
if !isempty (sz)
  assert (numel (sz) == 3);
  ssz = sprintf ("\n  size %f %f %f\n",sz);
else
  ssz = "";
end

s = ["Box {",ssz,"}\n"];

