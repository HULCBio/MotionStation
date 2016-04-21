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
## @deftypefn {Function File} { @var{ray} = } createRay (@var{point}, @var{angle})
## @deftypefnx {Function File} { @var{ray} = } createRay (@var{x0},@var{y0}, @var{angle})
## @deftypefnx {Function File} { @var{ray} = } createRay (@var{p1}, @var{p2})
##  Create a ray (half-line), from various inputs.
##
##  A Ray is represented in a parametric form: [x0 y0 dx dy].
##   x = x0 + t*dx
##   y = y0 + t*dy;
##   for all t>0.
##
##   @var{point} is a Nx2 array giving the starting point of the ray, and @var{angle} is the
##   orientation of the ray respect to the positive x-axis. The ray origin can be specified with 2 input arguments @var{x0},@var{y0}.
##
##   If two points @var{p1}, @var{p2} are given, creates a ray starting from point @var{p1} and going in the direction of point
##   @var{p2}.
##
##   Example
## @example
##   origin  = [3 4];
##   theta   = pi/6;
##   ray = createRay(origin, theta);
##   axis([0 10 0 10]);
##   drawRay(ray);
## @end example
##
## @seealso{rays2d, createLine, points2d}
## @end deftypefn

function ray = createRay(varargin)

  if length(varargin)==2
      p0 = varargin{1};
      arg = varargin{2};
      if size(arg, 2)==1
          # second input is the ray angle
          ray = [p0 cos(arg) sin(arg)];
      else
          # second input is another point
          ray = [p0 arg-p0];
      end
      
  elseif length(varargin)==3   
      x = varargin{1};
      y = varargin{2};
      theta = varargin{3};
      ray = [x y cos(theta) sin(theta)];   

  else
      error("Wrong number of arguments in 'createRay'. ");
  end

endfunction

%!shared p1,p2,ray
%!  p1 = [1 1];
%!  p2 = [2 3];
%!  ray = createRay(p1, p2);

%!assert (p1, ray(1,1:2), 1e-6);
%!assert (p2-p1, ray(1,3:4), 1e-6);

%!shared p1,p2,ray
%!  p1 = [1 1;1 1];
%!  p2 = [2 3;2 4];
%!  ray = createRay(p1, p2);

%!assert (2, size(ray, 1));
%!assert (p1, ray(:,1:2), 1e-6);
%!assert (p2-p1, ray(:,3:4), 1e-6);

