function y = convergent(x)
%CONVERGENT Convergent rounding.
%   CONVERGENT(X) rounds the elements of X to the nearest integer,
%   except in a tie, then round to the nearest even integer.
%
%   Example:
%     ROUND and CONVERGENT only differ in the way they treat values
%     whose fractional part is 0.5. 
%     In ROUND, every tie is rounded up in absolute value, while
%     in CONVERGENT, the ties are rounded to the nearest even integer. 
%       x=[-3.5:3.5]';
%       [x convergent(x) round(x)]
%
%   See also FLOOR, CEIL, FIX, ROUND, 
%   QUANTIZER/ROUND, QUANTIZER/QUANTIZE. 

%   Reference:
%     Phil Lapsley, Jeff Bier, Amit Shoham, Edward A. Lee, DSP Processor
%     Fundamentals, IEEE Press, 1997, ISBN 0-7803-3405-1
%
%   Thomas A. Bryan
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 20:51:12 $

if ~isnumeric(x)
  error('Input must be numeric.')
end
x = double(x+0); % To force it to double

% Quantize to integers (fractionlength = 0) with convergent rounding.
% Skip quantizing everything bigger than the largest "flint" (floating-point
% integer), which is 2^53, because those numbers are always integers anyway.
q = quantizer('fixed',[53 0],'convergent');
if isreal(x)
  y = x;
  L = abs(x)<2^53;
  y(L) = quantize(q,x(L));
else
  % Need to do real and imaginary separately because > is not defined for
  % complex numbers.
  xr = real(x); xi = imag(x);
  yr = xr;  yi = xi;
  L = abs(xr)<2^53;
  yr(L) = quantize(q,xr(L));
  L = abs(xi)<2^53;
  yi(L) = quantize(q,xi(L));
  y = complex(yr,yi);
end



