function y = modmap(x, Fd, Fs, method, M, opt2, opt3)
%MODMAP 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use SCATTERPLOT instead.

%
%   Plotting syntaxes:
%   MODMAP(METHOD...) plots the signal constellation associated with
%   the specified mapping method.
%
%   Mapping syntaxes:
%   Y = MODMAP(X, Fd, Fs, METHOD...) maps the digital signal X to
%   an analog signal Y. This syntax only maps; it does not modulate.
% 
%   More help for all syntaxes:
%   ---------------------------
%   For information about METHOD and subsequent parameters, and about
%   using a specific technique, type one of these commands at the MATLAB
%   prompt:
%
%   FOR DETAILS, TYPE     MAPPING/MODULATION TECHNIQUE
%     modmap ask          % M-ary amplitude shift keying 
%     modmap psk          % M-ary phase shift keying 
%     modmap qask         % M-ary quadrature amplitude shift keying
%     modmap fsk          % M-ary frequency shift keying 
%     modmap msk          % Minimum shift keying 
%
%   For digital modulation, use DMOD for passband simulation and
%   DMODCE for baseband simulation.
%
%   See also DEMODMAP, DMOD, DMODCE, AMOD, AMODCE, APKCONST.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

opt_pos = 5;        % position of 1st optional parameter
plot_const = 0;

if nargin < 1
    feval('help','modmap')
    return;
elseif isstr(x)
    if exist('method', 'var')
        tmp_sto = method;
    end
    method = lower(deblank(x));
    if findstr(method, 'samp')
        method = 'samp';
    end
    if nargin == 1
        % help lines for individual modulation method.
        if strcmp(method, '')
            method = 'ask';
        end
        hand = fopen('modmap.hlp');
        if hand<=0
            error('The Communications Toolbox on your computer is not completely installed.')
        else
            x = fscanf(hand, '%c', Inf);
            index_begin = findstr(x, [method,'_help_begin']);
            index_end = findstr(x, [method,'_help_end']);
            if index_end > index_begin
                x = x(index_begin+12+length(method):index_end-1);
                fprintf('%s', x);
                disp(' ')
                disp('    See also DEMODMAP, DMOD, DMODCE, AMOD, AMODCE, APKCONST.')
            else
                disp(['No help for ', method]);
            end
        end
        fclose(hand);
        return;
    else
        plot_const = 1;
        opt_pos = opt_pos - 3;
        M = Fd;
        if nargin > opt_pos
            opt2 = Fs;
        end
        if nargin > opt_pos+1
            opt3 = tmp_sto;
        end
    end
else
    if nargin < 3
        error('Usage: Y=MODMAP(X, Fd, Fs, METHOD, OPT1, OPT2, OPT3) for modulation mapping');
    elseif nargin < opt_pos-1
        method = 'sample';
    end

    if length(Fs)~=1 | ~isfinite(Fs) | ~isreal(Fs) | Fs<=0
        error('Fs must be a positive number.');
    elseif length(Fd)~=1 | ~isfinite(Fd) | ~isreal(Fd) | Fd<=0
        error('Fd must be a positive number.');
    else
        FsDFd = Fs / Fd;
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
    if ~(strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
         strncmpi(method, 'qsk', 3)) & ...
       (~isreal(x) | all(ceil(x)~=x) | any(any(x<0)) | any(any(x>M-1)))
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

method = lower(method);
if strncmpi(method, 'ask', 3)
    if plot_const
        plot([0 0], [-1.1 1.1], 'w-', [-1.1, 1.1], [0 0], 'w-', ([0:M-1] - (M - 1) / 2 ) * 2 / (M - 1), zeros(1, M), '*');
        axis([-1.1 1.1 -1.1 1.1])
        xlabel('In-phase component');
        title('ASK constellation')
    else
        y = (x - (M - 1) / 2 ) * 2 / (M - 1);
        if r==1 & ~isempty(y)
            y = y.';
        end
    end
elseif strncmpi(method, 'fsk', 3)
    if nargin < opt_pos + 1
        Tone = Fd;
    else
        Tone = opt2;
    end
    if plot_const
        maxTone = Tone*(M-1);
        x = [0 : Tone : maxTone];
        tmp = ones(1, M);
        tmp(1) = 2;
        stem(x, tmp);
        axis([-1, maxTone+1, 0, 2]);
        xlabel('Frequency (Hz)');
        title('FSK constellation');
    else
        y = x * Tone;
        if r==1 & ~isempty(y)
            y = y.';
        end
    end
elseif strncmpi(method, 'psk', 3)
    if plot_const
        apkconst(M);
    else
        y = modmap(x, Fs, Fs, 'qask/cir', M);
    end
elseif strncmpi(method, 'msk', 3)
    % This is a special case of fsk.
    if plot_const
        stem([0 Fd], [2 1]);
        axis([-1, Fd+1, 0, 2]);
        xlabel('Frequency (Hz)');
        title('MSK constellation');
    else
        M = 2;
        Tone = Fd/2;
        y = x * Tone;
        if r==1 & ~isempty(y)
            y = y.';
        end
    end
elseif ( strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
         strncmpi(method, 'qsk', 3) )
    if findstr(method, '/ar')   % arbitrary constellation
        if nargin < opt_pos + 1
            error('Incorrect format for METHOD=''qask/arbitrary''.');
        end
        I = M;
        Q = opt2;
        M = length(I);
        if plot_const
            axx = max(max(abs(I))) * [-1 1] + [-.1 .1];
            axy = max(max(abs(Q))) * [-1 1] + [-.1 .1];
            plot(I, Q, 'r*', axx, [0 0], 'w-', [0 0], axy, 'w-');
            axis('equal');
            axis('off');
            text(axx(1) + (axx(2) - axx(1))/4, axy(1) - (axy(2) - axy(1))/30, 'QASK Constellation');
            return;
        else
            % leave to the end for processing
        end
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
        if plot_const
            apkconst(NIC, AIC, PIC);
            return;
        else
            inx = apkconst(NIC, AIC, PIC);
            I = real(inx);
            Q = imag(inx);
            M = sum(NIC);
        end
    else    % square constellation
        if plot_const
            qaskenco(M);
            return;
        else
            [I, Q] = qaskenco(M);
        end
    end
    y = [];
    x = x + 1;
    if (min(min(x)) < 1)  | (max(max(x)) > M)
        error('An element in input X is outside the permitted range.');
    end
    for i = 1 : size(x, 2)
        tmp = I(x(:, i));
        y = [y tmp(:)];
        tmp = Q(x(:, i));
        y = [y tmp(:)];
    end
elseif strncmpi(method, 'samp', 4)
    %This is made possible to convert an input signal from sampling frequency Fd
    %to sampling frequency Fs.
    y = x;
	if r==1 & ~isempty(y)
		y = y.';
	end
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

% [EOF]

