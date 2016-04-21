function normalizefreq(this)
%NORMALIZEFREQ   Normalize frequency specifications.
%   NORMALIZEFREQ(H) will normalize the frequency specifications in H. The
%   'NormalizedFrequency' property will be set to true. In addition, the
%   Frequencies will be normalized by Fs so that they lie between 0 and 1.
%
%   NORMALIZEFREQ(H,BFL) where BFL is either true or false, specifies
%   whether the 'NormalizedFrequency' property will be set to true or
%   false. If not specified, BFL defaults to true. If BFL is set to false,
%   the frequencies will be converted to linear frequencies.
%
%   NORMALIZEFREQ(H,false,Fs) allows for the setting of a new sampling
%   frequency, Fs, when the 'NormalizedFrequency' property is set to false.
%
%   EXAMPLE: Use the periodogram to estimate the power spectral density of
%            a noisy sinusoidal signal. Then store the results in PSD data
%            object, convert it to normalized frequency and plot it.
%  
%         Fs = 32e3;   t = 0:1/Fs:2.96;
%         x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
%         Pxx = periodogram(x);
%         hpsd = dspdata.psd(Pxx,'Fs',Fs) % Create a PSD data object.
%         normalizefreq(hpsd);            % Normalize frequencies.
%         plot(hpsd)
%
%   See also DSPDATA/PSD, DSPDATA/MSSPECTRUM, DSPDATA/PSEUDOSPECTRUM,
%   DSPDATA/CENTERDC, DSPDATA/PLOT.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:06:44 $

% Help for NORMAZLIZEFREQ method.

% [EOF]
