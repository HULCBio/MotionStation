function f = fractionlength(q)
%FRACTIONLENGTH  Fraction length.
%   FRACTIONLENGTH(Q) returns the fraction length of quantizer object Q.  
%
%   If Q is a fixed-point quantizer, then FRACTIONLENGTH(Q) is the second
%   element of FORMAT(Q).
%
%   If Q is a floating-pint quantizer, then
%   FRACTIONLENGTH(Q) = WORDLENGTH(Q) - EXPONENTLENGTH(Q) - 1. 
%
%   Example:
%     q = quantizer('double')
%     fractionlength(q)
%   returns 52.
%
%   See also QUANTIZER, QUANTIZER/WORDLENGTH,
%   QUANTIZER/EXPONENTLENGTH, QUANTIZER/FORMAT.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:35:03 $

f = q.quantizer.fractionlength;
