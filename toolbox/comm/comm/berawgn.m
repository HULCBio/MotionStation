function ber = berawgn(EbNo, modType, varargin)
%BERAWGN Bit error rate (BER) for uncoded AWGN channels.
%   BER = BERAWGN(EbNo, MODTYPE, M) returns the BER for PAM or QAM over an
%   uncoded AWGN channel with coherent demodulation.
%   EbNo -- bit energy to noise power spectral density ratio (in dB)
%   MODTYPE -- modulation type, either 'pam' or 'qam'
%   M -- alphabet size, must be a positive integer power of 2
%
%   BER = BERAWGN(EbNo, 'psk', M, DATAENC) returns the BER for coherently
%   detected PSK over an uncoded AWGN channel.
%   DATAENC -- 'diff' for differential data encoding,
%              'nondiff' for nondifferential data encoding
%
%   BER = BERAWGN(EbNo, 'dpsk', M) returns the BER for DPSK over an uncoded
%   AWGN channel.
%
%   BER = BERAWGN(EbNo, 'fsk', M, COHERENCE) returns the BER for orthogonal
%   FSK over an uncoded AWGN channel.
%   COHERENCE -- 'coherent' for coherent demodulation,
%                'noncoherent' for noncoherent demodulation
%
%   BER = BERAWGN(EbNo, 'msk', DATAENC) returns the BER of coherently
%   detected MSK over an uncoded AWGN channel.
%   DATAENC -- 'diff' for differential data encoding,
%              'nondiff' for nondifferential data encoding
%
%   BERLB = BERAWGN(EbNo, 'cpfsk', M, MODINDEX, KMIN) returns a lower bound
%   on the BER of CPFSK over an uncoded AWGN channel.
%   MODINDEX -- modulation index
%   KMIN -- number of paths having the minimum  distance
%
%   See also BERCODING, BERFADING, BERSYNC.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/12 23:00:26 $

if (nargin < 3)
    error('comm:berawgn:numArgs', 'BERAWGN requires at least 3 arguments.');
elseif (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:berawgn:EbNo', 'EbNo must be a real vector.');
end

EbNoLin = 10.^(EbNo/10);    % converting EbNo from dB to linear scale
modType = lower(modType);

switch modType
    case {'pam', 'qam', 'psk', 'dpsk', 'fsk', 'cpfsk'}
        M = varargin{1};
        if ~is(M, 'scalar')
            error('comm:berawgn:scalarM', 'M must be a scalar.');
        end
        if M > 1
            k = log2(M);
        else
            k = 0.5;
        end
        if (~is(M, 'positive') || ceil(k)~=k)
            error('comm:berawgn:intM', ...
                'M must be a positive integer power of 2.');
        end
        if (strcmpi(modType, 'qam') && (M == 2))
            error('comm:berawgn:minM', 'M must be at least 4 for QAM.');
        end
end

switch modType
    case 'psk'
        if (nargin < 4)
            error('comm:berawgn:numArgsPSK', ...
                'BERAWGN requires 4 arguments for PSK.');
        end
        dataEnc = varargin{2};
    case {'fsk'}
        if (nargin < 4)
            error('comm:berawgn:numArgsFSK', ...
                'BERAWGN requires 4 arguments for FSK.');
        end
        coherence = varargin{2};
    case 'msk'
        dataEnc = varargin{1};
end

if strcmpi(modType, 'cpfsk')
    if (nargin < 5)
        error('comm:berawgn:numArgsCPFSK', ...
            'BERAWGN requires 5 arguments for CPFSK.');
    end
    modIndex = varargin{2};
    Kmin = varargin{3};
    if (~is(modIndex, 'positive') || ~is(modIndex, 'scalar'))
        error('comm:berawgn:modIndex', 'MODINDEX must be a positive number.');
    elseif (~is(Kmin, 'positive integer') || ~is(Kmin, 'scalar'))
        error('comm:berawgn:Kmin', 'KMIN must be a positive integer.');
    end
end
% end of error checking

switch modType
    case 'pam'
        ber = 2 * (M-1) ./ M .* qfunc(sqrt(6*k./(M.*M-1)*EbNoLin)) / k;
    case 'qam'
        if (ceil(k/2) == k/2)   % k is even
            ber = (1 - (1 - 2*(1-1/sqrt(M)).*qfunc(sqrt(3*k./(M-1)*EbNoLin))).^2) / k;
        elseif (M == 8)
            % combining 4-PAM (I-channel) and BPSK (Q-channel)
            % results to get QAM results
            EsNo = k * EbNoLin;
            EsNoI = EsNo * 5/6;     % 5/6 of total energy in I channel
            EsNoQ = EsNo / 6;       % 1/6 of total energy in Q channel
            EbNoI = EsNoI / 2;      % 2 bits in I channel
            EbNoQ = EsNoQ;          % 1 bit in I channel
            serI = berawgn(10*log10(EbNoI), 'pam', 4) * 2;    % SER of I channel
            serQ = berawgn(10*log10(EbNoQ), 'psk', 2, 'nondiff');    % SER of Q channel
            ber = (1 - (1-serI).*(1-serQ)) / k;
        else
            % tight upper bound
            ber = (1 - (1 - 2 * qfunc(sqrt(3*k./(M-1)*EbNoLin))) .^ 2) / k;
            ber(find(ber>1)) = 1;   % set upper limit to 1
        end
    case 'fsk'
        if strncmpi(coherence, 'c', 1)
            ser = zeros(size(EbNoLin));
            tol = 1e-4 ./ EbNoLin.^6;
            tol(find(tol>1e-4)) = 1e-4;
            tol(find(tol<eps)) = eps;

            for i = 1:length(EbNoLin)
                ser(i) = quad(@fskc, -5, 15, tol(i), [], EbNoLin(i), M, k) / sqrt(2*pi);
            end
            ber = ser .* M./(2*(M-1));
        elseif strncmpi(coherence, 'n', 1)
            if M > 64
                % numerical problems
                error('comm:berawgn:FSK', ...
                    'No results for noncoherent FSK with M > 64.');
            else
                s = warning('off', 'MATLAB:nchoosek:LargeCoefficient');
                ser = 0;
                for (n = 1:M-1)
                    ser = ser + (-1)^(n+1) * nchoosek(M-1,n) / (n+1) ...
                        .* exp(-EbNoLin*n*k/(n+1));
                end
                ber = ser .* M./(2*(M-1));
                warning(s.state, s.identifier);     % recover warning state
            end
        else
            error('comm:berawgn:coherence', ...
                'COHERENCE must be either ''coherent'' or ''noncoherent''.');
        end
    case 'psk'
        if strncmpi(dataEnc, 'n', 1)
            switch M
                case 2
                    ser = qfunc(sqrt(2*EbNoLin));
                case 4
                    q = qfunc(sqrt(2*EbNoLin));
                    ser = 2 * q .* (1-q/2);
                otherwise
                    ser = 2 * qfunc(sqrt(2*k*EbNoLin).*sin(pi/M));
            end
            ber = ser / k;
        elseif strncmpi(dataEnc, 'd', 1)
            switch M
                case 2
                    t = erfc(sqrt(EbNoLin));
                    ber = t .* (1 - t/2);
                case 4
                    s = warning('off', 'MATLAB:DivideByZero');
                    p = berawgn(EbNo, 'psk', M, 'nondiff') * k;
                    p = p(:);
                    pk = zeros(length(EbNo), M-1);
                    EbNoLinS = sqrt(EbNoLin);
                    EbNoLinS = EbNoLinS(:);
                    intp = zeros(size(EbNoLinS));
                    intn = intp;
                    tol = 1e-4 ./ EbNoLin.^5;
                    tol(find(tol>1e-4)) = 1e-4;
                    tol(find(tol<eps)) = eps;

                    for i = 1:M-1
                        tp = sin(pi * (2*i+1) / M);
                        tn = sin(pi * (2*i-1) / M);
                        for j = 1:length(EbNo)
                            intp(j) = quad(@pskp, 0, EbNoLinS(j)*tp, tol(j), [], M, i);
                            intn(j) = quad(@pskn, 0, EbNoLinS(j)*tn, tol(j), [], M, i);
                        end
                        pk(:, i) = 1/M + (erf(EbNoLinS * tp) - erf(EbNoLinS * tn)) /4 ...
                            + (intp - intn) /2/sqrt(pi);
                    end

                    ber = 2 * p .* (1 - p/2 - (sum(pk.^2, 2) / 2 ./ p)) / k;
                    ber(find(ber<0)) = 0;   % return 0 for negative result
                    ber = reshape(ber, size(EbNo, 1), size(EbNo, 2));
                    warning(s.state, s.identifier);     % recover warning state
                otherwise
                    % The equations in Lindsey & Simon lead to numerical
                    % problems in MATLAB
                    error('comm:berawgn:diffPSK', ...
                        'No results for coherent detection of differentially encoded PSK with M > 4.');
            end
        else
            error('comm:berawgn:dataEnc', ...
                'DATAENC must be either ''diff'' or ''nondiff''.');
        end
    case 'dpsk'
        switch M
            case 2
                ber = exp(-EbNoLin) / 2;
            case 4
                bigEbNoIndices = find(EbNo>17);
                smallEbNoIndices = find(EbNo<=17);
                ber(bigEbNoIndices) = 0;    % due to limited numerical precision
                a = sqrt(2*EbNoLin(smallEbNoIndices)*(1-sqrt(.5)));
                b = sqrt(2*EbNoLin(smallEbNoIndices)*(1+sqrt(.5)));
                ber(smallEbNoIndices) = marcumq(a, b) - ...
                    besseli(0, a.*b).*exp(-.5*(a.^2+b.^2))/2;
            otherwise
                ber = berawgn(EbNo-3, 'psk', M, 'nondiff');
        end
    case 'msk'
        if strncmpi(dataEnc, 'n', 1)
            ber = berawgn(EbNo, 'psk', 2, 'nondiff');
        elseif strncmpi(dataEnc, 'd', 1)
            ber = berawgn(EbNo, 'psk', 2, 'diff');
        else
            error('comm:berawgn:dataEnc', ...
                'DATAENC must be either ''diff'' or ''nondiff''.');
        end
    case 'cpfsk'
        dmin2 = min((1-sinc(2 * (1:(M-1)) * modIndex)) * 2*k);  % tight upper bound
        ser = Kmin * qfunc(sqrt(EbNoLin * dmin2)); % tight lower bound
        ber = ser / k;      % converting SER lower bound to BER lower bound
    otherwise
        error('comm:berawgn:modType', 'Invalid modulation type.');
end

function out = fskc(y, EbNoLin, M, k)
% integrand function for coherent FSK based on eq (5.2-21),
% Digital Communications (4th ed.) by Proakis, 2001.

out = (1 - (1-qfunc(y)).^(M-1)) .* exp(-.5*(y-sqrt(2*k*EbNoLin)).^2);

function out = pskp(y, M, k)
% integrand function for coherent detection of differentially encoded PSK
% based on eq (5-111), Telecommunication Systems Engineering by Lindsey &
% Simon, 1973.

out = exp(-y.^2) .* erf(y * cot(pi*(2*k+1)/M));

function out = pskn(y, M, k)
% integrand function for coherent detection of differentially encoded PSK
% based on eq (5-111), Telecommunication Systems Engineering by Lindsey &
% Simon, 1973.

out = exp(-y.^2) .* erf(y * cot(pi*(2*k-1)/M));
