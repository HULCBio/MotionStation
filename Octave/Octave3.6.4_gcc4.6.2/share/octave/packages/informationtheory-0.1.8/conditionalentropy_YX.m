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
##

## -*- texinfo -*-
## @deftypefn {Function File} {} conditionalentropy_YX (@var{xy}) 
##
## Computes the
## @iftex
## @tex
## $H(\frac{Y}{X}) = \sum_i{P(X_i) H(\frac{Y}{X_i})$, where
## $H(\frac{Y}{X_i}) = \sum_k{-P(\frac{Y_k}{X_i}) \log(P(\frac{Y_k}{X_i}))$.
## @end tex
## @end iftex
## @ifnottex
## H(Y/X) = SUM( P(Xi)*H(Y/Xi) ), where H(Y/Xi) = SUM( -P(Yk/Xi)log(P(Yk/Xi)))
## @end ifnottex
## The matrix @var{xy} must have @var{y} along rows and @var{x} along columns.
## @iftex
## @tex
## $X_i = \sum{COL_i} 
## $Y_i = \sum{ROW_i}
## $H(Y|X) = H(X,Y) - H(X)$
## @end tex
## @end iftex
## @ifnottex
## Xi = SUM( COLi ) 
## Yi = SUM( ROWi )
## H(Y|X) = H(X,Y) - H(X)
## @end ifnottex
## @end deftypefn
## @seealso{entropy, conditionalentropy_XY}

function val=conditionalentropy_YX(XY)
  val=0.0;
  for i=1:size(XY)(1)
    Xi = sum(XY(:,i));
    val = val + Xi*entropy(XY(:,i)/sum(XY(:,i)));
  end
  return
end
%!assert(conditionalentropy_YX([0.7 0.3; 0.3 0.7]),1.7626,1e-4)
