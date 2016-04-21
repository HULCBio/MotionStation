%PATCH  Create patch.
%   PATCH(X,Y,C) adds the "patch" or filled 2-D polygon defined by
%   vectors X and Y to the current axes. If X and Y are matrices of
%   the same size, one polygon ("face") per column is added. C
%   specifies the color of the face(s) ("flat" coloring), or the 
%   vertices ("interpolated" coloring), for which bilinear interpolation
%   is used to determine the interior color of the polygon.
%
%   For both vector or matrix X and Y, if C is a string, each face
%   is filled with 'color'. 'color' can be 'r','g','b','c','m','y', 
%   'w', or 'k'. If C is a scalar it specifies the color of the 
%   face(s) by indexing into the colormap. A 1x3 vector C is always
%   assumed to be an RGB triplet specifying a color directly.
%
%   For vector X and Y, if C is a vector of the same length, it
%   specifies the color of each vertex as indices into the
%   colormap and bilinear interpolation is used to determine the
%   interior color of the polygon ("interpolated" shading).
%
%   When X and Y are matrices, if C is a 1xn, where n is the number
%   of columns in X and Y, then each face j=1:n is flat colored by the
%   colormap index C(j). Note the special case of a 1x3 C is always 
%   assumed to be an RGB triplet ColorSpec and specifies the same
%   flat color for each face. If C is a matrix the same size as X
%   and Y, then it specifies the colors at the vertices as colormap
%   indices and bilinear interpolation is used to color the faces.
%   If C is 1xnx3, where n is the number of columns of X and Y,
%   then each face j is flat colored by the RGB triplet C(1,j,:).
%   If C is mxnx3, where X and Y are mxn, then each vertex
%   (X(i,j),Y(i,j)) is colored by the RGB triplet C(i,j,:) and the
%   face is colored using interpolation.
%
%   PATCH(X,Y,Z,C) creates a patch in 3-D coordinates. Z must be the
%   same size as X and Y.
%
%   PATCH returns a handle to a Patch object. Patches are children 
%   of AXES objects.
%
%   The X,Y,C triple (X,Y,Z,C quad for 3-D) can be followed by 
%   parameter/value pairs to specify additional properties of the
%   Patch. The X,Y,C triple (X,Y,Z,C quad for 3-D) can be omitted
%   entirely, and all properties specified using parameter/value
%   pairs.
%
%   Patch objects also support data specified using the properties
%   Faces, Vertices, and FaceVertexCData (see the reference manual
%   for more information).  These properties do not have a convenience
%   syntax, but may be specified using param-value pairs.  Patch
%   data specified as XData, YData, ZData, and CData is translated
%   and stored internally as Faces, Vertices, and FaceVertexCData, and
%   the original matrices are not stored.  When GET is used to query
%   XData, YData, ZData, or CData, the returned value is computed by
%   translating from Faces, Vertices, and FaceVertexCData.
%
%   GET(H), where H is a patch handle, displays a list of patch
%   object properties and their current values. SET(H) will display
%   a list of patch object properties and legal property values.
%
%   See also FILL, FILL3, LINE, TEXT, SHADING.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/06/17 13:38:26 $
%   Built-in function.

