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
## @deftypefn {Function File} {} mutualinformation (@var{xy})
##
## Computes the mutual information of the given channel transition matrix.
## By definition we have @code{I(@var{x}, @var{y})} given as
## @code{I(@var{x}:@var{y}) = SUM(P(@var{x},@var{y}) * log2(p(@var{x},@var{y})
## / p(@var{x})/p(@var{y}))) = relative_entropy(P(@var{x},@var{y}) ||
## P(@var{x}),P(@var{y}))}
## Mutual Information, is amount of information, one variable
## has, about the other. It is the reduction of uncertainity.
## This is a symmetric function.
## @seealso{entropy, conditionalentropy}
## @end deftypefn

function val=mutualinformation(XY)
  if nargin < 1 || ~ismatrix(XY)
    error('Usage: mutualinformation(XY) where XY is the transition matrix');
  end

  val=0.0;
  X=marginalc(XY);
  Y=marginalr(XY);

  cols=size(XY,1);
  rows=size(XY,2);

  for i=1:rows
      tVal=XY(i,:)./(X*Y(i));
      #cannot handle infinities,user should be prepared
      nz_idx=(tVal > 0);
      val=val+ sum(XY(i,nz_idx).*log2(tVal(nz_idx)));
  end

  return
end
%!assert(mutualinformation([0.7 0.3; 0.3 0.7]),-1.7626,1e-4)
