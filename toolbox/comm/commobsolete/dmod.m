function [y, t] = dmod(x, Fc, Fd, Fs, method, M, opt2, opt3)
%DMOD 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use PAMMOD, QAMMOD, GENQAMMOD, FSKMOD, PSMMOD
%         MSKMOD instead.

%   Y = DMOD(X, Fc, Fd, Fs, METHOD...) modulates the message signal X
%   with carrier frequency Fc (Hz) and symbol frequency Fd (Hz).  The
%   sample frequency of Y is Fs (Hz), where Fs > Fc and where Fs/Fd is
%   a positive integer. For information about METHOD and subsequent
%   parameters, and about using a specific modulation technique,
%   type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE     MODULATION TECHNIQUE
%     dmod ask            % M-ary amplitude shift keying modulation
%     dmod psk            % M-ary phase shift keying modulation
%     dmod qask           % M-ary quadrature amplitude shift keying
%                         % modulation
%     dmod fsk            % M-ary frequency shift keying modulation
%     dmod msk            % Minimum shift keying modulation
%   
%   For baseband simulation, use DMODCE.  To plot signal constellations,
%   use MODMAP.
%
%   See also DDEMOD, DMODCE, DDEMODCE, MODMAP, AMOD, ADEMOD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

opt_pos = 6;        % position of 1st optional parameter

if nargout > 0
   y = []; t = [];
end
if nargin < 1
    feval('help','dmod')
    return;
elseif isstr(x)
    method = lower(deblank(x));
    if length(method) < 3
        error('Invalid method option for DMOD.')
    end
    if nargin == 1
        % help lines for individual modulation method.
        addition = 'See also DDEMOD, DMODCE, DDEMODCE, MODMAP, AMOD, ADEMOD.';
        if method(1:3) == 'qas'
          callhelp('dmod.hlp', method(1:4), addition);
        else
          callhelp('dmod.hlp', method(1:3), addition);
        end
    else
        % plot constellation, make a shift.
        opt_pos = opt_pos - 3;
        M = Fc;
        if nargin >= opt_pos
            opt2 = Fd;
        else
            modmap(method, M);
            return;
        end
        if nargin >= opt_pos+1
            opt3 = Fs;
        else
            modmap(method, M, opt2);
            return;
        end
        modmap(method, M, opt2, opt3);  % plot constellation
    end
    return;
end

if (nargin < 4)
    error('Usage: Y = DMOD(X, Fc, Fd, Fs, METHOD, OPT1, OPT2, OPT3) for passband modulation');
elseif nargin < opt_pos-1
    method = 'samp';
else
    method = lower(method);
end

len_x = length(x);
if length(Fs) > 1
    ini_phase = Fs(2);
    Fs = Fs(1);
else
    ini_phase = 0;      % default initial phase
end

if ~isfinite(Fs) | ~isreal(Fs) | Fs<=0
    error('Fs must be a positive number.');
elseif length(Fd)~=1 | ~isfinite(Fd) | ~isreal(Fd) | Fd<=0
    error('Fd must be a positive number.');
else
    FsDFd = Fs/Fd;      % oversampling rate
    if ceil(FsDFd) ~= FsDFd
        error('Fs/Fd must be a positive integer.');
    end
end
if length(Fc) ~= 1 | ~isfinite(Fc) | ~isreal(Fc) | Fc <= 0
    error('Fc must be a positive number. For baseband modulation, use DMODCE.');
elseif Fs/Fc < 2
    warning('Fs/Fc must be much larger than 2 for accurate simulation.');
end

% determine M
if isempty(findstr(method, '/arb')) & isempty(findstr(method, '/cir'))
    if nargin < opt_pos
        M = max(max(x)) + 1;
        M = 2^(ceil(log(M)/log(2)));
        M = max(2, M);
    elseif length(M) ~= 1 | ~isfinite(M) | ~isreal(M) | M <= 0 | ceil(M) ~= M
        error('Alphabet size M must be a positive integer.');
    end
end

if isempty(x)
    y = [];
    return;
end
[r, c] = size(x);
if r == 1
    x = x(:);
    len_x = c;
else
    len_x = r;
end

% expand x from Fd to Fs.
if isempty(findstr(method, '/nomap'))
    if ~isreal(x) | all(ceil(x)~=x)
        error('Elements of input X must be integers in [0, M-1].');
    end
    yy = [];
    for i = 1 : size(x, 2)
        tmp = x(:, ones(1, FsDFd)*i)';
        yy = [yy tmp(:)];
    end
    x = yy;
    clear yy tmp;
end

if strncmpi(method, 'ask', 3)
    if isempty(findstr(method, '/nomap'))
        % --- Check that the data does not exceed the limits defined by M
        if (min(min(x)) < 0)  | (max(max(x)) > (M-1))
           error('An element in input X is outside the permitted range.');
        end
        y = (x - (M - 1) / 2 ) * 2 / (M - 1);
    else
        y = x;
    end
    [y, t] = amod(y, Fc, [Fs, ini_phase], 'amdsb-sc');
elseif strncmpi(method, 'fsk', 3)
    if nargin < opt_pos + 1
        Tone = Fd;
    else
        Tone = opt2;
    end
        
    if (min(min(x)) < 0)  | (max(max(x)) > (M-1))
       error('An element in input X is outside the permitted range.');
    end
    
    [len_y, wid_y] = size(x);
    t = (0:1/Fs:((len_y-1)/Fs))';   % column vector with all the time samples
    t = t(:, ones(1, wid_y));       % replicate time vector for multi-channel operation

 	osc_freqs = pi*[-(M-1):2:(M-1)]*Tone;
	osc_output = (0:1/Fs:((len_y-1)/Fs))'*osc_freqs;  
    
    mod_phase = zeros(size(x))+ini_phase;
    for index = 1:M
    	mod_phase = mod_phase + (osc_output(:,index)*ones(1,wid_y)).*(x==index-1);
	end
	y = cos(2*pi*Fc*t+mod_phase);
elseif strncmpi(method, 'psk', 3)
    % PSK is a special case of QASK.
    [len_y, wid_y] = size(x);
    t = (0:1/Fs:((len_y-1)/Fs))';
    if findstr(method, '/nomap')
        y = dmod(x, Fc, Fs, [Fs, ini_phase], 'qask/cir/nomap', M);
    else
        y = dmod(x, Fc, Fs, [Fs, ini_phase], 'qask/cir', M);
    end
elseif strncmpi(method, 'msk', 3)
    M = 2;
    Tone = Fd/2;
    if isempty(findstr(method, '/nomap'))
        % Check that the data is binary
        if (min(min(x)) < 0)  | (max(max(x)) > (1))
           error('An element in input X is outside the permitted range.');
        end
        x = (x-1/2) * Tone;
    end
    [len_y, wid_y] = size(x);
    t = (0:1/Fs:((len_y-1)/Fs))';     % column vector with all the time samples
    t = t(:, ones(1, wid_y));       % replicate time vector for multi-channel operation
    x = 2 * pi * x / Fs;            % scale the input frequency vector by the sampling frequency to find the incremental phase
	x = [0; x(1:end-1)];
    y = cos(2*pi*Fc*t+cumsum(x)+ini_phase);
elseif (strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
         strncmpi(method, 'qsk', 3) )
    if findstr(method,'nomap')
        [y, t] = amod(x, Fc, [Fs, ini_phase], 'qam');
    else
        if findstr(method, '/ar')       % arbitrary constellation
            if nargin < opt_pos + 1
                error('Incorrect format for METHOD=''qask/arbitrary''.');
            end
            I = M;
            Q = opt2;
            M = length(I);
            % leave to the end for processing
            CMPLEX = I + j*Q;
        elseif findstr(method, '/ci')   % circular constellation
            if nargin < opt_pos
                error('Incorrect format for METHOD=''qask/circle''.');
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
            CMPLEX = apkconst(NIC, AIC, PIC);
            M = sum(NIC);
        else    % square constellation
            [I, Q] = qaskenco(M);
            CMPLEX = I + j * Q;
        end
        y = [];
        x = x + 1;
        % --- Check that the data does not exceed the limits defined by M
        if (min(min(x)) < 1) | (max(max(x)) > M)
            error('An element in input X is outside the permitted range.');
        end
        for i = 1 : size(x, 2)
            tmp = CMPLEX(x(:, i));
            y = [y tmp(:)];
        end
        ind_y = [1: size(y, 2)]';
        ind_y = [ind_y, ind_y+size(y, 2)]';
        ind_y = ind_y(:);
        y = [real(y) imag(y)];
        y = y(:, ind_y);
        [y, t] = amod(y, Fc, [Fs, ini_phase], 'qam');
    end
elseif strncmpi(method, 'samp', 4)
    % This is for converting an input signal from sampling frequency Fd
    % to sampling frequency Fs.
    [len_y, wid_y] = size(x);
    t = (0:1/Fs:((len_y-1)/Fs))';
    y = x;
else    % invalid method
	error(sprintf(['You have used an invalid method.\n',...
        'The method should be one of the following strings:\n',...
        '\t''ask'' Amplitude shift keying modulation;\n',...
        '\t''psk'' Phase shift keying modulation;\n',...
        '\t''qask'' Quadrature amplitude shift-keying modulation, square constellation;\n',...
        '\t''qask/cir'' Quadrature amplitude shift-keying modulation, circle constellation;\n',...
        '\t''qask/arb'' Quadrature amplitude shift-keying modulation, user defined constellation;\n',...
        '\t''fsk'' Frequency shift keying modulation;\n',...
        '\t''msk'' Minimum shift keying modulation.']));
end

if r==1 & ~isempty(y)
    y = y.';
end

% [EOF]
