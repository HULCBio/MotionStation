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
## @deftypefn{Function File} {} join (d1, d2, joinop)
## Merges two given dictionaries. For common keys, the function @var{joinop} is
## called to combine the two values. If not supplied, values from d2 are taken.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function d = join (d1, d2, jop)
  if (nargin < 2 || nargin > 3 || ! (isa (d1, "dict") && isa (d2, "dict")))
    print_usage ();
  endif

  keys1 = d1.keys;
  keys2 = d2.keys;

  [keys, idx] = sort ([keys1; keys2]);
  values = [d1.values; d2.values](idx);
  n = numel (keys);

  if (n > 1)
    idx = find (strcmp (keys(1:n-1), keys(2:n)));
    keys(idx) = [];
    if (nargin == 3)
      values(idx+1) = cellfun (jop, values(idx), values(idx+1), "UniformOutput", false);
    endif
    values(idx) = [];
  endif

  d = dict;
  d.keys = keys;
  d.values = values;

endfunction

