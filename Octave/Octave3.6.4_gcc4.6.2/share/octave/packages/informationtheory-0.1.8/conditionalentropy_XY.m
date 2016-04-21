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
## @deftypefn {Function File} {} conditionalentropy_XY (@var{x}, @var{y}) 
##
## Computes the
## @iftex
## @tex
## $H(\frac{X}{Y}) = \sum_i{P(Y_i) H(\frac{X}{Y_i})$, where
## $H(\frac{X}{Y_i}) = \sum_k{-P(\frac{X_k}{Y_i}) \log(P(\frac{X_k}{Y_i}))$,
## where $P(\frac{X_k}{Y_i} = \frac{P(X_k,Y_i)}{P(Y_i)}$.
## @end tex
## @end iftex
## @ifnottex
## H(X/Y) = SUM( P(Yi)*H(X/Yi) ) , where 
## H(X/Yi) = SUM( -P(Xk/Yi)log(P(Xk/Yi))), where
## P(Xk/Yi) = P(Xk,Yi)/P(Yi).
## @end ifnottex
## The matrix @var{xy} must have @var{y} along rows and @var{x} along columns.
## @iftex
## @tex
## $X_i = \sum{COL_i} 
## $Y_i = \sum{ROW_i}
## $H(X|Y) = H(X,Y) - H(Y)$
## @end tex
## @end iftex
## @ifnottex
## Xi = SUM( COLi ) 
## Yi = SUM( ROWi )
## H(X|Y) = H(X,Y) - H(Y)
## @end ifnottex
## @seealso{entropy, conditionalentropy}
## @end deftypefn

function val=conditionalentropy_XY(XY)
  val=0.0;
  for i=1:size(XY)(2)
    Yi = sum(XY(i,:));
    val = val + Yi*entropy(XY(i,:)/sum(XY(i,:)));
  end
  return
end
%!assert(conditionalentropy_XY([0.7 0.3; 0.3 0.7]),1.7626,1e-4)
