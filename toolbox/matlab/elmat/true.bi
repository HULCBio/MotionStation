function [varargout] = true(varargin)
%TRUE   True array.
%   TRUE is short-hand for logical(1).
%   TRUE(N) is an N-by-N matrix of logical ones.
%   TRUE(M,N) or TRUE([M,N]) is an M-by-N matrix of logical ones.
%   TRUE(M,N,P,...) or TRUE([M N P ...]) is an M-by-N-by-P-by-...
%   array of logical ones.
%   TRUE(SIZE(A)) is the same size as A and all logical ones.
%
%   TRUE(N) is much faster and more memory efficient than LOGICAL(ONES(N)).
%
%   See also FALSE, LOGICAL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/16 22:06:32 $
%   Built-in function.

if nargout == 0
  builtin('true', varargin{:});
else
  [varargout{1:nargout}] = builtin('true', varargin{:});
end
