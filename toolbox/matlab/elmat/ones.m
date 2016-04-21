function [varargout] = ones(varargin)
%ONES   Ones array.
%   ONES(N) is an N-by-N matrix of ones.
%
%   ONES(M,N) or ONES([M,N]) is an M-by-N matrix of ones.
%
%   ONES(M,N,P,...) or ONES([M N P ...]) is an M-by-N-by-P-by-... array of
%   ones.
%
%   ONES(SIZE(A)) is the same size as A and all ones.
%
%   ONES with no arguments is the scalar 1.
%
%   ONES(M,N,...,CLASSNAME) or ONES([M,N,...],CLASSNAME) is an M-by-N-by-...
%   array of ones of class CLASSNAME.
%
%   Example:
%      x = ones(2,3,'int8');
%
%   See also EYE, ZEROS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.3 $  $Date: 2004/04/16 22:05:14 $
%   Built-in function.

if nargout == 0
  builtin('ones', varargin{:});
else
  [varargout{1:nargout}] = builtin('ones', varargin{:});
end
