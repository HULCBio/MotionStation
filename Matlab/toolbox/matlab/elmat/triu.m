function [varargout] = triu(varargin)
%TRIU Extract upper triangular part.
%   TRIU(X) is the upper triangular part of X.
%   TRIU(X,K) is the elements on and above the K-th diagonal of
%   X.  K = 0 is the main diagonal, K > 0 is above the main
%   diagonal and K < 0 is below the main diagonal.
%
%   See also TRIL, DIAG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:06:31 $
%   Built-in function.

if nargout == 0
  builtin('triu', varargin{:});
else
  [varargout{1:nargout}] = builtin('triu', varargin{:});
end
