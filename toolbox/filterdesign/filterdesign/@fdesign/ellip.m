%ELLIP   Elliptic or Cauer digital filter design.
%   H = ELLIP(D) Design an Elliptic digital filter using the specifications
%   in the object D.
%
%   H = ELLIP(D, 'MatchExactly', MATCH) Design a filter and match one band
%   exactly.  MATCH can be either 'passband' 'stopband' or 'both'
%   (default).  This flag is only used when designing minimum order
%   Elliptic filters.
%
%   % Example #1, construct the default object and design an elliptic
%   % filter:
%   h = fdesign.bandpass;
%   Hd = ellip(h,'MatchExactly','passband');
%
%   % Example #2, construct a lowpass object with order, passband-edge
%   % frequency, stopband-edge frequency, and passband ripple specifications,
%   % then design an elliptic filter:
%   h = fdesign.lowpass('n,fp,fst,ap',6,20,25,.8,80);
%   ellip(h);
%
%   % Example #3, construct a lowpass object with order, passband-edge
%   % frequency, passband ripple, and stopband attenuation specifications,
%   % then design an elliptic filter:
%   h = fdesign.lowpass('n,fp,ap,ast',6,20,.8,60,80);
%   ellip(h);
%
%   See also FDESIGN/BUTTER, FDESIGN/CHEBY1, FDESIGN/CHEBY2.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:20 $

% [EOF]
