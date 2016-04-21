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
## @deftypefn {Function File} {@var{} =} function_name (@var{}, @var{})
## Draw a sphere as a mesh
##
##   drawSphere(SPHERE)
##   Where SPHERE = [XC YC ZC R], draw the sphere centered on the point with
##   coordinates [XC YC ZC] and with radius R, using a quad mesh.
##
##   drawSphere(CENTER, R)
##   Where CENTER = [XC YC ZC], specifies the center and the radius with two
##   arguments.
##
##   drawSphere(XC, YC, ZC, R)
##   Specifiy sphere center and radius as four arguments.
##
##   drawSphere(..., NAME, VALUE);
##   Specifies one or several options using parameter name-value pairs.
##   Available options are usual drawing options, as well as:
##   'nPhi'    the number of arcs used for drawing the meridians
##   'nTheta'  the number of circles used for drawing the parallels
##
##   H = drawSphere(...)
##   Return a handle to the graphical object created by the function.
##
##   [X Y Z] = drawSphere(...)
##   Return the coordinates of the vertices used by the sphere. In this
##   case, the sphere is not drawn.
##
##   Run @code{demo drawSphere} to see several examples.
##
## @seealso{spheres, circles3d, sphere, drawEllipsoid}
## @end deftypefn

function varargout = drawSphere(varargin)

  # process input options: when a string is found, assumes this is the
  # beginning of options
  options = {'FaceColor', 'g', 'linestyle', 'none'};
  for i=1:length(varargin)
      if ischar(varargin{i})
          options = [options(1:end) varargin(i:end)];
          varargin = varargin(1:i-1);
          break;
      end
  end

  # Parse the input (try to extract center coordinates and radius)
  if isempty(varargin)
      # no input: assumes unit sphere
      xc = 0;	yc = 0; zc = 0;
      r = 1;

  elseif length(varargin) == 1
      # one argument: concatenates center and radius
      sphere = varargin{1};
      xc = sphere(:,1);
      yc = sphere(:,2);
      zc = sphere(:,3);
      r  = sphere(:,4);

  elseif length(varargin) == 2
      # two arguments, corresponding to center and radius
      center = varargin{1};
      xc = center(1);
      yc = center(2);
      zc = center(3);
      r  = varargin{2};

  elseif length(varargin) == 4
      # four arguments, corresponding to XC, YX, ZC and R
      xc = varargin{1};
      yc = varargin{2};
      zc = varargin{3};
      r  = varargin{4};
  else
      error('drawSphere: please specify center and radius');
  end

  # number of meridians
  nPhi    = 32;
  ind = strmatch('nphi', lower(options(1:2:end)));
  if ~isempty(ind)
      ind = ind(1);
      nPhi = options{2*ind};
      options(2*ind-1:2*ind) = [];
  end

  # number of parallels
  nTheta  = 16;
  ind = strmatch('ntheta', lower(options(1:2:end)));
  if ~isempty(ind)
      ind = ind(1);
      nTheta = options{2*ind};
      options(2*ind-1:2*ind) = [];
  end

  # compute spherical coordinates
  theta   = linspace(0, pi, nTheta+1);
  phi     = linspace(0, 2*pi, nPhi+1);

  # convert to cartesian coordinates
  sintheta = sin(theta);
  x = xc + cos(phi')*sintheta*r;
  y = yc + sin(phi')*sintheta*r;
  z = zc + ones(length(phi),1)*cos(theta)*r;

  # Process output
  if nargout == 0
      # no output: draw the sphere
      surf(x, y, z, options{:});

  elseif nargout == 1
      # one output: compute
      varargout{1} = surf(x, y, z, options{:});

  elseif nargout == 3
      varargout{1} = x;
      varargout{2} = y;
      varargout{3} = z;
  end

endfunction

%!demo
%! # Draw four spheres with different centers
%! figure(1); clf; hold on;
%! drawSphere([10 10 30 5]);
%! drawSphere([20 30 10 5]);
%! drawSphere([30 30 30 5]);
%! drawSphere([30 20 10 5]);
%! view([-30 20]);
%! axis tight
%! axis equal;


%!demo
%! # Draw sphere with different settings
%! figure(1); clf;
%! drawSphere([10 20 30 10], 'linestyle', ':', 'facecolor', 'r');
%! axis tight
%! axis equal;

%!demo
%! # Draw sphere with different settings, but changes style using graphic handle
%! figure(1); clf;
%! h = drawSphere([10 20 30 10]);
%! set(h, 'edgecolor', 'none');
%! set(h, 'facecolor', 'r');
%! axis tight
%! axis equal;

%!demo
%! # Draw a sphere with high resolution
%! figure(1); clf;
%! h = drawSphere([10 20 30 10], 'nPhi', 360, 'nTheta', 180);
%! view(3);
%!  axis equal;
