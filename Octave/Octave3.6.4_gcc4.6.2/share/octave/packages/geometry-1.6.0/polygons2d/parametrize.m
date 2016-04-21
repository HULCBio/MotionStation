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
## @deftypefn {Function File} {@var{par} = } parametrize (@var{poly})
## @deftypefnx {Function File} {@var{par} = } parametrize (@var{px},@var{py})
## @deftypefnx {Function File} {@var{par} = } parametrize (@dots{},@var{normalize})
##
##  Parametrization of a curve, based on edges length
##
##  Returns a parametrization of the curve defined by the serie of points,
## based on euclidean distance between two consecutive points.
## POLY is a N-by-2 array, representing coordinates of vertices. The
## result PAR is N-by-1, and contains the cumulative length of edges until
## corresponding vertex. The function also accepts the polygon as two inputs
## @var{px} and @var{py} representinx coordinates x and y respectively.
##  When optional argument @var{normalize} is non-empty @var{par} is rescaled
## such that the last element equals 1, i.e. @code{@var{par}(end)==1}.
##
##  Example
## @example
##     # Parametrize a circle approximation
##     poly = circleToPolygon([0 0 1], 200);
##     p = parametrize(poly);
##     p(end)
##     ans =
##         6.2829
##     p = parametrize(poly,'norm');
##     p(end)
##     ans =
##         1
##     p = parametrize(poly,true);
##     p(end)
##     ans =
##         1
## @end example
##
##  @seealso{polygons2d, polylineLength}
## @end deftypefn
function par = parametrize(varargin)
  ## Process inputs

  # extract vertex coordinates
  if size(varargin{1}, 2) > 1
      # vertices in a single array
      pts = varargin{1};
      normalize = numel(varargin) > 1;
  elseif size(varargin{1}, 2) == 1 && numel(varargin) >= 2
      # points as separate arrays
      pts = [varargin{1} varargin{2}];
      normalize = numel(varargin) > 2;
  end

  ## Parametrize polyline

  # compute cumulative sum of euclidean distances between consecutive
  # vertices, setting distance of first vertex to 0.
  if size(pts, 2) == 2
      # process points in 2D
      par = [0 ; cumsum(hypot(diff(pts(:,1)), diff(pts(:,2))))];
  else
      # process points in arbitrary dimension
      par = [0 ; cumsum(sqrt(sum(diff(pts).^2, 2)))];
  end

  # eventually rescale between 0 and 1
  if normalize
      par = par / par(end);
  end

endfunction
