function varargout = psd(this,x,varargin)
%PSD   Power Spectral Density (PSD) estimate.
%    Hpsd = PSD(H,X) returns a Power Spectral Density (PSD) object that has
%    a property containing the power spectral density estimate of a
%    discrete-time signal vector X using the SPECTRUM object specified in
%    H.
% 
%    The power spectral density contained in the object Hpsd is the
%    distribution of power per unit frequency. For real signals, PSD
%    returns the one-sided PSD by default; for complex signals, it returns
%    the two-sided PSD.  Note that a one-sided PSD contains the total power
%    of the input signal.
%
%    The power spectral density is intended for continuous spectra. Note
%    that unlike the mean-squared spectrum (MSS), in this case the peaks in
%    the spectra do not reflect the power at a given frequency. Instead,
%    the integral of the PSD over a given frequency band computes the
%    average power in the signal over such frequency band. See the help on
%    AVGPOWER for more information.
% 
%    The Hpsd object also has a property that contains the vector of
%    normalized frequencies W at which the PSD is estimated.  W has units
%    of rad/sample.  For real signals, W spans the interval [0,Pi] when
%    NFFT is even and [0,Pi) when NFFT is odd.  For complex signals, W
%    always spans the interval [0,2*Pi).
% 
%    Hpsd = PSD(...,'Fs',Fs) returns a PSD object with the spectrum
%    computed as a function of physical frequency (Hz).  Fs is the sampling
%    frequency specified in Hz.
% 
%    Hpsd = PSD(...,'SpectrumType','twosided') returns a PSD object with a
%    two-sided PSD of a real signal X. In this case, the spectrum will be
%    computed over the interval [0,2*Pi) if Fs is not specified and over
%    the interval [0,Fs) if Fs is specified.  The SpectrumType can also be
%    'onesided' for a real signal X, which is the default behavior.
% 
%    Hpsd = PSD(...,'NFFT',nfft) specifies nfft as the number of FFT points
%    to use to calculate the power spectral density.
%
%    Hpsd = PSD(...,'CenterDC',true) specifies that the spectrum should be
%    shifted so that the zero-frequency component is in the center of the
%    spectrum.  The CenterDC property is by default set to false.
%
%    PSD(...) with no output arguments by default plots the PSD estimate in
%    dB per unit frequency in the current figure window.
%  
%   EXAMPLE: Spectral analysis of a signal that contains a 200Hz cosine
%   plus noise.
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = cos(2*pi*t*200)+randn(size(t));  
%      h = spectrum.welch;                  % Instantiate a welch object. 
%      psd(h,x,'Fs',Fs);                    % Plot the one-sided PSD.
%
%    See also SPECTRUM/WELCH, SPECTRUM/PERIODOGRAM, SPECTRUM/MTM,
%    SPECTRUM/BURG, SPECTRUM/COV, SPECTRUM/MCOV, SPECTRUM/YULEAR,
%    SPECTRUM/PSDOPTS, SPECTRUM/MSSPECTRUM.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $Date: 2004/04/13 00:18:32 $

% Help file for PSD method.

% [EOF]
