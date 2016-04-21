## Copyright (C) 2007 Alexander Barth <barth.alexander@gmail.com>
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
## @deftypefn {Function File} {[@var{RT},@var{xp}] =} radon(@var{I}, @var{theta})
## @deftypefnx {Function File} {[@var{RT},@var{xp}] =} radon(@var{I})
##
## Calculates the 2D-Radon transform of the matrix @var{I} at angles given in
## @var{theta}. To each element of @var{theta} corresponds a column in @var{RT}. 
## The variable @var{xp} represents the x-axis of the rotated coordinate.
## If @var{theta} is not defined, then 0:179 is assumed.
## @end deftypefn

function [RT,xp] = radon (I,theta)

  ## Input checking
  if (nargin == 0 || nargin > 2)
    print_usage ();
  elseif (nargin == 1)
    theta = 0:179;
  endif
  
  if (!ismatrix(I) || ndims(I) != 2)
    error("radon: first input must be a MxN matrix");
  endif
  
  if (!isvector(theta))
    error("radon: second input must be a vector");
  endif

  [m, n] = size (I);

  # center of image
  xc = floor ((m+1)/2);
  yc = floor ((n+1)/2);

  # divide each pixel into 2x2 subpixels

  d = reshape (I,[1 m 1 n]);
  d = d([1 1],:,[1 1],:);
  d = reshape (d,[2*m 2*n])/4;

  b = ceil (sqrt (sum (size (I).^2))/2 + 1);
  xp = [-b:b]';
  sz = size(xp);

  [X,Y] = ndgrid (0.75 - xc + [0:2*m-1]/2,0.75 - yc + [0:2*n-1]/2);

  X = X(:)';
  Y = Y(:)';
  d = d(:)';

  th = theta*pi/180;

  for l=1:length (theta)
    # project each pixel to vector (-sin(th),cos(th))
    Xp = -sin (th(l)) * X + cos (th(l)) * Y;
    
    ip = Xp + b + 1;

    k = floor (ip);
    frac = ip-k;

    RT(:,l) = accumarray (k',d .* (1-frac),sz) + accumarray (k'+1,d .* frac,sz);
  endfor

endfunction

%!test
%! A = radon(ones(2,2),30);
%! assert (A,[0 0 0.608253175473055 2.103325780167649 1.236538105676658 0.051882938682637 0]',1e-10)
