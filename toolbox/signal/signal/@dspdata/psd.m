function this = psd(varargin)
%PSD   Power Spectral Density (PSD).
%   H = DSPDATA.PSD instantiates an object H with its data property set to
%   DATA. The frequency vector defaults to [0, pi), and Fs defaults to
%   "Normalized". DATA can be a vector or a matrix where each column
%   represents an independent trial.
%
%   The power spectral density is intended for continuous spectra. Note
%   that unlike the mean-squared spectrum (MSS), in this case the peaks in
%   the spectra do not reflect the power at a given frequency. Instead,
%   the integral of the PSD over a given frequency band computes the
%   average power in the signal over such frequency band. See the help on
%   AVGPOWER for more information.
%
%   H = DSPDATA.PSD(DATA,FREQUENCIES) sets the frequency vector to
%   FREQUENCIES in the object.  The length of the vector FREQUENCIES must
%   equal the length of the columns of DATA.
%
%   H = DSPDATA.PSD(...,'Fs',Fs) sets the sampling frequency to Fs.  If
%   FREQUENCIES is not specified the frequency vector defaults to [0, Fs/2]
%   for even length data and [0, Fs/2) for odd length data.  See the NOTE
%   below for more details.
%
%   H = DSPDATA.PSD(...,'SpectrumType',SPECTRUMTYPE) sets the SpectrumType
%   property to the string in SPECTRUMTYPE, which can be either 'onesided'
%   or 'twosided'.
%
%   H = DSPDATA.PSD(...,'CenterDC',true) shifts the zero-frequency
%   component to the center of a two-sided spectrum.  If the object's
%   SpectrumType property is set to 'onesided', it's changed to 'twosided'
%   and the data is converted to a two-sided spectrum.  
%
%   Setting the CenterDC property to false shifts the data and the
%   frequency values in the object, so that DC is in the left edge of the
%   spectrum.  This operation does not effect the SpectrumType property.
%
%   NOTE: If the spectrum data specified was calculated over "half" the
%   Nyquist interval and you don't specify a corresponding frequency
%   vector, then the default frequency vector will assume that the number
%   of points in the "whole" FFT was even.  Also, the plot option to
%   convert to a "whole" spectrum will assume the original "whole" FFT
%   length was even.
%
%   EXAMPLE: Use the periodogram to estimate the power spectral density of
%            a noisy sinusoidal signal with two frequency components. Then
%            store the results in PSD data object and plot it.
%
%        Fs = 32e3;   t = 0:1/Fs:2.96;
%        x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
%        Pxx = periodogram(x);
%        hpsd = dspdata.psd(Pxx,'Fs',Fs); % Create a PSD data object.
%        plot(hpsd);                      % Plot the PSD.
%
%   See also DSPDATA/MSSPECTRUM, DSPDATA/PSEUDOSPECTRUM,
%   SPECTRUM/PERIODOGRAM, DSPDATA/CENTERDC, DSPDATA/NORMALIZEFREQ,
%   DSPDATA/PLOT.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:01:07 $

% Help for instantiating a PSD object.

% [EOF]
