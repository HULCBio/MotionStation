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
## @deftypefn {Function File} {@var{T} = } fitAffineTransform2d (@var{pts1}, @var{pts2})
## Fit an affine transform using two point sets.
##
##   Example
##
## @example
##   N = 10;
##   pts = rand(N, 2)*10;
##   trans = createRotation(3, 4, pi/4);
##   pts2 = transformPoint(pts, trans);
##   pts3 = pts2 + randn(N, 2)*2;
##   fitted = fitAffineTransform2d(pts, pts2)
##@end example
##
## @seealso{transforms2d}
## @end deftypefn

function trans = fitAffineTransform2d(pts1, pts2)

  # number of points 
  N = size(pts1, 1);

  # main matrix of the problem
  A = [...
      pts1(:,1) pts1(:,2) ones(N,1) zeros(N, 3) ; ...
      zeros(N, 3) pts1(:,1) pts1(:,2) ones(N,1)  ];

  # conditions initialisations
  B = [pts2(:,1) ; pts2(:,2)];

  # compute coefficients using least square
  coefs = A\B;

  # format to a matrix
  trans = [coefs(1:3)' ; coefs(4:6)'; 0 0 1];

endfunction


