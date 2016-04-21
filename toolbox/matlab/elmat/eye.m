function [varargout] = eye(varargin)
%EYE Identity matrix.
%   EYE(N) is the N-by-N identity matrix.
%
%   EYE(M,N) or EYE([M,N]) is an M-by-N matrix with 1's on
%   the diagonal and zeros elsewhere.
%
%   EYE(SIZE(A)) is the same size as A.
%
%   EYE with no arguments is the scalar 1.
%
%   EYE(M,N,CLASSNAME) or EYE([M,N],CLASSNAME) is an M-by-N matrix with 1's
%   of class CLASSNAME on the diagonal and zeros elsewhere.
%
%   Example:
%      x = eye(2,3,'int8');
%
%   See also SPEYE, ONES, ZEROS, RAND, RANDN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.8.4.3 $  $Date: 2004/01/24 09:21:20 $
%   Built-in function.

if nargout == 0
  builtin('eye', varargin{:});
else
  [varargout{1:nargout}] = builtin('eye', varargin{:});
end
