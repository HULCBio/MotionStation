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
## @deftypefn {Function File} {@var{c} = } centroid (@var{points})
## @deftypefnx {Function File} {@var{c} = } centroid (@var{px}, @var{py})
## @deftypefnx {Function File} {@var{c} = } centroid (@dots{}, @var{mass})
## Compute centroid (center of mass) of a set of points.
##
##   Computes the ND-dimensional centroid of a set of points. 
##   @var{points} is an array with as many rows as the number of points, and as
##   many columns as the number of dimensions. 
##   @var{px} and @var{py} are two column vectors containing coordinates of the
##   2-dimensional points.
##   The result @var{c} is a row vector with ND columns.
##
##   If @var{mass} is given, computes center of mass of @var{points}, weighted by coefficient @var{mass}.
##   @var{points} is a Np-by-Nd array, @var{mass} is Np-by-1 array, and @var{px} and @var{py} are
##   also both Np-by-1 arrays.
##
##   Example:
## 
## @example
##   pts = [2 2;6 1;6 5;2 4];
##   centroid(pts)
##   ans =
##        4     3
##@end example
##
##   @seealso{points2d, polygonCentroid}
## @end deftypefn

function center = centroid(varargin)

  ## extract input arguments

  # use empty mass by default
  mass = [];

  if nargin==1
      # give only array of points
      pts = varargin{1};
      
  elseif nargin==2
      # either POINTS+MASS or PX+PY
      var = varargin{1};
      if size(var, 2)>1
          # arguments are POINTS, and MASS
          pts = var;
          mass = varargin{2};
      else
          # arguments are PX and PY
          pts = [var varargin{2}];
      end
      
  elseif nargin==3
      # arguments are PX, PY, and MASS
      pts = [varargin{1} varargin{2}];
      mass = varargin{3};
  end

  ## compute centroid

  if isempty(mass)
      # no weight
      center = mean(pts);
      
  else
      # format mass to have sum equal to 1, and column format
      mass = mass(:)/sum(mass(:));
      
      # compute weighted centroid
      center = sum(bsxfun(@times, pts, mass), 1);
      # equivalent to:
      # center = sum(pts .* mass(:, ones(1, size(pts, 2))));
  end

endfunction

%!test 
%!  points = [0 0;10 0;10 10;0 10];
%!  centro = centroid(points);
%!   assert ([5 5], centro, 1e-6);

%!test 
%!  points = [0 0;10 0;10 10;0 10];
%!  centro = centroid(points(:,1), points(:,2));
%!   assert ([5 5], centro, 1e-6);

%!test 
%!  points = [0 0;30 0;30 30;0 30];
%!  centro = centroid(points, [1;1;1;3]);
%!   assert ([10 20], centro, 1e-6);

%!test 
%!  points = [0 0;30 0;30 30;0 30];
%!  centro = centroid(points(:,1), points(:,2), [1;1;1;3]);
%!   assert ([10 20], centro, 1e-6);

