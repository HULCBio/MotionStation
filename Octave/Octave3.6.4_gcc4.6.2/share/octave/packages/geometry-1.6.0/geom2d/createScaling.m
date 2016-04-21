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
## @deftypefn {Function File} {@var{T} = } createScaling (@var{s})
## @deftypefnx {Function File} {@var{T} = } createScaling (@var{sx}, @var{sy})
## Create the 3x3 matrix of a scaling in 2 dimensions.
#
#   Assume scaling @var{s} is equal n all directions unless @var{sx} and @var{sy} are given.
#   Returns the matrix corresponding to scaling in the 2 main directions.
#   The returned matrix has the form:
#   [SX  0  0]
#   [0  SY  0]
#   [0   0  1]
#
#   @seealso{transforms2d, transformPoint, createTranslation, createRotation}
## @end deftypefn

function trans = createScaling(varargin)

  # defined default arguments
  sx = 1;
  sy = 1;
  cx = 0;
  cy = 0;

  # process input arguments
  if length(varargin)==1
      # the argument is either the scaling factor in both direction,
      # or a 1x2 array containing scaling factor in each direction
      var = varargin{1};
      sx = var(1);
      sy = var(1);
      if length(var)>1
          sy = var(2);
      end
  elseif length(varargin)==2
      # the 2 arguments are the scaling factors in each dimension
      sx = varargin{1};
      sy = varargin{2};
  elseif length(varargin)==3
      # first argument is center, 2nd and 3d are scaling factors
      center = varargin{1};
      cx = center(1);
      cy = center(2);
      sx = varargin{2};
      sy = varargin{3};
  end

  # create result matrix
  trans = [sx 0 cx*(1-sx); 0 sy cy*(1-sy); 0 0 1];

endfunction

%!test
%!  trans = createScaling(2);
%!  assert (trans, [2 0 0;0 2 0;0 0 1], 1e-6);

%!test
%!  trans = createScaling(2, 3);
%!  assert (trans, [2 0 0;0 3 0;0 0 1], 1e-6);

%!test
%!  trans = createScaling([2 3]);
%!  assert (trans, [2 0 0;0 3 0;0 0 1], 1e-6);

%!test
%!  sx = 2;
%!  sy = 3;
%!  p0 = [4 5];
%!  trans1 = createScaling(p0, sx, sy);
%!  t1 = createTranslation(-p0);
%!  sca = createScaling(sx, sy);
%!  t2 = createTranslation(p0);
%!  trans2 = t2*sca*t1;
%!  assert (trans1, trans2, 1e-6);
