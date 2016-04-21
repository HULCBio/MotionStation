## Copyright (C) 2006, 2007 Thomas Kasper, <thomaskasper@gmx.net>
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
## @deftypefn {Mapping Function} {} gradconj (@var{x})
## overloads built-in mapper @code{conj} for a gradient @var{x}
## @end deftypefn
## @seealso{conj}

## PKG_ADD: dispatch ("conj", "gradconj", "gradient")
function retval = gradconj (g)

  if nargin != 1
    usage ("gradconj (g)");
  endif

  g.x = conj (g.x);
  if iscomplex (g.dx)
    g.dx = conj (g.dx);
  endif

  retval = g;
endfunction
