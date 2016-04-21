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
## @deftypefn {Function File} {@var{theta} =} vectorAngle3d (@var{v1}, @var{v2})
## Angle between two 3D vectors
##
##   THETA = vectorAngle3d(V1, V2)
##   Computes the angle between the 2 3D vectors V1 and V2. The result THETA
##   is given in radians, between 0 and PI.
##
##
##   Example
##   # angle between 2 orthogonal vectors
##   vectorAngle3d([1 0 0], [0 1 0])
##   ans =
##       1.5708
##
##   # angle between 2 parallel vectors
##   v0 = [3 4 5];
##   vectorAngle3d(3*v0, 5*v0)
##   ans =
##       0
##
## @seealso{vectors3d, vectorNorm}
## @end deftypefn

function theta = vectorAngle3d(v1, v2)

  # compute angle using arc-tangent to get better precision for angles near
  # zero, see the discussion in:
  # http://www.mathworks.com/matlabcentral/newsreader/view_thread/151925#381952
  # equivalent to:
  # v1 = normalizeVector(v1);
  # v2 = normalizeVector(v2);
  # theta = acos(dot(v1, v2, 2));
  theta = atan2(vectorNorm(cross (v1, v2)), sum(v1.*v2,2));

endfunction
