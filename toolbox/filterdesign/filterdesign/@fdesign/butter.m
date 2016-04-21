%BUTTER   Butterworth IIR digital filter design.
%   H = BUTTER(D) Design a Butterworth IIR digital filter using the
%   specifications in the object D.
%
%   H = BUTTER(D, 'MatchExactly', MATCH) Design a filter and match one band
%   exactly.  MATCH can be either 'passband' or 'stopband' (default).  This
%   flag is only used when designing minimum order Butterworth filters.
%
%   % Example #1, construct the default object and design a Butterworth
%   % filter:
%   h = fdesign.lowpass;
%   Hd = butter(h,'MatchExactly','passband');
%
%   % Example #2, construct a highpass object with order and cutoff
%   frequency specifications, then design a Butterworth filter:
%   h = fdesign.highpass('n,fc',8,.6);
%   butter(h);
%
%   See also FDESIGN/CHEBY1, FDESIGN/CHEBY2, FDESIGN/ELLIP.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:15 $

% [EOF]
