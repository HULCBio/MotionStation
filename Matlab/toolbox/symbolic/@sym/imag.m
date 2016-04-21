function Y = imag(Z)
%IMAG   Symbolic imaginary part.
%   IMAG(Z) is the imaginary part of a symbolic Z.
    
%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 03:10:39 $

Y = (Z - maple('map','conjugate',Z))/2i;
