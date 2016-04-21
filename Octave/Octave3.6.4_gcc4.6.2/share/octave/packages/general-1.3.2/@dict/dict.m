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
## @deftypefn{Function File} {d =} dict (@var{keys}, @var{values})
## @deftypefnx{Function File} {d =} dict ()
## @deftypefnx{Function File} {d =} dict (@var{str})
## Creates a dictionary object with given keys and values. @var{keys}
## should be a cell array of strings; @var{values} should be a cell array
## with matching size. @var{values} can also be a singleton array, in
## which case it is expanded to the proper size; or omitted, in which case
## the default value of empty matrix is used.
## If neither @var{keys} nor @var{values} are supplied, an empty dictionary
## is constructed.
## If a scalar structure is supplied as an argument, it is converted to 
## a dictionary using field names as keys.
##
## A dictionary can be indexed either by a single string or cell array of
## strings, like this:
##
## @example
## @group
##   d = dict (keys, values);
##   d(str) # result is a single value
##   d(cellstr) # result is a cell array
## @end group
## @end example
##
## In the first case, the stored value is returned directly; in the second case,
## a cell array is returned. The cell array returned inherits the shape of the index.
## 
## Similarly, indexed assignment works like this:
##
## @example
## @group
##   d = dict (keys, values);
##   d(str) = val; # store a single value
##   d(cellstr) = vals; # store a cell array
##   d(cellstr) = []; # delete a range of keys
## @end group
## @end example
##
## Any keys that are not present in the dictionary are added. The values of
## existing keys are overwritten. In the second case, the lengths of index and
## rhs should match or rhs should be a singleton array, in which case it is
## broadcasted. 
##
## It is also possible to retrieve keys and values as cell arrays, using the
## "keys" and "values" properties. These properties are read-only.
##
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function d = dict (keys, values)

  if (nargin == 0)
    keys = values = cell (0, 1);
  elseif (nargin == 1)
    if (iscellstr (keys))
      keys = sort (keys(:));
      values = cell (numel (keys), 1);
    elseif (isstruct (keys))
      values = struct2cell (keys)(:,:);
      if (columns (values) != 1)
        error ("dict: structure must be a scalar");
      endif
      [keys, ind] = sort (fieldnames (keys));
      values = values(ind);        
    else
      error ("dict: keys must be a cell vector of strings");
    endif
  elseif (nargin == 2)
    [keys, idx] = sort (keys(:));
    values = values (idx)(:);
  else
    print_usage ();
  endif

  d = class (struct ("keys", {keys}, "values", {values}), "dict");

endfunction

%!test
%! free = dict ();
%! free({"computing", "society"}) = {true};
%! assert (free("computing"), free("society"));
