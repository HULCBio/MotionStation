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
## @deftypefn {Function File} {@var{h} =} drawCylinder (@var{cyl})
## @deftypefnx {Function File} {@var{h} =} drawCylinder (@var{cyl},@var{n})
## @deftypefnx {Function File} {@var{h} =} drawCylinder (@dots{}, @var{opt})
## @deftypefnx {Function File} {@var{h} =} drawCylinder (@dots{}, @asis{"Facecolor"},@var{color})
## @deftypefnx {Function File} {@var{h} =} drawCylinder (@dots{})
## Draw a cylinder
##
##   drawCylinder(@var{cyl})
##   where @var{cyl} is a cylinder defined by [x1 y1 z1 x2 y2 z2 r]:
##   [x1 y2 z1] are coordinates of starting point, [x2 y2 z2] are
##   coordinates of ending point, and R is the radius of the cylinder,
##   draws the corresponding cylinder on the current axis.
##
##   drawCylinder(@var{cyl}, @var{N})
##   uses @var{N} points for discretisation of angle. Default value is 32.
##
##   drawCylinder(..., @var{opt})
##   with @var{opt} = 'open' (default) or 'closed', specify if bases of the
##   cylinder should be drawn.
##
##   drawCylinder(..., @asis{"FaceColor"}, @var{color})
##   Specifies the color of the cylinder. Any couple of parameters name and
##   value can be given as argument, and will be transfered to the 'surf'
##   matlab function
##
##   @var{h} = drawCylinder(...)
##   returns a handle to the patch representing the cylinder.
##
##   Run @code{demo drawCylinder} to see several examples.
##
##   WARNING: This function doesn't work in gnuplot (as of version 4.2).
##
## @seealso{drawSphere, drawLine3d, surf}
## @end deftypefn

function varargout = drawCylinder(cyl, varargin)

  if strcmpi (graphics_toolkit(),"gnuplot")
    error ("geometry:Incompatibility", ...
    ["This function doesn't work with gnuplot (as of version 4.1)." ...
     "Use graphics_toolkit('fltk').\n"]);
  end

  ## Input argument processing
  if iscell(cyl)
      res = zeros(length(cyl), 1);
      for i=1:length(cyl)
          res(i) = drawCylinder(cyl{i}, varargin{:});
      end

      if nargout>0
          varargout{1} = res;
      end
      return;
  end

  # default values
  N = 32;
  closed = true;

  # check number of discretization steps
  if ~isempty(varargin)
      var = varargin{1};
      if isnumeric(var)
          N = var;
          varargin = varargin(2:end);
      end
  end

  # check if cylinder must be closed or open
  if ~isempty(varargin)
      var = varargin{1};
      if ischar(var)
          if strncmpi(var, 'open', 4)
              closed = false;
              varargin = varargin(2:end);
          elseif strncmpi(var, 'closed', 5)
              closed = true;
              varargin = varargin(2:end);
          end
      end
  end


  ## Computation of mesh coordinates

  # extreme points of cylinder
  p1 = cyl(1:3);
  p2 = cyl(4:6);

  # radius of cylinder
  r = cyl(7);

  # compute orientation angle of cylinder
  [theta phi rho] = cart2sph2d(p2 - p1);
  dphi = linspace(0, 2*pi, N+1);

  # generate a cylinder oriented upwards
  x = repmat(cos(dphi) * r, [2 1]);
  y = repmat(sin(dphi) * r, [2 1]);
  z = repmat([0 ; rho], [1 length(dphi)]);

  # transform points
  trans   = localToGlobal3d(p1, theta, phi, 0);
  pts     = transformPoint3d([x(:) y(:) z(:)], trans);

  # reshape transformed points
  x2 = reshape(pts(:,1), size(x));
  y2 = reshape(pts(:,2), size(x));
  z2 = reshape(pts(:,3), size(x));


  ## Display cylinder mesh

  # add default drawing options
  varargin = [{'FaceColor', 'g', 'edgeColor', 'none'} varargin];

  # plot the cylinder as a surface
  hSurf = surf(x2, y2, z2, varargin{:});

  # eventually plot the ends of the cylinder
  if closed
      ind = find(strcmpi(varargin, 'facecolor'), 1, 'last');
      if isempty(ind)
          color = 'k';
      else
          color = varargin{ind+1};
      end

      patch(x2(1,:)', y2(1,:)', z2(1,:)', color, 'edgeColor', 'none');
      patch(x2(2,:)', y2(2,:)', z2(2,:)', color, 'edgeColor', 'none');
  end

  # format ouptut
  if nargout == 1
      varargout{1} = hSurf;
  end

endfunction

%!demo
%!  close all
%!  graphics_toolkit ("fltk")
%!
%!  figure;
%!  h = drawCylinder([0 0 0 10 20 30 5],'FaceColor', 'r');
%!  set(h, 'facecolor', 'g');
%!  axis equal
%!  view([60 30])
%!
%!  figure;
%!  drawCylinder([0 0 0 10 20 30 5], 'open');
%!  axis equal
%!  view([60 30])
%!
%!  figure;
%!  drawCylinder([0 0 0 10 20 30 5], 'FaceColor', 'r');
%!  axis equal
%!  view([60 30])
%!
%!  figure;
%!  h = drawCylinder([0 0 0 10 20 30 5]);
%!  set(h, 'facecolor', 'b');
%!  axis equal
%!  view([60 30])

%!demo
%!  close all
%!  graphics_toolkit ("fltk")
%!
%!  # Draw three mutually intersecting cylinders
%!  p0 = [30 30 30];
%!  p1 = [90 30 30];
%!  p2 = [30 90 30];
%!  p3 = [30 30 90];
%!
%!  figure;
%!  drawCylinder([p0 p1 25], 'FaceColor', 'r');
%!  hold on
%!  drawCylinder([p0 p2 25], 'FaceColor', 'g');
%!  drawCylinder([p0 p3 25], 'FaceColor', 'b');
%!  axis equal
%!  view([60 30])

%!demo
%!  close all
%!  graphics_toolkit ("gnuplot")
