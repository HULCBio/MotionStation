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
## @deftypefn{Function File} {d =} subsasgn (d, s, val)
## Overloaded subsasgn for dictionaries.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function d = subsasgn (d, s, val)
  if (isempty (s))
    error ("dict: missing index");
  endif

  switch (s(1).type)
    case "()"
      ind = s(1).subs;
      if (numel (ind) == 1)
        ind = ind{1};
      else
        error ("dict: needs exactly one index");
      endif
      if (ischar (ind))
        ## Scalar assignment case. Search whether the key is present.
        i = lookup (d.keys, ind, "m");
        if (i)
          ## The key is present; handle the rest of chain if needed,
          ## then assign.
          if (numel (s) > 1)
            val = subsasgn (d.values{i}, s(2:end), val);
          endif
          d.values{i} = val;
        else
          ## The key is missing; handle the rest of chain if needed.
          if (numel (s) > 1)
            val = subsasgn ([], s(2:end), val);
          endif
          ## Look up the proper place to insert the new key.
          i = lookup (d.keys, ind);
          d.keys = [d.keys(1:i,1); {ind}; d.keys(i+1:end,1)];
          ## Insert value.
          d.values = [d.values(1:i,1); {val}; d.values(i+1:end,1)];
        endif
      elseif (iscellstr (ind))
        ## Multiple assignment case. Perform checks.
        if (numel (s) > 1)
          error ("chained subscripts not allowed for multiple fields");
        endif
        if (isnull (val))
          ## Deleting elements.
          i = lookup (d.keys, ind, "m");
          i = i(i != 0);
          d.keys(i) = [];
          d.values(i) = [];
        elseif (iscell (val))
          if (numel (val) == 1)
            val = repmat (val, size (ind));
          elseif (numel (ind) != numel (val))
            error ("numbers of elements of index and rhs must match");
          endif
          ## Choose from two paths.
          if (numel (ind) < numel (d.keys))
            ## Scarce assignment. There's a good chance that all keys will be present.
            i = lookup (d.keys, ind, "m");
            mask = i != 0;
            if (all (mask))
              d.values(i) = val;
            else
              d.values(i(mask)) = val(mask);
              mask = !mask;
              [d.keys, i] = sort ([d.keys; ind(mask)(:)]);
              d.values = [d.values; val(mask)(:)](i);
            endif
          else
            ## Mass assignment. Probably most of the keys are new ones, so simply
            ## melt all together.
            [d.keys, i] = unique ([d.keys; ind(:)]);
            d.values = [d.values; val(:)](i);
          endif
        else
          error ("expected cell rhs for cell index");
        endif
      else
        error ("invalid index");
      endif
    otherwise
      error ("invalid subscript type for assignment");
  endswitch
endfunction

