function varargout = pwelch(x,varargin)
%PWELCH Power Spectral Density estimate via Welch's method.
%   Pxx = PWELCH(X) returns the Power Spectral Density (PSD) estimate, 
%   Pxx, of a discrete-time signal vector X using Welch's averaged, 
%   modified periodogram method.  By default, X is divided into eight
%   sections with 50% overlap, each section is windowed with a Hamming
%   window and eight modified periodograms are computed and averaged.
%
%   If the length of X is such that it cannot be divided exactly into
%   eight sections with 50% overlap, X will be truncated accordingly. 
%
%   Pxx is the distribution of power per unit frequency. For real signals,
%   PWELCH returns the one-sided PSD by default; for complex signals, it
%   returns the two-sided PSD.  Note that a one-sided PSD contains the
%   total power of the input signal.
%
%   Pxx = PWELCH(X,WINDOW), when WINDOW is a vector, divides X into
%   overlapping sections of length equal to the length of WINDOW, and then
%   windows each section with the vector specified in WINDOW.  If WINDOW is
%   an integer, X is divided into sections of length equal to that integer
%   value, and a Hamming window of equal length is used.  If the length of 
%   X is such that it cannot be divided exactly into integer number of 
%   sections with 50% overlap, X will be truncated accordingly.  If WINDOW 
%   is omitted or specified as empty, a default window is used to obtain 
%   eight sections of X.
%
%   Pxx = PWELCH(X,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap from
%   section to section.  NOVERLAP must be an integer smaller than the WINDOW
%   if WINDOW is an integer.  NOVERLAP must be an integer smaller than the
%   length of WINDOW if WINDOW is a vector.  If NOVERLAP is omitted or
%   specified as empty, the default value is used to obtain a 50% overlap.
%
%   [Pxx,W] = PWELCH(X,WINDOW,NOVERLAP,NFFT) specifies the number of FFT
%   points used to calculate the PSD estimate.  For real X, Pxx has length
%   (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if NFFT is odd.  For complex
%   X, Pxx always has length NFFT.  If NFFT is specified as empty, the 
%   default NFFT -the maximum of 256 or the next power of two
%   greater than the length of each section of X- is used.
%
%   Note that if NFFT is greater than the segment the data is zero-padded.
%   If NFFT is less than the segment, the segment is "wrapped" (using
%   DATAWRAP) to make the length equal to NFFT. This produces the correct
%   FFT when NFFT < L, L being signal or segment length.                       
%
%   W is the vector of normalized frequencies at which the PSD is
%   estimated.  W has units of rad/sample.  For real signals, W spans the
%   interval [0,Pi] when NFFT is even and [0,Pi) when NFFT is odd.  For
%   complex signals, W always spans the interval [0,2*Pi).
%
%   [Pxx,F] = PWELCH(X,WINDOW,NOVERLAP,NFFT,Fs) returns a PSD computed as
%   a function of physical frequency (Hz).  Fs is the sampling frequency
%   specified in Hz.  If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies at which the PSD is estimated and has
%   units of Hz.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [...] = PWELCH(...,'twosided') returns a two-sided PSD of a real signal
%   X. In this case, Pxx will have length NFFT and will be computed  over
%   the interval [0,2*Pi) if Fs is not specified and over the interval
%   [0,Fs) if Fs is specified.  Alternatively, the string 'twosided' can be
%   replaced with the string 'onesided' for a real signal X.  This would
%   result in the default behavior.  The string 'twosided' or 'onesided'
%   may be placed in any position in the input argument list after NOVERLAP. 
%
%   PWELCH(...) with no output arguments by default plots the PSD
%   estimate in dB per unit frequency in the current figure window.
%
%   EXAMPLE:
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
%      pwelch(x,[],[],[],Fs,'twosided'); % Uses default window, overlap & NFFT. 
% 
%   See also PERIODOGRAM, PCOV, PMCOV, PBURG, PYULEAR, PEIG, PMTM, PMUSIC,
%   SPECTRUM/WELCH, DSPDATA/PSD, DSPDATA/MSSPECTRUM.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.28.4.4 $  $Date: 2004/04/13 00:18:58 $ 

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice-Hall, 1997, pg. 15
%     [2] Monson Hayes, Statistical Digital Signal Processing and 
%         Modeling, John Wiley & Sons, 1996.

error(nargchk(1,7,nargin));
error(nargoutchk(0,3,nargout));

esttype = 'psd';
if nargin > 1 & isstr(varargin{end}) & strcmpi(varargin{end},'ms'),
    esttype = 'ms';
    varargin(end)=[];
end

% Possible outputs are:
%       Plot
%       Pxx
%       Pxx, freq
[varargout{1:nargout}] = welch(x,esttype,varargin{:});

% [EOF]
