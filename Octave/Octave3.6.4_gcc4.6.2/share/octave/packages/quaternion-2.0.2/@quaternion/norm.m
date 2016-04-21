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
## @deftypefn {Function File} {@var{n} =} norm (@var{q})
## Norm of a quaternion.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function n = norm (a)

  if (nargin != 1)
    print_usage ();
  endif
  
  if (! isscalar (a.w))
    warning ("norm: use 'abs' to calculate the lengths of quaternion arrays");
    error ("norm: only the 2-norm of scalar quaternions is implemented until now");
  endif

  n = abs (a);

endfunction
