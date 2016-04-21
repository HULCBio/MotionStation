function e=exponentmin(q)
%EXPONENTMIN Minimum biased exponent.
%   EXPONENTMIN(Q) returns the minimum biased exponent for Quantizer object
%   Q. 
%
%   If Q is a floating-point quantizer, then
%   EXPONENTMIN(Q) = -2^(EXPONENTLENGTH(Q)-1) + 2. 
%
%   If Q is a fixed-point quantizer, then EXPONENTMIN(Q)=0.
%
%   Example:
%     q = quantizer('double');
%     exponentmin(q)
%   returns -1022.
%
%   See also QUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:33:34 $

e=q.quantizer.minexponent;
