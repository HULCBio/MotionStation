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
## @deftypefn {Function File} {@var{vn} = } normalizeVector (@var{v})
## Normalize a vector to have norm equal to 1
##
## Returns the normalization of vector @var{v}, such that ||@var{v}|| = 1.
## @var{v} can be either a row or a column vector.
##
## When @var{v} is a MxN array, normalization is performed for each row of the
## array.
##
##   Example:
##
## @example
##   vn = normalizeVector([3 4])
##   vn =
##       0.6000   0.8000
##   vectorNorm(vn)
##   ans =
##       1
## @end example
##
## @seealso{vectors2d, vectorNorm}
## @end deftypefn

function vn = normalizeVector(v)

  dim = size(v);

  if dim(1)==1 || dim(2)==1
      vn = v / sqrt(sum(v.^2));
  else
      #same as: vn = v./repmat(sqrt(sum(v.*v, 2)), [1 dim(2)]);
      vn = bsxfun(@rdivide, v, sqrt(sum(v.^2, 2)));
  end

endfunction

%!assert (1,vectorNorm (normalizeVector ([3 4])))

