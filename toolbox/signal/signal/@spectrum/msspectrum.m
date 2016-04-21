function varargout = msspectrum(this,x,varargin)
%MSSPECTRUM   Mean-square Spectrum.
%    Hmss = MSSPECTRUM(H,X) returns a Mean-square Spectrum object that has
%    a property containing the mean-square (power) estimate of a
%    discrete-time signal vector X using the SPECTRUM object specified in
%    H.
% 
%    The mean-square spectrum contained in the object Hmss is the
%    distribution of power over frequency. For real signals, MSSPECTRUM
%    returns the one-sided mean-square spectrum by default; for complex
%    signals, it returns the two-sided mean-square spectrum.  Note that a
%    one-sided mean-square spectrum contains the total power of the input
%    signal.
% 
%    The mean-squared spectrum is intended for discrete spectra. Unlike the
%    power spectral density (PSD), the peaks in the mean-square spectrum
%    reflect the power in the signal at a given frequency.
% 
%    The Hmss object also has a property that contains the vector of
%    normalized frequencies W at which the mean-square spectrum is
%    estimated.  W has units of rad/sample.  For real signals, W spans the
%    interval [0,Pi] when NFFT is even and [0,Pi) when NFFT is odd.  For
%    complex signals, W always spans the interval [0,2*Pi).
% 
%    Hmss = MSSPECTRUM(H,X,'Fs',Fs) returns a mean-square spectrum object
%    containing the spectrum computed as a function of physical frequency
%    (Hz). Fs is the sampling frequency specified in Hz.
% 
%    Hmss = MSSPECTRUM(...,'SpectrumType','twosided') returns a mean-square
%    spectrum object with a two-sided mean-square spectrum of a real signal
%    X. In this case, the spectrum will be computed over the interval
%    [0,2*Pi) if Fs is not specified and over the interval [0,Fs) if Fs is
%    specified. The SpectrumType can also be 'onesided' for a real signal
%    X, which is the default behavior.
% 
%    Hmss = MSSPECTRUM(...,'NFFT',nfft) specifies nfft as the number of FFT
%    points to use to calculate the mean-square spectrum.
%
%    Hmss = MSSPECTRUM(...,'CenterDC',true) specifies that the spectrum
%    should be shifted, so that the zero-frequency component is in the
%    center of the spectrum.  The CenterDC property is by default set to
%    false.
%
%    MSSPECTRUM(...) with no output arguments by default plots the
%    mean-square spectrum estimate in dB per unit frequency in the current
%    figure window.
%  
%   EXAMPLE: 
%      % In this example we will measure the power of a deterministic
%      % power signal which has a frequency component at 200Hz. We'll use a
%      % signal with a peak amplitude of 3 volts therefore, the theoretical
%      % power at 200Hz sould be 3^2/2 volts^2 (watts) or 6.5321dB. 
%      Fs = 1000;   t = 0:1/Fs:.2;
%      x = 3*cos(2*pi*t*200);  
%      h = spectrum.welch;           % Instantiate a welch object. 
%
%      % Plot the one-sided Mean-square spectrum.
%      h.FFTLength = 'UserDefined';
%      msspectrum(h,x,'Fs',Fs,'NFFT',2^14);
%
%    See also SPECTRUM/WELCH, SPECTRUM/PERIODOGRAM, SPECTRUM/MSSPECTRUMOPTS
%    SPECTRUM/PSD.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2004/04/13 00:18:27 $

% Help file for MSSPECTRUM method.

% [EOF]
