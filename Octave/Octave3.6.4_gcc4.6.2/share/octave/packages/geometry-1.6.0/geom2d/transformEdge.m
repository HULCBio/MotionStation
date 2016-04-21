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
## @deftypefn {Function File} {@var{edge2} = } transformEdge (@var{edge1}, @var{T})
## Transform an edge with an affine transform.
##
##   Where @var{edge1} has the form [x1 y1 x2 y1], and @var{T} is a transformation
##   matrix, return the edge transformed with affine transform @var{T}. 
##
##   Format of TRANS can be one of :
##   [a b]   ,   [a b c] , or [a b c]
##   [d e]       [d e f]      [d e f]
##                            [0 0 1]
##
##   Also works when @var{edge1} is a [Nx4] array of double. In this case, @var{edge2}
##   has the same size as @var{edge1}. 
##
##   @seealso{edges2d, transforms2d, transformPoint, translation, rotation}
## @end deftypefn

function dest = transformEdge(edge, trans)

  dest = zeros(size(edge));

  # compute position
  dest(:,1) = edge(:,1)*trans(1,1) + edge(:,2)*trans(1,2);
  dest(:,2) = edge(:,1)*trans(2,1) + edge(:,2)*trans(2,2);
  dest(:,3) = edge(:,3)*trans(1,1) + edge(:,3)*trans(1,2);
  dest(:,4) = edge(:,4)*trans(2,1) + edge(:,4)*trans(2,2);

  # add translation vector, if exist
  if size(trans, 2)>2
      dest(:,1) = dest(:,1)+trans(1,3);
      dest(:,2) = dest(:,2)+trans(2,3);
      dest(:,3) = dest(:,3)+trans(1,3);
      dest(:,4) = dest(:,4)+trans(2,3);
  end

endfunction

