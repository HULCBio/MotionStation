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
## {[@var{z}, @var{p}]} = glagrule (@var{n})
##
## Compute the nodes @var{z} and weights @var{p}
## for the n-point Gauss-Laguerre quadrature rule for the
## approximation of the integral of w(x) * f(x) on [0,inf] with 
## w(x)=exp(-x). 
## 
## Example:
## @example
## [z, p] = glagrule (50);
## abs (sum (p) - quad (@(x) exp (-x), 0, 100, eps))
## @end example
##
## @seealso{grule,ghrule}
## @end deftypefn

function [z, p] = glagrule (n)

  if (n <= 1)
    z=1;
    p=1;
    return
  endif

  jac = zeros (n);
  k = [1:n];
  v = sqrt (k.^2);
  jac = jac + diag (v(1:n-1), 1) + diag (v(1:n-1), -1) + diag (2*(k-1)+1);
  [p,z] = eig (jac);
  norm2 = sqrt (diag(p'*p));     % weight normalization
  p = (1*p(1,:)'.^2) ./ norm2;   % 1 = beta0; 
  z = diag (z);		   

%!shared z, p
%!
%!test
%! [z, p] = glagrule (5);
%! err = abs (sum (p) - quad (@(x) exp (-x), 0, 100, eps));
%! assert (err, 0, sqrt (eps))
%!
%!test
%! err = abs (sum (p .* z) - quad (@(x) x .* exp (-x), 0, 100, eps));
%! assert (err, 0, sqrt (eps))
%!
%!test
%! err = abs (sum (p .* z.^2) - quad (@(x) x.^2 .* exp (-x), 0, 100, eps));
%! assert (err, 0, sqrt (eps))


