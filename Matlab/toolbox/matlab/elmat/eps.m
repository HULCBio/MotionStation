function [varargout] = eps(varargin)
%EPS  Spacing of floating point numbers.
%   D = EPS(X), is the positive distance from ABS(X) to the next larger in
%   magnitude floating point number of the same precision as X.
%   X may be either double precision or single precision.
%   For all X, EPS(X) = EPS(-X) = EPS(ABS(X)).
%
%   EPS, with no arguments, is the distance from 1.0 to the next larger double
%   precision number, that is EPS = 2^(-52).
%
%   EPS('double') is the same as EPS, or EPS(1.0).
%   EPS('single') is the same as EPS(single(1.0)), or single(2^-23).
%
%   Except for denormals, if 2^E <= ABS(X) < 2^(E+1), then
%      EPS(X) = 2^(E-23) if ISA(X,'single')
%      EPS(X) = 2^(E-52) if ISA(X,'double')
%
%   Replace expressions of the form
%      if Y < EPS * ABS(X)
%   with
%      if Y < EPS(X)
%
%   Examples:
%      double precision
%         eps(1/2) = 2^(-53)
%         eps(1) = 2^(-52)
%         eps(2) = 2^(-51)
%         eps(realmax) = 2^971
%         eps(0) = 2^(-1074)
%         if(abs(x)) <= realmin, eps(x) = 2^(-1074)
%         eps(Inf) = NaN
%         eps(NaN) = NaN
%      single precision
%         eps(single(1/2)) = 2^(-24)
%         eps(single(1)) = 2^(-23)
%         eps(single(2)) = 2^(-22)
%         eps(realmax('single')) = 2^104
%         eps(single(0)) = 2^(-149)
%         if(abs(x)) <= realmin('single'), eps(x) = 2^(-149)
%         eps(single(Inf)) = single(NaN)
%         eps(single(NaN)) = single(NaN)
%
%   See also REALMAX, REALMIN.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.9.4.5 $  $Date: 2004/03/26 13:26:17 $
%   Built-in function.


if nargout == 0
  builtin('eps', varargin{:});
else
  [varargout{1:nargout}] = builtin('eps', varargin{:});
end
