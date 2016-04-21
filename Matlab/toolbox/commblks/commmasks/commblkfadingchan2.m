function varargout = commblkfadingchan2(block,varargin)
% COMMBLKFADINGCHAN Rayleigh/Rician channel helper function.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.3 $  $Date: 2004/04/12 23:02:52 $

% --- Mask parameters
% Fd
% LOSFd
% K
% simTs
% delayVec
% gainVecdB
% normGain
% Seed
%
% Exit code assignments:
% 0 = No error/warning
% 1 = Error
% 2 = Warning

% --- Initial checks
error(nargchk(9,9,nargin));

% --- Input parameter assignments
Fd          = varargin{1}(:).';
LOSFd       = varargin{2};
K           = varargin{3};
simTs       = varargin{4}(:).';
delayVec    = varargin{5};
gainVecdB   = varargin{6};
normGain    = varargin{7};
Seed        = varargin{8}(:).';
params = [];

% --- Exit code and error message definitions
ecode = 0;
emsg  = '';

% --- Determine how this block is being used
blkMode = determineMode(block);

% --- Number of paths is determined by the length of the delay, gain, LOSFd and K vectors
%     Scalar expansion rules apply.
switch(blkMode)
case 'RAYLEIGH'
    if(any([ismatrix(delayVec) ismatrix(gainVecdB)]))
        emsg  = 'The Gain and delay parameters must be either scalar or vector entries.';
        ecode = 1;
    end;
case 'RICIAN'
    if(any([ismatrix(K) ismatrix(delayVec) ismatrix(gainVecdB)]))
        emsg  = 'K-factor, gain and delay parameters must be scalars.';
        ecode = 1;
    end;
otherwise
    if(any([ismatrix(LOSFd) ismatrix(K) ismatrix(delayVec) ismatrix(gainVecdB)]))
        emsg  = 'The Line-of-Sight, K-factor, gain and delay parameters must be either scalar or vector entries.';
        ecode = 1;
    end;
end;

% --- Parameter checks
if(~ecode)
    % --- Ensure parameters that may be vectors are all rows
    LOSFd     = LOSFd(:).';
    K         = K(:).';
    delayVec  = delayVec(:).';
    gainVecdB = gainVecdB(:).';
    
    % --- Core parameter checks
    if(any([~isreal(Fd) (any(Fd <= 0)) (length(Fd)~=1)]))
        emsg  = 'The Maximum Doppler shift must be a nonnegative scalar.';
        ecode = 1;
    elseif(any([~isreal(simTs) (any(simTs <= 0)) (length(simTs)~=1)]))
        emsg  = 'The sample time must be a real scalar greater than zero.';
        ecode = 1;
    elseif(any([~isreal(Seed) ((Seed-floor(Seed)) ~= 0) (ndims(Seed) > 2) (size(Seed,1)>1) (size(Seed,2)>1)]))
        emsg  = 'The seed must be an integer.';
        ecode = 1;
    end;
    
    switch(blkMode)
    case 'RAYLEIGH'
        % --- Rayleigh specific parameter checks
        if(any([~isreal(delayVec) (any(delayVec < 0))]))
            emsg  = 'The delay parameter must be a nonnegative scalar or vector.';
            ecode = 1;
        elseif(~isreal(gainVecdB))
            emsg  = 'The gain parameter must be a real scalar or vector.';
            ecode = 1;
        elseif( any([~isreal(LOSFd) (any(LOSFd ~= 0))]))
            emsg  = 'The Line-of-Sight Doppler frequency must be zero for a Rayleigh channel.';
            ecode = 1;
        elseif(any([~isreal(K) (any(K ~= 0))]))
            emsg  = 'The K-factor parameter must be zero for a Rayleigh channel.';
            ecode = 1;
        end;
    case 'RICIAN'
        % --- Rician specific parameter checks
        if(any([~isreal(LOSFd) ( isvector(LOSFd) && ~isempty(LOSFd) && ~isscalar(LOSFd) )]))
            emsg  = 'The Line-of-Sight Doppler frequency must be a real scalar.';
            ecode = 1;
        elseif(any([~isreal(K) (any(K < 0)) ( isvector(K) && ~isempty(K) && ~isscalar(K) )]))
            emsg  = 'The K-factor parameter must be a nonnegative scalar.';
            ecode = 1;
        elseif(any([~isreal(delayVec) (any(delayVec < 0)) ( isvector(delayVec) && ~isempty(delayVec) && ~isscalar(delayVec) )]))
            emsg  = 'The delay parameter must be a nonnegative scalar.';
            ecode = 1;
        elseif(any([~isreal(gainVecdB) ( isvector(gainVecdB) && ~isempty(gainVecdB) && ~isscalar(gainVecdB) )]))
            emsg  = 'The gain parameter must be a real scalar.';
            ecode = 1;
        end;
    case 'STAND_ALONE'
        % --- General mode parameter checks
        if(any([~isreal(delayVec) (any(delayVec < 0))]))
            emsg  = 'The delay parameter must be a nonnegative scalar or vector.';
            ecode = 1;
        elseif(~isreal(gainVecdB))
            emsg  = 'The gain parameter must be a real scalar or vector.';
            ecode = 1;
        elseif(~isreal(LOSFd))
            emsg  = 'The Line-of-Sight Doppler frequency must be a real scalar or vector.';
            ecode = 1;
        elseif(any([~isreal(K) (any(K < 0))]))
            emsg  = 'The K-factor parameter must be a nonnegative scalar or vector.';
            ecode = 1;
        end;
        
    otherwise
        error('Unknown internal mode encountered.');
    end;
    
end;

% --- Perform scalar expansion and length checks
if(~ecode)
    lenVec = [length(LOSFd) length(K) length(delayVec) length(gainVecdB)];
    maxLen = max(lenVec);
    
    vectorPos = find(lenVec > 1); % Vector with of vector parameter positions
    
    if(isempty(vectorPos))
        nPaths = 1;
    else
        vectorLengths = lenVec(vectorPos(find(vectorPos > 0)));
        if(~all((vectorLengths) == maxLen))
            switch(blkMode)
            case 'RAYLEIGH'
                emsg  = 'The Gain and delay parameters are vectors of different lengths.';
                ecode = 1;
            case 'RICIAN'
                emsg  = 'The K-factor, gain and delay fields must be scalar entries.';
                ecode = 1;
            otherwise
                emsg  = 'The Line-of-Sight Doppler frequency, K-factor, gain and delay parameters are vectors of different lengths.';
                ecode = 1;
            end;
        else
            nPaths = vectorLengths(1); % As the lengths are the same, just choose the first
        end;
    end;
    
    if(~ecode)
        scalarPos = (lenVec == 1);    % Boolean vector with a 1 where a scalar exists
        % --- Scalars are expanded to rows
        for n=1:length(lenVec)
            if(scalarPos(n))
                switch n
                case 1 % LOSFd
                    LOSFd = ones(1,nPaths)*LOSFd;
                case 2 % K
                    K = ones(1,nPaths)*K;
                case 3 % delayVec
                    delayVec = ones(1,nPaths)*delayVec;
                case 4 % gainVec
                    gainVecdB = ones(1,nPaths)*gainVecdB;
                end;
            end;
        end;
        
    end;
    
end;


% --- At this point, if ecode==0, all parameters are OK and calculations can continue
varargout{1} = ecode;
varargout{2} = emsg;
varargout{3} = params;

if(ecode)
    return;
end;

% --- If the K-factor is infinite, then the noise power is zero, so don't filter
%     If the Doppler frequency is infinite, then don't filter.

% --- Define the Doppler filter
dopplerFilterDetails = defineDopplerFilter;

ni = 5;     % number of rate conversion blocks to generate fading profile

if(any([isinf(K) isinf(Fd)]))
    dopplerFilterDetails.Num = 1;
    dopplerFilterDetails.Den = 1;
    
    actualIntFactor = Inf;  % Here, intFactor will be used to set the width of the profile signal
    
    startDelay = 0;
    
    intfactors = ones(1,ni);
    decfactors = intfactors;
    rc1Num = [1 0];
    rc2Num = [1 0];
    rc3Num = [1 0];
    rc4Num = [1 0];
    rc5Num = [1 0];
else
    Kf = dopplerFilterDetails.NormalizedBandwidth;
    
    % --- Compute interpolation required
    intFactor = Kf/(Fd*simTs);
    if (intFactor<100)
        [intFactor, decFactor] = rat(intFactor, .01);
    else
        intFactor = round(intFactor);
        decFactor = 1;
    end
    
    % Warn if the interpolation or decimation factor is too large
    Limit = 25^ni;     % upper limit for each interpolator is 25
    if(intFactor > Limit | decFactor > Limit)
        blkName = gcb;
        blkName(find(abs(blkName)<32))=' ';
        blkName = [blkName '/Fading Profile/Triggered Rayleigh Profile'];    
        emsg  = sprintf('%s: \nThe Maximum Doppler shift and Sample time have produced an internal \ninterpolation factor greater than %d. This may produce inaccurate results.', blkName, Limit); 
        ecode = 2;
    end;
    
    % --- Split interpolation/decimation among the 4 rate change blocks
    intfactors = splitint(intFactor, ni);
    decfactors = splitint(decFactor, ni);
    
    % Remove repetitions of interpolation and decimation factors
    repindex = find(intfactors==decfactors);
    intfactors(repindex) = 1;
    decfactors(repindex) = 1;
    
    actualIntFactor = prod(intfactors);
    actualDecFactor = prod(decfactors);
    maxfactors = max([intfactors; decfactors]);
    
    % --- Design the interpolation filters using Kaiser
    Ts = 1; % Notional sample frequency
    
    % --- Design stage 1
    rp = 1;     % Passband ripple
    rs = 50;    % Stopband attenuation
    a = [1 0];  % Desired amplitudes
    
    % --- Compute deviations
    dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % --- Design the filter
    [n,Wn,beta,typ] = kaiserord([Kf .5-Kf], a, dev, maxfactors(1)/Ts);
    rc1Num = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
    
    % --- Design stage 2
    rp = 1;     % Passband ripple
    rs = 60;    % Stopband attenuation
    a = [1 0];  % Desired amplitudes
    
    % --- Compute deviations
    dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % --- Design the filter
    Kf = Kf*decfactors(1)/intfactors(1);
    [n,Wn,beta,typ] = kaiserord([Kf .5-Kf], a, dev, maxfactors(2)/Ts);
    rc2Num = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
    
    % --- Design stage 3
    rp = 1;     % Passband ripple
    rs = 70;    % Stopband attenuation
    a = [1 0];  % Desired amplitudes
    
    % --- Compute deviations
    dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % --- Design the filter
    Kf = Kf*decfactors(2)/intfactors(2);
    [n,Wn,beta,typ] = kaiserord([Kf .5-Kf], a, dev, maxfactors(3)/Ts);
    rc3Num = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
    
    % --- Design stage 4
    rp = 1;     % Passband ripple
    rs = 80;    % Stopband attenuation
    a = [1 0];  % Desired amplitudes
    
    % --- Compute deviations
    dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % --- Design the filter
    Kf = Kf*decfactors(3)/intfactors(3);
    [n,Wn,beta,typ] = kaiserord([Kf .5-Kf], a, dev, maxfactors(4)/Ts);
    rc4Num = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
     
    % --- Design stage 5
    rp = 1;     % Passband ripple
    rs = 90;    % Stopband attenuation
    a = [1 0];  % Desired amplitudes
    
    % --- Compute deviations
    dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % --- Design the filter
    Kf = Kf*decfactors(4)/intfactors(4);
    [n,Wn,beta,typ] = kaiserord([Kf .5-Kf], a, dev, maxfactors(5)/Ts);
    rc5Num = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
   
    % --- Determine startup transient
    D1 = filterdelay(rc1Num);
    D2 = filterdelay(rc2Num);
    D3 = filterdelay(rc3Num);
    D4 = filterdelay(rc4Num);
    D5 = filterdelay(rc5Num);
   
    startDelay = round(((((dopplerFilterDetails.Delay    ...
        *intfactors(1)/decfactors(1)+D1) ...
        *intfactors(2)/decfactors(2)+D2) ...
        *intfactors(3)/decfactors(3)+D3) ...
        *intfactors(4)/decfactors(4)+D4) ...
        *intfactors(5)/decfactors(5)+D5);
    
    % --- Account for the gains/attenuations required in each stage
    rc1Num = rc1Num*intfactors(1);
    rc2Num = rc2Num*intfactors(2);
    rc3Num = rc3Num*intfactors(3);
    rc4Num = rc4Num*intfactors(4);
    rc5Num = rc5Num*intfactors(5);
end;

% --- If the normalise gain option is chosen, then ensure that the overall
%     gain of the channels is 0dB
gainVecLin = 10.^(gainVecdB/10);
if(normGain)
    gainVecLin = gainVecLin/sum(gainVecLin);
end;

% --- Assign values to the parameter structure
params.nPaths     = nPaths;
params.Seed       = Seed;
params.dopplerSos = dopplerFilterDetails.sos;  % Doppler SOS matrix
params.rc1Num     = rc1Num;
params.interp1    = intfactors(1);
params.decim1     = decfactors(1);
params.rc2Num     = rc2Num;
params.interp2    = intfactors(2);
params.decim2     = decfactors(2);
params.rc3Num     = rc3Num;
params.interp3    = intfactors(3);
params.decim3     = decfactors(3);
params.rc4Num     = rc4Num;
params.interp4    = intfactors(4);
params.decim4     = decfactors(4);
params.rc5Num     = rc5Num;
params.interp5    = intfactors(5);
params.decim5     = decfactors(5);
params.intFactor  = actualIntFactor;
params.startDelay = startDelay;

if(isinf(actualIntFactor)) % An infinite interpolation indicates that no filtering or interpolation is required
    params.intFactor    = 1;
    %   params.maxPathWidth = Inf;
else
    %   params.maxPathWidth = actualIntFactor*max([1 round(10000/actualIntFactor)]);
end;

params.K     = K;
params.LOSFd = LOSFd;

params.sampleDelayVec = delayVec/simTs;
params.gainVecLin     = gainVecLin;

% --- Assign the output arguments
varargout{1} = ecode;
varargout{2} = emsg;
varargout{3} = params;

% ----------------
% --- Subfunctions
% ----------------

% --- Determine the mode of operation
function blkMode = determineMode(block)
blkParent     = get_param(block,'Parent');
blkParentType = get_param(get_param(gcb,'parent'),'type');

% --- If the block is contained within another block, then check if it's Rayleigh or Rician
if(strcmp(blkParentType,'block'))
    blkParentMaskType = get_param(get_param(gcb,'parent'),'MaskType');
    
    if(strcmp(blkParentMaskType,'Multipath Rayleigh Fading Channel'))
        blkMode = 'RAYLEIGH';
    elseif(strcmp(blkParentMaskType,'Rician Fading Channel'))
        blkMode = 'RICIAN';
    else
        blkMode = 'STAND_ALONE';
    end;
    
else  % The block is at the top level of a model
    blkMode = 'STAND_ALONE';
end;

return;


% --- Doppler filter definition
function [filterDetails] = defineDopplerFilter

% --- Poles
P(1) = 9.9015456438065e-01 + j*  4.500919952989e-02;
P(2) = 9.9015456438065e-01 + j*(-4.500919952989e-02);
P(3) = 9.8048448562622e-01 + j*  1.875760592520e-02;
P(4) = 9.8048448562622e-01 + j*(-1.875760592520e-02);
P(5) = 9.9652880430222e-01 + j*  5.493839457631e-02;
P(6) = 9.9652880430222e-01 + j*(-5.493839457631e-02);
P(7) = 9.9827980995178e-01 + j*  5.666938796639e-02;
P(8) = 9.9827980995178e-01 + j*(-5.666938796639e-02 );

% --- Zeros
Z(1) = 9.9835836887360e-01 + j*  5.727641656995e-02;
Z(2) = 9.9835836887360e-01 + j*(-5.727641656995e-02);
Z(3) = 9.9744373559952e-01 + j*  7.145611196756e-02;
Z(4) = 9.9744373559952e-01 + j*(-7.145611196756e-02);
Z(5) = 9.9440407752991e-01 + j*  1.0564350336790e-01;
Z(6) = 9.9440407752991e-01 + j*(-1.0564350336790e-01);
Z(7) = 9.6530824899673e-01 + j*  2.6111298799515e-01;
Z(8) = 9.6530824899673e-01 + j*(-2.6111298799515e-01);

% --- Determine transfer function
PVec = [P(1) P(2) P(3) P(4) P(5) P(6) P(7) P(8) ]';
ZVec = [Z(1) Z(2) Z(3) Z(4) Z(5) Z(6) Z(7) Z(8) ]';

% --- Convert to sos
sos = zp2sos(ZVec,PVec,1);

% --- Determine the gain of the filter
rho    = max(abs(P));
tol    = 0.1;          
logtol = log(tol);   
neff   = round(logtol/log(rho));

impSeq = zeros(neff,1);
impSeq(1) = 1;

H = sosfilt(sos,impSeq);
sos(1,1:3) = sos(1,1:3)/norm(H); % Remove gain

% --- Set the output struture
filterDetails.NormalizedBandwidth = 0.009;
filterDetails.sos   = sos;
filterDetails.Delay = 400; % Filter delay in samples
return;

function factors = splitint(N, ni)
% Split an integer into several smaller ones for multistage interpolation
% or decimation
% N  -- the integer to be splitted
% ni -- number of integers returned by the function

if (ni == 1)     % ending condition of the recursion
    factors = N;
else
    fac = factor(N);
    facl = length(fac);
    % If maximum prime factor < 25, assign the prime factors to the output
    % vector, so that prod(factors) == N (accurate split).
    if (fac(facl)<25)
        factors = ones(1, ni);
        for r = 1:ceil(facl/ni)
            for i = 1:ni
                % Assign the ni prime factors to output vector.
                % Order of assignment depends on either r is even or
                % odd.
                if (logical(mod(r,2)))
                    index = facl-ni+i-(r-1)*ni;
                else
                    index = facl-i+1-(r-1)*ni;
                end
                if (index > 0)
                    factors(i) = factors(i) * fac(index);
                end
            end
        end
    else
        % This estimate tries to make the splitted integers even.
        factors(ni) = round(N^(1/ni));
        
        % Remove the above integer from the original,
        % and call the same function recursively.
        N = round(N/factors(ni));
        factors(1:ni-1) = splitint(N, ni-1);
    end
end
return


% --- Determine the centre of mass of the filter transfer function
function D = filterdelay(h)
i = 0:length(h)-1;
D = sum((h.^2).*i)/sum(h.^2);
return
