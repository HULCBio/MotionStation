function varargout = tfestimate(x,y,varargin)
%TFESTIMATE   Transfer Function Estimate.
%   Txy = TFESTIMATE(X,Y) estimates the transfer function of the  system
%   with input X and output Y using Welch's averaged periodogram  method.
%   Txy is the quotient of Cross Power Spectral Density (CPSD) of X and Y,
%   Pxy and the Power Spectral Density (PSD) of X, Pxx. 
%
%   Pxx is the PSD estimate of X, and Pxy is the CPSD estimate of X and Y,
%   using Welch's averaged, modified periodogram method.  By default, X is
%   divided into eight sections with 50% overlap, each section is windowed
%   with a Hamming window and eight  modified periodograms are computed and
%   averaged.  See "help pwelch" and "help cpsd" for complete details.
%
%   Txy = TFESTIMATE(X,Y,WINDOW), when WINDOW is a vector, divides X and Y
%   into overlapping sections of length equal to the length of WINDOW, and
%   then windows each section with the vector specified in WINDOW.  If
%   WINDOW is an integer, X and Y are divided into sections of length equal
%   to that integer value, and a Hamming window of equal length is used.
%    
%   Txy = TFESTIMATE(X,Y,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap
%   from section to section.  NOVERLAP must be an integer smaller than the
%   WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%   than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is
%   omitted or specified as empty, the default value is used to obtain a
%   50% overlap.
%
%   [Txy,W] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of
%   FFT points used to calculate the PSD and CPSD estimates.  For real X
%   and Y, Txy has length (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if
%   NFFT is odd.  For complex X or Y, Txy always has length NFFT.  If NFFT
%   is specified as empty, the default NFFT -the maximum of 256 or the next
%   power of two greater than the length of each section of X (or Y)- is
%   used.
%
%   W is the vector of normalized frequencies at which the Txy is
%   estimated.  W has units of rad/sample.  For real signals, W spans the
%   interval [0,Pi] when NFFT is even and [0,Pi) when NFFT is odd.  For
%   complex signals, W always spans the interval [0,2*Pi).
%
%   [Txy,F] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,NFFT,Fs) returns a transfer
%   function computed as a function of physical frequency (Hz).  Fs is the
%   sampling frequency specified in Hz. If Fs is empty, it defaults to 1Hz.
% 
%   F is the vector of frequencies at which the Txy is estimated and has
%   units of Hz.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [...] = TFESTIMATE(...,'whole') returns the transfer function estimate
%   computed over the whole Nyquist interval for the real signals X and Y.
%   In this case, Txy will have length NFFT and will be computed over the
%   interval [0,2*Pi) if Fs is not specified and over the interval [0,Fs)
%   if Fs is specified.  Alternatively, the string 'whole' can be replaced
%   with the string 'half' for real signals.  This would result in the
%   default behavior.  The string 'whole' or 'half' may be placed in any
%   position in the input argument list after NOVERLAP. 
%
%   TFESTIMATE(...) with no output arguments plots the transfer function
%   estimate in the current figure window.
%
%   EXAMPLE:
%      randn('seed',0);
%      h = fir1(30,0.2,boxcar(31));
%      x = randn(16384,1);
%      y = filter(h,1,x);
%      tfestimate(x,y,[],512,1024); % Plot estimate using a default window.
% 
%      % Now let's get the transfer function estimate, and calculate the
%      % filter coefficients using INVFREQZ.
%      [txy,w] = tfestimate(x,y,[],512,1024); 
%      [b,a] = invfreqz(txy,w,30,0);
%      htool = fvtool(h,1,b,a); legend(htool,'Original','Estimated');
%
%   See also CPSD, PWELCH, MSCOHERE, PERIODOGRAM, SPECTRUM/WELCH 

% 	Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:09:36 $

error(nargchk(2,7,nargin))

esttype = 'tfe';
% Possible outputs are:
%       Plot
%       Txy
%       Txy, freq
[varargout{1:nargout}] = welch({x,y},esttype,varargin{:});

if nargout == 0,
    title('Transfer Function Estimate via Welch');
end

% [EOF]
