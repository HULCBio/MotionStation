function onesided(this)
%ONESIDED   Spectrum calculated over half the Nyquist interval.
%   ONESIDED(h) converts the power spectrum, in the object h, to a spectrum
%   calculated over half the Nyquist interval containing the full power.
%   The relevant properties such as, Frequencies and SpectrumType, are
%   modified to reflect the new frequency range.
%
%   NOTE: No check is made to ensure that the data is symmetric, i.e., it
%   assumes the spectrum is from a real signal and therefore uses only half
%   the data points.
%
%   See also DSPDATA/TWOSIDED, DSPDATA/CENTERDC, DSPDATA/NORMALIZEFREQ,
%   DSPDATA/PLOT, DSPDATA/PSD, DSPDATA/MSSPECTRUM.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:01:06 $

% Help for the ONESIDED method.

% [EOF]
