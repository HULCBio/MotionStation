function h = double(this)
%DOUBLE   Cast filter to a double-precision arithmetic version.
%   Hd = DOUBLE(H) returns a new filter Hd that has the same structure and
%   coefficients as H, but whose arithmetic is set to 'double'.
%
%   DOUBLE(H) differs from REFFILTER(H) in that the returned filter has the
%   actual (quantized) coefficients of H instead of the reference
%   coefficients.
%
%   DOUBLE(H) is useful if it is desired to isolate the effect of
%   quantizing the coefficients of a filter.
%
%   Example: Compare fixed-point filtering with double-precision
%   floating-point filtering using the same coefficients.
%
%   H = dfilt.dffir(firgr(27,[0 .4 .6 1],[1 1 0 0])); % Lowpass filter
%   H.Arithmetic = 'fixed'; % Set H to filter using fixed-point arithmetic
%   Hd = double(H);         % Cast to double-precision floating-point.
%   n = 0:99; x = sin(0.7*pi*n(:)); % Setup an input signal
%   y = filter(H,x);   % Fixed-point output
%   yd = filter(Hd,x); % Floating-point output
%   norm(yd-double(y),inf)
%
%   See also DFILT/REFFILTER.

%   Author(s): R. Losada
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:00:01 $

% [EOF]
