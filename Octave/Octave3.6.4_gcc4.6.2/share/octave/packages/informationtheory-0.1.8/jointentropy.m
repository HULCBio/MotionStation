## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {} jointentropy (@var{xy})
##
## Computes the joint entropy of the given channel transition matrix.
## By definition we have @code{H(@var{x}, @var{y})} given as
## @code{H(@var{x}:@var{y}) = SUMx(SUMy(P(@var{x}, @var{y}) * 
## log2(p(@var{x}, @var{y}))))}
## @end deftypefn
## @seealso{entropy, conditionalentropy}

function val=jointentropy(XY)
     if nargin < 1 || ~ismatrix(XY)
       error('Usage: jointentropy(XY) where XY is the transition matrix');
     end

     val=0.0;
     S=size(XY);
     if (S(1)==1)
       val=entropy(XY)
     else
       row=S(2);
       for i=1:row
	 val=val+entropy(XY(i,:));
       end
     end
     return
end
%!assert(jointentropy([0.7 0.3; 0.3 0.7]),1.7626,1e-4)
