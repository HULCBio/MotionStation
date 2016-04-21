function y = ctranspose(x,varargin);
%CTRANSPOSE Conjugate transpose ' of GF array.
%    X' is the transpose of X.  CTRANSPOSE is the
%    same as TRANSPOSE for GF arrays.
%
%    See also TRANSPOSE.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:15:19 $ 

y=x;
y.x = y.x';
