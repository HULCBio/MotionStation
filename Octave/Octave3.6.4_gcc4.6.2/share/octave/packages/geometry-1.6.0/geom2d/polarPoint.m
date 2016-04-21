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
## @deftypefn {Function File} {@var{point} = } polarPoint (@var{rho}, @var{theta})
## @deftypefnx {Function File} {@var{point} = } polarPoint (@var{theta})
## @deftypefnx {Function File} {@var{point} = } polarPoint (@var{point}, @var{rho}, @var{theta})
## @deftypefnx {Function File} {@var{point} = } polarPoint (@var{x0}, @var{y0}, @var{rho}, @var{theta})
##Create a point from polar coordinates (rho + theta)
##
##   Creates a point using polar coordinate. @var{theta} is angle with horizontal
##   (counted counter-clockwise, and in radians), and @var{rho} is the distance to
##   origin. If only angle is given radius @var{rho} is assumed to be 1.
##
##   If a point is given, adds the coordinate of the point to the coordinate of the specified
##   point. For example, creating a point with :
##     P = polarPoint([10 20], 30, pi/2);
##   will give a result of [40 20].
##
##   @seealso{points2d}
## @end deftypefn

function point = polarPoint(varargin)

  # default values
  x0 = 0; y0=0;
  rho = 1;
  theta =0;

  # process input parameters
  if length(varargin)==1
      theta = varargin{1};
  elseif length(varargin)==2
      rho = varargin{1};
      theta = varargin{2};
  elseif length(varargin)==3
      var = varargin{1};
      x0 = var(:,1);
      y0 = var(:,2);
      rho = varargin{2};
      theta = varargin{3};
  elseif length(varargin)==4
      x0 = varargin{1};
      y0 = varargin{2};
      rho = varargin{3};
      theta = varargin{4};
  end

  point = [x0 + rho.*cos(theta) , y0+rho.*sin(theta)];

endfunction


