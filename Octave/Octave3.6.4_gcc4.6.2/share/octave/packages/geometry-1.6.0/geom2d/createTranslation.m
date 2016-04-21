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
## @deftypefn {Function File} {@var{T} = } createTranslation (@var{vector})
## @deftypefnx {Function File} {@var{T} = } createTranslation (@var{dx},@var{dy})
## Create the 3*3 matrix of a translation.
##
##   Returns the matrix corresponding to a translation by the vector [@var{dx} @var{dy}].
##   The components can be given as two arguments.
##   The returned matrix has the form :
##   [1 0 TX]
##   [0 1 TY]
##   [0 0  1]
##
##   @seealso{transforms2d, transformPoint, createRotation, createScaling}
## @end deftypefn

function trans = createTranslation(varargin)

  # process input arguments
  if isempty(varargin)
      tx = 0;
      ty = 0;
  elseif length(varargin)==1
      var = varargin{1};
      tx = var(1);
      ty = var(2);
  else
      tx = varargin{1};
      ty = varargin{2};
  end

  # create the matrix representing the translation
  trans = [1 0 tx ; 0 1 ty ; 0 0 1];
  
endfunction

%!test
%!  trans = createTranslation(2, 3);
%!  assert (trans, [1 0 2;0 1 3;0 0 1], 1e-6);
