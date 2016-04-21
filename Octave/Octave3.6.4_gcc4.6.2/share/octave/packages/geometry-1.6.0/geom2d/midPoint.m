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
## @deftypefn {Function File} {@var{mid} = } midPoint (@var{p1}, @var{p2})
## @deftypefnx {Function File} {@var{mid} = } midPoint (@var{edge})
## @deftypefnx {Function File} {[@var{midx}, @var{midy}] = } midPoint (@var{edge})
## Middle point of two points or of an edge
##
##   Computes the middle point of the two points @var{p1} and @var{p2}.
##
##   If an edge is given, computes the middle point of the edge given by @var{edge}.
##   @var{edge} has the format: [X1 Y1 X2 Y2], and @var{mid} has the format [XMID YMID],
##   with XMID = (X1+X2)/2, and YMID = (Y1+Y2)/2.
##
##   If two output arguments are given, it returns the result as two separate variables or arrays.
##
##   Works also when @var{edge} is a N-by-4 array, in this case the result is a
##   N-by-2 array containing the midpoint of each edge.
##
##   Example
##
## @example
##   p1 = [10 20];
##   p2 = [30 40];
##   midPoint([p1 p2])
##   ans =
##       20  30
## @end example
##
##   @seealso{edges2d, points2d}
## @end deftypefn

function varargout = midPoint(varargin)

  if nargin == 1
      # input is an edge
      edge = varargin{1};
      mid = [mean(edge(:, [1 3]), 2) mean(edge(:, [2 4]), 2)];
      
  elseif nargin == 2
      # input are two points
      p1 = varargin{1};
      p2 = varargin{2};
      
      # assert inputs are equal
      n1 = size(p1, 1);
      n2 = size(p2, 1);
      if n1 != n2 && min(n1, n2)>1
          error('geom2d:midPoint', ...
              'Inputs must have same size, or one must have length 1');
      end
      
      # compute middle point
      mid = bsxfun(@plus, p1, p2) / 2;
  end

  # process output arguments
  if nargout<=1
      varargout{1} = mid;
  else
      varargout = {mid(:,1), mid(:,2)};
  end

endfunction

%!test
%!  p1 = [10 20];
%!  p2 = [30 40];
%!  exp = [20 30];
%!  mid = midPoint(p1, p2);
%!  assert (mid, exp);

%!test
%!  p1 = [ ...
%!      10 20 ; ...
%!      30 40 ; ...
%!      50 60 ; ...
%!      ];
%!  p2 = [ ...
%!      30 40; ...
%!      50 60; ...
%!      70 80];
%!  exp = [...
%!      20 30; ...
%!      40 50; ...
%!      60 70];
%!  mid = midPoint(p1, p2);
%!  assert (mid, exp);

%!test
%!  p1 = [30 40];
%!  p2 = [ ...
%!      30 40; ...
%!      50 60; ...
%!      70 80];
%!  exp = [...
%!      30 40; ...
%!      40 50; ...
%!      50 60];
%!  mid = midPoint(p1, p2);
%!  assert (mid, exp);

%!test
%!  p1 = [ ...
%!      10 20 ; ...
%!      30 40 ; ...
%!      50 60 ; ...
%!      ];
%!  p2 = [30 40];
%!  exp = [...
%!      20 30; ...
%!      30 40; ...
%!      40 50];
%!  mid = midPoint(p1, p2);
%!  assert (mid, exp);

%!test
%!  p1 = [ ...
%!      10 20 ; ...
%!      30 40 ; ...
%!      50 60 ; ...
%!      ];
%!  p2 = [30 40];
%!  expX = [20 ; 30 ; 40];
%!  expY = [30 ; 40 ; 50];
%!  [x y] = midPoint(p1, p2);
%!  assert (x, expX);
%!  assert (y, expY);

%!test
%!  edge = [10 20 30 40];
%!  exp = [20 30];
%!  mid = midPoint(edge);
%!  assert (mid, exp);
%!  edge = [10 20 30 40; 30 40 50 60; 50 60 70 80];
%!  exp = [20 30;40 50; 60 70];
%!  mid = midPoint(edge);
%!  assert (mid, exp);

