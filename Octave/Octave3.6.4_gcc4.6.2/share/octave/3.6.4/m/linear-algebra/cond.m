## Copyright (C) 1993-2012 John W. Eaton
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
## @deftypefn  {Function File} {} cond (@var{A})
## @deftypefnx {Function File} {} cond (@var{A}, @var{p})
## Compute the @var{p}-norm condition number of a matrix.
##
## @code{cond (@var{A})} is ## defined as
## @tex
## $ {\parallel A \parallel_p * \parallel A^{-1} \parallel_p .} $
## @end tex
## @ifnottex
## @code{norm (@var{A}, @var{p}) * norm (inv (@var{A}), @var{p})}.
## @end ifnottex
##
## By default @code{@var{p} = 2} is used which implies a (relatively slow)
## singular value decomposition.  Other possible selections are
## @code{@var{p} = 1, Inf, "fro"} which are generally faster.  See
## @code{norm} for a full discussion of possible @var{p} values.
## @seealso{condest, rcond, norm, svd}
## @end deftypefn

## Author: jwe

function retval = cond (A, p)

  if (nargin && nargin < 3)
    if (ndims (A) > 2)
      error ("cond: only valid on 2-D objects");
    endif

    if (nargin <2)
      p = 2;
    endif

    if (! ischar (p) && p == 2)
      [nr, nc] = size (A);
      if (nr == 0 || nc == 0)
        retval = 0.0;
      elseif (any (any (isinf (A) | isnan (A))))
        error ("cond: argument must not contain Inf or NaN values");
      else
        sigma   = svd (A);
        sigma_1 = sigma(1);
        sigma_n = sigma(end);
        if (sigma_1 == 0 || sigma_n == 0)
          retval = Inf;
        else
          retval = sigma_1 / sigma_n;
        endif
      endif
    else
      retval = norm (A, p) * norm (inv (A), p);
    endif
  else
    print_usage ();
  endif

endfunction

%!test
%! y= [7, 2, 3; 1, 3, 4; 6, 4, 5];
%! tol = 1e-6;
%! type = {1, 2, 'fro', 'inf', inf};
%! for n = 1:numel(type)
%!   rcondition(n) = 1 / cond (y, type{n});
%! endfor
%! assert (rcondition, [0.017460, 0.019597, 0.018714, 0.012022, 0.012022], tol);

%!assert (abs (cond ([1, 2; 2, 1]) - 3) < sqrt (eps));

%!assert (cond ([1, 2, 3; 4, 5, 6; 7, 8, 9]) > 1.0e+16);

%!error cond ();

%!error cond (1, 2, 3);

