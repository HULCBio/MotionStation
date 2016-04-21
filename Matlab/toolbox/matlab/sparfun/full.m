function [varargout] = full(varargin)
%FULL   Convert sparse matrix to full matrix.
%   A = FULL(X) converts a sparse matrix S to full storage
%   organization.  If X is a full matrix, it is left unchanged.
%
%   If A is full, issparse(A) returns 0.
%
%   See also ISSPARSE, SPARSE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:08:22 $
%   Built-in function.

if nargout == 0
  builtin('full', varargin{:});
else
  [varargout{1:nargout}] = builtin('full', varargin{:});
end
