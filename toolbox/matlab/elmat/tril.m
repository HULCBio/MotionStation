function [varargout] = tril(varargin)
%TRIL Extract lower triangular part.
%   TRIL(X) is the lower triangular part of X.
%   TRIL(X,K) is the elements on and below the K-th diagonal
%   of X .  K = 0 is the main diagonal, K > 0 is above the
%   main diagonal and K < 0 is below the main diagonal.
%
%   See also TRIU, DIAG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:06:30 $
%   Built-in function.

if nargout == 0
  builtin('tril', varargin{:});
else
  [varargout{1:nargout}] = builtin('tril', varargin{:});
end
