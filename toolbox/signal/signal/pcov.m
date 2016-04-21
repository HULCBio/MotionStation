function varargout = pcov(x,p,varargin)
%PCOV   Power Spectral Density (PSD) estimate via the Covariance method.
%   Pxx = PCOV(X,ORDER) returns the PSD of a discrete-time signal vector X
%   in the vector Pxx.  Pxx is the distribution of power per unit frequency.
%   The frequency is expressed in units of radians/sample.  ORDER is the 
%   order of the autoregressive (AR) model used to produce the PSD.  PCOV 
%   uses a default FFT length of 256 which determines the length of Pxx.
%
%   For real signals, PCOV returns the one-sided PSD by default; for 
%   complex signals, it returns the two-sided PSD.  Note that a one-sided 
%   PSD contains the total power of the input signal.
%
%   Pxx = PCOV(X,ORDER,NFFT) specifies the FFT length used to calculate 
%   the PSD estimates.  For real X, Pxx has length (NFFT/2+1) if NFFT is 
%   even, and (NFFT+1)/2 if NFFT is odd.  For complex X, Pxx always has 
%   length NFFT.  If empty, the default NFFT is 256.
%
%   [Pxx,W] = PCOV(...) returns the vector of normalized angular
%   frequencies, W, at which the PSD is estimated.  W has units of 
%   radians/sample.  For real signals, W spans the interval [0,Pi] when 
%   NFFT is even and [0,Pi) when NFFT is odd.  For complex signals, W 
%   always spans the interval [0,2*Pi).
%
%   [Pxx,F] = PCOV(...,Fs) specifies a sampling frequency Fs in Hz and
%   returns the power spectral density in units of power per Hz.  F is a
%   vector of frequencies, in Hz, at which the PSD is estimated.  For real 
%   signals, F spans the interval [0,Fs/2] when NFFT is even and [0,Fs/2)
%   when NFFT is odd.  For complex signals, F always spans the interval 
%   [0,Fs).  If Fs is empty, [], the sampling frequency defaults to 1 Hz.  
%
%   [Pxx,W] = PCOV(...,'twosided') returns the PSD over the interval 
%   [0,2*Pi), and [Pxx,F] = PCOV(...,Fs,'twosided') returns the PSD over
%   the interval [0,Fs).  Note that 'onesided' may be optionally specified,
%   but is only valid for real X.  The string 'twosided' or 'onesided' may 
%   be placed in any position in the input argument list after ORDER.
%
%   PCOV(...) with no output arguments plots the PSD estimate in dB per 
%   unit frequency in the current figure window.
%
%   EXAMPLE:
%      randn('state',1);
%      x = randn(100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x);
%      pcov(y,4,[],1000);             % Uses the default NFFT of 256.
%
%   See also PMCOV, PYULEAR, PBURG, PMTM, PMUSIC, PEIG, PWELCH, PERIODODGRAM,
%   ARCOV, PRONY, SPECTRUM/COV, DSPDATA/PSD.

%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.5 $  $Date: 2004/04/13 00:18:08 $


error(nargchk(2,5,nargin))

method = 'arcov';
[Pxx,freq,msg,units,Sxx,options] = arspectra(method,x,p,varargin{:});
error(msg);

if nargout==0,
   % If no output arguments are specified plot the PSD.
   freq = {freq};
   if strcmpi(units,'Hz'), freq = {freq{:},'Fs',options.Fs}; end
   hpsd = dspdata.psd(Pxx,freq{:},'SpectrumType',options.range);

   % Create a spectrum object to store in the PSD object's metadata.
   hspec = spectrum.cov(p);
   hpsd.Metadata.setsourcespectrum(hspec);

   plot(hpsd);

else
   % Assign output arguments.
   varargout = {Pxx,freq,Sxx};  % Pxx=PSD, Sxx=PS
end

% [EOF] pcov.m
