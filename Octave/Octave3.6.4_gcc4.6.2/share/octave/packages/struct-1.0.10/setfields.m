## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
## Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2012 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Function File} {} @var{s} = setfields(@var{s},@var{key},@var{value},...)
## Sets @var{s}.@var{key1} = @var{value1},  @var{s}.@var{key2} = @var{value2}, etc, finally
## returning s.
## For some compatibility and flexibility.
## @seealso{cmpstruct, fields, rmfield, isstruct, getfields, isfield,struct}
## @end deftypefn

function s = setfields (s, varargin)

  if ((nargs = nargin ()) == 0)
    s = struct ();
  elseif (all (size (s) <= 1))
    if (rem (nargs, 2))
      pairs = reshape (varargin, 2, []);
      if (! iscellstr (pairs(1, :)))
        error ("setfields: called with non-string key");
      endif
      if (isempty (s))
        s = struct (); # might have been an empty array
      endif
      s = cell2fields (pairs(2, :), pairs(1, :), 2, s);
    else
      error ("setfields: expected struct, key1, val1, key2, val2, ...");
    endif
  else
    error ("structure must be scalar or empty");
  endif

%!assert (setfields ({}, 'key', 'value'), struct ('key', 'value'));
