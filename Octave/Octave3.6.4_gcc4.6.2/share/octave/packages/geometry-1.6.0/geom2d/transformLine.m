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
## @deftypefn {Function File} {@var{line2} = } transformLine (@var{line1}, @var{T})
## Transform a line with an affine transform.
##
##   Returns the line @var{line1} transformed with affine transform @var{T}.
##   @var{line1} has the form [x0 y0 dx dy], and @var{T} is a transformation
##   matrix.
##
##   Format of @var{T} can be one of :
##   [a b]   ,   [a b c] , or [a b c]
##   [d e]       [d e f]      [d e f]
##                            [0 0 1]
##
##   Also works when @var{line1} is a [Nx4] array of double. In this case, @var{line2}
##   has the same size as @var{line1}. 
##
##   @seealso{lines2d, transforms2d, transformPoint}
## @end deftypefn

function dest = transformLine(line, trans)

  # isolate points
  points1 = line(:, 1:2);
  points2 = line(:, 1:2) + line(:, 3:4);

  # transform points 
  points1 = transformPoint(points1, trans);
  points2 = transformPoint(points2, trans);

  dest = createLine(points1, points2);

endfunction

