function y = transpose(x,varargin);
%TRANSPOSE Transpose .' of GF array.
%    X.' is the transpose of X.  TRANSPOSE is the
%    same as CTRANSPOSE for GF arrays.
%
%    See also CTRANSPOSE.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:16:45 $ 

y=x;
y.x = y.x.';
