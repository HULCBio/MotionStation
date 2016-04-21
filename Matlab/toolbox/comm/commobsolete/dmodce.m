function y = dmodce(x, Fd, Fs, method, M, opt2, opt3)
%DMODCE 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use PAMMOD, QAMMOD, GENQAMMOD, FSKMOD, PSKMOD, or
%         MSKMOD instead.

%   Y = DMODCE(X, Fd, Fs, METHOD...) outputs the complex envelope
%   of a digital modulated signal.  The sample frequency of the
%   message signal X is Fd (Hz) and the sample frequency of Y is
%   Fs (Hz), where Fs/Fd is a positive integer. For information
%   about METHOD and subsequent parameters, and about using a
%   specific modulation technique, type one of these commands at
%   the MATLAB prompt:
%
%   FOR DETAILS, TYPE     MODULATION TECHNIQUE
%     dmodce ask          % M-ary amplitude shift keying modulation
%     dmodce psk          % M-ary phase shift keying modulation
%     dmodce qask         % M-ary quadrature amplitude shift keying
%                         % modulation
%     dmodce fsk          % M-ary frequency shift keying modulation
%     dmodce msk          % Minimum shift keying modulation
%   
%   To plot signal constellations, use MODMAP.
%
%   See also DDEMODCE, DMOD, DDEMOD, AMOD, AMODCE, MODMAP, APKCONST.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

opt_pos = 5;    % position of 1st optional parameter
plot_const = 0;

if nargin < 1
    feval('help','dmodce');
    return;
elseif isstr(x)
    if exist('method', 'var')
        % Save the 4th input before it's changed by lower and deblank.
        % For plotting constellation.
        opt3 = method;
    end
    method = lower(deblank(x));
    if length(method) < 3
        error('Invalid method option for DMODCE.');
    end
    if nargin == 1
        % help lines for individual modulation method.
        addition = 'See also DDEMODCE, DMOD, DDEMOD, AMOD, AMODCE, MODMAP, APKCONST.';
        if method(1:3) == 'qas'
          callhelp('dmodce.hlp',method(1:4),addition);
        else
          callhelp('dmodce.hlp',method(1:3),addition);
        end
        return;
    else
        plot_const = 1;
        opt_pos = opt_pos - 3;
        M = Fd;
        if nargin > opt_pos
            opt2 = Fs;
        end
    end
else
    if (nargin < 3)
        error('Usage: Y = DMODCE(X, Fd, Fs, METHOD, OPT1, OPT2, OPT3) for modulation mapping.');
    elseif nargin < opt_pos-1
        method = 'samp';
    end
    
    len_x = length(x);
    if length(Fs) > 1
        ini_phase = Fs(2);
        Fs = Fs(1);
    else
        ini_phase = 0;
    end
    
    if ~isfinite(Fs) | ~isreal(Fs) | Fs<=0
        error('Fs must be a positive number.');
    elseif length(Fd)~=1 | ~isfinite(Fd) | ~isreal(Fd) | Fd<=0
        error('Fd must be a positive number.');
    else
        FsDFd = Fs / Fd;    % oversampling rate
        if ceil(FsDFd) ~= FsDFd
            error('Fs/Fd must be a positive integer.');
        end
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
end

method = lower(method);
if strncmpi(method, 'ask', 3)
    if plot_const
        plot([0 0], [-1.1 1.1], 'w-', [-1.1, 1.1], [0 0], 'w-', ([0:M-1] - (M - 1) / 2 ) * 2 / (M - 1), zeros(1, M), '*');
        axis([-1.1 1.1 -1.1 1.1])
        xlabel('In-phase component');
        title('ASK constellation')
    else
        if isempty(findstr(method, '/nomap'))
            % --- Check that the data does not exceed the limits defined by M
            if (min(min(x)) < 0)  | (max(max(x)) > (M-1))
                error('An element in input X is outside the permitted range.');
            end
            y = (x - (M - 1) / 2 ) * 2 / (M - 1);
        else
            y = x;
        end
        if ini_phase
            y = y * exp(j * ini_phase);
		else
	        y = complex(y,0);
		end	
	end
elseif strncmpi(method, 'fsk', 3)
    if nargin < opt_pos + 1
        Tone = Fd;
    else
        Tone = opt2;
    end
    if plot_const
        modmap('fsk', M, Tone);  % plot spectrum
    else
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
        y = exp(j*mod_phase);
    end
elseif strncmpi(method, 'psk', 3)
    if plot_const
        apkconst(M);    % plot constellation
    else
       if isempty(findstr(method, '/nomap'))
            method = 'qask/cir';
        else
            method = 'qask/cir/nomap';
        end
        y = dmodce(x, Fs, [Fs, ini_phase], method, M, 1, 0);
    end
elseif strncmpi(method, 'msk', 3)
    if plot_const
        modmap('msk', Fd);  % plot spectrum
    else
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
        t = (0:1/Fs:((len_y-1)/Fs))';   % column vector with all the time samples
        t = t(:, ones(1, wid_y));       % replicate time vector for multi-channel operation
        x = 2 * pi * x / Fs;            % scale the input frequency vector by the sampling frequency to find the incremental phase
        x = [zeros(1,size(x,2)); x(1:end-1,:)]; % initialize so that ini_phase really is the initial phase
        y = exp(j*(cumsum(x)+ini_phase));
    end
elseif ( strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
		strncmpi(method, 'qsk', 3) )
	if findstr(method, '/nomap')
		y = amodce(x, [Fs, ini_phase], 'qam');
	else
		if findstr(method, '/ar')   % arbitrary constellation
			if nargin < opt_pos + 1
				error('Incorrect format for METHOD=''qask/arb''.');
			end
			I = M;
			Q = opt2;
			M = length(I);
			if plot_const
				axx = max(max(abs(I))) * [-1 1] + [-.1 .1];
				axy = max(max(abs(Q))) * [-1 1] + [-.1 .1];
				plot(I, Q, 'r*', axx, [0 0], 'w-', [0 0], axy, 'w-');
				axis('equal')
				axis('off');
				text(axx(1) + (axx(2) - axx(1))/4, axy(1) - (axy(2) - axy(1))/30, 'QASK Constellation');
				return;
			else
				% leave to the end for processing
				CMPLEX = I + j*Q;
			end
		elseif findstr(method, '/ci')   % circular constellation
			if nargin < opt_pos
				error('Incorrect format for METHOD=''qask/cir''.');
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
			if plot_const
				apkconst(NIC, AIC, PIC);
				return;
			else
				CMPLEX = apkconst(NIC, AIC, PIC);
				M = sum(NIC);
			end
		else    % square constellation
			if plot_const
				qaskenco(M);
				return;
			else
				[I, Q] = qaskenco(M);
				CMPLEX = I + j * Q;
			end
		end
		y = [];
		x = x + 1;
		if (min(min(x)) < 1)  | (max(max(x)) > M)
			error('An element in input X is outside the permitted range.');
		end
		for i = 1 : size(x, 2)
			tmp = CMPLEX(x(:, i));
			y = [y tmp(:)];
		end; 
		if ini_phase
			y = y * exp(j * ini_phase);
		end
	end
elseif strncmpi(method, 'samp', 4)
	%This is made possible to convert an input signal from sampling frequency Fd
    %to sampling frequency Fs.
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

if plot_const==0 & r==1 & ~isempty(y)
    y = y.';
end
	
% [EOF]
