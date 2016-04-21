## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
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
## @deftypefn{Function File} {} has (d, key)
## Check whether the dictionary contains specified key(s). 
## Key can be either a string or a cell array. In the first case,
## the result is a logical scalar; otherwise, the result is a logical array
## with the same shape as @var{key}.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function b = has (d, key)
  if (nargin != 2)
    print_usage ();
  endif

  if (ischar (key) || iscellstr (key))
    b = lookup (d.keys, key, "b");
  else
    error ("has: invalid key value");
  endif
endfunction

