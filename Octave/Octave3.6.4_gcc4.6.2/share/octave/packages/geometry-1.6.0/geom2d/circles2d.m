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
## @deftypefn {Function File} circles2d ()
## Description of functions operating on circles
##
##   Circles are represented by their center and their radius:
##   C = [xc yc r];
##   One sometimes considers orientation of circle, by adding an extra
##   boolean value in 4-th position, with value TRUE for direct (i.e.
##   turning Counter-clockwise) circles.
##
##   Circle arcs are represented by their center, their radius, the starting
##   angle and the angle extent, both in degrees:
##   CA = [xc yc r theta0 dtheta];
##   
##   Ellipses are represented by their center, their 2 semi-axis length, and
##   their angle (in degrees) with Ox direction.
##   E = [xc yc A B theta];
##
##   @seealso{ellipses2d, createCircle, createDirectedCircle, enclosingCircle
##   isPointInCircle, isPointOnCircle
##   intersectLineCircle, intersectCircles, radicalAxis
##   circleAsPolygon, circleArcAsCurve
##   drawCircle, drawCircleArc}
## @end deftypefn

function circles2d(varargin)

  help('circles2d');

endfunction

