function x = round(q,x)
%ROUND Round using quantizer, but do not check for overflow.
%   ROUND(Q,X) uses the round mode and fraction length of quantizer Q to
%   round the numeric data X, but does not check for overflow.  Compare
%   to QUANTIZER/QUANTIZE.
%
%   Example:
%     q = quantizer('fixed', 'convergent', 'wrap', [3 2]);
%     x = (-2:eps(q)/4:2)';
%     y = round(q,x);
%     plot(x,[x,y],'.-'); axis square
%
%   See also QUANTIZER, QUANTIZER/QUANTIZE.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:26:17 $

if ~strcmp(mode(q),'double')
  p = pow2(fractionlength(q));
  rmode = roundmode(q);
  switch rmode
    case 'round'
      % Exactly 1/2 LSB, round toward positive infinity.
      x = floor(p*x+0.5)/p;
    otherwise
      x = feval(rmode,p*x)/p;
  end
end
