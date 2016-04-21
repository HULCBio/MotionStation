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
## @deftypefn {Function File} {@var{ell} = } inertiaEllipse (@var{pts})
## Inertia ellipse of a set of points
##
##   ELL = inertiaEllipse(PTS);
##   where PTS is a N*2 array containing coordinates of N points, computes
##   the inertia ellispe of the set of points.
##
##   The result has the form:
##   ELL = [XC YC A B THETA],
##   with XC and YC being the center of mass of the point set, A and B are
##   the lengths of the inertia ellipse (see below), and THETA is the angle
##   of the main inertia axis with the horizontal (counted in degrees
##   between 0 and 180). 
##   A and B are the standard deviations of the point coordinates when
##   ellipse is aligned with the inertia axes.
##
##   @example
##   pts = randn(100, 2);
##   pts = transformPoint(pts, createScaling(5, 2));
##   pts = transformPoint(pts, createRotation(pi/6));
##   pts = transformPoint(pts, createTranslation(3, 4));
##   ell = inertiaEllipse(pts);
##   figure(1); clf; hold on;
##   drawPoint(pts);
##   drawEllipse(ell, 'linewidth', 2, 'color', 'r');
## @end example
##
##   @seealso{ellipses2d, drawEllipse}
## @end deftypefn

function ell = inertiaEllipse(points)

  # ellipse center
  xc = mean(points(:,1));
  yc = mean(points(:,2));

  # recenter points
  x = points(:,1) - xc;
  y = points(:,2) - yc;

  # number of points
  n = size(points, 1);

  # inertia parameters
  Ixx = sum(x.^2) / n;
  Iyy = sum(y.^2) / n;
  Ixy = sum(x.*y) / n;

  # compute ellipse semi-axis lengths
  common = sqrt( (Ixx - Iyy)^2 + 4 * Ixy^2);
  ra = sqrt(2) * sqrt(Ixx + Iyy + common);
  rb = sqrt(2) * sqrt(Ixx + Iyy - common);

  # compute ellipse angle in degrees
  theta = atan2(2 * Ixy, Ixx - Iyy) / 2;
  theta = rad2deg(theta);

  # create the resulting inertia ellipse
  ell = [xc yc ra rb theta];

endfunction

