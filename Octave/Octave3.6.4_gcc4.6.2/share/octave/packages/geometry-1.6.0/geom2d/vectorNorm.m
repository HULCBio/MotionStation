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
## @deftypefn {Function File} {@var{nm} = } vectorNorm (@var{v})
## @deftypefnx {Function File} {@var{nm} = } vectorNorm (@var{v},@var{n})
## Compute norm of a vector, or of a set of vectors
##
## Without extra arguments, returns the euclidean norm of vector V.
## Optional argument @var{n} specifies the norm to use. N can be any value
## greater than 0. 
## @table @samp
## @item  N=1 
##   City lock norm.
## @item  N=2 
##   Euclidean norm.
## @item N=inf 
##   Compute max coord.
## @end table
##
##   When @var{v} is a MxN array, compute norm for each vector of the array.
##   Vector are given as rows. Result is then a Mx1 array.
##
##   Example
##
## @example
##   n1 = vectorNorm([3 4])
##   n1 =
##       5
##
##   n2 = vectorNorm([1, 10], inf)
##   n2 =
##       10
## @end example
##
## @seealso{vectors2d, vectorAngle}
## @end deftypefn

function n = vectorNorm(v, varargin)

  # size of vector
  dim = size(v);

  # extract the type of norm to compute
  d = 2;
  if ~isempty(varargin)
      d = varargin{1};
  end

  if d==2
      # euclidean norm: sum of squared coordinates, and take square root
      if dim(1)==1 || dim(2)==1
          n = sqrt(sum(v.*v));
      else
          n = sqrt(sum(v.*v, 2));
      end
  elseif d==1 
      # absolute norm: sum of absolute coordinates
      if dim(1)==1 || dim(2)==1
          n = sum(abs(v));
      else
          n = sum(abs(v), 2);
      end
  elseif d==inf
      # infinite norm: uses the maximal corodinate
      if dim(1)==1 || dim(2)==1
          n = max(v);
      else
          n = max(v, [], 2);
      end
  else
      # Other norms, use explicit but slower expression  
      if dim(1)==1 || dim(2)==1
          n = power(sum(power(v, d)), 1/d);
      else
          n = power(sum(power(v, d), 2), 1/d);
      end
  end

endfunction

%!assert (5, vectorNorm ([3 4]))
%!assert(10, vectorNorm ([1, 10], inf))

