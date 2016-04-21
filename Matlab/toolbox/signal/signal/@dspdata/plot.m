function plot(this)
%PLOT   Plot method for dspdata objects.
%   PLOT(H) plots the data in the object H.
%
%   EXAMPLE: Use the periodogram to estimate the power spectral density of
%            a noisy sinusoidal signal with two frequency components.
%            Then store the results in PSD data object and plot it.
%
%        Fs = 32e3;   t = 0:1/Fs:2.96;
%        x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
%        Pxx = periodogram(x);
%        hpsd = dspdata.psd(Pxx,'Fs',Fs); % Create a PSD data object.
%        plot(hpsd);                      % Plot the PSD.
%
%   See also DSPDATA/PSD, DSPDATA/MSSPECTRUM, DSPDATA/PSEUDOSPECTRUM,
%   DSPDATA/CENTERDC, DSPDATA/HALFRANGE, DSPDATA/ONESIDED,
%   DSPDATA/NORMALIZEFREQ.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:06:46 $

% Help for dspdata PLOT method.

% [EOF]
