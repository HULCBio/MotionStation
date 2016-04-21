function varargout = pseudospectrum(this,x,varargin)
%PSEUDOSPECTRUM  Pseudospectrum estimate.
%    Hps = PSEUDOSPECTRUM(H,X) returns an object that has a property
%    containing a pseudospectrum estimate of the discrete-time signal
%    represented by X.  It uses the SPECTRUM object specified in H, which
%    can be either a MUSIC or EIGENVECTOR object.  X can be a vector or a
%    matrix. If X is a vector it is a signal, if it's matrix it may be
%    either a data matrix such that X'*X=R, or a correlation matrix R.
%
%    For real signals, PSEUDOSPECTRUM returns half the range of the Nyquist
%    interval by default; for complex signals, it returns the whole range.
%
%    Hps = PSEUDOSPECTRUM(H,X) returns the object Hps that has a property
%    which contains a vector of normalized frequencies at which the
%    pseudospectrum is estimated.  The frequency has units of rad/sample.
%    For real signals, the frequency spans the interval [0,Pi] when NFFT is
%    even and [0,Pi) when NFFT is odd.  For complex signals, the frequency
%    always spans the interval [0,2*Pi).
%
%    Hps = PSEUDOSPECTRUM(H,X,'Fs',Fs) returns an object with the
%    pseudospectrum computed as a function of physical frequency (Hz).  Fs
%    is the sampling frequency specified in Hz.
%
%    Hps = PSEUDOSPECTRUM(...,'SpectrumRange','whole') returns an object
%    with the pseudospectrum for the whole Nyquist range of a real signal
%    X. In this case, the spectrum be computed over the interval [0,2*Pi)
%    if Fs is not specified and over the interval [0,Fs) if Fs is
%    specified.  The SpectrumRange can also be 'half' for a real signal X,
%    which is the default behavior.
%
%    Hps = PSEUDOSPECTRUM(...,'NFFT',nfft) specifies nfft as the number of
%    FFT points to use to calculate the pseudospectrum.
%
%    Hps = PSEUDOSPECTRUM(...,'CenterDC',true) specifies that the spectrum
%    should be shifted so that the zero-frequency component is in the
%    center of the spectrum.  The CenterDC property is by default set to
%    false.
%
%    PSEUDOSPECTRUM(...) with no output arguments plots the pseudospectrum
%    estimate in dB in the current figure window.
%
%   EXAMPLE: Spectral analysis of a signal containing complex sinusoids
%   and noise.
%      randn('state',1); n = 0:99;   
%      s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      h = spectrum.music(3);    % Instantiate a music object.
%      pseudospectrum(h,s);      % Plot the pseudospectrum.
%
%    See also SPECTRUM/MUSIC, SPECTRUM/EIGENVECTOR, SPECTRUM/POWEREST,
%    SPECTRUM/PSEUDOSPECTRUMOPTS.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2004/04/13 00:18:33 $

% Help for MUSIC and EIGENVECTOR's PSEUDOSPECTRUM method.

% [EOF]
