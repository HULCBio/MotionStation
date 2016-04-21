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
## @deftypefn {Mapping Function} {} gradabs (@var{x})
## overloads built-in mapper @code{abs} for a gradient @var{x}
## @end deftypefn
## @seealso{abs}

## PKG_ADD: dispatch ("abs", "gradabs", "gradient")

function retval = gradabs (g)

  if nargin != 1
    usage ("gradabs (g)");
  endif

  if isreal (g)
    idx = find (g.x < 0);
    g.x = abs (g.x);
    if !isempty (idx)
      g.dx(:, idx) = -g.dx(:, idx);
    endif
  else
    tmp = abs (g.x);
    aux = (conj (g.x) ./ tmp)(:).';
    g.x = tmp;
    r = size (g.dx, 1);
    g.dx = real (g.dx .* aux(ones (1, r), :));
  endif
    retval = g;
endfunction
