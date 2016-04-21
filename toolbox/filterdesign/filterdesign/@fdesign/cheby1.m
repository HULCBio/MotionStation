%CHEBY1   Chebyshev Type I digital filter design.
%   H = CHEBY1(D) Design a Chebyshev Type I digital filter using the
%   specifications in the object D.
%
%   H = CHEBY1(D, 'MatchExactly', MATCH) Design a filter and match one band
%   exactly.  MATCH can be either 'passband' (default) or 'stopband'.  This
%   flag is only used when designing minimum order Chebyshev filters.
%
%   % Example #1, construct the default object and design a Chebyshev Type
%   % I filter:
%   h = fdesign.lowpass;
%   Hd = cheby1(h,'MatchExactly','passband');
%
%   % Example #2, construct a highpass object with order, passband-edge
%   % frequency, and passband ripple specifications, then design a
%   % Chebyshev Type I filter:
%   h = fdesign.highpass('n,fp,ap',7,20,.4,50);
%   cheby1(h);
%
%   See also FDESIGN/BUTTER, FDESIGN/CHEBY2, FDESIGN/ELLIP.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:16 $

% [EOF]
