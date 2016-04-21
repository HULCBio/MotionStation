function [Px,w,units,Sxx] = periodogram(x,win,varargin)
%PERIODOGRAM  Power Spectral Density (PSD) estimate via periodogram method.
%   Pxx = PERIODOGRAM(X) returns the PSD estimate of the signal specified
%   by vector X in the vector Pxx.  By default, the signal X is windowed
%   with a BOXCAR window of the same length as X. The PSD estimate is
%   computed using an FFT of length given by the larger of 256 and the next
%   power of 2 greater than the length of X.
%
%   Pxx is the distribution of power per unit frequency. For real signals,
%   PERIODOGRAM returns the one-sided PSD by default; for complex signals,
%   it returns the two-sided PSD.  Note that a one-sided PSD contains the
%   total power of the input signal.
%
%   Pxx = PERIODOGRAM(X,WINDOW) specifies a window to be applied to X.
%   WINDOW must be a vector of the same length as X.  If WINDOW is a window
%   other than a boxcar (rectangular), the resulting estimate is a modified
%   periodogram.  If WINDOW is specified as empty, the default window is
%   used.
% 
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,NFFT) specifies the number of FFT points
%   used to calculate the PSD estimate.  For real X, Pxx has length
%   (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if NFFT is odd.  For complex
%   X, Pxx always has length NFFT.  If NFFT is specified as empty, the 
%   default NFFT is used.
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
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs) returns a PSD computed as a
%   function of physical frequency (Hz).  Fs is the sampling frequency 
%   specified in Hz. If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies at which the PSD is estimated and has
%   units of Hz.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [...] = PERIODOGRAM(...,'twosided') returns a two-sided PSD of a real
%   signal X. In this case, Pxx will have length NFFT and will be computed
%   over the interval [0,2*Pi) if Fs is not specified and over the interval
%   [0,Fs) if Fs is specified.  Alternatively, the string 'twosided' can be
%   replaced with the string 'onesided' for a real signal X.  This would
%   result in the default behavior.  The string 'twosided' or 'onesided'
%   may be placed in any position in the input argument list after WINDOW.
%
%   PERIODOGRAM(...) with no output arguments by default plots the PSD
%   estimate in dB per unit frequency in the current figure window.
%
%   EXAMPLE:
%      Fs = 1000;   t = 0:1/Fs:.3;
%      x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
%      periodogram(x,[],'twosided',512,Fs); % The default window is used
%      
%   See also PWELCH, PBURG, PCOV, PYULEAR, PMTM, PMUSIC, PMCOV, PEIG,
%   SPECTRUM/PERIODOGRAM, DSPDATA/PSD, DSPDATA/MSSPECTRUM.

%   Author(s): R. Losada 
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.5 $  $Date: 2004/04/13 00:18:10 $

error(nargchk(1,6,nargin));

% Look for undocumented (unsupported) window compensation flag.
if nargin>2 & isstr(varargin{end}) & any(strcmpi(varargin{end},{'ms','psd'})),
    esttype = varargin{end};  % Can only be specified as last input arg.
    varargin(end) = [];       % remove from input arg list.
else
    esttype = 'psd';     % default
end

N = length(x); % Record the length of the data

% Generate a default window if needed
winName = 'User Defined';
winParam = '';
if (nargin == 1) | isempty(win),
   win = boxcar(N);
   winName = 'Rectangular';
   winParam = N;
end

[options,msg] = periodogram_options(isreal(x),N,varargin{:}); 
error(msg);

Fs    = options.Fs;
range = options.range;
nfft  = options.nfft;

% Compute the PS using periodogram over the whole nyquist range.
Sxx = computeperiodogram(x,win,nfft,esttype);

% Generate the frequency vector in [rad/sample] at which Sxx was computed
% If Fs is not empty, w will be converted to Hz in computepsd below
w = psdfreqvec(nfft);

% Compute the one-sided or two-sided PSD [Power/freq].
% Also compute the corresponding one-sided or two-sided power spectrum [Power],
% the frequency at which the psd is computed and the corresponding frequency units
[Pxx,w,units] = computepsd(Sxx,w,range,nfft,Fs,esttype);

if nargout==0, % Plot when no output arguments are specified  
   w = {w};
   if strcmpi(units,'Hz'), w = {w{:},'Fs',options.Fs}; end
   hpsd = dspdata.psd(Pxx,w{:},'SpectrumType',options.range);

   % Create a spectrum object to store in the PSD object's metadata.
   hspec = spectrum.periodogram({winName,winParam});
   hpsd.Metadata.setsourcespectrum(hspec);

   plot(hpsd);

else
   Px = Pxx;
end

%------------------------------------------------------------------------------
function [options,msg] = periodogram_options(isreal_x,N,varargin)
%PERIODOGRAM_OPTIONS   Parse the optional inputs to the PERIODOGRAM function.
%   PERIODOGRAM_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
   
% Generate defaults 
options.nfft = max(256, 2^nextpow2(N));
options.Fs = []; % Work in rad/sample
if isreal_x,
   options.range = 'onesided';
else
   options.range = 'twosided';
end
msg = '';

[options,msg] = psdoptions(isreal_x,options,varargin{:});

% [EOF] periodogram.m
