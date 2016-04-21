function [P,f,Pc] = svextrap(P,f,nfft,Pc)
%SVEXTRAP Extrapolation of Spectrum and frequency vector for Spectrum Viewer.
%    [P,f] = svextrap(P,f,nfft);
%    [P,f,Pc] = svextrap(P,f,nfft,Pc);
%    Returns P (and optionally Pc) which are extrapolated over the frequency
%    range [-Fs/2, Fs] (1 1/2 periods of spectra).
%
%    Assumes all inputs are in columns.
%
%    P is length NFFT/2+1 for NFFT even, (NFFT+1)/2
%    for NFFT odd, or NFFT if the original signal X is complex.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

% Author: T. Krauss

if length(P)<nfft
    if rem(nfft,2)  % nfft odd
        P = [P(end:-1:2); P; P(end:-1:2)];
        f = [-f(end:-1:2); f; f(1)*nfft-f(end:-1:2)];
        if nargin > 3
            Pc = [Pc(end:-1:2,:); Pc; Pc(end:-1:2,:)];
        end
    else
        P = [P(end:-1:2); P; P(end-1:-1:2)];
        f = [-f(end:-1:2); f; f(2:end-1)+f(end)];
        if nargin > 3
            Pc = [Pc(end:-1:2,:); Pc; Pc(end-1:-1:2,:)];
        end
    end
else
    P = [ P(ceil(end/2+1):end); P];
    f = [ -f(floor(end/2+1):-1:2); f];
    if nargin > 3
        Pc = [ Pc(ceil(end/2+1):end,:); Pc];
    end
end
