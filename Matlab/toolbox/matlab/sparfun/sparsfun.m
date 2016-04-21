function [varargout] = sparsfun(varargin)
%SPARSFUN Sparse auxiliary functions and parameters.
%   Several MATLAB functions, defined in M-files, use this built-in
%   function with a text keyword as the first argument to access the
%   internal sparse data structure.
%   eg. nnz = sparsfun('nnz',S) and p = sparsfun('colmmd',S).

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:08:30 $
%   Built-in function.

if nargout == 0
  builtin('sparsfun', varargin{:});
else
  [varargout{1:nargout}] = builtin('sparsfun', varargin{:});
end
