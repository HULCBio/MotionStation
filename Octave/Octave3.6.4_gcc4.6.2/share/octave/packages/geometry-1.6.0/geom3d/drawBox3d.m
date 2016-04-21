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
## @deftypefn {Function File} drawBox3d (@var{box})
## @deftypefnx {Function File} drawBox3d (@dots{},@var{opt})
## Draw a 3D box defined by coordinate extents
##
##   Draw a box defined by its coordinate extents:
##   BOX = [XMIN XMAX YMIN YMAX ZMIN ZMAX].
##   The function draws only the outline edges of the box.
##   Extra options @var{opt} are passed to the function @code{drawEdges3d}.
##
##   Example
## @example
##     # Draw bounding box of a cubeoctehedron
##     [v e f] = createCubeOctahedron;
##     box3d = boundingBox3d(v);
##     figure; hold on;
##     drawMesh(v, f);
##     drawBox3d(box3d);
##     axis([-2 2 -2 2 -2 2]);
##     view(3)
## @end example
##
## @seealso{boxes3d, boundingBox3d}
## @end deftypefn

function drawBox3d(box, varargin)

  # default values

  xmin = box(:,1);
  xmax = box(:,2);
  ymin = box(:,3);
  ymax = box(:,4);
  zmin = box(:,5);
  zmax = box(:,6);

  nBoxes = size(box, 1);

  for i=1:length(nBoxes)
      # lower face (z=zmin)
      drawEdge3d([xmin(i) ymin(i) zmin(i)     xmax(i) ymin(i) zmin(i)], varargin{:});
      drawEdge3d([xmin(i) ymin(i) zmin(i)     xmin(i) ymax(i) zmin(i)], varargin{:});
      drawEdge3d([xmax(i) ymin(i) zmin(i)     xmax(i) ymax(i) zmin(i)], varargin{:});
      drawEdge3d([xmin(i) ymax(i) zmin(i)     xmax(i) ymax(i) zmin(i)], varargin{:});

      # front face (y=ymin)
      drawEdge3d([xmin(i) ymin(i) zmin(i)     xmin(i) ymin(i) zmax(i)], varargin{:});
      drawEdge3d([xmax(i) ymin(i) zmin(i)     xmax(i) ymin(i) zmax(i)], varargin{:});
      drawEdge3d([xmin(i) ymin(i) zmax(i)     xmax(i) ymin(i) zmax(i)], varargin{:});

      # left face (x=xmin)
      drawEdge3d([xmin(i) ymax(i) zmin(i)     xmin(i) ymax(i) zmax(i)], varargin{:});
      drawEdge3d([xmin(i) ymin(i) zmax(i)     xmin(i) ymax(i) zmax(i)], varargin{:});

      # the last 3 remaining edges
      drawEdge3d([xmin(i) ymax(i) zmax(i)     xmax(i) ymax(i) zmax(i)], varargin{:});
      drawEdge3d([xmax(i) ymax(i) zmin(i)     xmax(i) ymax(i) zmax(i)], varargin{:});
      drawEdge3d([xmax(i) ymin(i) zmax(i)     xmax(i) ymax(i) zmax(i)], varargin{:});

  end

endfunction

%!demo
%!  close all
%!  graphics_toolkit("fltk")
%!  # Draw bounding box of a cubeoctehedron
%!  [v e f] = createCubeOctahedron;
%!  box3d = boundingBox3d(v);
%!  figure;
%!  hold on;
%!  drawMesh(v, f);
%!  drawBox3d(box3d);
%!  axis([-2 2 -2 2 -2 2]);
%!  view(3)

%!demo
%!  close all
%!  graphics_toolkit("gnuplot")
