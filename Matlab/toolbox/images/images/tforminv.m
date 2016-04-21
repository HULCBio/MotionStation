function varargout = tforminv(varargin)
%TFORMINV Apply inverse spatial transformation.
%   TFORMINV applies an inverse spatial transformation based on a TFORM
%   structure created with MAKETFORM, FLIPTFORM, or CP2TFORM.
%   
%   [U,V] = TFORMINV(T,X,Y) applies the 2D-to-2D inverse transformation
%   defined in TFORM structure T to coordinate arrays X and Y, mapping
%   the point [X(k) Y(k)] to the point [U(k) V(k)].  Both T.ndims_in
%   and T.ndims_out must equal 2.  X and Y will typically be column
%   vectors matching in length.  In general, X and Y can have any
%   dimensionality, but must have the same size.  In any case, U and V
%   will have the same size as X and Y.
%
%   [U1,U2,U3,...] = TFORMINV(T,X1,X2,X3,...) applies the NDIMS_OUT-to-
%   NDIMS_IN inverse transformation defined in TFORM structure T to the
%   coordinate arrays X1,X2,...,XNDIMS_OUT (where NDIMS_IN = T.ndims_in
%   and NDIMS_OUT = T.ndims_out).  The number of output arguments
%   must equal NDIMS_IN.  The transformation maps the point
%              [X1(k) X2(k) ... XNDIMS_OUT(k)]
%   to the point
%              [U1(k) U2(k) ... UNDIMS_IN(k)].
%   X1,X2,X3,... can have any dimensionality, but must be the same size.
%   U1,U2,U3,... will have this size also.
%
%   U = TFORMINV(T,X) applies the NDIMS_OUT-to-NDIMS_IN inverse
%   transformation defined in TFORM structure T to each row of X, where
%   X is an M-by-NDIMS_OUT matrix.  It maps the point X(k,:) to the
%   point U(k,:).  U will be an M-by-NDIMS_IN matrix.
%
%   U = TFORMINV(T,X), where X is an (N+1)-dimensional array, maps
%   the point X(k1,k2,...,kN,:) to the point U(k1,k2,...,kN,:).
%   SIZE(X,N+1) must equal NDIMS_OUT.  U will be an (N+1)-dimensional
%   array, with SIZE(U,I) equal to SIZE(X,I) for I = 1,...,N and
%   SIZE(U,N+1) equal to NDIMS_IN.
%
%   [U1,U2,U3,...] = TFORMINV(T,X) maps an (N+1)-dimensional array
%   to NDIMS_IN equally-sized N-dimensional arrays.
%
%   U = TFORMINV(T,X1,X2,X3,...) maps NDIMS_OUT N-dimensional arrays
%   to one (N+1)-dimensional array.
%
%   Note
%   ----
%   U = TFORMINV(X,T) is an older form of the two-argument syntax
%   that remains supported for backward compatibility.
% 
%   Example
%   -------
%   Create an affine transformation that maps the triangle with vertices
%   (0,0), (6,3), (-2,5) to the triangle with vertices (-1,-1), (0,-10),
%   (4,4):
%
%       u = [ 0   6  -2]';
%       v = [ 0   3   5]';
%       x = [-1   0   4]';
%       y = [-1 -10   4]';
%       tform = maketform('affine',[u v],[x y]);
%   
%   Validate the mapping by applying TFORMINV:
%
%       [um, vm] = tforminv(tform, x, y)  % Results should equal [u, v]
%
%   See also TFORMFWD, MAKETFORM, FLIPTFORM, CP2TFORM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $ $Date: 2003/05/03 17:52:41 $

varargout = tform('inv', nargout, varargin{:});
