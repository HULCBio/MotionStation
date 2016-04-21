%FIRLS   Design a filter using least-squares error minimization.
%   H = FIRLS(D) Designs a discrete-time filter using least-squares error
%   minimization.
%
%   H will be either a single-rate digital filter, DFILT, or a multirate
%   digital filter, MFILT, depending on the specification type D.
%
%   % Example #1, design a single-rate halfband filter:
%   h = fdesign.halfband('n,tw',120,.04);
%   Hd = firls(h);
%
%   % Example #2, design a multirate halfband interpolator filter:
%   h = fdesign.interp(2,'n,tw',60,.04); % n=60 is now the polyphase length
%   Hm = firls(h);
%
%   See also FDESIGN/EQUIRIPPLE, FDESIGN/KAISERWIN.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:23 $

% [EOF]
