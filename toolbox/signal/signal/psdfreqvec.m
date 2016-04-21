function w = psdfreqvec(nfft, Fs, freqRange)
%PSDFREQVEC   Frequency vector for calculating power spectrums.
%   PSDFREQVEC(NFFT,FS,FREQRANGE) returns a frequency column vector based
%   on the number of points specified in NFFT, using FS as the sampling
%   frequency, and the range specified in FREQRANGE.  The vector returned
%   assumes 2pi periodicity.
%
%   The units of the frequency vector are Hz, unless an empty is specified
%   for the FS, in that case the units are normalized.
%
%   Inputs:
%       nfft      -  The number of FFT points.
%       Fs        -  The sampling frequency of the signal; []=normalized.
%       freqRange -  'half'     = [0, pi] or [0, pi), 
%                    'wholepos' = [0, 2pi) (default), 
%                    'negnpos'  = [-pi,pi) or (-pi,pi)
%
%  This is a helper function intended to be used by spectral estimation
%  functions.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:18:56 $ 

error(nargchk(1,3,nargin));

if nargin < 2, Fs = []; end
if nargin < 3, freqRange = 'wholepos'; end

% Determine if nfft is odd.
isNfftOdd = 0;
if rem(nfft,2), % ODD 
    isNfftOdd = 1;
end

% Determine half the number of FFT points.
if isNfftOdd,   nfft_halfNyq = (nfft+1)/2;  % ODD
else            nfft_halfNyq = (nfft/2)+1;  % EVEN
end

% Compute the whole frequency range [0,2pi) - this avoids round off errors.
if ~isempty(Fs), 
    w = Fs/nfft*(0:nfft-1); 
else
    w = 2*pi/nfft*(0:nfft-1); 
end

switch freqRange
    case 'half'       % [0, pi] or [0, pi)
        w = w(1:nfft_halfNyq);
        
    case 'wholepos',  % [0, 2pi)
        % Calculated by default.
        
    case 'negnpos',   % (-pi, pi] or (-pi, pi)
        if isNfftOdd,
            negEndPt = nfft_halfNyq; 
        else
            negEndPt = nfft_halfNyq-1; 
        end
        w = [-fliplr(w(2:negEndPt)), w(1:nfft_halfNyq)];
            
    otherwise
        error('Invalid frequency range option.');
end
w = w(:);  % Return a column vector.

% [EOF]
