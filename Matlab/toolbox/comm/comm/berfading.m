function ber = berfading(EbNo, modType, M, divOrder, coherence)
%BERFADING Bit error rate (BER) for Rayleigh fading channels.
%   BER = BERFADING(EbNo, MODTYPE, M, DIVORDER) returns the BER of DPSK and
%   coherent PSK over uncoded flat Rayleigh fading channels.
%   EbNo -- average bit energy to noise power spectral density ratio
%           (in dB)
%   MODTYPE -- modulation type, either 'psk', or 'dpsk'
%   M -- alphabet size, must be a positive integer power of 2
%   DIVORDER -- diversity order
%
%   BER = BERFADING(EbNo, 'fsk', M, DIVORDER, COHERENCE) returns the BER of
%   orthogonal FSK over uncoded flat Rayleigh fading
%   channels.
%   COHERENCE -- string variable: 'coherent' for coherent demodulation,
%                           'noncoherent' for noncoherent demodulation
%
%   See also BERAWGN, BERCODING, BERSYNC.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/12 23:00:29 $

if (nargin < 4)
    error('comm:berfading:minArgs', 'BERFADING requires at least 4 input arguments.');
elseif (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:berfading:EbNo', 'EbNo must be a real vector.');
end

EbNo = 10.^(EbNo/10);    % converting EbNo from dB to linear scale

modType = lower(modType);
if ~is(M, 'scalar')
    error('comm:berfading:scalarM', 'M must be a scalar.');
end
if M > 1
    k = log2(M);
else
    k = 0.5;
end
if (~is(M, 'positive') || ceil(k)~=k)
    error('comm:berfading:intM', 'M must be a positive integer power of 2.');
elseif (~is(divOrder, 'scalar') || ~is(divOrder, 'positive integer'))
    error('comm:berfading:divOrder', 'DIVORDER must be a positive integer.');
end
gamma_c = EbNo * k / divOrder;  % average SNR per diversity channel

switch modType
    case 'psk'  % BER
        if (M == 2)
            mu = sqrt(gamma_c ./ (1+gamma_c));
            ber = pskf(mu, divOrder);
        elseif (M == 4)
            mu = sqrt(gamma_c ./ (1+gamma_c));
            rho = mu ./ sqrt(2-mu.^2);
            ber = pskf(rho, divOrder);
        elseif (divOrder == 1)
            ber = (M-1) ./ (M.*k.*(sin(pi/M)).^2*EbNo*2) / k;
        else
            error('comm:berfading:PSK', 'No theoretical results for PSK if M > 4 and DIVORDER > 1.');
        end
        ber(find(ber>1)) = 1; % set upper limit to 1
    case 'dpsk'
        if (M == 2)
            mu = gamma_c ./ (1+gamma_c);
            ber = pskf(mu, divOrder);
        elseif (M == 4)
            mu = gamma_c ./ (1+gamma_c);
            rho = mu ./ sqrt(2-mu.^2);
            ber = pskf(rho, divOrder);
        elseif (divOrder == 1)
            ber = (M-1) ./ (M.*k.*(sin(pi/M)).^2*EbNo) / k;
        else
            error('comm:berfading:DPSK', 'No theoretical results for DPSK if M > 4 and DIVORDER > 1.');
        end
        ber(find(ber>1)) = 1; % set upper limit to 1
    case 'fsk'  % BER
        if strncmpi(coherence, 'n', 1)
            ber = zeros(size(EbNo));
            tol = 1e-4 ./ EbNo.^4;
            tol(find(tol>1e-4)) = 1e-4;
            tol(find(tol<eps)) = eps;

            for i = 1:length(EbNo)
                ber(i) = (1 - quad(@fskf, 0, max(gamma_c(i)*divOrder, 1)*15, ...
                    tol(i), [], gamma_c(i), M, divOrder)) * M/(2*(M-1));
            end
            
            ber(find(ber<0)) = 0;
            
        elseif strncmpi(coherence, 'c', 1)
            if (M == 2)
                mu = sqrt(gamma_c ./ (2 + gamma_c));
                ber = zeros(size(EbNo));
                for i = 1:length(EbNo)
                    for k = 0:divOrder-1
                        ber(i) = ber(i) + nchoosek(divOrder-1+k, k)* ...
                            ((1+mu(i))/2).^k;
                    end
                end
                ber = ber .* ((1-mu)/2).^divOrder;
            else
                error('comm:berfading:FSK', 'No theoretical results for M > 2 coherent FSK.');
            end
        else
            error('comm:berfading:coherence', 'COHERENCE must be either ''coherent'' or ''noncoherent''.');
        end
    otherwise
        error('comm:berfading:modType', 'Invalid modulation type.');
end

function out = pskf(mu, divOrder)
% (C-18) in Digital Communications (4th ed.), Proakis

out = zeros(size(mu));
for k = 0:divOrder-1
    out = out + nchoosek(2*k, k) * ((1-mu.^2)/4).^k;
end
out = (1-mu.*out) / 2;

function out = fskf(U, gamma_c, M, divOrder)
% integrand function for FSK on Rayleigh channel(14.4-47)
% (14.4-47) in Digital Communications (4th ed.), Proakis

s = 0;
for i = 0:divOrder-1
    s = s + U.^i/factorial(i);
end
out = U.^(divOrder-1) .* exp(-U./(1+gamma_c)) ...
    ./ ((1+gamma_c).^divOrder .* factorial(divOrder-1)) ...
    .* (1-exp(-U).*s).^(M-1);
