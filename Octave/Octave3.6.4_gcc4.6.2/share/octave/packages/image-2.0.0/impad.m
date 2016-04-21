## Copyright (C) 2000 Teemu Ikonen <tpikonen@pcu.helsinki.fi>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} impad(@var{A}, @var{xpad}, @var{ypad}, [@var{padding}, [@var{const}]])
## Pad (augment) a matrix for application of image processing algorithms.
##
## Pads the input image @var{A} with @var{xpad}(1) elements from left, 
## @var{xpad}(2), elements from right, @var{ypad}(1) elements from above 
## and @var{ypad}(2) elements from below.
## Values of padding elements are determined from the optional arguments
## @var{padding} and @var{const}. @var{padding} is one of
##
## @table @samp
## @item "zeros"     
## pad with zeros (default)
##
## @item "ones"      
## pad with ones
##
## @item "constant"  
## pad with a value obtained from the optional fifth argument const
##
## @item "symmetric" 
## pad with values obtained from @var{A} so that the padded image mirrors 
## @var{A} starting from edges of @var{A}
## 
## @item "reflect"   
## same as symmetric, but the edge rows and columns are not used in the padding
##
## @item "replicate" 
## pad with values obtained from A so that the padded image 
## repeates itself in two dimensions
## 
## @end table
## @end deftypefn

## A nice test matrix for padding:
## A = 10*[1:5]' * ones(1,5) + ones(5,1)*[1:5]

function retim = impad(im, xpad, ypad, padding = "zeros", const = 1)
  ## Input checking
  if (!ismatrix(im) || ndims(im) < 2 || ndims(im) > 3)
    error("impad: first input argument must be an image");
  endif
  if (isscalar(xpad) && xpad >= 0)
    xpad(2) = xpad;
  elseif (!isreal(xpad) || numel(xpad) != 2 || any(xpad < 0))
    error("impad: xpad must be a positive scalar or 2-vector");
  endif
  if (isscalar(ypad) && ypad >= 0)
    ypad(2) = ypad;
  elseif (!isreal(ypad) || numel(ypad) != 2 || any(ypad < 0))
    error("impad: ypad must be a positive scalar or 2-vector");
  endif
  if (!isscalar(const))
    error("impad: fifth input argument must be a scalar");
  endif

  origx = size(im,2);
  origy = size(im,1);
  retx = origx + xpad(1) + xpad(2);
  rety = origy + ypad(1) + ypad(2);
  cl = class(im);

  for iter = size(im,3):-1:1
    A = im(:,:,iter);
    switch (lower(padding))
      case "zeros"
        retval = zeros(rety, retx, cl);
        retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
      case "ones"
        retval = ones(rety, retx, cl);
        retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
      case "constant"
        retval = const.*ones(rety, retx, cl);
        retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
      case "replicate"
        y1 = origy-ypad(1)+1;
        x1 = origx-xpad(1)+1;
        if (y1 < 1 || x1 < 1 || ypad(2) > origy || xpad(2) > origx)
          error("impad: too large padding for this padding type");
        else
          yrange1 = y1:origy;
          yrange2 = 1:ypad(2);
          xrange1 = x1:origx;
          xrange2 = 1:xpad(2);
          retval = [ A(yrange1, xrange1), A(yrange1, :), A(yrange1, xrange2);
                     A(:, xrange1),       A,             A(:, xrange2);
                     A(yrange2, xrange1), A(yrange2, :), A(yrange2, xrange2) ];
        endif                        
      case "symmetric"
        y2 = origy-ypad(2)+1;
        x2 = origx-xpad(2)+1;
        if (ypad(1) > origy || xpad(1) > origx || y2 < 1 || x2 < 1)
          error("impad: too large padding for this padding type");
        else
          yrange1 = 1 : ypad(1);
          yrange2 = y2 : origy;
          xrange1 = 1 : xpad(1);
          xrange2 = x2 : origx;
          retval = [ fliplr(flipud(A(yrange1, xrange1))), flipud(A(yrange1, :)), fliplr(flipud(A(yrange1, xrange2)));
                     fliplr(A(:, xrange1)), A, fliplr(A(:, xrange2));
                     fliplr(flipud(A(yrange2, xrange1))), flipud(A(yrange2, :)), fliplr(flipud(A(yrange2, xrange2))) ];
        endif      
      case "reflect"
        y2 = origy-ypad(2);
        x2 = origx-xpad(2);
        if (ypad(1)+1 > origy || xpad(1)+1 > origx || y2 < 1 || x2 < 1)
          error("impad: too large padding for this padding type");
        else
          yrange1 = 2 : ypad(1)+1;
          yrange2 = y2 : origy-1;
          xrange1 = 2 : xpad(1)+1;
          xrange2 = x2 : origx-1;
          retval = [ fliplr(flipud(A(yrange1, xrange1))), flipud(A(yrange1, :)), fliplr(flipud(A(yrange1, xrange2)));
                     fliplr(A(:, xrange1)), A, fliplr(A(:, xrange2));
                     fliplr(flipud(A(yrange2, xrange1))), flipud(A(yrange2, :)), fliplr(flipud(A(yrange2, xrange2))) ];
        endif
      otherwise   
        error("impad: unknown padding type");
    endswitch
    
    retim(:,:,iter) = retval;
  endfor
endfunction
