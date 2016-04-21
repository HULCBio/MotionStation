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
## @deftypefn {Function File} {@var{mesh} =} parseMeshData  (@var{vertices},@var{edges},@var{faces})
## @deftypefnx {Function File} {@var{mesh} =} parseMeshData  (@var{vertices},@var{faces})
## @deftypefnx {Function File} {[@var{vertices},@var{edges},@var{faces}] =} parseMeshData  (@var{mesh})
## @deftypefnx {Function File} {[@var{vertices},@var{faces}] =} parseMeshData  (@var{mesh})
## Conversion of data representation for meshes
##
##   MESH = parseMeshData(VERTICES, EDGES, FACES)
##   MESH = parseMeshData(VERTICES, FACES)
##   [VERTICES EDGES FACES] = parseMeshData(MESH)
##   [VERTICES FACES] = parseMeshData(MESH)
##
##
## @seealso{meshes3d, formatMeshOutput}
## @end deftypefn

function varargout = parseMeshData(varargin)

  # initialize edges
  edges = [];

  # Process input arguments
  if nargin == 1
      # input is a data structure
      mesh = varargin{1};
      vertices = mesh.vertices;
      faces = mesh.faces;
      if isfield(mesh, 'edges')
          edges = mesh.edges;
      end
      
  elseif nargin == 2
      # input are vertices and faces
      vertices = varargin{1};
      faces = varargin{2};
      
  elseif nargin == 3
      # input are vertices, edges and faces
      vertices = varargin{1};
      edges = varargin{2};
      faces = varargin{3};
      
  else
      error('Wrong number of arguments');
  end

  varargout = formatMeshOutput(nargout, vertices, edges, faces);

endfunction
