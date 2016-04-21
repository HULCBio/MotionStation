## Copyright (C) 2010 VZLU Prague, a.s., Czech Republic
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

## -*- texinfo -*-
## @deftypefn{Function File} {} struct (d)
## Converts the dict object to a structure, if possible.
## This requires the keys to be valid variable names.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function s = struct (d)
  keys = d.keys;
  valid = cellfun (@isvarname, keys);
  if (all (valid))
    s = cell2struct (d.values, keys, 1);
  else
    error ("struct: invalid key value: %s", keys{find (! valid, 1)});
  endif
endfunction
