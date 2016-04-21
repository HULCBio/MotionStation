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
## @deftypefn {Function File} {@var{T} = } createRotation (@var{theta})
## @deftypefnx {Function File} {@var{T} = } createRotation (@var{point}, @var{theta})
## @deftypefnx {Function File} {@var{T} = } createRotation (@var{x0}, @var{y0}, @var{theta})
## Create the 3*3 matrix of a rotation.
##
##   Returns the rotation corresponding to angle @var{theta} (in radians)
##   The returned matrix has the form :
##   [cos(theta) -sin(theta)  0]
##   [sin(theta)  cos(theta)  0]
##   [0           0           1]
##
##   @var{point} or (@var{x0},@var{y0}), specifies origin of rotation. The result is similar as performing
##   translation(-@var{x0},-@var{y0}), rotation(@var{theta}), and translation(@var{x0},@var{y0}).
##
##
##   @seealso{transforms2d, transformPoint, createTranslation, createScaling}
## @end deftypefn

function trans = createRotation(varargin)

  # default values
  cx = 0;
  cy = 0;
  theta = 0;

  # get input values
  if length(varargin)==1
      # only angle
      theta = varargin{1};
  elseif length(varargin)==2
      # origin point (as array) and angle
      var = varargin{1};
      cx = var(1);
      cy = var(2);
      theta = varargin{2};
  elseif length(varargin)==3
      # origin (x and y) and angle
      cx = varargin{1};
      cy = varargin{2};
      theta = varargin{3};
  end

  # compute coefs
  cot = cos(theta);
  sit = sin(theta);
  tx =  cy*sit - cx*cot + cx;
  ty = -cy*cot - cx*sit + cy;

  # create transformation matrix
  trans = [cot -sit tx; sit cot ty; 0 0 1];

endfunction

%!test
%!  trans = createRotation(0);
%!  assert (trans, [1 0 0;0 1 0;0 0 1], 1e-6);

%!test
%!  trans = createRotation(pi/2);
%!  assert (trans, [0 -1 0; 1 0 0; 0 0 1], 1e-6);

%!test
%!  trans = createRotation(pi);
%!  assert (trans, [-1 0 0;0 -1 0;0 0 1], 1e-6);

%!test
%!  trans = createRotation(3*pi/2);
%!  assert (trans, [0 1 0; -1 0 0; 0 0 1], 1e-6);

%!test
%!  p0 = [3 5];
%!  theta = pi/3;
%!  trans1 = createRotation(p0, theta);
%!  t1 = createTranslation(-p0);
%!  rot = createRotation(theta);
%!  t2 = createTranslation(p0);
%!  trans2 = t2*rot*t1;
%!  assert (trans1, trans2, 1e-6);
