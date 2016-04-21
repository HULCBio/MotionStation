function y = reshape(x,varargin)
%RESHAPE Reshape GF array.
%   RESHAPE(X,M,N) returns the M-by-N matrix whose elements
%   are taken columnwise from X.  An error results if X does
%   not have M*N elements.
%
%   RESHAPE(X,[M N]) is the same thing.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:16:33 $ 

y=x;
y.x = reshape(x.x,varargin{:});
