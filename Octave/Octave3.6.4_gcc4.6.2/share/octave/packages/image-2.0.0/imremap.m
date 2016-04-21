## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{warped} = imremap(@var{im}, @var{XI}, @var{YI})
## @deftypefnx{Function File} @var{warped} = imremap(@var{im}, @var{XI}, @var{YI}, @var{interp}, @var{extrapval})
## @deftypefnx{Function File} [@var{warped}, @var{valid} ] = imremap(@dots{})
## Applies any geometric transformation to the image @var{im}.
##
## The arguments @var{XI} and @var{YI} are lookup tables that define the resulting
## image
## @example
## @var{warped}(y,x) = @var{im}(@var{YI}(y,x), @var{XI}(y,x))
## @end example
## where @var{im} is assumed to be a continuous function, which is achieved
## by interpolation. Note that the image @var{im} is expressed in a (X, Y)-coordinate
## system and not a (row, column) system.
##
## The argument @var{interp} selects the used interpolation method, and most be one
## of the following strings
## @table @code
## @item "nearest"
## Nearest neighbor interpolation.
## @item "linear"
## @itemx "bilinear"
## Bilinear interpolation. This is the default behavior.
## @item "cubic"
## @itemx "bicubic"
## Bicubic interpolation.
## @end table
##
## All values of the result that fall outside the original image will
## be set to @var{extrapval}. For images of class @code{double} @var{extrapval}
## defaults to @code{NA} and for other classes it defaults to 0.
##
## The optional output @var{valid} is a matrix of the same size as @var{warped}
## that contains the value 1 in pixels where @var{warped} contains an interpolated
## value, and 0 in pixels where @var{warped} contains an extrapolated value.
## @seealso{imperspectivewarp, imrotate, imresize, imshear, interp2}
## @end deftypefn

function [warped, valid] = imremap(im, XI, YI, interp = "bilinear", extrapval = NA)
  ## Check input
  if (nargin < 3)
    print_usage();
  endif
  
  [imrows, imcols, imchannels, tmp] = size(im);
  if (tmp != 1 || (imchannels != 1 && imchannels != 3))
    error("imremap: first input argument must be an image");
  endif
  
  if (!size_equal(XI, YI) || !ismatrix(XI) || ndims(XI) != 2)
    error("imremap: XI and YI must be matrices of the same size");
  endif
  
  if (!any(strcmpi(interp, {"nearest", "linear", "bilinear", "cubic", "bicubic", "spline"})))
    error("imremap: unsupported interpolation method");
  endif
  if (any(strcmpi(interp, {"bilinear", "bicubic"})))
    interp = interp(3:end); # Remove "bi"
  endif
  interp = lower(interp);
  
  if (!isscalar(extrapval))
    error("imremap: extrapolation value must be a scalar");
  endif
  
  ## Interpolate
  if (imchannels == 1) # Gray
    warped = grayinterp(im, XI, YI, interp, NA);
  else # rgb image
    for i = 3:-1:1
      warped(:,:,i) = grayinterp(im(:,:,i), XI, YI, interp, NA);
    endfor
  endif
  valid = !isna(warped);
  warped(!valid) = extrapval;

  ## Change the class of the results according to the class of the image
  c = class(im);
  if (strcmpi(c, "uint8"))
    warped = uint8(warped);
  elseif (strcmpi(c, "uint16"))
    warped = uint16(warped);
  endif

endfunction

function [warped, valid] = grayinterp(im, XI, YI, interp, extrapval)
  if (strcmp(interp, "cubic"))
    warped = graybicubic(double(im), XI, YI, NA);
  else
    warped = interp2(double(im), XI, YI, interp, NA);
  endif
  valid = !isna(warped);
  warped(!valid) = extrapval;
endfunction

## -*- texinfo -*-
## @deftypefn {Function File} {@var{zi}=} bicubic (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi})
## Reference:
## Image Processing, Analysis, and Machine Vision, 2nd Ed.
## Sonka et.al.
## Brooks/Cole Publishing Company
## ISBN: 0-534-95393-X
## @seealso{interp2}
## @end deftypefn

function ZI = graybicubic (Z, XI, YI, extrapval = NA)
  
  ## Allocate output
  [X, Y] = meshgrid(1:columns(Z), 1:rows(Z));
  [Zr, Zc] = size(XI);
  ZI = zeros(Zr, Zc);
  
  ## Find inliers
  inside = !( XI < X(1) | XI > X(end) | YI < Y(1) | YI > Y(end) );
  
  ## Scale XI and YI to match indices of Z (not needed when interpolating images)
  #XI = (columns(Z)-1) * ( XI - X(1) ) / (X(end)-X(1)) + 1;
  #YI = (rows(Z)-1)    * ( YI - Y(1) ) / (Y(end)-Y(1)) + 1;
  
  ## Start the real work
  K = floor(XI);
  L = floor(YI);

  ## Coefficients
  AY1  = bc((YI-L+1)); AX1  = bc((XI-K+1));
  AY0  = bc((YI-L+0)); AX0  = bc((XI-K+0));
  AY_1 = bc((YI-L-1)); AX_1 = bc((XI-K-1));
  AY_2 = bc((YI-L-2)); AX_2 = bc((XI-K-2));

  ## Perform interpolation
  sz = size(Z);
  %ZI(inside) = AY_2 .* AX_2 .* Z(sym_sub2ind(sz, L+2, K+2)) ...
  ZI = AY_2 .* AX_2 .* Z(sym_sub2ind(sz, L+2, K+2)) ...
     + AY_2 .* AX_1 .* Z(sym_sub2ind(sz, L+2, K+1))    ...
     + AY_2 .* AX0  .* Z(sym_sub2ind(sz, L+2, K)) ...
     + AY_2 .* AX1  .* Z(sym_sub2ind(sz, L+2, K-1)) ...
     + AY_1 .* AX_2 .* Z(sym_sub2ind(sz, L+1, K+2)) ...
     + AY_1 .* AX_1 .* Z(sym_sub2ind(sz, L+1, K+1))    ...
     + AY_1 .* AX0  .* Z(sym_sub2ind(sz, L+1, K)) ...
     + AY_1 .* AX1  .* Z(sym_sub2ind(sz, L+1, K-1)) ...
     + AY0  .* AX_2 .* Z(sym_sub2ind(sz, L,   K+2)) ...
     + AY0  .* AX_1 .* Z(sym_sub2ind(sz, L,   K+1))    ...
     + AY0  .* AX0  .* Z(sym_sub2ind(sz, L,   K)) ...
     + AY0  .* AX1  .* Z(sym_sub2ind(sz, L,   K-1)) ...
     + AY1  .* AX_2 .* Z(sym_sub2ind(sz, L-1, K+2)) ...
     + AY1  .* AX_1 .* Z(sym_sub2ind(sz, L-1, K+1))    ...
     + AY1  .* AX0  .* Z(sym_sub2ind(sz, L-1, K)) ...
     + AY1  .* AX1  .* Z(sym_sub2ind(sz, L-1, K-1));
  ZI(!inside) = extrapval;

endfunction

## Checks if data is meshgrided
function b = isgriddata(X)
  D = X - repmat(X(1,:), rows(X), 1);
  b = all(D(:) == 0);
endfunction

## Checks if data is equally spaced (assumes data is meshgrided)
function b = isequallyspaced(X)
  Dx = gradient(X(1,:));
  b = all(Dx == Dx(1));
endfunction

## Computes the interpolation coefficients
function o = bc(x)
  x = abs(x);
  o = zeros(size(x));
  idx1 = (x < 1);
  idx2 = !idx1 & (x < 2);
  o(idx1) = 1 - 2.*x(idx1).^2 + x(idx1).^3;
  o(idx2) = 4 - 8.*x(idx2) + 5.*x(idx2).^2 - x(idx2).^3;
endfunction

## This version of sub2ind behaves as if the data was symmetrically padded
function ind = sym_sub2ind(sz, Y, X)
  Y(Y<1) = 1 - Y(Y<1);
  while (any(Y(:)>2*sz(1)))
    Y(Y>2*sz(1)) = round( Y(Y>2*sz(1))/2 );
  endwhile
  Y(Y>sz(1)) = 1 + 2*sz(1) - Y(Y>sz(1));
  X(X<1) = 1 - X(X<1);
  while (any(X(:)>2*sz(2)))
    X(X>2*sz(2)) = round( X(X>2*sz(2))/2 );
  endwhile
  X(X>sz(2)) = 1 + 2*sz(2) - X(X>sz(2));
  ind = sub2ind(sz, Y, X);
endfunction

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure, imshow(I);
%! ## Resize the image to the double size and show it
%! [XI, YI] = meshgrid(linspace(1, 100, 200));
%! warped = imremap(I, XI, YI);
%! figure, imshow(warped);

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure, imshow(I);
%! ## Rotate the image around (0, 0) by -0.4 radians and show it
%! [XI, YI] = meshgrid(1:100);
%! R = [cos(-0.4) sin(-0.4); -sin(-0.4) cos(-0.4)];
%! RXY = [XI(:), YI(:)] * R;
%! XI = reshape(RXY(:,1), [100, 100]); YI = reshape(RXY(:,2), [100, 100]);
%! warped = imremap(I, XI, YI);
%! figure, imshow(warped);
