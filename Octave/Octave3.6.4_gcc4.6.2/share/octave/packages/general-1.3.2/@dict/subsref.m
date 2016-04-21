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
## @deftypefn{Function File} {d =} subsref (d, s)
## Overloaded subsref for dictionaries.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function varargout = subsref (d, s)
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
        i = lookup (d.keys, ind, "m");
        if (i)
          e = d.values {i};
        else
          error ("key does not exist: %s", ind);
        endif
      elseif (iscellstr (ind))
        i = lookup (d.keys, ind, "m");
        if (all (i(:)))
          e = reshape (d.values (i), size (ind)); # ensure correct shape.
        else
          ## Report the first non-existing key.
          error ("key does not exist: %s", ind{find (i == 0, 1)});
        endif
      else
        error ("invalid index");
      endif
    case "."
      fld = s.subs;
      switch (fld)
      case 'keys'
        e = d.keys;
      case 'values'
        e = d.values;
      otherwise
        error ("@dict/subsref: invalid property \"%s\"", fld);
      endswitch
    otherwise
      error ("invalid subscript type");
  endswitch

  if (numel (s) > 1)
    varargout = {subsref(e, s(2:end))};
  else
    varargout = {e};
  endif
endfunction
