function x = realmin(q)
%REALMIN Smallest positive normal quantized number.
%   REALMIN(Q) is the smallest positive quantized number where Q is a
%   QUANTIZER object.  Anything smaller underflows or is an IEEE "denormal".
%
%   Example:
%     q = quantizer('float',[6 3]);
%     realmin(q)
%   returns 0.25.
%
%    See also QUANTIZER, QUANTIZER/EPS, QUANTIZER/REALMAX.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:34:12 $

x = q.quantizer.realmin;
