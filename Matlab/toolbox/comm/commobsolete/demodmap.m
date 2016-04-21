function x = demodmap(y, Fd, Fs, method, M, opt2, opt3)
%DEMODMAP
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use PAMDEMOD, QAMDEMOD, GENQAMDEMOD, FSKDEMOD, PSMDEMOD
%         MSKDEMOD instead.

%   Z = DEMODMAP(Y, Fd, Fs, METHOD...) reverses the mapping functionality
%   of MODMAP. It demaps the analog signal Y to the digital signal Z.
%   The demapping process finds the distance from the sample value to
%   all of the possible digital symbols. The digital symbols with the 
%   shortest distance to the current sampling point become the demodulated
%   output. 
%
%   For information about METHOD and subsequent parameters, and about
%   using a specific technique, type one of these commands at the MATLAB
%   prompt:
%
%   FOR DETAILS, TYPE     DEMAPPING/DEMODULATION TECHNIQUE
%     demodmap ask        % M-ary amplitude shift keying 
%     demodmap psk        % M-ary phase shift keying 
%     demodmap qask       % M-ary quadrature amplitude shift keying
%     demodmap fsk        % M-ary frequency shift keying 
%     demodmap msk        % Minimum shift keying 
%     demodmap sample     % Downsample X
%
%   This function only demaps; it does not demodulate.
%   For digital demodulation, use DDEMOD for passband simulation and
%   DDEMODCE for baseband simulation.
%
%   See also MODMAP, DDEMOD, DDEMODCE, ADEMOD, ADEMODCE, 
%            EYEDIAGRAM, SCATTERPLOT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

opt_pos = 5;        % position of 1st optional parameter

if nargin < 1
    feval('help','demodmap');
    return;
elseif isstr(y)
    method = lower(deblank(y));
    if length(method) < 3
        error('Invalid method option for DEMODMAP.');
    else
        method = method(1:3);
    end
    if nargin == 1
        addition = ['See also MODMAP, DDEMOD, DDEMODCE, ADEMOD, ADEMODCE, EYEDIAGRAM,',...
		           '\r             SCATTERPLOT.'];
        addition = sprintf(addition);
        callhelp('demodmap.hlp', method, addition);
        return;
    else
        warning('Wrong number of input variables. Use MODMAP to plot constellations.');
        return;
    end
end

if nargin < 3
	disp('Usage: Z=DEMODMAP(Y, Fd, Fs, METHOD, M, OPT2, OPT3) for modulation demapping');
	return;
elseif nargin < opt_pos - 1
	method = 'sample';
else
    method = lower(method); % findstr is case sensitive
end

if length(Fd) > 1
    offset = Fd(2);
    Fd = Fd(1);
else
    offset = 0;     % default timing offset
end

if length(Fs)~=1 | ~isfinite(Fs) | ~isreal(Fs) | Fs<=0
    error('Fs must be a positive number.');
elseif ~isfinite(Fd) | ~isreal(Fd) | Fd<=0
    error('Fd must be a positive number.');
else
    FsDFd = Fs/Fd;      % oversampling rate
    if ceil(FsDFd) ~= FsDFd
        error('Fs/Fd must be a positive integer.');
    end
end
if ~isreal(offset) | ceil(offset)~=offset | offset<0 | offset>=FsDFd
    error('OFFSET must be an integer in the range [0, Fs/Fd).');
end
if offset == 0
    offset = FsDFd;
end
if (nargin >= opt_pos & isempty(findstr(method, '/arb')) & ...
   isempty(findstr(method, '/cir')) & ...
   (length(M) ~= 1 | ~isfinite(M) | ~isreal(M) | M <= 0 | ceil(M) ~= M))
    error('Alphabet size M must be a positive integer.');
end

if isempty(y)
    x = [];
    return;
end
[r, c] = size(y);
if r == 1
    y = y(:);
    len_y = c;
else
    len_y = r;
end
if nargin < opt_pos-1
    method = 'sample';      % default method
end
if rem(len_y, FsDFd) ~= 0
    error('Number of samples in y must be an integer multiple of Fs/Fd.');
elseif ~isreal(y)
    error('Input Y must be real.');
end

if strncmpi(method, 'ask', 3)
    yy = y([offset:FsDFd:len_y], :);
    if nargin < opt_pos
        error('Not enough input variables for DEMODMAP.');
    end
    index = ([0 : M - 1] - (M - 1) / 2) * 2 / (M - 1);
    x = [];
    for i = 1 : size(y, 2)
        [tmp, x_p] = min(abs(yy(:, i*ones(1, M)) - index(ones(1, size(yy, 1)), :))');
        x = [x x_p'-1];
    end
elseif strncmpi(method, 'fsk', 3)
    if nargin < opt_pos + 1
        Tone = Fd;
    else
        Tone = opt2;
    end
    yy = y([offset:FsDFd:len_y], :);
    if findstr(method, 'max')
        % in case yy is the correlation output.
        [tmp, x] = max(yy');
        x = (x-1)';
    else
        index = [0:M-1] * Tone;
        x = [];
        for i = 1 : size(y, 2)
            [tmp, x_p] = min(abs(yy(:, i*ones(1, M)) - index(ones(1, size(yy, 1)), :))');
            x = [x x_p'-1];
        end
    end
elseif strncmpi(method, 'msk', 3)
    % This is a special case of fsk.
    method(1) = 'f';
    M = 2;
    Tone = Fd/2;
    x = demodmap(y, Fd, Fs, method, M, Tone);
elseif (strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
         strncmpi(method, 'qsk', 3) | strncmpi(method, 'psk', 3))
    if findstr(method, '/ar')       % arbitrary constellation
        if nargin < opt_pos + 1
            error('Incorrect format for METHOD=''qask/arbitrary''.');
        end
        I = M;
        Q = opt2;
        M = length(I);
    elseif ~isempty(findstr(method, '/ci')) | strncmpi(method, 'psk', 3)
        % circular constellation
        if nargin < opt_pos
            if findstr(method, 'psk')
                error('M-ary number must be specified for psk demap.');
            else
                error('Incorrect format for METHOD=''qask/arbitrary''.');
            end
        end
        NIC = M;
        M = length(NIC);
        if nargin < opt_pos+1
            AIC = [1 : M];
        else
            AIC = opt2;
        end
        if nargin < opt_pos + 2
            PIC = NIC * 0;
        else
            PIC = opt3;
        end
        inx = apkconst(NIC, AIC, PIC);
        I = real(inx);
        Q = imag(inx);
        M = sum(NIC);
    else        % square constellation
        [I, Q] = qaskenco(M);
    end
    yy = y([offset:FsDFd:len_y], :);
    [len_y, wid_y] = size(yy);
    if (ceil(wid_y/2) ~= wid_y/2)
        error('qask demap requires input to be a matrix with even number of columns.');
    end
    x = []; I = I(:).'; Q = Q(:).';
    for i = 1 : 2 : wid_y
        [tmp, x_p] = min(((yy(:, i*ones(1, M)) - I(ones(1, len_y), :)).^2 + ...
            (yy(:, (i+1)*ones(1, M)) - Q(ones(1, len_y), :)).^2)');
        x = [x x_p'-1];
    end
elseif strncmpi(method, 'samp', 4)
    % This is for converting an input signal from sampling frequency Fs
    % to sampling frequency Fd.
    x = y([offset:FsDFd:len_y], :);
elseif strncmpi(method, 'eye', 3)
    % generate eye diagram (set offset to be the sample of of a symbol)
    eyediagram(y, FsDFd, 1, rem(offset-1+FsDFd,FsDFd));
elseif strncmpi(method, 'scat', 4)
    % generate scatterplot (set offset to be the sample of of a symbol)
    h = scatterplot(y, FsDFd, rem(offset-1+FsDFd,FsDFd));
else    % invalid method
    error(sprintf(['You have used an invalid method.\n',...
        'The method should be one of the following strings:\n',...
        '\t''ask'' Amplitude shift keying modulation;\n',...
        '\t''psk'' Phase shift keying modulation;\n',...
        '\t''qask'' Quadrature amplitude shift-keying modulation, square constellation;\n',...
        '\t''qask/cir'' Quadrature amplitude shift-keying modulation, circle constellation;\n',...
        '\t''qask/arb'' Quadrature amplitude shift-keying modulation, user defined constellation;\n',...
        '\t''fsk'' Frequency shift keying modulation;\n',...
        '\t''msk'' Minimum shift keying modulation;\n',...
        '\t''sample'' Convert sample frequency Fs input to sample frequency Fd output.']))
end

if r==1 & ~isempty(x)
    x = x.';
end

% [EOF]
