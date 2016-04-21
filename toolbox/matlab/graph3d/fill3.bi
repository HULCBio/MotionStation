%FILL3  Filled 3-D polygons.
%   FILL3(X,Y,Z,C) fills the 3-D polygon defined by vectors X, Y and Z
%   with the color specified by C.  The vertices of the polygon
%   are specified by triples of components of X, Y and Z.  If necessary,
%   the polygon is closed by connecting the last vertex to the first.
%
%   If C is a single character string chosen from the list 'r','g','b',
%   'c','m','y','w','k', or an RGB row vector triple, [r g b], the
%   polygon is filled with the constant specified color.
%
%   If C is a vector the same length as X, Y and Z, its elements are
%   scaled by CAXIS and used as indices into the current COLORMAP to
%   specify colors at the vertices; the color within the polygon is
%   obtained by bilinear interpolation in the vertex colors.
%
%   If X, Y and Z are matrices the same size, one polygon per column
%   is drawn. In this case, C is a row vector for "flat" polygon
%   colors, and C is a matrix for "interpolated" polygon colors. 
%
%   If any of X, Y or Z is a matrix, and the others are column vectors
%   with the same number of rows, the column vector arguments are
%   replicated to produce matrices of the required size.
%
%   FILL3(X1,Y1,Z1,C1,X2,Y2,Z2,C2,...) is another way of specifying
%   multiple filled areas.
%
%   FILL3 sets the PATCH object FaceColor property to 'flat', 'interp',
%   or a colorspec depending upon the value of the C matrix.
%
%   FILL3 returns a column vector of handles to PATCH objects, one handle
%   per patch. The X,Y,Z,C quads can be followed by parameter/value pairs 
%   to specify additional properties of the patches.
%
%   See also PATCH, FILL, COLORMAP, SHADING.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:27:19 $
%   Built-in function.
