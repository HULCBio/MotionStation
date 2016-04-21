## Copyright (C) 2012 Rik Wehbring
## Copyright (C) 1995-2012 Kurt Hornik
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
## @deftypefn  {Function File} {} frnd (@var{m}, @var{n})
## @deftypefnx {Function File} {} frnd (@var{m}, @var{n}, @var{r})
## @deftypefnx {Function File} {} frnd (@var{m}, @var{n}, @var{r}, @var{c}, @dots{})
## @deftypefnx {Function File} {} frnd (@var{m}, @var{n}, [@var{sz}])
## Return a matrix of random samples from the F distribution with
## @var{m} and @var{n} degrees of freedom.
##
## When called with a single size argument, return a square matrix with
## the dimension specified.  When called with more than one scalar argument the
## first two arguments are taken as the number of rows and columns and any
## further arguments specify additional matrix dimensions.  The size may also
## be specified with a vector of dimensions @var{sz}.
## 
## If no size arguments are given then the result matrix is the common size of
## @var{m} and @var{n}.
## @end deftypefn

## Author: KH <Kurt.Hornik@wu-wien.ac.at>
## Description: Random deviates from the F distribution

function rnd = frnd (m, n, varargin)

  if (nargin < 2)
    print_usage ();
  endif

  if (!isscalar (m) || !isscalar (n))
    [retval, m, n] = common_size (m, n);
    if (retval > 0)
      error ("frnd: M and N must be of common size or scalars");
    endif
  endif

  if (iscomplex (m) || iscomplex (n))
    error ("frnd: M and N must not be complex");
  endif

  if (nargin == 2)
    sz = size (m);
  elseif (nargin == 3)
    if (isscalar (varargin{1}) && varargin{1} >= 0)
      sz = [varargin{1}, varargin{1}];
    elseif (isrow (varargin{1}) && all (varargin{1} >= 0))
      sz = varargin{1};
    else
      error ("frnd: dimension vector must be row vector of non-negative integers");
    endif
  elseif (nargin > 3)
    if (any (cellfun (@(x) (!isscalar (x) || x < 0), varargin)))
      error ("frnd: dimensions must be non-negative integers");
    endif
    sz = [varargin{:}];
  endif

  if (!isscalar (m) && !isequal (size (m), sz))
    error ("frnd: M and N must be scalar or of size SZ");
  endif

  if (isa (m, "single") || isa (n, "single"))
    cls = "single";
  else
    cls = "double";
  endif

  if (isscalar (m) && isscalar (n))
    if ((m > 0) && (m < Inf) && (n > 0) && (n < Inf))
      rnd = n/m * randg (m/2, sz) ./ randg (n/2, sz);
    else
      rnd = NaN (sz, cls);
    endif
  else
    rnd = NaN (sz, cls);

    k = (m > 0) & (m < Inf) & (n > 0) & (n < Inf);
    rnd(k) = n(k) ./ m(k) .* randg (m(k)/2) ./ randg (n(k)/2);
  endif

endfunction


%!assert(size (frnd (1,2)), [1, 1]);
%!assert(size (frnd (ones(2,1), 2)), [2, 1]);
%!assert(size (frnd (ones(2,2), 2)), [2, 2]);
%!assert(size (frnd (1, 2*ones(2,1))), [2, 1]);
%!assert(size (frnd (1, 2*ones(2,2))), [2, 2]);
%!assert(size (frnd (1, 2, 3)), [3, 3]);
%!assert(size (frnd (1, 2, [4 1])), [4, 1]);
%!assert(size (frnd (1, 2, 4, 1)), [4, 1]);

%% Test class of input preserved
%!assert(class (frnd (1, 2)), "double");
%!assert(class (frnd (single(1), 2)), "single");
%!assert(class (frnd (single([1 1]), 2)), "single");
%!assert(class (frnd (1, single(2))), "single");
%!assert(class (frnd (1, single([2 2]))), "single");

%% Test input validation
%!error frnd ()
%!error frnd (1)
%!error frnd (ones(3),ones(2))
%!error frnd (ones(2),ones(3))
%!error frnd (i, 2)
%!error frnd (2, i)
%!error frnd (1,2, -1)
%!error frnd (1,2, ones(2))
%!error frnd (1, 2, [2 -1 2])
%!error frnd (1,2, 1, ones(2))
%!error frnd (1,2, 1, -1)
%!error frnd (ones(2,2), 2, 3)
%!error frnd (ones(2,2), 2, [3, 2])
%!error frnd (ones(2,2), 2, 2, 3)

