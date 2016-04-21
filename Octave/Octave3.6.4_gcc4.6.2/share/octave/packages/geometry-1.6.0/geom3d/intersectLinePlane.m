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
## @deftypefn {Function File} {@var{pt} =} intersectLinePlane (@var{line}, @var{plane})
## @deftypefnx {Function File} {@var{pt} =} intersectLinePlane (@dots{}, @var{tol})
## Intersection point between a 3D line and a plane
##
##   PT = intersectLinePlane(LINE, PLANE)
##   Returns the intersection point of the given line and the given plane.
##   LINE:  [x0 y0 z0 dx dy dz]
##   PLANE: [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
##   PT:    [xi yi zi]
##   If LINE and PLANE are parallel, return [NaN NaN NaN].
##   If LINE (or PLANE) is a matrix with 6 (or 9) columns and N rows, result
##   is an array of points with N rows and 3 columns.
##
##   PT = intersectLinePlane(LINE, PLANE, TOL)
##   Specifies the tolerance factor to test if a line is parallel to a
##   plane. Default is 1e-14.
##
##   Example
## @example
##     # define horizontal plane through origin
##     plane = [0 0 0   1 0 0   0 1 0];
##     # intersection with a vertical line
##     line = [2 3 4  0 0 1];
##     intersectLinePlane(line, plane)
##     ans =
##        2   3   0
##     # intersection with a line "parallel" to plane
##     line = [2 3 4  1 2 0];
##     intersectLinePlane(line, plane)
##     ans =
##       NaN  NaN  NaN
## @end example
##
## @seealso{lines3d, planes3d, points3d, clipLine3d}
## @end deftypefn

function point = intersectLinePlane (line, plane, varargin)

  # extract tolerance if needed
  tol = 1e-14;
  if nargin > 2
      tol = varargin{1};
  end

  # unify sizes of data
  nLines  = size (line, 1);
  nPlanes = size (plane, 1);

  # N planes and M lines not allowed
  if nLines ~= nPlanes && min (nLines, nPlanes) > 1
      error ('geometry:geom3d:intersectLinePlane', ...
          'Input must have same number of rows, or one must be 1');
  end

  # plane normal
  n = cross (plane(:,4:6), plane(:,7:9));

  # difference between origins of plane and line
  dp = bsxfun (@minus, plane(:, 1:3), line(:, 1:3));

  # dot product of line direction with plane normal
  denom = sum (bsxfun (@times, n, line(:,4:6)), 2);

  # relative position of intersection point on line (can be inf in case of a
  # line parallel to the plane)
  t = sum (bsxfun (@times, n, dp),2) ./ denom;

  # compute coord of intersection point
  point = bsxfun (@plus, line(:,1:3),  bsxfun (@times, [t t t], line(:,4:6)));

  # set indices of line and plane which are parallel to NaN
  par = abs (denom) < tol;
  point(par,:) = NaN;

endfunction
