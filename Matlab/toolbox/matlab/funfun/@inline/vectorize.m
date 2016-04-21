function fcn = vectorize(fcn)
%VECTORIZE Vectorize an INLINE function object.
%   VECTORIZE(FCN) inserts a '.' before any '^', '*' or '/' in the formula
%   for FCN.  The result is the vectorized version of the INLINE fuction.
%
%   See also INLINE/FORMULA, INLINE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:21:20 $

fcn.expr = vectorize(fcn.expr);
