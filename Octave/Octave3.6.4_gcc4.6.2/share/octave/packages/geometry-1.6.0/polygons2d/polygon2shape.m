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
## @deftypefn {Function File} {@var{shape} = } polygon2shape (@var{polygon})
## Converts a polygon to a shape with edges defined by smooth polynomials.
##
## @var{polygon} is a N-by-2 matrix, each row representing a vertex.
## @var{shape} is a N-by-1 cell, where each element is a pair of polynomials
## compatible with polyval.
##
## In its current state, the shape is formed by polynomials of degree 1. Therefore
## the shape representation costs more memory except for colinear points in the
## polygon.
##
## @seealso{shape2polygon, simplifypolygon, polyval}
## @end deftypefn

function shape = polygon2shape (polygon)

  # Filter colinear points
  polygon = simplifypolygon (polygon);

  np = size(polygon,1);
  # polygonal shapes are memory inefficient!!
  # TODO filter the regions where edge angles are canging slowly and fit
  # polynomial of degree 3;
  pp = nan (2*np,2);

  # Transform edges into polynomials of degree 1;
  # pp = [(p1-p0) p0];
  pp(:,1) = diff(polygon([1:end 1],:)).'(:);
  pp(:,2) = polygon.'(:);

  shape = mat2cell(pp, 2*ones (1,np), 2);

endfunction

%!test
%! pp = [0 0; 1 0; 1 1; 0 1];
%! s = polygon2shape (pp);

