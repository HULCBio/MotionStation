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
## @deftypefn {Function File} {@var{alpha} =} vectorAngle (@var{v1})
## Angle of a vector, or between 2 vectors
##
##   A = vectorAngle(V);
##   Returns angle between Ox axis and vector direction, in Counter
##   clockwise orientation.
##   The result is normalised between 0 and 2*PI.
##
##   A = vectorAngle(V1, V2);
##   Returns the angle from vector V1 to vector V2, in counter-clockwise
##   order, and in radians.
##
##   A = vectorAngle(..., 'cutAngle', CUTANGLE);
##   A = vectorAngle(..., CUTANGLE); # (deprecated syntax)
##   Specifies convention for angle interval. CUTANGLE is the center of the
##   2*PI interval containing the result. See <a href="matlab:doc
##   ('normalizeAngle')">normalizeAngle</a> for details.
##
##   Example:
##   rad2deg(vectorAngle([2 2]))
##   ans =
##       45
##   rad2deg(vectorAngle([1 sqrt(3)]))
##   ans =
##       60
##   rad2deg(vectorAngle([0 -1]))
##   ans =
##       270
## 
## @seealso{vectors2d, angles2d, normalizeAngle}
## @end deftypefn

function alpha = vectorAngle(v1, varargin)

  ## Initializations

  # default values
  v2 = [];
  cutAngle = pi;

  # process input arguments
  while ~isempty(varargin)
      var = varargin{1};
      if isnumeric(var) && isscalar(var)
          # argument is normalization constant
          cutAngle = varargin{1};
          varargin(1) = [];
          
      elseif isnumeric(var) && size(var, 2) == 2
          # argument is second vector
          v2 = varargin{1};
          varargin(1) = [];
          
      elseif ischar(var) && length(varargin) >= 2
          # argument is option given as string + value
          if strcmpi(var, 'cutAngle')
              cutAngle = varargin{2};
              varargin(1:2) = [];
              
          else
              error(['Unknown option: ' var]);
          end
          
      else
          error('Unable to parse inputs');
      end
  end


  ## Case of one vector

  # If only one vector is provided, computes its angle
  if isempty(v2)
      # compute angle and format result in a 2*pi interval
      alpha = atan2(v1(:,2), v1(:,1));
      
      # normalize within a 2*pi interval
      alpha = normalizeAngle(alpha + 2*pi, cutAngle);
      
      return;
  end


  ## Case of two vectors

  # compute angle of each vector
  alpha1 = atan2(v1(:,2), v1(:,1));
  alpha2 = atan2(v2(:,2), v2(:,1));

  # difference
  alpha = bsxfun(@minus, alpha2, alpha1);

  # normalize within a 2*pi interval
  alpha = normalizeAngle(alpha + 2*pi, cutAngle);

endfunction

%!test
%! ang = vectorAngle([1 0]);
%! assert(0, ang, 1e-6);

%!test
%! ang = vectorAngle([0 1]);
%! assert(pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([-1 0]);
%! assert(pi, ang, 1e-6);

%!test
%! ang = vectorAngle([0 -1]);
%! assert(3*pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([-1 1]);
%! assert(3*pi/4, ang, 1e-6);

%!test
%! ang = vectorAngle([1 0], pi);
%! assert(0, ang, 1e-6);

%!test
%! ang = vectorAngle([0 1], pi);
%! assert(pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([-1 0], pi);
%! assert(pi, ang, 1e-6);

%!test
%! ang = vectorAngle([0 -1], pi);
%! assert(3*pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([-1 1], pi);
%! assert(3*pi/4, ang, 1e-6);

%!test
%! vecs = [1 0;0 1;-1 0;0 -1;1 1];
%! angs = [0;pi/2;pi;3*pi/2;pi/4];
%! assert(angs, vectorAngle(vecs));
%! assert(angs, vectorAngle(vecs, pi));

%!test
%! ang = vectorAngle([1 0], 0);
%! assert(0, ang, 1e-6);

%!test
%! ang = vectorAngle([0 1], 0);
%! assert(pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([0 -1], 0);
%! assert(-pi/2, ang, 1e-6);

%!test
%! ang = vectorAngle([-1 1], 0);
%! assert(3*pi/4, ang, 1e-6);

%!test
%! vecs = [1 0;0 1;0 -1;1 1;1 -1];
%! angs = [0;pi/2;-pi/2;pi/4;-pi/4];
%! assert(angs, vectorAngle(vecs, 0), 1e-6);

%!test
%! v1 = [1 0];
%! v2 = [0 1];
%! ang = pi /2 ;
%! assert(ang, vectorAngle(v1, v2), 1e-6);

%!test
%! v1 = [1 0];
%! v2 = [0 1; 0 1; 1 1; -1 1];
%! ang = [pi / 2 ;pi / 2 ;pi / 4 ; 3 * pi / 4];
%! assert(ang, vectorAngle(v1, v2), 1e-6);

%!test
%! v1 = [0 1; 0 1; 1 1; -1 1];
%! v2 = [-1 0];
%! ang = [pi / 2 ;pi / 2 ; 3 * pi / 4 ; pi / 4];
%! assert(ang, vectorAngle(v1, v2), 1e-6);

%!test
%! v1 = [1 0; 0 1; 1 1; -1 1];
%! v2 = [0 1; 1 0; -1 1; -1 0];
%! ang = [pi / 2 ;3 * pi / 2 ;pi / 2 ; pi / 4];
%! assert(ang, vectorAngle(v1, v2), 1e-6);
