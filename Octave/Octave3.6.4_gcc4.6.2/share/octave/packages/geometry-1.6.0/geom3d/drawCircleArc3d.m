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
## @deftypefn {Function File} drawCircleArc3d([@var{xc} @var{yc} @var{zc} @var{r} @var{theta} @var{phi} @var{psi} @var{start} @var{extent}])
## Draw a 3D circle arc
##
##   [@var{xc} @var{yc} @var{zc}]  : coordinate of arc center
##   @var{r}           : arc radius
##   [@var{theta} @var{phi}] : orientation of arc normal, in degrees (theta: 0->180).
##   @var{psi}         : roll of arc (rotation of circle origin)
##   @var{start}       : starting angle of arc, from arc origin, in degrees
##   @var{extent}      : extent of circle arc, in degrees (can be negative)
##
##   Drawing options can be specified, as for the plot command.
##
## @seealso{angles3, circles3d, drawCircle3d, drawCircleArc}
## @end deftypefn

function varargout = drawCircleArc3d(arc, varargin)

  if iscell(arc)
      h = [];
      for i = 1:length(arc)
          h = [h drawCircleArc3d(arc{i}, varargin{:})]; ##ok<AGROW>
      end
      if nargout > 0
          varargout = {h};
      end
      return;
  end

  if size(arc, 1) > 1
      h = [];
      for i = 1:size(arc, 1)
          h = [h drawCircleArc3d(arc(i,:), varargin{:})]; ##ok<AGROW>
      end
      if nargout > 0
          varargout = {h};
      end
      return;
  end

  # get center and radius
  xc  = arc(:,1);
  yc  = arc(:,2);
  zc  = arc(:,3);
  r   = arc(:,4);

  # get angle of normal
  theta   = arc(:,5);
  phi     = arc(:,6);
  psi     = arc(:,7);

  # get starting angle and angle extent of arc
  start   = arc(:,8);
  extent  = arc(:,9);

  # positions on circle arc
  N       = 60;
  t       = linspace(start, start+extent, N+1) * pi / 180;

  # compute coordinate of points
  x       = r*cos(t)';
  y       = r*sin(t)';
  z       = zeros(length(t), 1);
  curve   = [x y z];

  # compute transformation from local basis to world basis
  trans   = localToGlobal3d(xc, yc, zc, theta, phi, psi);

  # transform circle arc
  curve   = transformPoint3d(curve, trans);

  # draw the curve with specified options
  h = drawPolyline3d(curve, varargin{:});

  if nargout > 0
      varargout = {h};
  end

endfunction
