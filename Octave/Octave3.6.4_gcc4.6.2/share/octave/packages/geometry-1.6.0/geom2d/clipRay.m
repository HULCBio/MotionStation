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
## @deftypefn {Function File} {[@var{edge} @var{inside}] =} clipRay (@var{ray}, @var{box})
## Clip a ray with a box.
## 
##   @var{ray} is a straight ray given as a 4 element row vector: [x0 y0 dx dy],
##   with (x0 y0) being the origin of the ray and (dx dy) its direction
##   vector, @var{box} is the clipping box, given by its extreme coordinates: 
##   [xmin xmax ymin ymax].
##   The result is given as an edge, defined by the coordinates of its 2
##   extreme points: [x1 y1 x2 y2].
##   If the ray does not intersect the box, [NaN NaN NaN NaN] is returned.
##   
##   Function works also if @var{ray} is a Nx4 array, if @var{box} is a Nx4 array, or
##   if both @var{ray} and @var{box} are Nx4 arrays. In these cases, @var{edge} is a Nx4
##   array.
##
## @seealso{rays2d, boxes2d, edges2d, clipLine, drawRay}
## @end deftypefn

function [edge isInside] = clipRay(ray, bb)

  # adjust size of two input arguments
  if size(ray, 1)==1
      ray = repmat(ray, size(bb, 1), 1);
  elseif size(bb, 1)==1
      bb = repmat(bb, size(ray, 1), 1);
  elseif size(ray, 1) != size(bb, 1)
      error('bad sizes for input');
  end

  # first compute clipping of supporting line
  edge = clipLine(ray, bb);

  # detectes valid edges (edges outside box are all NaN)
  inds = find(isfinite(edge(:, 1)));

  # compute position of edge extremities relative to the ray
  pos1 = linePosition(edge(inds,1:2), ray(inds,:));
  pos2 = linePosition(edge(inds,3:4), ray(inds,:));

  # if first point is before ray origin, replace by origin
  edge(inds(pos1<0), 1:2) = ray(inds(pos1<0), 1:2);

  # if last point of edge is before origin, set all edge to NaN
  edge(inds(pos2<0), :) = NaN;

  # eventually returns result about inside or outside
  if nargout>1
      isInside = isfinite(edge(:,1));
  end
  
endfunction

%!shared bb
%! bb = [0 100 0 100];

%!test # inside
%!  origin      = [30 40];
%!  direction   = [10 0];
%!  ray         = [origin direction];
%!  expected    = [30 40 100 40];
%!  assert (expected, clipRay(ray, bb), 1e-6);

%!test # outside
%!  origin      = [30 140];
%!  direction   = [10 0];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # line inside, but ray outside
%!  origin      = [130 40];
%!  direction   = [10 0];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # inside
%!  origin      = [30 40];
%!  direction   = [-10 0];
%!  ray         = [origin direction];
%!  expected    = [30 40 0 40];
%!  assert (expected, clipRay(ray, bb), 1e-6);

%!test # outside
%!  origin      = [30 140];
%!  direction   = [-10 0];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # line inside, but ray outside
%!  origin      = [-30 40];
%!  direction   = [-10 0];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # inside
%!  origin      = [30 40];
%!  direction   = [0 10];
%!  ray         = [origin direction];
%!  expected    = [30 40 30 100];
%!  assert (expected, clipRay(ray, bb), 1e-6);

%!test # outside
%!  origin      = [130 40];
%!  direction   = [0 10];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # line inside, but ray outside
%!  origin      = [30 140];
%!  direction   = [0 10];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # inside
%!  origin      = [30 40];
%!  direction   = [0 -10];
%!  ray         = [origin direction];
%!  expected    = [30 40 30 0];
%!  assert (expected, clipRay(ray, bb), 1e-6);

%!test # outside
%!  origin      = [130 40];
%!  direction   = [0 -10];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test # line inside, but ray outside
%!  origin      = [30 -40];
%!  direction   = [0 -10];
%!  ray         = [origin direction];
%!  assert (sum(isnan(clipRay(ray, bb)))==4);

%!test 
%!  origins     = [30 40;30 40;30 140;130 40];
%!  directions  = [10 0;0 10;10 0;0 10];
%!  rays        = [origins directions];
%!  expected    = [30 40 100 40;30 40 30 100;NaN NaN NaN NaN;NaN NaN NaN NaN];
%!  clipped     = clipRay(rays, bb);
%!  assert (expected, clipped, 1e-6);
