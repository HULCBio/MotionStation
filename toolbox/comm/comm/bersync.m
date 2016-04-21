function ber = bersync(EbNo, sigma, type)
%BERSYNC Bit error rate (BER) for imperfect synchronization.
%   BER = BERSYNC(EbNo, TIMERR, 'timing') returns the BER of coherent BPSK
%   modulation over an uncoded AWGN channel with timing error. The
%   normalized timing error is assumed to be Gaussian distributed.
%   EbNo -- bit energy to noise power spectral density ratio (in dB)
%   TIMERR -- standard deviation of the timing error, normalized to the
%             symbol interval
%
%   BER = BERSYNC(EbNo, PHASERR, 'carrier') returns the BER of BPSK
%   modulation over an uncoded AWGN channel with a noisy phase reference.
%   The phase error is assumed to be Gaussian distributed.
%   PHASERR -- standard deviation of the reference carrier phase error
%              (in rad)
%
%   See also BERAWGN, BERCODING, BERFADING.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:00:30 $

if (nargin < 3)
    error('comm:bersync:numArgs', 'BERSYNC requires 3 input arguments.');
end
if (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:bersync:EbNo', 'EbNo must be a real vector.');
end

EbNoLin = 10.^(EbNo/10);    % converting from dB to linear scale
ber = zeros(size(EbNo));

if strncmpi(type, 't', 1)    % timing error
    if (~is(sigma, 'nonnegative') || ~is(sigma, 'scalar') || sigma>.5)
        error('comm:bersync:timerr', 'TIMERR must be a scalar between 0 and 0.5.');
    elseif sigma < eps
        ber = berawgn(EbNo, 'psk', 2, 'n');
    else
        s = warning('off', 'MATLAB:quad:MaxFcnCount');
        tol = 1e-4 ./ EbNoLin.^6;
        tol(find(tol>1e-4)) = 1e-4;
        tol(find(tol<eps)) = eps;

        for i = 1:length(EbNoLin)
            ber(i) = quad(@t2, -10*sigma, 10*sigma, tol(i), [], EbNoLin(i), sigma) ...
                * sqrt(2) / (8*sqrt(pi)*sigma);
        end
        warning(s.state, s.identifier);     % recover warning state
        ber = ber + erfc(sqrt(EbNoLin)) / 4;
    end
elseif strncmpi(type, 'c', 1)    % carrier phase noise
    if (~is(sigma, 'nonnegative') || ~is(sigma, 'scalar'))
        error('comm:bersync:phaserr', 'PHASERR must be a nonnegative number.');
    elseif sigma < eps
        ber = berawgn(EbNo, 'psk', 2, 'n');
    else
        s = warning('off', 'MATLAB:quad:MaxFcnCount');
        tol = 1e-4 ./ EbNoLin.^6;
        tol(find(tol>1e-4)) = 1e-4;
        tol(find(tol<eps)) = eps;

        for i = 1:length(EbNoLin)
            ber(i) = quad(@pn2, 0, 10*sigma, tol(i), [], EbNoLin(i), sigma) ...
                / (sqrt(2*pi) * sigma);
        end
        warning(s.state, s.identifier);     % recover warning state
    end
else
    error('comm:bersync:thirdArg', ...
        'The 3rd argument must be either ''timing'' or ''carrier''.');
end

function out = t2(xi, EbNoLin, timerr)
% integrand function for BPSK with timing error
% (9.3.5) in Theory of Synchronous Communications, Stiffler

out = erfc(sqrt(EbNoLin)*(1-2*abs(xi))) .* exp(-xi.^2/(2*(timerr)^2));

function out = pn2(phi, EbNoLin, phaserr)
% integrand function for BPSK with noisy phase reference
% (9.3.3) in Theory of Synchronous Communications, Stiffler

out = erfc(sqrt(EbNoLin).*cos(phi)) .* exp(-phi.^2/(2*(phaserr)^2));
