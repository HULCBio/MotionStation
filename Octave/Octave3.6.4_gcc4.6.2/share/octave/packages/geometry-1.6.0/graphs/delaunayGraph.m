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
## @deftypefn {Function File} {[@var{points} @var{edges}]= } delaunayGraph (@var{points})
## Graph associated to Delaunay triangulation of input points
##
## Compute the Delaunay triangulation of the set of input points, and
## convert to a set of edges. The output NODES is the same as the input
## POINTS.
##
## WARNING: 3d pltottig works correctly in Octave >= 3.6
##
## Example
## @example
##
## # Draw a planar graph correpspionding to Delaunay triangulation
## points = rand(30, 2) * 100;
## [nodes edges] = delaunayGraph(points);
## figure;
## drawGraph(nodes, edges);
##
## # Draw a 3Dgraph corresponding to Delaunay tetrahedrisation
## points = rand(20, 3) * 100;
## [nodes edges] = delaunayGraph(points);
## figure;
## drawGraph(nodes, edges);
## view(3);
##
## @end example
##
## @seealso{delaunay, delaunayn}
## @end deftypefn

function [points edges] = delaunayGraph(points, varargin)
  # compute triangulation
  tri = delaunayn(points, varargin{:});

  # number of simplices (triangles), and of vertices by simplex (3 in 2D)
  nt = size(tri, 1);
  nv = size(tri, 2);

  # allocate memory
  edges = zeros(nt * nv, 2);

  # compute edges of each simplex
  for i = 1:nv-1
    edges((1:nt) + (i-1)*nt, :) = sort([tri(:, i) tri(:, i+1)], 2);
  end
  edges((1:nt) + (nv-1)*nt, :) = sort([tri(:, end) tri(:, 1)], 2);

  # remove multiple edges
  edges = unique(edges, 'rows');

endfunction

%!demo
%! # Draw a planar graph correpspionding to Delaunay triangulation
%! points = rand(30, 2) * 100;
%! [nodes edges] = delaunayGraph(points);
%! figure;
%! drawGraph(nodes, edges);
%! axis tight

%!demo
%! # WARNING 3d pltottig works correctly in Octave >= 3.6
%! # Draw a 3Dgraph corresponding to Delaunay tetrahedrisation
%! points = rand(20, 3) * 100;
%! [nodes edges] = delaunayGraph(points);
%! figure;
%! drawGraph(nodes, edges);
%! view(3);
%! axis tight
