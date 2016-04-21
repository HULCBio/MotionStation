function varargout = mscohere(x,y,varargin)
%MSCOHERE   Magnitude Squared Coherence Estimate.
%   Cxy = MSCOHERE(X,Y) estimates the magnitude squared coherence estimate
%   of the  system with input X and output Y using Welch's averaged
%   periodogram  method.  Coherence is a function of frequency with values
%   between 0 and 1 that indicate how well the input X corresponds to the
%   output Y at each frequency. 
%
%   Pxx is the PSD estimate of X, and Pxy is the Cross PSD estimate of X
%   and Y, using Welch's averaged, modified periodogram method.  By
%   default, X is divided into eight sections with 50% overlap, each
%   section is windowed with a Hamming window and eight  modified
%   periodograms are computed and averaged.  See "help pwelch" and "help
%   cpsd" for complete details.
%
%   The magnitude squared of the length NFFT DFTs of the sections of X and 
%   the sections of Y are averaged to form Pxx and Pyy, the Power Spectral
%   Densities of X and Y respectively. The products of the length NFFT DFTs
%   of the sections of X and Y are averaged to form Pxy, the Cross Spectral
%   Density of X and Y. The magnitude squared coherence Cxy is given by
%       Cxy = (abs(Pxy).^2)./(Pxx.*Pyy)
%
%   Cxy = MSCOHERE(X,Y,WINDOW), when WINDOW is a vector, divides X and Y
%   into overlapping sections of length equal to the length of WINDOW, and
%   then windows each section with the vector specified in WINDOW.  If
%   WINDOW is an integer, X and Y are divided into sections of length equal
%   to that integer value, and a Hamming window of equal length is used.
%    
%   Cxy = MSCOHERE(X,Y,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap
%   from section to section.  NOVERLAP must be an integer smaller than the
%   WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%   than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is
%   omitted or specified as empty, the default value is used to obtain a
%   50% overlap.
%
%   [Cxy,W] = MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of
%   FFT points used to calculate the PSD and CPSD estimates.  For real X
%   and Y, Cxy has length (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if
%   NFFT is odd.  For complex X or Y, Cxy always has length NFFT.  If NFFT
%   is specified as empty, the default NFFT -the maximum of 256 or the next
%   power of two greater than the length of each section of X (or Y)- is
%   used.
%
%   [Cxy,F] = MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT,Fs) returns the magnitude
%   squared coherence computed as a function of physical frequency (Hz).
%   Fs is the sampling frequency specified in Hz. If Fs is empty, it
%   defaults to 1Hz.
% 
%   F is the vector of frequencies at which the Cxy is estimated and has
%   units of Hz.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [...] = MSCOHERE(...,'whole') returns the magnitude squared coherence
%   computed over the whole Nyquist interval for the real signals X and Y.
%   In this case, Cxy will have length NFFT and will be computed over the
%   interval [0,2*Pi) if Fs is not specified and over the interval [0,Fs)
%   if Fs is specified.  Alternatively, the string 'whole' can be replaced
%   with the string 'half' for real signals.  This would result in the
%   default behavior.  The string 'whole' or 'half' may be placed in any
%   position in the input argument list after NOVERLAP. 
%
%   MSCOHERE(...) with no output arguments plots the magnitude squared
%   coherence estimate in the current figure window.
%
%   EXAMPLE:
%      randn('state',0);
%      h = fir1(30,0.2,rectwin(31));
%      h1 = ones(1,10)/sqrt(10);
%      r = randn(16384,1);
%      x = filter(h1,1,r);
%      y = filter(h,1,x);
%      noverlap = 512; nfft = 1024;
%      mscohere(x,y,hanning(nfft),noverlap,nfft); % Plot estimate.
% 
%   See also TFESTIMATE, CPSD, PWELCH, PERIODOGRAM, SPECTRUM/WELCH 

% 	Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:09:08 $

error(nargchk(2,7,nargin))

esttype = 'mscohere';
% Possible outputs are:
%       Plot
%       Cxy
%       Cxy, freq
[varargout{1:nargout}] = welch({x,y},esttype,varargin{:});

if nargout == 0, 
    title('Coherence Estimate via Welch');
end

% [EOF]
