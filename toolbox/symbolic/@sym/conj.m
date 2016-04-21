function X = conj(Z)
%CONJ   Symbolic conjugate.
%   CONJ(Z) is the conjugate of a symbolic Z.
    
%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:10:27 $

X = maple('map','conjugate',Z);
