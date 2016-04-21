function varargout = amod(x, Fc, Fs, method, opt1, opt2, opt3)
%AMOD 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use AMMOD, FMMOD, PMMOD or SSBMOD instead.

%   Y = AMOD(X, Fc, Fs, METHOD...) modulates the message signal X
%   with carrier frequency Fc (Hz) and sample frequency Fs (Hz), 
%   where Fc > Fs. For information about METHOD and subsequent
%   parameters, and about using a specific modulation technique,
%   type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE     MODULATION TECHNIQUE
%     amod amdsb-tc        % Amplitude modulation, double sideband
%                          % with transmission carrier
%     amod amdsb-sc        % Amplitude modulation, double sideband
%                          % suppressed carrier
%     amod amssb           % Amplitude modulation, single sideband
%                          % suppressed carrier
%     amod qam             % Quadrature amplitude modulation
%     amod fm              % Frequency modulation
%     amod pm              % Phase modulation
%
%   For baseband simulation, use AMODCE.
%
%   See also ADEMOD, DMOD, DDEMOD, AMODCE, ADEMODCE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   This function calls amod.hlp for help.

error(nargoutchk(0,2,nargout));

opt_pos = 5;
if nargin < 1
    disp('Usage: Y=AMOD(X, Fc, Fs, METHOD, OPT1, OPT2, OPT3)');
    return;
elseif ischar(x) && nargin == 1
    % help lines for individual modulation method.
    method = deblank(x);
    if strcmp(method, 'am')
        method = 'amdsb-tc';
    end
    addition = 'See also ADEMOD, DMOD, DDEMOD, AMODCE, ADEMODCE.';
    callhelp('amod.hlp',method, addition);
    return;
elseif nargin < 3
    disp('Usage: Y=AMOD(X, Fc, Fs, METHOD, OPT1, OPT2, OPT3) for analog modulation');
    return;
elseif nargin < 4    
    method = 'am';
end

if length(Fs) < 2
    ini_phase = 0;
else
    ini_phase = Fs(2);
    Fs = Fs(1);
end

method = lower(method);

[r, c] = size(x);
if r*c == 0
    return;
end
if (r == 1)
    x = x(:);
end

%begin the calculation.
if strcmp(method, 'amdsb-sc')
    t = (0:1/Fs:((size(x,1)-1)/Fs))';
    t = t(:, ones(1, size(x, 2)));
    y = x .* cos(2 * pi * Fc * t + ini_phase);
elseif strcmp(method, 'amdsb-tc') || strcmp(method, 'am')
    if nargin < opt_pos
        opt1 = -min(min(x));
    end
    t = (0:1/Fs:((size(x, 1)-1)/Fs))';
    t = t(:, ones(1, size(x, 2)));
    y = (x + opt1) .* cos(2 * pi * Fc * t + ini_phase);
elseif strcmp(method, 'amssb') ||(strcmp(method,'amssb/up'))
    t = (0:1/Fs:((size(x,1)-1)/Fs))';
    t = t(:, ones(1, size(x, 2)));
    if nargin < opt_pos
        % do the Hilbert transform in frequence domain.
        if findstr(method, '/up')
            y = x .* cos(2 * pi * Fc * t + ini_phase) - ...
                imag(hilbert(x)) .* sin(2 * pi * Fc * t + ini_phase);    
        else
            y = x .* cos(2 * pi * Fc * t + ini_phase) + ...
                imag(hilbert(x)) .* sin(2 * pi * Fc * t + ini_phase);    
		end
		% handle the early return
		t = t(:, 1);
		if (r==1)
			y = y.';
			t = t.';
		end
		if nargout > 0
			varargout{1} = y;
		end
		if nargout > 1
			varargout{2} = t;
		end
        return;
    elseif nargin <= opt_pos
        [num, den] = hilbiir(1/Fs);
    else
        num = opt1;
        den = opt2;
    end
    y = x;
    for  i = 1 : size(x, 2)
        y(:,i) = filter(num, den, y(:,i));
    end
    if findstr(method, '/up')
        y = x .* cos(2 * pi * Fc * t + ini_phase) - ...
            y .* sin(2 * pi * Fc * t + ini_phase);
    else
        y = x .* cos(2 * pi * Fc * t + ini_phase) + ...
            y .* sin(2 * pi * Fc * t + ini_phase);
    end 
elseif strcmp(method, 'qam')
    if floor(c/2) ~= c/2
        error('Input signal for AMOD QAM must have an even number of columns.')
    end
    [len_x, wid_x] = size(x);
    if ceil(wid_x/2) ~= wid_x/2
        error('Input signal for AMOD QAM must have an even number of columns.')
    end
    t = (0:1/Fs:((size(x,1)-1)/Fs))';
    t = t(:, ones(1, wid_x/2));
    y = x(:, 1:2:wid_x) .* cos(2 * pi * Fc * t + ini_phase) + ...
        x(:, 2:2:wid_x) .* sin(2 * pi * Fc * t + ini_phase);
elseif strcmp(method, 'fm')
    if nargin >= opt_pos
        x = opt1 * x;
    end
    t = (0:1/Fs:((size(x,1)-1)/Fs))';
    t = t(:, ones(1, size(x, 2)));
    x = 2 / Fs * pi * x;
    x = [zeros(1, size(x, 2)); cumsum(x(1:size(x,1)-1, :))];
    y = cos(2 * pi * Fc * t + x + ini_phase);
elseif strcmp(method, 'pm')
    if nargin >= opt_pos
        x = opt1 * x;
    end
    t = (0:1/Fs:((size(x, 1)-1)/Fs))';
    t = t(:, ones(1, size(x, 2)));
    y = cos(2 * pi * Fc * t + x + ini_phase);
else
    % digital modulation, format changed to be
    % Y = AMOD(X, Fc, Fs, METHOD, Fd, M, OPT1, OPT2, OPT3);
    if nargin < 5
        M = max(max(x)) + 1;
        M = 2^(ceil(log(M)/log(2)));
        M = max(2, M);
    else
        M = opt1;
    end

    if nargin < 5
        ini_phase = 0;
    else
        ini_phase = opt1;
    end

    if strcmp(method, 'ask')
        x = (x - (M-1)/2)*2/(M-1);
        [y, t] = amod(x, Fc, Fs, 'amdsb-sc', ini_phase);
    elseif strcmp(method, 'psk')
        x = 2 * pi * x / M;
        [y, t] = amod(x, Fc, Fs, 'pm', ini_phase);
    elseif findstr(method, 'qask')
        if strcmp(method, 'qask')
            %plain square QASK style.
            [s1, s2] = qaskenco(M);
        elseif findstr(method, 'qask/cir')
            if nargin < opt_pos+1
                disp('Usage: Y = AMOD(X, Fc, Fs, ''qask/cir'', NIC, AIC, PIC).')
                return
            elseif nargin < opt_pos+2
                opt3 = 0;
            end
            NIC = M;
            AIC = ini_phase;
            PIC = opt2
            s1 = apkconst(NIC, AIC, PIC);
            s2=imag(s1);
            s1 = real(s1);
            ini_phase = opt3;
            M = sum(NIC);
        else
            s1 = M;
            s2 = ini_phase;
            if nargin < opt_pos
                disp('Usage: Y = AMOD(X, Fc, Fs, ''qask/arb'', In_Phase, Quad).')
            elseif nargin < opt_pos + 1
                opt2 = 0;
            end
            ini_phase = opt2;
            M = length(s1);
        end
        if min(min(x)) < 0
            error('The input signal for AMOD has an illegal element.');
        elseif max(max(x)) > M
            error('The input signal for AMOD has an element larger than given limit.');
        end
        x = x(:) + 1;
        y = amod([s1(x) s2(x)], Fc, Fs, 'qam', ini_phase);
    elseif strcmp(method, 'fsk')
        % M has been calculated
        % Fd = ini_phase (opt1)
        if nargin < opt_pos
            Fd = Fs / M;
        else
            Fd = opt1;
        end
        % Tone = opt2
        if nargin < opt_pos + 1
            Tone = 2 * Fd / M;
        else
            Tone = opt2;
        end
        % ini_phase = opt3
        if nargin < opt_pos + 2
            ini_phase = 0;
        else
            ini_phase = opt3;
        end
        % modulation map part.
        FsDFd = Fs/Fd;
        offset = 0;
        if length(Fd) > 1
           offset = rem(rem(Fd(2), FsDFd) + FsDFd, FsDFd);
        end
        x = x(:) * Tone;
        % analog modulation.
        y = [];
        len_x = length(x);
        mod_b = 1;
        mod_e = FsDFd;
        if offset > 0
            mod_e = offset;
        end
        while mod_b <= len_x
            y = [y; amod(x(mod_b:min(len_x, mod_e)), Fc, Fs, 'fm', ini_phase)];
            mod_b = mod_b + FsDFd;
            mod_e = mod_e + FsDFd;
        end
        t = (0:1/Fs:((size(x,1)-1)/Fs))';
        t = t(:, ones(1, size(x, 2)));
    elseif strcmp(method, 'msk')
        %msk is a special case of fsk, with M=2; Tone = Fd.
        M = 2;
        if nargin < opt_pos - 1
            Fd = Fs/2;
        else
            Fd = ini_phase;
        end
        if nargin < opt_pos
            ini_phase = 0;
        else
            ini_phase = opt1;
        end
        % it is a special case of fsk with M = 2 and Tone = Fd. 
        y = amod(x, Fc, Fs, 'fsk', ini_phase, 2, Fd, Fd, ini_phase);
    else
        %not match any one of them. Display error message.
        msg =sprintf(['Modulation method ', method, ' is not a legal option in function AMOD.',...
        '\rThe current available methods are:',...
        '\r  amdsb-tc   Amplitude modulation, double sideband with transmission carrier.',...
        '\r  amdsb-sc   Amplitude modulation, double sideband suppressed carrier.',...
        '\r  amssb      Amplitude modulation, single side band suppressed carrier.',...
        '\r  qam        Quadrature Amplitude modulation.',...
        '\r  pm         Phase modulation.',...
        '\r  fm         Frequency modulation.']);
		error(msg);
    end
end
t = t(:, 1);
if (r==1)
    y = y.';
    t = t.';
end

if nargout > 0
	varargout{1} = y;
end
if nargout > 1
	varargout{2} = t;
end

% [EOF]
