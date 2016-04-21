## Copyright (C) 1994-2012 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} prepad (@var{x}, @var{l})
## @deftypefnx {Function File} {} prepad (@var{x}, @var{l}, @var{c})
## @deftypefnx {Function File} {} prepad (@var{x}, @var{l}, @var{c}, @var{dim})
## Prepend the scalar value @var{c} to the vector @var{x} until it is of length
## @var{l}.  If @var{c} is not given, a value of 0 is used.
##
## If @code{length (@var{x}) > @var{l}}, elements from the beginning of
## @var{x} are removed until a vector of length @var{l} is obtained.
##
## If @var{x} is a matrix, elements are prepended or removed from each row.
##
## If the optional argument @var{dim} is given, operate along this
## dimension.
## @seealso{postpad, cat, resize}
## @end deftypefn

## Author: Tony Richardson <arichard@stark.cc.oh.us>
## Created: June 1994

function y = prepad (x, l, c, dim)

  if (nargin < 2 || nargin > 4)
    print_usage ();
  endif

  if (nargin < 3 || isempty (c))
    c = 0;
  else
    if (! isscalar (c))
      error ("prepad: third argument must be empty or a scalar");
    endif
  endif

  nd = ndims (x);
  sz = size (x);
  if (nargin < 4)
    ## Find the first non-singleton dimension.
    (dim = find (sz > 1, 1)) || (dim = 1);
  else
    if (!(isscalar (dim) && dim == fix (dim))
        || !(1 <= dim && dim <= nd))
      error ("prepad: DIM must be an integer and a valid dimension");
    endif
  endif

  if (! isscalar (l) || l < 0)
    error ("prepad: second argument must be a positive scaler");
  endif

  if (dim > nd)
    sz(nd+1:dim) = 1;
  endif

  d = sz (dim);

  if (d >= l)
    idx = repmat ({':'}, nd, 1);
    idx{dim} = d-l+1:d;
    y = x(idx{:});
  else
    sz (dim) = l - d;
    y = cat (dim, c * ones (sz), x);
  endif

endfunction

%!error prepad ();
%!error prepad (1);
%!error prepad (1,2,3,4,5);
%!error prepad ([1,2], 2, 2,3);

%!assert (prepad ([1,2], 4), [0,0,1,2]);
%!assert (prepad ([1;2], 4), [0;0;1;2]);

%!assert (prepad ([1,2], 4, 2), [2,2,1,2]);
%!assert (prepad ([1;2], 4, 2), [2;2;1;2]);

%!assert (prepad ([1,2], 2, 2, 1), [2,2;1,2]);

## FIXME -- we need tests for multidimensional arrays.
