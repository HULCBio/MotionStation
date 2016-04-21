## Copyright (C) 2007 Tiago Charters de Azevedo <tca@diale.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} lfdif (@var{a}, @var{b}, @var{alpha}, @var{beta}, @var{n})
## Approximate the solution of a boundary-value problem. The problem is
## defined as
##
## @iftex
## @example
## @tex
##  $y'' = p(x)  y' + q(x) y + r(x), a \le x \le b$, $y(a) = \alpha$, $y(b) = \beta$
## @end tex
## @end example
## @end iftex
## @ifnottex
## @example
##  y''=p(x)*y' + q(x)*y + r(x), a<=x<=b, y(a)=alpha, y(b)=beta
## @end example
## @end ifnottex
##
## @noindent
## by the linear finite-diffence method. The inputs are
##
## @table @asis
## @item a, b
## Endpoints
## @item alpha, beta
## boundary conditions
## @item n
## An integer value greater than or equal to 2
## @end table
## @end deftypefn

function sol = lfdif(ai, bi, alpha, beta, n)

  h = (bi - ai) / (n + 1);
  x = [ai + h : h : bi - h];
  a = 2 + h^2 * q(x);
  b = -1 +(h / 2.) * p(x);
  c = -1 - (h / 2.) * p(x);

  A = spdiag(c(2 : n), -1) + spdiag(a) + spdiag(b(1 : n - 1), 1);

  d(1) = -h^2 * r(x(1)) + (1 + (h / 2.) * p(x(1))) * alpha;
  d(2 : n - 1) = -h^2 * r(x(2 : n - 1));
  d(n) = -h^2 *r(x(n)) + (1 - (h / 2.) * p(x(n))) * beta;
  
  x = vertcat(ai, x', bi);
  y = vertcat(alpha, A\d', beta);

  sol = horzcat(x, y);
endfunction

