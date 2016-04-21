function [varargout] = reshape(varargin)
%RESHAPE Change size.
%   RESHAPE(X,M,N) returns the M-by-N matrix whose elements
%   are taken columnwise from X.  An error results if X does
%   not have M*N elements.
%
%   RESHAPE(X,M,N,P,...) returns an N-D array with the same
%   elements as X but reshaped to have the size M-by-N-by-P-by-...
%   M*N*P*... must be the same as PROD(SIZE(X)).
%
%   RESHAPE(X,[M N P ...]) is the same thing.
%
%   RESHAPE(X,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions 
%   equals PROD(SIZE(X)). PROD(SIZE(X)) must be evenly divisible 
%   by the product of the known dimensions. You can use only one 
%   occurrence of [].
%
%   In general, RESHAPE(X,SIZ) returns an N-D array with the same
%   elements as X but reshaped to the size SIZ.  PROD(SIZ) must be
%   the same as PROD(SIZE(X)). 
%
%   See also SQUEEZE, SHIFTDIM, COLON.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.2 $  $Date: 2004/04/16 22:06:28 $
%   Built-in function.

if nargout == 0
  builtin('reshape', varargin{:});
else
  [varargout{1:nargout}] = builtin('reshape', varargin{:});
end
