## Copyright (C) 2000 Paul Kienzle
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
## @deftypefn {Function File} {} {mktheta (@var{a}, @var{b})}
##
## Create a theta structure from the IIR system @code{Ay = Bx}.  See  poly2th
## for details on the theta structure.
##
## @end deftypefn
## @seealso {poly2th, idsim}

function th=mktheta(a,b)
  th=poly2th(a,b);
endfunction
