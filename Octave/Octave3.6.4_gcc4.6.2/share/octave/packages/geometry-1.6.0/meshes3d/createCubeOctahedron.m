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
## @deftypefn {Function File} {[@var{v}, @var{e}, @var{f}] =} createCubeOctahedron ()
## @deftypefnx {Function File} {@var{mesh} =} createCubeOctahedron ()
## Create a 3D mesh representing a cube-octahedron
##
##   [V E F] = createCubeOctahedron;
##   Cubeoctahedron can be seen either as a truncated cube, or as a
##   truncated octahedron.
##   V is the 12-by-3 array of vertex coordinates
##   E is the 27-by-2 array of edge vertex indices
##   F is the 1-by-14 cell array of face vertex indices
##
##   [V F] = createCubeOctahedron;
##   Returns only the vertices and the face vertex indices.
##
##   MESH = createCubeOctahedron;
##   Returns the data as a mesh structure, with fields 'vertices', 'edges'
##   and 'faces'.
##
## @seealso{meshes3d, drawMesh, createCube, createOctahedron}
## @end deftypefn

function varargout = createCubeOctahedron()

  nodes = [...
      0 -1 1;1 0 1;0 1 1;-1 0 1; ...
      1 -1 0;1 1 0;-1 1 0;-1 -1 0;...
      0 -1 -1;1 0 -1;0 1 -1;-1 0 -1];

  edges = [...
       1  2;  1  4; 1 5; 1 8; ...
       2  3;  2  5; 2 6; ...
       3  4;  3  6; 3 7; ...
       4  7;  4  8; ...
       5  9;  5 10; ...
       6 10;  6 11; ...
       7 11;  7 12; ...
       8  9;  8 12; ...
       9 10;  9 12; ...
      10 11; 11 12];

  faces = {...
      [1 2 3 4], [1 5 2], [2 6 3], [3 7 4], [4 8 1], ...
      [5 10 6 2], [3 6 11 7], [4 7 12 8], [1 8 9 5], ...
      [5 9 10], [6 10 11], [7 11 12], [8 12 9], [9 12 11 10]};

  # format output
  varargout = formatMeshOutput(nargout, nodes, edges, faces);

endfunction

%!demo
%!  [n e f] = createCubeOctahedron;
%!  drawMesh(n, f);

