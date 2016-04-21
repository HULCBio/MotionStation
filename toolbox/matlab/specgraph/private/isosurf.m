function varargout = isosurf(varargin)
%ISOSURF  Isosurface extraction.
%   [VERTICES, FACES] = ISOSURF(V, C, ISOVALUE, NOSHARE, VERBOSE)
%   extracts an isovalue surface from data V at ISOVALUE.
%   The algorithm is edge based and returns the result (in patch
%   format) in arrays VERTICES and FACES (both transposed). If 
%   NOSHARE is 1, shared vertices are not created. If VERBOSE 
%   is 1, progress messages are printed as the computation 
%   progresses. C is an optional color array.
%
%   Example:
%       [v f] = isosurf(flow, [], -3, 0, 1);
%       v = v'; f = f';
%       p = patch('Vertices', v, 'Faces', f, 'FaceColor', 'red');
%       view(3); daspect([1 1 1])
%       camlight
%
%   See also ISOSURFACE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/06/17 13:37:42 $
%#mex

error('Missing MEX-file ISOSURF');


