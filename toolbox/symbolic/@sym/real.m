function X = real(Z)
%REAL   Symbolic real part.
%   REAL(Z) is the real part of a symbolic Z.
    
%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 03:11:36 $

X = (Z + maple('map','conjugate',Z))/2;
