function e = exponentlength(q)
%EXPONENTLENGTH    Exponent length of quantizer
%   E = EXPONENTLENGTH(Q) returns the length in bits of the exponent
%   specified by QUANTIZER object Q.  
%
%   If Q is a floating-point quantizer, then EXPONENTLENGTH(Q) is the second
%   element of FORMAT(Q).
%
%   If Q is a fixed-point quantizer, then EXPONENTLENGTH(Q)=0.
%
%   Example:
%     q = quantizer('double');
%     e = exponentlength(q)
%   returns 11.
%
%   See also QUANTIZER, QUANTIZER/WORDLENGTH,
%   QUANTIZER/FRACTIONLENGTH, QUANTIZER/FORMAT.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:35:12 $

e = q.quantizer.exponentlength;
