function x = realmax(q)
%REALMAX Largest positive quantized number.
%   REALMAX(Q) is the largest quantized number representable where Q is a
%   QUANTIZER object.  Anything larger overflows.
%
%   Examples:
%     format
%     q = quantizer('float',[32 8]);
%     realmax(q)
%   returns 3.4028e+038.
%
%     q = quantizer('fixed',[8 7]);
%     realmax(q)
%   returns 0.9922.
%
%     q = quantizer('ufixed',[8 7]);
%     realmax(q)
%   returns 1.9922.
%
%   See also QUANTIZER, QUANTIZER/EPS, QUANTIZER/REALMIN.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:26:16 $
x = q.quantizer.realmax;


