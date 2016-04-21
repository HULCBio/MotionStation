## Copyright (C) 2006 Joseph Wakeling <joseph.wakeling@webdrake.net>
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
##

## -*- texinfo -*-
## @deftypefn {Function File} {} condentr_seq (@var{seq_x}, @var{seq_y})
## Calculates information entropy of the sequence x
## conditional on the sequence y:
##      H(X|Y) = H(X,Y) - H(Y)
## @example
## @group
##          X=[1, 1, 2, 1, 1];
##          Y=[2, 2, 1, 1, 2];
##          condentr_seq(X,Y)
## @end group
## @end example
## @end deftypefn
## @seealso{infoentr_seq}

function Hcond = condentr_seq(x,y)
if nargin!=2
	usage("condentr(x,y)")
endif

Hcond = infoentr_seq(x,y) - infoentr_seq(y);
end
%!assert(condentr_seq([2, 2, 1, 1, 2],[1, 1, 2, 1, 1]),0.64902,1e-4)
