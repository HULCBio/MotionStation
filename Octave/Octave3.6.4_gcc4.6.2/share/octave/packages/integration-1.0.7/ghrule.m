## Copyright (C) 2003,2011  Eros Sormani, Marco Frontini
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
##
## @deftypefn {Function File} @
## {[@var{z}, @var{p}]} = ghrule (@var{n})
##
## Compute the nodes @var{z} and weights @var{p}
## for the n-point Gauss-Hermite quadrature rule for the
## approximation of the integral of w(x) * f(x) on [-inf,inf] with 
## w(x)=exp(-x^2). 
## 
## Example:
## @example
## [z, p] = ghrule (50);
## abs (sum (p) - quad (@(x) exp (-x.^2), -100, 100, eps))
## @end example
##
## @seealso{grule,glagrule}
## @end deftypefn

function [z, p] = ghrule (n)

  if (n <= 1)
    z=0; p = sqrt (pi);
    return
  endif

  jac = zeros (n);
  k = [1:n];
  v = sqrt (1/2 * k);
  jac += diag (v(1:n-1), 1) + diag (v(1:n-1), -1);
  [p, z] = eig (jac);
  norm2 =sqrt (diag (p' * p));               % weight normalization
  p = (sqrt (pi) * p(1,:)' .^ 2) ./ norm2;   % sqrt(pi) = beta0;
  z = diag (z);		   

endfunction

%!shared z, p 
%!
%!test
%! [z, p] = ghrule (5);
%! err = abs (sum (p) - quad (@(x) exp (-x.^2), -100, 100, eps));
%! assert (err, 0, sqrt (eps))
%!
%!test
%! err = abs (dot (z, p));
%! assert (err, 0, sqrt (eps))
%!
%!test
%! err = abs (dot (z.^7, p));
%! assert (err, 0, sqrt (eps))