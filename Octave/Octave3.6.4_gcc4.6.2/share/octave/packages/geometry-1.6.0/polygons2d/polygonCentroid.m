## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {[ @var{pt}, @var{area} ] = } polygonCentroid (@var{points})
## @deftypefnx {Function File} {[ @dots{} ]= } polygonCentroid (@var{ptx},@var{pty})
## Compute the centroid (center of mass) of a polygon.
##
## Computes the center of mass of a polygon defined by @var{points}. @var{points} is a
## N-by-2 matrix. The two columns can be given separately using @var{ptx} and @var{pty}
## for the x and y component respectively.
##
## The area of the polygon is returned in the second output argument.
##
## Adapted from @url{http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/}
##
## @seealso{polygons2d, polygonArea, drawPolygon}
## @end deftypefn

function [pt A] = polygonCentroid(varargin)

  if nargin==1
      var = varargin{1};

      px = var(:,1);
      py = var(:,2);

  elseif nargin==2

      px = varargin{1};
      py = varargin{2};

  end

  # Algorithme P. Bourke (vectorized)
  inext  = [2:N 1];

  cros = (px.*py(inext) - px(inext).*py);
  sx_  = sum ( (px + px(inext)) .*  cros);
  sy_  = sum ( (py + py(inext)) .*  cros);

  A = sum(cros) / 2;

  pt_ = [sx_ sy_]/A/6;

  #  sx = 0;
  #  sy = 0;
  #  N = length(px);
  #  for i=1:N-1
  #      sx = sx + (px(i)+px(i+1))*(px(i)*py(i+1) - px(i+1)*py(i));
  #      sy = sy + (py(i)+py(i+1))*(px(i)*py(i+1) - px(i+1)*py(i));
  #  end
  #  sx = sx + (px(N)+px(1))*(px(N)*py(1) - px(1)*py(N));
  #  sy = sy + (py(N)+py(1))*(px(N)*py(1) - px(1)*py(N));
  #  pt = [sx sy]/6/polygonArea(px, py)

endfunction
