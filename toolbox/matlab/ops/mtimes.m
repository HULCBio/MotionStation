function [varargout] = mtimes(varargin)
%*   Matrix multiply.
%   X*Y is the matrix product of X and Y.  Any scalar (a 1-by-1 matrix)
%   may multiply anything.  Otherwise, the number of columns of X must
%   equal the number of rows of Y.
%
%   C = MTIMES(A,B) is called for the syntax 'A * B' when A or B is an
%   object.
%
%   See also TIMES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:56 $

if nargout == 0
  builtin('mtimes', varargin{:});
else
  [varargout{1:nargout}] = builtin('mtimes', varargin{:});
end
