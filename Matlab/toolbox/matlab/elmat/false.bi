function [varargout] = false(varargin)
%FALSE  False array.
%   FALSE is short-hand for logical(0).
%   FALSE(N) is an N-by-N matrix of logical zeros. 
%   FALSE(M,N) or FALSE([M,N]) is an M-by-N matrix of logical zeros.
%   FALSE(M,N,P,...) or FALSE([M N P ...]) is an M-by-N-by-P-by-...
%   array of logical zeros.
%   FALSE(SIZE(A)) is the same size as A and all logical zeros.
%
%   FALSE(N) is much faster and more memory efficient than LOGICAL(ZEROS(N)).
%
%   See also TRUE, LOGICAL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/16 22:04:56 $
%   Built-in function.

if nargout == 0
  builtin('false', varargin{:});
else
  [varargout{1:nargout}] = builtin('false', varargin{:});
end
