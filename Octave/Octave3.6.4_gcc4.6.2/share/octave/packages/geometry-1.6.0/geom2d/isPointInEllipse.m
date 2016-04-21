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
## @deftypefn {Function File} {@var{b} = } isPointInellipse (@var{point}, @var{ellipse})
## Check if a point is located inside a given ellipse
##
##   B = isPointInEllipse(POINT, ELLIPSE) 
##   Returns true if point is located inside the given ellipse.
##
##   B = isPointInEllipse(POINT, ELLIPSE, TOL) 
##   Specifies the tolerance value
##
##   Example:
##   isPointInEllipse([1 0], [0 0 2 1 0])
##   ans =
##       1
##   isPointInEllipse([0 0], [0 0 2 1 0])
##   ans =
##       1
##   isPointInEllipse([1 1], [0 0 2 1 0])
##   ans =
##       0
##   isPointInEllipse([1 1], [0 0 2 1 30])
##   ans =
##       1
##
##   @seealso{ellipses2d, isPointInCircle}
## @end deftypefn

function b = isPointInEllipse(point, ellipse, varargin)

  # extract computation tolerance
  tol = 1e-14;
  if ~isempty(varargin)
      tol = varargin{1};
  end

  # compute ellipse to unit circle transform
  rot = createRotation(-deg2rad(ellipse(5)));
  sca = createScaling(1./ellipse(3:4));
  trans = sca * rot;

  # transform points to unit circle basis
  pTrans = bsxfun(@minus, point, ellipse(:,1:2));
  pTrans = transformPoint(pTrans, trans);

  # test if distance to origin smaller than 1
  b = sqrt(sum(power(pTrans, 2), 2)) - 1 <= tol;

endfunction
