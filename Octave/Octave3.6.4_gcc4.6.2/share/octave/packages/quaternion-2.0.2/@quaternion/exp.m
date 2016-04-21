## Copyright (C) 2011   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{qexp} =} exp (@var{q})
## Exponential of a quaternion.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = exp (q)

  if (nargin != 1)
    print_usage ();
  endif

  normv = normv (q);
  exps = exp (q.w);
  sinv = sin (normv);

  q.w = exps .* cos (normv);    
  q.x = exps .* (q.x ./ normv) .* sinv;
  q.y = exps .* (q.y ./ normv) .* sinv;
  q.z = exps .* (q.z ./ normv) .* sinv;

endfunction
