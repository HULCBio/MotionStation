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
## @deftypefn {Function File} geom3d_Contents ()
## GEOM3D Geometry 3D Toolbox
## Version 1.0 21-Mar-2011 .
##
##   Creation, transformations, algorithms and visualization of geometrical
##   3D primitives, such as points, lines, planes, polyhedra, circles and
##   spheres.
##   
##   Euler Angles are defined as follow:
##   PHI is the azimut, i.e. the angle of the projection on horizontal plane
##   with the Ox axis, with value beween 0 and 180 degrees.
##   THETA is the latitude, i.e. the angle with the Oz axis, with value
##   between -90 and +90 degrees.
##   PSI is the 'roll', i.e. the rotation around the (PHI, THETA) direction,
##   with value in degrees
##   See also the 'angles3d' page.
##
##   Base format for primitives:
##   Point:      [x0 y0 z0]
##   Vector:     [dx dy dz]
##   Line:       [x0 y0 z0 dx dy dz]
##   Edge:       [x1 y1 z1 x2 y2 z2]
##   Plane:      [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
##   Sphere:     [x0 y0 z0 R]
##   Circle:     [x0 y0 z0 R PHI THETA PSI] (origin+center+normal+'roll').
##   Cylinder:   [X1 Y1 Z1 X2 Y2 Z2 R]
##   Box:        [xmin xmax ymin ymax zmin zmax]. Used for clipping shapes.
##   
##   Polygons are represented by N-by-3 array of points, the last point is
##   not necessarily the same as the first one. Points must be coplanar.
##
##   Meshes and Polyhedra are represented by a couple of variables @{V, F@}:
##   V: N-by-3 array of vetrtices: [x1 y1 z1; ... ;xn yn zn];
##   F: is either a [Nf*3] or [Nf*4] array containing reference for vertices
##       of each face, or a [Nf*1] cell array, where each cell is an array
##       containing a variable number of node indices.
##   For some functions, the array E of edges is needed. It consists in a
##   Ne-by-2 array containing indices of source and target vertices. 
##
##
## 3D Points
##   points3d                  - Description of functions operating on 3D points
##   midPoint3d                - Middle point of two 3D points or of a 3D edge
##   isCoplanar                - Tests input points for coplanarity in 3-space.
##   transformPoint3d          - Transform a point with a 3D affine transform
##   distancePoints           - Compute euclidean distance between pairs of 3D Points
##   clipPoints3d              - Clip a set of points by a box
##   drawPoint3d               - Draw 3D point on the current axis.
##
## 3D Vectors
##   vectors3d                 - Description of functions operating on 3D vectors
##   transformVector3d         - Transform a vector with a 3D affine transform
##   normalizeVector3d         - Normalize a 3D vector to have norm equal to 1
##   vectorNorm3d              - Norm of a 3D vector or of set of 3D vectors
##   vectorAngle3d             - Angle between two 3D vectors
##   isParallel3d              - Check parallelism of two 3D vectors
##   isPerpendicular3d         - Check orthogonality of two 3D vectors
##
## Angles
##   angles3d                  - Conventions for manipulating angles in 3D
##   anglePoints3d             - Compute angle between three 3D points
##   sphericalAngle            - Compute angle between points on the sphere
##   angleSort3d               - Sort 3D coplanar points according to their angles in plane
##   randomAngle3d             - Return a 3D angle uniformly distributed on unit sphere
##
## Coordinate transforms
##   sph2cart2                 - Convert spherical coordinates to cartesian coordinates
##   cart2sph2                 - Convert cartesian coordinates to spherical coordinates
##   cart2sph2d                - Convert cartesian coordinates to spherical coordinates in degrees
##   sph2cart2d                - Convert spherical coordinates to cartesian coordinates in degrees
##   cart2cyl                  - Convert cartesian to cylindrical coordinates
##   cyl2cart                  - Convert cylindrical to cartesian coordinates
##
## 3D Lines and Edges
##   lines3d                   - Description of functions operating on 3D lines
##   createLine3d              - Create a line with various inputs.
##   transformLine3d           - Transform a 3D line with a 3D affine transform
##   clipLine3d                - Clip a line with a box and return an edge
##   midPoint3d                - Middle point of two 3D points or of a 3D edge
##   distancePointLine3d       - Euclidean distance between 3D point and line
##   distanceLines3d           - Minimal distance between two 3D lines
##   linePosition3d            - Return the position of a 3D point on a 3D line
##   drawEdge3d                - Draw 3D edge in the current Window
##   drawLine3d                - Draw a 3D line on the current axis
##
## Planes
##   planes3d                  - Description of functions operating on 3D planes
##   createPlane               - Create a plane in parametrized form
##   normalizePlane            - Normalize parametric representation of a plane
##   intersectPlanes           - Return intersection line between 2 planes in space
##   intersectLinePlane        - Return intersection point between a plane and a line
##   intersectEdgePlane        - Return intersection point between a plane and a edge
##   distancePointPlane        - Signed distance betwen 3D point and plane
##   projPointOnPlane          - Return the orthogonal projection of a point on a plane
##   isBelowPlane              - Test whether a point is below or above a plane
##   medianPlane               - Create a plane in the middle of 2 points
##   planeNormal               - Compute the normal to a plane
##   planePosition             - Compute position of a point on a plane
##   planePoint                - Compute 3D position of a point in a plane
##   dihedralAngle             - Compute dihedral angle between 2 planes
##   drawPlane3d               - Draw a plane clipped in the current window
##
## 3D Polygons and curves
##   polygons3d                - Description of functions operating on 3D polygons
##   polygonCentroid3d         - Centroid (or center of mass) of a polygon
##   triangleArea3d            - Area of a 3D triangle
##   polygon3dNormalAngle      - Normal angle at a vertex of the 3D polygon
##   intersectLinePolygon3d    - Intersection point of a 3D line and a 3D polygon
##   intersectLineTriangle3d   - Intersection point of a 3D line and a 3D triangle
##   intersectRayPolygon3d     - Intersection point of a 3D ray and a 3D polygon
##   clipConvexPolygon3dHP     - Clip a convex 3D polygon with Half-space
##   drawPolygon3d             - Draw a 3D polygon specified by a list of vertices
##   drawPolyline3d            - Draw a 3D polyline specified by a list of vertices
##   fillPolygon3d             - Fill a 3D polygon specified by a list of points
##
## 3D circles and ellipses
##   circles3d                 - Description of functions operating on 3D circles
##   circle3dPosition          - Return the angular position of a point on a 3D circle
##   circle3dPoint             - Coordinates of a point on a 3D circle from its position
##   circle3dOrigin            - Return the first point of a 3D circle
##   drawCircle3d              - Draw a 3D circle
##   drawCircleArc3d           - Draw a 3D circle arc
##   drawEllipse3d             - Draw a 3D ellipse
##
## Spheres
##   spheres                   - Description of functions operating on 3D spheres
##   createSphere              - Create a sphere containing 4 points
##   intersectLineSphere       - Return intersection points between a line and a sphere
##   intersectPlaneSphere      - Return intersection circle between a plane and a sphere
##   drawSphere                - Draw a sphere as a mesh
##   drawSphericalTriangle     - Draw a triangle on a sphere
##
## Smooth surfaces
##   inertiaEllipsoid          - Inertia ellipsoid of a set of 3D points
##   intersectLineCylinder     - Compute intersection points between a line and a cylinder
##   revolutionSurface         - Create a surface of revolution from a planar curve
##   surfaceCurvature          - Curvature on a surface from angle and principal curvatures
##   drawEllipsoid             - Draw a 3D ellipsoid
##   drawTorus                 - Draw a torus (3D ring)
##   drawCylinder              - Draw a cylinder
##   drawSurfPatch             - Draw a 3D surface patch, with 2 parametrized surfaces
##
## Bounding boxes management
##   boxes3d                   - Description of functions operating on 3D boxes
##   point3dBounds             - Bounding box of a set of 3D points
##   intersectBoxes3d          - Intersection of two 3D bounding boxes
##   mergeBoxes3d              - Merge 3D boxes, by computing their greatest extent
##   box3dVolume               - Volume of a 3-dimensional box
##   randomPointInBox3d        - Generate random point(s) within a 3D box
##   drawBox3d                 - Draw a 3D box defined by coordinate extents
##
## Geometric transforms
##   transforms3d              - Conventions for manipulating 3D affine transforms
##   createTranslation3d       - Create the 4x4 matrix of a 3D translation
##   createScaling3d           - Create the 4x4 matrix of a 3D scaling
##   createRotationOx          - Create the 4x4 matrix of a 3D rotation around x-axis
##   createRotationOy          - Create the 4x4 matrix of a 3D rotation around y-axis
##   createRotationOz          - Create the 4x4 matrix of a 3D rotation around z-axis
##   createBasisTransform3d    - Compute matrix for transforming a basis into another basis
##   eulerAnglesToRotation3d   - Convert 3D Euler angles to 3D rotation matrix
##   rotation3dToEulerAngles   - Extract Euler angles from a rotation matrix
##   createRotation3dLineAngle - Create rotation around a line by an angle theta
##   rotation3dAxisAndAngle    - Determine axis and angle of a 3D rotation matrix
##   recenterTransform3d       - Change the fixed point of an affine 3D transform
##   composeTransforms3d       - Concatenate several space transformations
##
## Various drawing Functions
##   drawGrid3d                - Draw a 3D grid on the current axis
##   drawAxis3d                - Draw a coordinate system and an origin
##   drawAxisCube              - Draw a colored cube representing axis orientation
##   drawCube                  - Draw a 3D centered cube, eventually rotated
##   drawCuboid                - Draw a 3D cuboid, eventually rotated
##
##
##   Credits:
##   * function isCoplanar was originally written by Brett Shoelson.
##   * Songbai Ji enhanced file intersectPlaneLine (6/23/2006).
##
## @end deftypefn

function geom3d_Contents ()

  help('geom3d_Contents');
  
  ## In development:
  ##   clipPolygon3dHP           - clip a 3D polygon with Half-space
  ##   drawPartialPatch          - draw surface patch, with 2 parametrized surfaces


  ## Deprecated:
  ##   intersectPlaneLine        - return intersection between a plane and a line
  ##   translation3d             - return 4x4 matrix of a 3D translation
  ##   scale3d                   - return 4x4 matrix of a 3D scaling
  ##   rotationOx                - return 4x4 matrix of a rotation around x-axis
  ##   rotationOy                - return 4x4 matrix of a rotation around y-axis
  ##   rotationOz                - return 4x4 matrix of a rotation around z-axis
  ##   scaling3d                 - return 4x4 matrix of a 3D scaling
  ##   vecnorm3d                 - compute norm of vector or of set of 3D vectors
  ##   normalize3d               - normalize a 3D vector
  ##   drawCurve3d               - draw a 3D curve specified by a list of points
  ##   createEulerAnglesRotation - Create a rotation matrix from 3 euler angles

endfunction
