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
## @deftypefn {Function File} {@var{output} =} formatMeshOutput (@var{nbargs}, @var{vertices},@var{edges},@var{faces})
## @deftypefnx {Function File} {@var{output} =} formatMeshOutput (@var{nbargs}, @var{vertices},@var{faces})
## Format mesh output depending on nargout
##
##   OUTPUT = formatMeshOutput(@var{nbargs}, VERTICES, EDGES, FACES)
##   Utilitary function to convert mesh data .
##   If @var{nbargs} is 0 or 1, return a matlab structure with fields vertices,
##   edges and faces.
##   If @var{nbargs} is 2, return a cell array with data VERTICES and FACES.
##   If @var{nbargs} is 3, return a cell array with data VERTICES, EDGES and
##   FACES. 
##
##   OUTPUT = formatMeshOutput(@var{nbargs}, VERTICES, FACES)
##   Same as before, but do not intialize EDGES in output. NARGOUT can not
##   be equal to 3.
##
##   Example
##     # Typical calling sequence (for a very basic mesh of only one face)
##     v = [0 0; 0 1;1 0;1 1];
##     e = [1 2;1 3;2 4;3 4];
##     f = [1 2 3 4];
## 
##     varargout = formatMeshOutput(nargout, v, e, f);
##
## @seealso{meshes3d, parseMeshData}
## @end deftypefn

function res = formatMeshOutput(nbArgs, vertices, edges, faces)

  if nargin < 4
      faces = edges;
      edges = [];
  end

  switch nbArgs
      case {0, 1}
          # output is a data structure with fields vertices, edges and faces
          mesh.vertices = vertices;
          mesh.edges = edges;
          mesh.faces = faces;
          res = {mesh};

      case 2
          # keep only vertices and faces
          res = cell(nbArgs, 1);
          res{1} = vertices;
          res{2} = faces;
          
      case 3
          # return vertices, edges and faces as 3 separate outputs
          res = cell(nbArgs, 1);
          res{1} = vertices;
          res{2} = edges;
          res{3} = faces;
          
      otherwise
          error('Can not manage more than 3 outputs');
  end

endfunction
