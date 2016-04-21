## Copyright (C) 2010 Michel D. Schmid <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} __dradbas (@var{n})
## First derivative of the radial basis transfer function.
##
## @code{__dradbas(n) = exp(-n^2)*-2*x}
##
## @end deftypefn

## Author: Michel D. Schmid


function retval = __dradbas (n)

  if (nargin != 1)
    print_usage ();
  else
    retval = exp (-n^2)*(-2)*x;
    # the derivative of exp(-n^2) must be calculated
    # with help of the chain-rule!
    # d/dx of e^x = e^x
    # d/dx of -x^2 = -2x
    # now calculate the product of both
  endif
endfunction


#%!assert (radbas (3), exp (-3^2));
