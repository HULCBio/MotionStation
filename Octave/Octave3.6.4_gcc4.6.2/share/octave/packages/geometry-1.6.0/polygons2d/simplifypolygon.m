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
## @deftypefn {Function File} {@var{spoly} = } simplifypolygon (@var{poly})
## Simplify a polygon using the Ramer-Douglas-Peucker algorithm.
##
## @var{poly} is a N-by-2 matrix, each row representing a vertex.
##
## @seealso{simplifypolyline, shape2polygon}
## @end deftypefn

function polygonsimp = simplifypolygon (polygon, varargin)

  polygonsimp = simplifypolyline (polygon,varargin{:});

  # Remove parrallel consecutive edges
  PL = polygonsimp(1:end-1,:);
  PC = polygonsimp(2:end,:);
  PR = polygonsimp([3:end 1],:);
  a = PL - PC;
  b = PR - PC;
  tf = find(isParallel(a,b))+1;
  polygonsimp (tf,:) = [];

endfunction

%!test
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%! assert(simplifypolygon (P2),P,min(P2(:))*eps)

%!demo
%!
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%!  Pr = simplifypolygon (P2);
%!
%!  cla
%!  drawPolygon(P,'or;Reference;');
%!  hold on
%!  drawPolygon(P2,'x-b;Redundant;');
%!  drawPolygon(Pr,'*g;Simplified;');
%!  hold off
%!
%! # --------------------------------------------------------------------------
%! # The two polygons describe the same figure, a triangle. Extra points are
%! # removed form the redundant one.
