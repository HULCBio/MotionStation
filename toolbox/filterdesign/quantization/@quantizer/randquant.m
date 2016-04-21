function u = randquant(q,varargin)
%RANDQUANT Uniformly distributed quantized random number.
%   RANDQUANT(Q,N)
%   RANDQUANT(Q,M,N)
%   RANDQUANT(Q,M,N,P,...)
%   RANDQUANT(Q,[M,N])
%   RANDQUANT(Q,[M,N,P,...])
%
%   Works like RAND except the numbers are quantized and:
%   (1) If Q is a fixed-point quantizer then the numbers cover the
%       range of Q. 
%   (2) If Q is a floating-point quantizer then the numbers cover the
%       range -[square root of realmax(q)] to [square root of realmax(q)].
%
%   Example:
%     q=quantizer([4 3]);
%     rand('state',0)
%     randquant(q,3)
%   returns
%     0.7500   -0.1250   -0.2500
%    -0.6250    0.6250   -1.0000
%     0.1250    0.3750    0.5000
%
%   See also QUANTIZER, QUANTIZER/RANGE, QUANTIZER/REALMAX, RAND.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/12 23:26:15 $

u = rand(varargin{:});

mode = get(q,'mode');
switch mode
  case {'fixed','ufixed'}
    % In fixed-point, cover the entire range of the quantizer
    [a,b]=range(q);
    u = (b-a)*u+a;
  otherwise
    % In floating-point, cover +-sqrt(realmax(q))
    r = sqrt(realmax(q));
    u = r*(2*u-1);
end

u = quantize(q,u);
