function varargout = tformfwd(varargin)
%TFORMFWD Apply forward spatial transformation.
%   TFORMFWD applies a forward spatial transformation based on a TFORM
%   structure created with MAKETFORM, FLIPTFORM, or CP2TFORM.
%   
%   [X,Y] = TFORMFWD(T,U,V) applies the 2D-to-2D spatial transformation
%   defined in TFORM structure T to coordinate arrays U and V, mapping
%   the point [U(k) V(k)] to the point [X(k) Y(k)].  Both T.ndims_in
%   and T.ndims_out must equal 2.  U and V will typically be column
%   vectors matching in length.  In general, U and V can have any
%   dimensionality, but must have the same size.  In any case, X and Y
%   will have the same size as U and V.
%
%   [X1,X2,X3,...] = TFORMFWD(T,U1,U2,U3,...) applies the NDIMS_IN-to-
%   NDIMS_OUT spatial transformation defined in TFORM structure T to the
%   coordinate arrays U1,U2,...,UNDIMS_IN (where NDIMS_IN = T.ndims_in
%   and NDIMS_OUT = T.ndims_out).  The number of output arguments
%   must equal NDIMS_OUT.  The transformation maps the point
%              [U1(k) U2(k) ... UNDIMS_IN(k)]
%   to the point
%              [X1(k) X2(k) ... XNDIMS_OUT(k)].
%   U1,U2,U3,... can have any dimensionality, but must be the same size.
%   X1,X2,X3,... will have this size also.
%
%   X = TFORMFWD(T,U) applies the NDIMS_IN-to-NDIMS_OUT spatial
%   transformation defined in TFORM structure T to each row of U, where
%   U is an M-by-NDIMS_IN matrix.  It maps the point U(k,:) to the
%   point X(k,:).  X will be an M-by-NDIMS_OUT matrix.
%
%   X = TFORMFWD(T,U), where U is an (N+1)-dimensional array, maps
%   the point U(k1,k2,...,kN,:) to the point X(k1,k2,...,kN,:).
%   SIZE(U,N+1) must equal NDIMS_IN.  X will be an (N+1)-dimensional
%   array, with SIZE(X,I) equal to SIZE(U,I) for I = 1,...,N and
%   SIZE(X,N+1) equal to NDIMS_OUT.
%
%   [X1,X2,X3,...] = TFORMFWD(T,U) maps an (N+1)-dimensional array
%   to NDIMS_OUT equally-sized N-dimensional arrays.
%
%   X = TFORMFWD(T,U1,U2,U3,...) maps NDIMS_IN N-dimensional arrays
%   to one (N+1)-dimensional array.
%
%   Note
%   ----
%   X = TFORMFWD(U,T) is an older form of the two-argument syntax
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
%   Validate the mapping by applying TFORMFWD:
%
%       [xm, ym] = tformfwd(tform, u, v)  % Results should equal [x, y]
%
%   See also TFORMINV, MAKETFORM, FLIPTFORM, CP2TFORM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $ $Date: 2003/05/03 17:52:40 $

varargout = tform('fwd', nargout, varargin{:});
