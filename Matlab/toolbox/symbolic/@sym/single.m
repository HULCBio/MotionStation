function S = single(X)
%SINGLE Converts symbolic matrix to single precision.
%   SINGLE(S) converts the symbolic matrix S to a matrix of single
%   precision floating point numbers.  S must not contain any symbolic
%   variables, except 'eps'.
%
%   See also SYM, VPA, DOUBLE

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:07 $

S = single(double(X));
