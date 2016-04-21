%FILL Filled 2-D polygons.
%   FILL(X,Y,C) fills the 2-D polygon defined by vectors X and Y
%   with the color specified by C.  The vertices of the polygon
%   are specified by pairs of components of X and Y.  If necessary,
%   the polygon is closed by connecting the last vertex to the first.
%
%   If C is a single character string chosen from the list 'r','g','b',
%   'c','m','y','w','k', or an RGB row vector triple, [r g b], the
%   polygon is filled with the constant specified color.
%
%   If C is a vector the same length as X and Y, its elements are
%   scaled by CAXIS and used as indices into the current COLORMAP to
%   specify colors at the vertices; the color within the polygon is
%   obtained by bilinear interpolation in the vertex colors.
%
%   If X and Y are matrices the same size, one polygon per column
%   is drawn. In this case, C is a row vector for "flat" polygon
%   colors, and C is a matrix for "interpolated" polygon colors. 
%
%   If either of X or Y is a matrix, and the other is a column vector
%   with the same number of rows, the column vector argument is
%   replicated to produce a matrix of the required size.
%
%   FILL(X1,Y1,C1,X2,Y2,C2,...) is another way of specifying
%   multiple filled areas.
%
%   FILL sets the PATCH object FaceColor property to 'flat', 'interp',
%   or a colorspec depending upon the value of the C matrix.
%
%   H = FILL(...) returns a column vector of handles to PATCH objects, 
%   one handle per patch. The X,Y,C triples can be followed by 
%   parameter/value pairs to specify additional properties of the patches.
%
%   See also PATCH, FILL3, COLORMAP, SHADING.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2002/06/17 13:38:16 $
%   Built-in function.



