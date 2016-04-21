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
## @deftypefn{Function File} {[@var{q}, @var{r}, @var{z}] =} cod (@var{a})
## @deftypefnx{Function File} {[@var{q}, @var{r}, @var{z}, @var{p}] =} cod (@var{a})
## @deftypefnx{Function File} {[@dots{}] =} cod (@var{a}, '0')
## Computes the complete orthogonal decomposition (COD) of the matrix @var{a}:
## @example
##   @var{a} = @var{q}*@var{r}*@var{z}'
## @end example
## Let @var{a} be an M-by-N matrix, and let @code{K = min(M, N)}. 
## Then @var{q} is M-by-M orthogonal, @var{z} is N-by-N orthogonal,
## and @var{r} is M-by-N such that @code{@var{r}(:,1:K)} is upper 
## trapezoidal and @code{@var{r}(:,K+1:N)} is zero.
## The additional @var{p} output argument specifies that pivoting should be used in
## the first step (QR decomposition). In this case,
## @example
##   @var{a}*@var{p} = @var{q}*@var{r}*@var{z}'
## @end example
## If a second argument of '0' is given, an economy-sized factorization is returned
## so that @var{r} is K-by-K.
##
## @emph{NOTE}: This is currently implemented by double QR factorization plus some
## tricky manipulations, and is not as efficient as using xRZTZF from LAPACK.
## @seealso{qr}
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function [q, r, z, p] = cod (a, varargin)

  if (nargin < 1 || nargin > 2 || nargout > 4 || ! ismatrix (a))
    print_usage ();
  endif

  [m, n] = size (a);
  k = min (m, n);
  economy = nargin == 2;
  pivoted = nargout == 4;

  ## Compute the initial QR decomposition
  if (pivoted)
    [q, r, p] = qr (a, varargin{:});
  else
    [q, r] = qr (a, varargin{:});
  endif

  if (m >= n)
    ## In this case, Z is identity, and we're finished.
    z = eye (n, class (a));
  else
    ## Permutation inverts row order.
    pr = eye (m) (m:-1:1, :);
    ## Permutation inverts first m columns order.
    pc = eye (n) ([m:-1:1, m+1:n], :);
    ## Make n-by-m matrix, invert first m columns
    r = (pr * r * pc')';
    ## QR factorize again.
    [z, r] = qr (r, varargin{:});
    ## Recover final R and Z
    if (economy)
      r = pr * r' * pr';
      z = pc * z * pr';
    else
      r = pr * r' * pc';
      z = pc * z * pc';
    endif
  endif

endfunction

%!test
%! a = rand (5, 10);
%! [q, r, z] = cod (a);
%! assert (norm (q*r*z' - a) / norm (a) < 1e-10);
%!test
%! a = rand (5, 10) + i * rand (5, 10);
%! [q, r, z] = cod (a);
%! assert (norm (q*r*z' - a) / norm (a) < 1e-10);
%!test
%! a = rand (5, 10);
%! [q, r, z, p] = cod (a);
%! assert (norm (q*r*z' - a*p) / norm (a) < 1e-10);
