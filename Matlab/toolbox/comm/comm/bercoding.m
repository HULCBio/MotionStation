function ber = bercoding(EbNo, coding, decision, varargin)
%BERCODING Bit error rate (BER) for coded AWGN channels.
%   BERUB = BERCODING(EbNo, 'conv', DECISION, CODERATE, DSPEC) returns an
%   upper bound of the BER of binary convolutional
%   codes with coherent BPSK or QPSK modulation.
%   EbNo -- bit energy to noise power spectral density ratio (in dB)
%   DECISION -- string variable: 'hard' for hard decision,
%                                'soft' for soft decision
%   DSPEC -- distance spectrum of the code
%   CODERATE -- code rate
%
%   BERUB = BERCODING(EbNo, 'block', 'hard', N, K, DMIN) returns an upper
%   bound of the BER of (N, K) binary block codes with hard decision
%   decoding and coherent BPSK or QPSK modulation.
%
%   BERUB = BERCODING(EbNo, 'block', 'soft', N, K, DMIN) returns an upper
%   bound of the BER of (N, K) binary block codes with soft decision
%   decoding and coherent BPSK or QPSK modulation.
%   DMIN -- minimum distance of the code
%
%   See also DISTSPEC, BERAWGN, BERFADING, BERSYNC.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/12 23:00:27 $

if (nargin < 5)
    error('comm:bercoding:minArgs', 'BERCODING requires at least 5 input arguments.');
elseif (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
    error('comm:bercoding:EbNo', 'EbNo must be a real vector.');
end

EbNo = 10.^(EbNo/10);    % converting EbNo from dB to linear scale

if strncmpi(coding, 'c', 1)    % convolutional coding

    dspec = varargin{2};
    if (~isstruct(dspec))
        error('comm:bercoding:dspec', ...
            'DSPEC must be a structure containing dfree and weight.');
    end

    codeRate = varargin{1};
    distSpec = dspec.weight;
    dfree = dspec.dfree;

    if (~is(codeRate, 'real') || ~is(codeRate, 'scalar') ...
            || codeRate > 1 || codeRate <= 0)
        error('comm:bercoding:codeRate', ...
            'CODERATE must be a real number between 0 and 1.');
    elseif (~is(dfree, 'scalar') || ~is(dfree, 'positive integer'))
        error('comm:bercoding:dfree', 'DSPEC.DFREE must be a positive integer.');
    elseif (~is(distSpec, 'real') || ~is(distSpec, 'vector'))
        error('comm:bercoding:distSpec', 'DSPEC.WEIGHT must be a real vector.');
    end

    ber = zeros(size(EbNo));

    for d = dfree : (length(distSpec) + dfree - 1)
        if strncmpi(decision, 'h', 1)           % hard decision
            p = qfunc(sqrt(2*EbNo*codeRate));   % BSC BER
            P2d = 0;
            for k =ceil((d+1)/2):d
                P2d = P2d + nchoosek(d, k)*p.^k.*(1-p).^(d-k);
            end
            if (ceil(d/2) == d/2)
                P2d = P2d + nchoosek(d, d/2)*(p.*(1-p)).^(d/2)/2;
            end
        elseif strncmpi(decision, 's', 1)   % soft decision
            P2d = qfunc(sqrt(2*EbNo*codeRate*d));
        else
            error('comm:bercoding:decision', ...
                'DECISION must be either ''hard'' or ''soft''.');
        end
        ber = ber + distSpec(d-dfree+1)*P2d;
    end
elseif strncmpi(coding, 'b', 1) % block coding

    if (nargin < 6)
        error('comm:bercoding:minArgsBlock', ...
            'BERCODING requires 6 input arguments for block coding.');
    end
    n = varargin{1};
    k = varargin{2};
    dmin = varargin{3};

    if (~is(n, 'scalar') || ~is(n, 'positive integer'))
        error('comm:bercoding:N', 'N must be a positive integer.');
    elseif (~is(k, 'scalar') || ~is(k, 'positive integer') || k > n)
        error('comm:bercoding:K', 'K must be a positive integer smaller than n.');
    elseif (~is(dmin, 'scalar') || ~is(dmin, 'positive integer'))
        error('comm:bercoding:dmin', 'DMIN must be a positive integer.');
    elseif strncmpi(decision, 'h', 1)   % hard decision
        p = qfunc(sqrt(2*EbNo*k/n));    % BSC BER
        t = floor((dmin-1)/2);
        b = 2^(n-k);
        for i = 0:t
            b = b - nchoosek(n, i);
        end
        wer = (nchoosek(n,t+1)-b) * p.^(t+1) .* (1-p).^(n-t-1);
        for m = t+2:n
            wer = wer + nchoosek(n,m) * p.^m .* (1-p).^(n-m);  % WER
        end
    elseif strncmpi(decision, 's', 1)   % soft decision
        wer = (2^k - 1) * qfunc(sqrt(2*EbNo*k/n*dmin));  % upper bound of WER
    else
        error('comm:bercoding:decision', 'DECISION must be either ''hard'' or ''soft''.');
    end
    
    % converting WER to BER upper bound
    % p. 443, Digital Communications (4th ed.), Proakis
    ber = wer / 2;
else
    error('comm:bercoding:coding', 'CODING must be either ''conv'' or ''block''.');
end

ber(find(ber>1)) = 1;   % set upper limit to 1
negativeBERIndices = find(ber<0);
if ~isempty(negativeBERIndices)
    ber(find(ber<0)) = NaN;
    warning('comm:bercoding:NaN', 'NaN is returned due to invalid coding parameters.');
end
