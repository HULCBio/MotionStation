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
## @deftypefn {Function File} meshes3d_Contents ()
## MESHES3D 3D Surface Meshes
## Version 1.0 21-Mar-2011 .
##
##   Creation, vizualization, and manipulation of 3D surface meshes or
##   polyhedra.
##
##   Meshes and Polyhedra are represented by a couple of variables @{V, F@}:
##   V: Nv-by-3 array of vertices: [x1 y1 z1; @dots{} ; xn yn zn];
##   F: is either a NF-by-3 or NF-by-4 array containing reference for
##   vertices of each face, or a NF-by-1 cell array, where each cell is an
##   array containing a variable number of node indices.
##   For some functions, the array E of edges is needed. It consists in a
##   NE-by-2 array containing indices of source and target vertices.
##
##   The library provides function to create basic polyhedric meshes (the 5
##   platonic solids, plus few others), as well as functions to perform
##   basic computations (surface area, normal angles, face centroids @dots{}).
##   The 'MengerSponge' structure is an example of mesh that is not simply
##   connected (multiple tunnels in the structure).
##
##   The drawMesh function is mainly a wrapper to the Matlab 'patch'
##   function, allowing passing arguments more quickly.
##
##   Example
## @example
##     # create a soccer ball mesh and display it
##     [n e f] = createSoccerBall;
##     drawMesh(n, f, 'faceColor', 'g', 'linewidth', 2);
##     axis equal;
## @end example
##
##
## General functions
##   meshFace                 - Return the vertex indices of a face in a mesh
##   computeMeshEdges         - Computes edges array from face array
##   meshEdgeFaces            - Compute index of faces adjacent to each edge of a mesh
##   faceCentroids            - Compute centroids of a mesh faces
##   faceNormal               - Compute normal vector of faces in a 3D mesh
##
## Measures on meshes
##   meshSurfaceArea          - Surface area of a polyhedral mesh
##   trimeshSurfaceArea       - Surface area of a triangular mesh
##   meshEdgeLength           - Lengths of edges of a polygonal or polyhedral mesh
##   meshDihedralAngles       - Dihedral at edges of a polyhedal mesh
##   polyhedronNormalAngle    - Compute normal angle at a vertex of a 3D polyhedron
##   polyhedronMeanBreadth    - Mean breadth of a convex polyhedron
##
## Basic processing
##   triangulateFaces         - Convert face array to an array of triangular faces
##   meshReduce               - Merge coplanar faces of a polyhedral mesh
##   minConvexHull            - Return the unique minimal convex hull of a set of 3D points
##   polyhedronSlice          - Intersect a convex polyhedron with a plane.
##   checkMeshAdjacentFaces   - Check if adjacent faces of a mesh have similar orientation
##   clipMeshVertices         - Clip vertices of a surfacic mesh and remove outer faces
##   clipConvexPolyhedronHP   - Clip a convex polyhedron by a plane
##
## Typical polyhedra
##   polyhedra                - Index of classical polyhedral meshes
##   createCube               - Create a 3D mesh representing the unit cube
##   createOctahedron         - Create a 3D mesh representing an octahedron
##   createCubeOctahedron     - Create a 3D mesh representing a cube-octahedron
##   createIcosahedron        - Create a 3D mesh representing an Icosahedron.
##   createDodecahedron       - Create a 3D mesh representing a dodecahedron
##   createTetrahedron        - Create a 3D mesh representing a tetrahedron
##   createRhombododecahedron - Create a 3D mesh representing a rhombododecahedron
##   createTetrakaidecahedron - Create a 3D mesh representing a tetrakaidecahedron
##
## Less typical polyhedra
##   createSoccerBall         - Create a 3D mesh representing a soccer ball
##   createMengerSponge       - Create a cube with an inside cross removed
##   steinerPolytope          - Create a steiner polytope from a set of vectors
##
## Drawing functions
##   drawFaceNormals          - Draw normal vector of each face in a mesh
##   drawMesh                 - Draw a 3D mesh defined by vertices and faces
## @end deftypefn

function meshes3d_Contents ()

  help meshes3d_Contents

endfunction
