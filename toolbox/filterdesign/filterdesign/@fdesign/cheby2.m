%CHEBY2   Chebyshev Type II digital filter design.
%   H = CHEBY2(D) Design a Chebyshev Type II digital filter using the
%   specifications in the object D.
%
%   H = CHEBY2(D, 'MatchExactly', MATCH) Design a filter and match one band
%   exactly.  MATCH can be either 'passband' or 'stopband' (default).  This
%   flag is only used when designing minimum order Chebyshev filters.
%
%   % Example #1, construct the default object and design a Chebyshev Type
%   % II filter:
%   h = fdesign.lowpass;
%   Hd = cheby2(h,'MatchExactly','passband');
%
%   % Example #2, construct a highpass object with order, stopband-edge
%   % frequency, and stopband attenuation specifications, then design a
%   % Chebyshev Type II filter:
%   h = fdesign.highpass('n,fst,ast',5,20,55,50);
%   cheby2(h);
%
%   See also FDESIGN/BUTTER, FDESIGN/CHEBY1, FDESIGN/ELLIP.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:17 $

% [EOF]
