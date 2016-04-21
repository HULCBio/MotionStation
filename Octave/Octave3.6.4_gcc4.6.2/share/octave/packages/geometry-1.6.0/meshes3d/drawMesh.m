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
## @deftypefn {Function File} {@var{h} =} drawMesh (@var{vertices}, @var{faces})
## @deftypefnx {Function File} {@var{h} =} drawMesh (@var{mesh})
## @deftypefnx {Function File} {@var{h} =} drawMesh (@dots{}, @var{color})
## @deftypefnx {Function File} {@var{h} =} drawMesh (@dots{}, @var{name},@var{value})
## Draw a 3D mesh defined by vertices and faces
##
##   drawMesh(VERTICES, FACES)
##   Draws the 3D mesh defined by vertices VERTICES and the faces FACES.
##   vertices is a [NVx3] array containing coordinates of vertices, and FACES
##   is either a [NFx3] or [NFx4] array containing indices of vertices of
##   the triangular or rectangular faces.
##   FACES can also be a cell array, in the content of each cell is an array
##   of indices to the vertices of the current face. Faces can have different
##   number of vertices.
##
##   drawMesh(MESH)
##   Where mesh is a structure with fields 'vertices' and 'faces', draws the
##   given mesh.
##
##   drawMesh(..., COLOR)
##   Use the specified color to render the mesh faces.
##
##   drawMesh(..., NAME, VALUE)
##   Use one or several pairs of parameter name/value to specify drawing
##   options. Options are the same as the 'patch' function.
##
##
##   H = drawMesh(...);
##   Also returns a handle to the created patch.
##
##  WARNING: This function doesn't work with gnuplot (as of version 4.1)
##
##   Example:
## @example
##     [v f] = createSoccerBall;
##     drawMesh(v, f);
## @end example
##
## @seealso{polyhedra, meshes3d, patch}
## @end deftypefn

function varargout = drawMesh(vertices, faces, varargin)

  if strcmpi (graphics_toolkit(),"gnuplot")
    error ("geometry:Incompatibility", ...
    ["This function doesn't work with gnuplot (as of version 4.1)." ...
     "Use graphics_toolkit('fltk').\n"]);
  end
  ## Initialisations

  # Check if the input is a mesh structure
  if isstruct(vertices)
      # refresh options
      if nargin > 1
          varargin = [{faces} varargin];
      end

      # extract data to display
      faces = vertices.faces;
      vertices = vertices.vertices;
  end

  # process input arguments
  switch length(varargin)
      case 0
          # default color is red
          varargin = {'facecolor', [1 0 0]};
      case 1
          # use argument as color for faces
          varargin = {'facecolor', varargin{1}};
      otherwise
          # otherwise keep varargin unchanged
  end

  # overwrites on current figure
  hold on;

  # if vertices are 2D points, add a z=0 coordinate
  if size(vertices, 2)==2
      vertices(1,3)=0;
  end


  ## Use different processing depending on the type of faces
  if isnumeric(faces)
      # array FACES is a NC*NV indices array, with NV : number of vertices of
      # each face, and NC number of faces
      h = patch('vertices', vertices, 'faces', faces, varargin{:});

  elseif iscell(faces)
      # array FACES is a cell array
      h = zeros(length(faces(:)), 1);

      for f=1:length(faces(:))
          # get vertices of the cell
          face = faces{f};

          # Special processing in case of multiple polygonal face:
          # each polygonal loop is separated by a NaN.
          if sum(isnan(face))~=0

              # find indices of loops breaks
              inds = find(isnan(face));

              # replace NaNs by index of first vertex of each polygon
              face(inds(2:end))   = face(inds(1:end-1)+1);
              face(inds(1))       = face(1);
              face(length(face)+1)= face(inds(end)+1);
          end

          # draw current face
          cnodes  = vertices(face, :);
          h(f)    = patch(cnodes(:, 1), cnodes(:, 2), cnodes(:, 3), [1 0 0]);
      end

      # set up drawing options
      set(h, varargin{:});
  else
      error('second argument must be a face array');
  end


  ## Process output arguments

  # format output parameters
  if nargout>0
      varargout{1}=h;
  end

endfunction

%!demo
%! close all
%! graphics_toolkit ("fltk");
%! [v f] = createCubeOctahedron;
%! drawMesh(v, f);
%! view (3)

%!demo
%! close all
%! graphics_toolkit ("gnuplot");
