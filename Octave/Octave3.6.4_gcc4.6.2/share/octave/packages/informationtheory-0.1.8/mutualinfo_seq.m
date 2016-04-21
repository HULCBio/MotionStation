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
## @deftypefn {Function File} {} mutualinfo_seq (@var{seq_x}, @var{seq_y})
##
## Calculates mutual information of the sequences x and y:
##      I(X;Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = I(Y;X)
##
## @example
## @group
##          X=[1, 1, 2, 1, 1];
##          Y=[2, 2, 1, 1, 2];
##          mutualinfo_seq(X,Y)
## @end group
## @end example
## @end deftypefn
## @seealso{infoentr_seq}

function I = mutualinfo_seq(x,y)
if nargin!=2
	usage("mutualinfo(x,y)")
endif

I = infoentr_seq(x) - condentr_seq(x,y);
end
%!assert(mutualinfo_seq([1,2,2,1],[1,2,2,2]),0.31128,1e-4)
