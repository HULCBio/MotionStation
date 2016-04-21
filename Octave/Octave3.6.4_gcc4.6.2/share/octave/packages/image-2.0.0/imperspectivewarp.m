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
## @deftypefn {Function File} @var{warped} = imperspectivewarp(@var{im}, @var{P}, @var{interp}, @var{bbox}, @var{extrapval})
## @deftypefnx{Function File} [@var{warped}, @var{valid}] = imperspectivewarp(@dots{})
## Applies the spatial perspective homogeneous transformation @var{P} to the image @var{im}.
## The transformation matrix @var{P} must be a 3x3 homogeneous matrix, or 2x2 or 2x3
## affine transformation matrix.
## 
## The resulting image @var{warped} is computed using an interpolation method that
## can be selected through the @var{interp} argument. This must be one
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
## By default the resulting image contains the entire warped image. In some situation
## you only parts of the warped image. The argument @var{bbox} controls this, and can
## be one of the following strings
## @table @code
## @item "loose"
## The entire warped result is returned. This is the default behavior.
## @item "crop"
## The central part of the image of the same size as the input image is returned.
## @item "same"
## The size and coordinate system of the input image is keept.
## @end table
##
## All values of the result that fall outside the original image will
## be set to @var{extrapval}. For images of class @code{double} @var{extrapval}
## defaults to @code{NA} and for other classes it defaults to 0.
##
## The optional output @var{valid} is a matrix of the same size as @var{warped}
## that contains the value 1 in pixels where @var{warped} contains an interpolated
## value, and 0 in pixels where @var{warped} contains an extrapolated value.
## @seealso{imremap, imrotate, imresize, imshear, interp2}
## @end deftypefn

function [warped, valid] = imperspectivewarp(im, P, interp = "bilinear", bbox = "loose", extrapolation_value = NA)
  ## Check input
  if (nargin < 2)
    print_usage();
  endif
  
  [imrows, imcols, imchannels, tmp] = size(im);
  if (tmp != 1 || (imchannels != 1 && imchannels != 3))
    error("imperspectivewarp: first input argument must be an image");
  endif
  
  if (ismatrix(P) && ndims(P) == 2)
    if (issquare(P) && rows(P) == 3) # 3x3 matrix
      if (P(3,3) != 0)
        P /= P(3,3);
      else
        error("imperspectivewarp: P(3,3) must be non-zero");
      endif
    elseif (rows(P) == 2 && (columns(P) == 2 || columns(P) == 3)) # 2x2 or 2x3 matrix
      P(3,3) = 1;
    else # unsupported matrix size
      error("imperspectivewarp: transformation matrix must be 2x2, 2x3, or 3x3");
    endif
  else
    error("imperspectivewarp: transformation matrix not valid");
  endif
  
  if (!any(strcmpi(interp, {"nearest", "linear", "bilinear", "cubic", "bicubic"})))
    error("imperspectivewarp: unsupported interpolation method");
  endif
  if (any(strcmpi(interp, {"bilinear", "bicubic"})))
    interp = interp(3:end); # Remove "bi"
  endif
  interp = lower(interp);
  
  if (!any(strcmpi(bbox, {"loose", "crop", "same"})))
    error("imperspectivewarp: bounding box must be either 'loose', 'crop', or 'same'");
  endif
  
  if (!isscalar(extrapolation_value))
    error("imperspective: extrapolation value must be a scalar");
  endif
  
  ## Do the transformation
  [y, x, tmp] = size(im);
  ## Transform corners
  corners = [1, 1, 1;
             1, y, 1;
             x, 1, 1;
             x, y, 1]';
  Tcorners = P*corners;
  Tx = Tcorners(1,:)./Tcorners(3,:);
  Ty = Tcorners(2,:)./Tcorners(3,:);

  ## Do cropping?
  x1 = round(min(Tx)); x2 = round(max(Tx));
  y1 = round(min(Ty)); y2 = round(max(Ty));
  # FIXME: This seems to work fine for rotations, but
  # somebody who knows computational geometry should
  # be able to come up with a better algorithm.
  if (strcmpi(bbox, "crop"))
    xl = x2 - x1 + 1;
    yl = y2 - y1 + 1;
    xd = (xl - x)/2;
    yd = (yl - y)/2;
    x1 += xd; x2 -= xd;
    y1 += yd; y2 -= yd;
  elseif (strcmpi(bbox, "same"))
    x1 = 1; x2 = x;
    y1 = 1; y2 = y;
  endif
 
  ## Transform coordinates
  [X, Y] = meshgrid(x1:x2, y1:y2);
  [sy, sx] = size(X);
  D = [X(:), Y(:), ones(sx*sy, 1)]';
  PD = inv(P)*D;
  XI = PD(1,:)./PD(3,:);
  YI = PD(2,:)./PD(3,:);
  XI = reshape(XI, sy, sx);
  YI = reshape(YI, sy, sx);

  clear X Y D PD;
  
  ## Interpolate
  [warped, valid] = imremap(im, XI, YI, interp, extrapolation_value);

endfunction

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure(), imshow(I);
%! ## Resize the image to the double size and show it
%! P = diag([1, 1, 0.5]);
%! warped = imperspectivewarp(I, P);
%! figure(), imshow(warped);

%!demo
%! ## Generate a synthetic image and show it
%! I = tril(ones(100)) + abs(rand(100)); I(I>1) = 1;
%! I(20:30, 20:30) = !I(20:30, 20:30);
%! I(70:80, 70:80) = !I(70:80, 70:80);
%! figure(), imshow(I);
%! ## Rotate the image around (0, 0) by -0.4 radians and show it
%! R = [cos(-0.4) sin(-0.4); -sin(-0.4) cos(-0.4)];
%! warped = imperspectivewarp(I, R, :, :, 0);
%! figure(), imshow(warped);
