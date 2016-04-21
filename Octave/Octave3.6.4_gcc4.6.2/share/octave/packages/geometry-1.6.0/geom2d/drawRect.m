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
## @deftypefn {Function File} {@var{r} = } drawRect (@var{x}, @var{y}, @var{w}, @var{h})
## @deftypefnx {Function File} {@var{r} = } drawRect (@var{x}, @var{y}, @var{w}, @var{h}, @var{theta})
## @deftypefnx {Function File} {@var{r} = } drawRect (@var{coord})
## Draw rectangle on the current axis.
##   
##   r = DRAWRECT(x, y, w, h) draw rectangle with width W and height H, at
##   position (X, Y).
##   the four corners of rectangle are then :
##   (X, Y), (X+W, Y), (X, Y+H), (X+W, Y+H).
##
##   r = DRAWRECT(x, y, w, h, theta) also specifies orientation for
##   rectangle. Theta is given in degrees.
##
##   r = DRAWRECT(coord) is the same as DRAWRECT(X,Y,W,H), but all
##   parameters are packed into one array, whose dimensions is 4*1 or 5*1.
##
##
##   @seealso{drawBox, drawOrientedBox}
## @end deftypefn

function varargout = drawRect(varargin)

  # default values
  theta = 0;

  # get entered values
  if length(varargin) > 3
      x = varargin{1};
      y = varargin{2};
      w = varargin{3};
      h = varargin{4};
      if length(varargin)> 4 
          theta = varargin{5} * pi / 180;
      end
      
  else
      coord = varargin{1};
      x = coord(1);
      y = coord(2);
      w = coord(3);
      h = coord(4);
      if length(coord) > 4
          theta = coord(5) * pi / 180;
      end
  end

  r = zeros(size(x));
  for i = 1:length(x)
      tx = zeros(5, 1);
      ty = zeros(5, 1);
      tx(1) = x(i);
      ty(1) = y(i);
      tx(2) = x(i) + w(i) * cos(theta(i));
      ty(2) = y(i) + w(i) * sin(theta(i));
      tx(3) = x(i) + w(i) * cos(theta(i)) - h(i) * sin(theta(i));
      ty(3) = y(i) + w(i) * sin(theta(i)) + h(i) * cos(theta(i));
      tx(4) = x(i) - h(i) * sin(theta(i));
      ty(4) = y(i) + h(i) * cos(theta(i));
      tx(5) = x(i);
      ty(5) = y(i);

      r(i) = line(tx, ty);
  end

  if nargout > 0
      varargout{1} = r;
  end

endfunction

