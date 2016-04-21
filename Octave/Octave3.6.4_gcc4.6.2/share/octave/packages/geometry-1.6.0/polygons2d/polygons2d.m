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
## @deftypefn {Function File} {} polygons2d ()
## Description of functions operating on 2D polygons
##
##   The 'polygons' module contains functions operating on shapes composed
##   of a vertex list, like polygons or polylines.
##
##   We call 'polyline' the curve defined by a series of vertices.
##   A polyline can be either closed or open, depending on whether the last
##   vertex is connected to the first one or not. This can be given as an
##   option is some functions in the module.
##   A 'polygon' is the planar domain delimited by a closed polyline. We
##   sometimes want to consider 'complex polygons', whose boundary is
##   composed of several disjoint domains. The domain defined by a single
##   closed polyline is called 'simple polygon'.
##   We call 'curve' a polyline with many vertices, such that the polyline
##   can be considered as a discrete approximation of a "real" curve.
##
##   A simple polygon or polyline is represented by a N-by-2 array, each row
##   of the array representing the coordinates of a vertex. 
##   Simple polygons are assumed to be closed, so there is no need to repeat
##   the first vertex at the end. 
##   As both polygons and polylines can be represented by a list of vertex
##   coordinates, some functions also consider the vertex list itself. Such
##   functions are prefixed by 'pointSet'. Also, many functions prefixed by
##   'polygon' or 'polyline' works also on the other type of shape.
##
##   For multiple-connected polygons, the different connected boundaries are
##   separated by a row [NaN NaN].
##
##   For some functions, the orientation of the polygon can be relevant: CCW
##   stands for 'Conter-Clockwise' (positive orientation), CW stands for
##   'Clockwise'.
##
##   Polylines are parametrized in the following way:
##   * the i-th vertex is located at position i-1
##   * points of the i-th edge have positions ranging linearly from i-1 to i
##   The parametrization domain for an open polyline is from 0 to Nv-1, and
##   from 0 to Nv for a closed polyline (positions 0 and Nv correspond to
##   the same point).
##
##   Example:
##   # Simple polygon:
##   P1 = [1 1;2 1;2 2;1 2];
##   drawPolygon(P1);
##   axis([0 5 0 5]);
##   # Multiple polygon:
##   P2 = [10 10;40 10;40 40;10 40;NaN NaN;20 20;20 30;30 30;30 20];
##   figure;drawPolygon(P2); axis([0 50 0 50]);
##
##
## Point Sets
##   pointSetBounds            - Bounding box of a set of points
##   pointSetsAverage          - Compute the average of several point sets
##   minimumCaliperDiameter    - Minimum caliper diameter of a set of points
##   findPoint                 - Find index of a point in an set from its coordinates
##
## Polylines
##   polylinePoint             - Extract a point from a polyline
##   polylineLength            - Return length of a polyline given as a list of points
##   polylineCentroid          - Compute centroid of a curve defined by a series of points
##   polylineSubcurve          - Extract a portion of a polyline
##   reversePolyline           - Reverse a polyline, by iterating vertices from the end
##   isPointOnPolyline         - Test if a point belongs to a polyline
##   projPointOnPolyline       - Compute position of a point projected on a polyline
##   distancePointPolyline     - Compute shortest distance between a point and a polyline
##   distancePolylines         - Compute the shortest distance between 2 polylines
##   intersectPolylines        - Find the common points between 2 polylines
##   polylineSelfIntersections - Find self-intersections points of a polyline
##
## Curves (polylines with lot of vertices)
##   parametrize               - Parametrization of a curve, based on edges length
##   curvature                 - Estimate curvature of a polyline defined by points
##   cart2geod                 - Convert cartesian coordinates to geodesic coord.
##   geod2cart                 - Convert geodesic coordinates to cartesian coord.
##   curveMoment               - Compute inertia moment of a 2D curve
##   curveCMoment              - Compute centered inertia moment of a 2D curve
##   curveCSMoment             - Compute centered scaled moment of a 2D curve
##
## Polygons
##   polygonPoint              - Extract a point from a polygon
##   polygonSubcurve           - Extract a portion of a polygon
##   reversePolygon            - Reverse a polygon, by iterating vertices from the end
##   projPointOnPolygon        - Compute position of a point projected on a polygon
##   splitPolygons             - Convert a NaN separated polygon list to a cell array of polygons
##   clipPolygon               - Clip a polygon with a rectangular box
##   clipPolygonHP             - Clip a polygon with a Half-plane defined by a directed line
##   intersectLinePolygon      - Intersection points between a line and a polygon
##   intersectRayPolygon       - Intersection points between a ray and a polygon
##   polygonSelfIntersections  - Find-self intersection points of a polygon
##   convexHull                - Convex hull of a set of points
##   polygonLoops              - Divide a possibly self-intersecting polygon into a set of simple loops
##   expandPolygon             - Expand a polygon by a given (signed) distance
##   medialAxisConvex          - Compute medial axis of a convex polygon
##
## Measures on Polygons
##   isPointInPolygon          - Test if a point is located inside a polygon
##   polygonContains           - Test if a point is contained in a multiply connected polygon
##   polygonCentroid           - Compute the centroid (center of mass) of a polygon
##   polygonArea               - Compute the signed area of a polygon
##   polygonLength             - Perimeter of a polygon
##   polygonNormalAngle        - Compute the normal angle at a vertex of the polygon
##   polygonBounds             - Compute the bounding box of a polygon
##   distancePointPolygon      - Compute shortest distance between a point and a polygon
##   distancePolygons          - Compute the shortest distance between 2 polygons
##
## Triangles
##   isPointInTriangle         - Test if a point is located inside a triangle
##   triangleArea              - Area of a triangle
##
## Functions from stochastic geometry
##   steinerPoint              - Compute steiner point (weighted centroid) of a polygon
##   steinerPolygon            - Create a Steiner polygon from a set of vectors
##   supportFunction           - Compute support function of a polygon
##   convexification           - Compute the convexification of a polygon
##
## Input, Output and conversions
##   readPolygon               - Read a polygon stored in a file
##   polygonToRow              - Convert polygon coordinates to a row vector
##   rowToPolygon              - Create a polygon from a row vector
##   rectAsPolygon             - Convert a (centered) rectangle into a series of points
##
## Drawing functions
##   drawPolyline              - Draw a polyline specified by a list of points
##   drawPolygon               - Draw a polygon specified by a list of points
##   fillPolygon               - Fill a polygon specified by a list of points
##
##
##   Credits:
##   * function intersectPolylines uses the 'interX' contribution from "NS"
##       (file exchange 22441, called 'curve-intersections')
##
## -----
## Author: David Legland
## e-mail: david.legland@@grignon.inra.fr
## created the  07/11/2005.
## Homepage: @url{http://matgeom.sourceforge.net/}
## @url{http://www.pfl-cepia.inra.fr/index.php?page=geom2d}
## Copyright INRA - Cepia Software Platform.
##
## @end deftypefn 

function polygons2d ()

help('polygons2d');

endfunction
