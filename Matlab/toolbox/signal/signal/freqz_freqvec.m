function w = freqz_freqvec(nfft, Fs, s)
%FREQZ_FREQVEC Frequency vector for calculating filter responses.
%   This is a helper function intended to be used by FREQZ.
%
%   Inputs:
%       nfft    -   The number of points
%       Fs      -   The sampling frequency of the filter
%       s       -   1 = 0-2pi, 2 = 0-pi, 3 = -pi-pi

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:17:58 $ 

if nargin < 2, Fs = []; end
if nargin < 3, s  = 2; end

switch s
    case 1,  % 0-2pi
        deltaF = (2*pi)/nfft;
        w = linspace(0,2*pi-deltaF,nfft);
        
    case 2,  % 0-pi
        deltaF = pi/nfft;
        w = linspace(0,pi-deltaF,nfft);
        
    case 3, % -pi-pi
        deltaF = (2*pi)/nfft;
        
        if rem(nfft,2), % ODD, don't include Nyquist.
            wmin = -(pi - (deltaF/2));
            wmax = pi - (deltaF/2);
            
        else            % EVEN include Nyquist point in the negative freq.
            wmin = -pi;
            wmax = pi - deltaF;
        end
        w = linspace(wmin, wmax, nfft);
end

if ~isempty(Fs), % Fs was given, return freq. in Hz
    w = w.*Fs./(2.*pi); % Convert from rad/sample to Hz      
end


% [EOF]
