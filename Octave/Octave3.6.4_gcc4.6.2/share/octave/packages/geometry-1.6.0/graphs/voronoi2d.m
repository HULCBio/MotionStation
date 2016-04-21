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
## @deftypefn {Function File} {[@var{nodes} @var{edges} @var{faces}] = } voronoi2d (@var{germs})
## Compute a voronoi diagram as a graph structure
##
## [NODES EDGES FACES] = voronoi2d(GERMS)
## GERMS an array of points with dimension 2
## NODES, EDGES, FACES: usual graph representation, FACES as cell array
##
## Example
## @example
##
## [n e f] = voronoi2d(rand(100, 2)*100);
## drawGraph(n, e);
##
## @end example
##
## @end deftypefn

function [nodes edges faces] = voronoi2d(germs)
  [V C] = voronoin(germs);

  nodes = V(2:end, :);
  edges = zeros(0, 2);
  faces = {};

  for i=1:length(C)
  cell = C{i};
  if ismember(1, cell)
    continue;
  end

  cell = cell-1;
  edges = [edges; sort([cell' cell([2:end 1])'], 2)]; ##ok<AGROW>
  faces{length(faces)+1} = cell; ##ok<AGROW>
  end

  edges = unique(edges, 'rows');

endfunction

%!demo
%! [n e f] = voronoi2d(rand(100, 2)*100);
%! drawGraph(n, e);
%! axis tight
