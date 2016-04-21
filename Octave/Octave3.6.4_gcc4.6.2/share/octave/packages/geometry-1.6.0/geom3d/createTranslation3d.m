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
## @deftypefn {Function File} {@var{} =} createTranslation3d (@var{dx}, @var{dy}, @var{dz})
## @deftypefnx {Function File} {@var{} =} createTranslation3d (@var{vect})
## Create the 4x4 matrix of a 3D translation
##
##   usage:
##   TRANS = createTranslation3d(DX, DY, DZ);
##   return the translation corresponding to DX and DY.
##   The returned matrix has the form :
##   [1 0 0 DX]
##   [0 1 0 DY]
##   [0 0 1 DZ]
##   [0 0 0  1]
##
##   TRANS = createTranslation3d(VECT);
##   return the translation corresponding to the given vector [x y z].
##
## @seealso{transforms3d, transformPoint3d, transformVector3d,
## createRotationOx, createRotationOy, createRotationOz, createScaling3d}
## @end deftypefn

function trans = createTranslation3d(varargin)

  if isempty(varargin)
      # assert translation with null vector
      dx = 0;
      dy = 0;
      dz = 0;
  elseif length(varargin)==1
      # translation vector given in a single argument
      var = varargin{1};
      dx = var(1);
      dy = var(2);
      dz = var(3);
  else
      # translation vector given in 3 arguments
      dx = varargin{1};
      dy = varargin{2};
      dz = varargin{3};
  end

  # create the translation matrix
  trans = [1 0 0 dx ; 0 1 0 dy ; 0 0 1 dz; 0 0 0 1];

endfunction
