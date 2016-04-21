function centerdc(this,state)
%CENTERDC   Shift the zero-frequency component to center of spectrum.
%   CENTERDC(H) or CENTERDC(H,true) shifts the data and the frequency
%   values in the object H, so that DC is in the center of the spectrum.
%
%   Note that if the object H has the SpectrumType set to 'onesided', it's
%   first converted to a 'twosided' spectrum, before the DC component is
%   centered.  This causes the number of points to roughly double, since
%   the spectrum now occupies the whole Nyquist interval.
%
%   CENTERDC(H,false) shifts the data and the frequency values in the
%   object H, so that DC is in the left edge of the spectrum.  
%
%   See also DSPDATA/HALFRANGE, DSPDATA/ONESIDED, DSPDATA/NORMALIZEFREQ,
%   DSPDATA/PLOT, DSPDATA/PSD, DSPDATA/MSSPECTRUM, DSPDATA/PSEUDOSPECTRUM.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:06:40 $

% Help for the CENTERDC method.

% [EOF]