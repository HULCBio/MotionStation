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
## @deftypefn{Function File} {@var{x} =} smwsolve (@var{a}, @var{u}, @var{v}, @var{b})
## @deftypefnx{Function File} {} smwsolve (@var{solver}, @var{u}, @var{v}, @var{b})
## Solves the square system @code{(A + U*V')*X == B}, where @var{u} and @var{v} are
## matrices with several columns, using the Sherman-Morrison-Woodbury formula,
## so that a system with @var{a} as left-hand side is actually solved. This is
## especially advantageous if @var{a} is diagonal, sparse, triangular or
## positive definite.
## @var{a} can be sparse or full, the other matrices are expected to be full.
## Instead of a matrix @var{a}, a user may alternatively provide a function
## @var{solver} that performs the left division operation.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function x = smwsolve (a, u, v, b)

  if (nargin != 4)
    print_usage ();
  endif
  
  n = columns (u);

  if (n != columns (v) || rows (a) != rows (u) || columns (a) != rows (v))
    error ("smwsolve: dimension mismatch");
  elseif (! issquare (a))
    error ("smwsolve: need a square matrix");
  endif


  nc = columns (b);
  n = columns (u);

  if (ismatrix (a))
    xx = a \ [b, u];
  elseif (isa (a, "function_handle"))
    xx = a ([b, u]);
    if (rows (xx) != rows (a) || columns (xx) != (nc + n))
      error ("smwsolve: invalid result from a solver function");
    endif
  else
    error ("smwsolve: a must be a matrix or function handle");
  endif

  x = xx(:,1:nc);
  y = xx(:,nc+1:nc+n);

  vxx = v' * xx;
  vx = vxx(:,1:nc);
  vy = vxx(:,nc+1:nc+n);

  x = x - y * ((eye (n) + vy) \ vx);

endfunction

%!test
%! A = 2.1*eye (10);
%! u = rand (10, 2); u /= diag (norm (u, "cols")); 
%! v = rand (10, 2); v /= diag (norm (v, "cols"));
%! b = rand (10, 2);
%! x1 = (A + u*v') \ b;
%! x2 = smwsolve (A, u, v, b);
%! assert (x1, x2, 1e-13);
