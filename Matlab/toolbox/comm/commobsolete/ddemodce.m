function x = ddemodce(y, Fd, Fs, method, M, opt1, opt2, opt3, opt4)
%DDEMODCE
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use PAMDEMOD, QAMDEMOD, GENQAMDEMOD, FSKDEMOD, PSMDEMOD
%         MSKDEMOD instead.

%   Z = DDEMODCE(Y, Fd, Fs, METHOD...) demodulates the digital baseband
%   modulated signal Y with sample frequency Fd (Hz), and computation
%   sampling frequency Fs (Hz).  The ratio Fs/Fd must be a positive integer.
%   For information about METHOD and subsequent parameters, and about using
%   a specific demodulation technique, type one of these commands at the
%   MATLAB prompt:
%
%   FOR DETAILS, TYPE     DEMODULATION TECHNIQUE
%     ddemodce ask        % M-ary amplitude shift keying demodulation
%     ddemodce psk        % M-ary phase shift keying demodulation
%     ddemodce qask       % M-ary quadrature amplitude shift keying
%                         % demodulation
%     ddemodce fsk        % M-ary frequency shift keying demodulation
%     ddemodce msk        % Minimum shift keying demodulation
%     ddemodce sample     % Downsample Y without demodulating
%   
%   To plot signal constellations, use MODMAP.
%
%   See also DMODCE, AMODCE, ADEMODCE, DMOD, DDEMOD, DEMODMAP, MODMAP, 
%            EYEDIAGRAM, SCATTERPLOT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

opt_pos = 6;        % position of 1st optional parameter

if nargin < 1
    feval('help','ddemodce');
    return;
elseif isstr(y)
    method = lower(deblank(y));
    if length(method) < 3
        error('Invalid method option for DDEMODCE.')
    end
    if nargin == 1
        addition = ['See also DMODCE, AMODCE, ADEMODCE, DMOD, DDEMOD, DEMODMAP, MODMAP,',...
		            '\r             EYEDIAGRAM, SCATTERPLOT.'];
        addition = sprintf(addition);
        if method(1:3) == 'qas'
          callhelp('ddemodce.hlp', method(1:4), addition);
        else
          callhelp('ddemodce.hlp', method(1:3), addition);
        end
    else
        warning('Wrong number of input variables, use MODMAP for plotting constellations.');
    end
	return;
end

if nargin < 3
    error('Usage: Y = DDEMODCE(X, Fd, Fs, METHOD, OPT1, OPT2, OPT3) for modulation mapping.');
elseif (nargin < opt_pos  - 2)
    if nargout < 1
        method = 'eye';
    else
        method = 'sample';
    end
end

if length(Fs) > 1
    ini_phase = Fs(2);
    Fs = Fs(1);
else
    ini_phase = 0;      % default initial phase
end
if length(Fd) > 1
    offset = Fd(2);
    Fd = Fd(1);
else
    offset = 0;         % default timing offset
end

if ~isfinite(Fs) | ~isreal(Fs) | Fs<=0
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
if rem(len_y, FsDFd) ~= 0
    error('Number of samples in y must be an integer multiple of Fs/Fd.');
end

method = lower(method);
if strncmpi(method, 'ask', 3)
    % M has to be specified in 'ask' option.
    if nargin < opt_pos - 1
        error('Not enough input variables for DDEMODCE.')
    end
    
    index = ([0 : M - 1] - (M - 1) / 2) * 2 / (M - 1);
    if nargin < opt_pos
        num = 1;
        den = 1;
    else
        num = opt1;
        den = opt2;
    end
    if findstr(method, '/cos')
        y = ademodce(y, [Fs, ini_phase], 'amdsb-sc/costas', num, den);
    else
        y = ademodce(y, [Fs, ini_phase], 'amdsb-sc', num, den);
    end
    
    % Integrate to remove double freq component and replicate average 
    % over symbol
	sizey = size(y);
	y = integ(y, FsDFd, offset);
	y = repmat(y(:), 1, FsDFd);
	y  = reshape(y.', sizey(1), sizey(2));
	 
    if findstr(method, '/eye')
        ddemodce(y, [Fd, offset], [Fs, ini_phase], 'eye')
    end
    if findstr(method, '/sca')
        ddemodce(y, [Fd, offset], [Fs, ini_phase], 'sca')
    end
	if findstr(method, '/nomap')
        x = y;
    else
        x = demodmap(y, [Fd, offset], Fs, 'ask', M);
    end
elseif strncmpi(method, 'fsk', 3)
    if nargin < opt_pos
        Tone = Fd;
    else
        Tone = opt1;
    end
    if findstr(method, '/nomap')
        warning(sprintf(['The option ''/nomap'' does not apply to FSK demodulation.\n',...
		    '         The function will proceed ignoring the ''/nomap'' switch.']));
	end
    % calculate the correlation of fsk.
	[len_y, wid_y] = size(y);
	z = [-(M-1):2:(M-1)]  * Tone * pi / Fs;
	z = [ones(len_y, 1)]*z;
	z = cumsum(z);

	symbol_period=1/Fd;
	t = [0 : 1/Fs : symbol_period-1/Fs]';
	t = t(:, ones(1, M));

    x = real(y([offset+1 : FsDFd : len_y], :));

    if findstr(method, '/eye')
        clf;
        subplot(2, 1, 1);
        hold on;
        subplot(2, 1, 2);
        hold on;
    end
    [len_x, wid_x] = size(x);
    for i = 1 : wid_x
        comp_low = 1;
        if offset <= 0
            comp_upp = FsDFd;
        else
            comp_upp = offset;
        end
        for k = 1 : len_x
			if findstr(method, '/nonc')
    			z_temp  = exp(-j*z(1:FsDFd,:));
				corr = y(comp_low:comp_upp, i)*ones(1,M) .* z_temp;
			else
				z_temp  = exp(-j*(z(comp_low:comp_upp,:) + ini_phase));
				corr = y(comp_low:comp_upp, i)*ones(1,M) .* z_temp;
			end
            if findstr(method, '/eye')
                if findstr(method, '/nonc')
                    cor2 = (real(y(comp_low : comp_upp, i)) * ones(1, M)) .* real(zz(1 : comp_upp-comp_low + 1, :)) + ...
                        (imag(y(comp_low : comp_upp, i)) * ones(1, M)) .* imag(zz(1 : comp_upp-comp_low + 1, :));
                    corr = cumsum(corr).^2 + cumsum(cor2).^2;
                else
                    corr = cumsum(corr);
                end
                corr = corr / max(max(max(abs(corr))), eps);
                if k == 1
                    subplot(2, 1, 1);
                    plot(t(FsDFd-size(corr, 1)+1 : FsDFd)', real(corr));
                    subplot(2, 1, 2);
                    plot(t(FsDFd-size(corr, 1)+1 : FsDFd)', imag(corr));
                else
                    subplot(2, 1, 1);
                    plot(t(1:size(corr, 1))', real(corr));
                    subplot(2, 1, 2);
                    plot(t(1:size(corr, 1))', imag(corr));
                end
                corr = corr(size(corr, 1), :);
            else
				if findstr(method, '/nonc')
					corr = sum(real(corr)).^2 + sum(imag(corr)).^2;
				else 
					corr = sum(real(corr));
				end
            end
            [tmp_v, tmp_i] = max(corr);
            x(k, i) = tmp_i - 1;
            comp_low = min(comp_low + FsDFd, len_y);
            comp_upp = min(comp_upp + FsDFd, len_y);
        end
    end
elseif strncmpi(method, 'msk', 3)
	M = 2;
	symbol_period=1/Fd;
	t = [0 : 1/Fs : 1/Fd-1/Fs]';
		
	if findstr(method, '/nomap')
		warning(sprintf(['The option ''/nomap'' does not apply to MSK demodulation.\n',...
			'         The function will proceed ignoring the ''/nomap'' switch.']));
	end
	if findstr(method,'/noncoherence')
		warning(sprintf(['The option ''/noncoherence'' does not apply to MSK demodulation.\n',...
			'         The function will proceed ignoring the ''/noncoherence'' switch.']));
	end
	if findstr(method,'/eye')
		warning(sprintf(['The option ''/eye'' has not been implemented for MSK demodulation.\n',...
			'         The function will proceed ignoring the ''/eye'' switch.']));
	end
		
	x = y([offset+1 : FsDFd : len_y], :);
	[len_x, wid_x] = size(x);
		
	for i = 1 : wid_x
		comp_low = 1;
		if offset <= 0
			comp_upp = FsDFd;
		else
			comp_upp = offset;
		end
			
		% initial conditions for demodulator
		sigmanminus1=0;
		lambda0_prev=0;
		lambda1_prev=0;
			
		for k = 1 : len_x
			%
			% Based on algorithm provided by B. Rimoldi, 
			% "A Decomposition Approach to CPM," IEEE Transactions on Information Theory, 
			% Vol. 34, No. 2, March 1988
			%
			% MODIFIED FOR COMPLEX BASEBAND REPRESENTATION
			%
			% phiI and phiQ are from equations (22a) and (22b)
			phiI    =    sqrt(1/2)*exp(j*(-ini_phase+(t + (k-1)*symbol_period)*(1/2)*(pi/symbol_period)));
			% s0 is determined from Figure 7 for sigman=0 and Un=0
			% s1 is determined from Figure 7 for sigman=0 and Un=1
			s0      =    sqrt(1/symbol_period)*phiI;
			s1      =    sqrt(1/symbol_period)*phiI.*exp(-j*(pi*t/symbol_period));
				
			if findstr(method,'/eye')
				% lambda0 = cumsum(y(comp_low:comp_upp, i) .* s0(1:comp_upp-comp_low+1,:));
				% lambda1 = cumsum(y(comp_low:comp_upp, i) .* s0(1:comp_upp-comp_low+1,:));
				% lambda0 = lambda0/(max(max(max(abs(lambda0))),eps));
				% lambda1 = lambda1/(max(max(max(abs(lambda1))),eps));
				% if(k==1)
				%	plot(t(FsDFd-size(lambda0,1)+1:FsDFd)',lambda0,	t(FsDFd-size(lambda1,1)+1:FsDFd)',lambda1);
				% else
				% 	plot(t(1:size(lambda0,1))',lambda0,	t(1:size(lambda1,1))', lambda1);
				% end
				% lambda0=lambda0(size(lambda0,1),:); % last value
				% lambda1=lambda1(size(lambda1,1),:); % last value
			else					
				% lambda0 and lambda1 are defined by (26) for s0 and s1, respectively
				lambda0 = sum(y(comp_low:comp_upp, i) .* s0);
				lambda1 = sum(y(comp_low:comp_upp, i) .* s1);
				
				% decision rule is based on (34)
				if((lambda0_prev+lambda0)>(lambda1_prev-lambda1))
					sigman=0;
				else
					sigman=1;
				end
				
				lambda0_prev=lambda0;
				lambda1_prev=lambda1;
				
				% inverse of MSK state encoder {c.f., Fig. 11}
				un=mod(sigman-sigmanminus1,2);
				sigmanminus1=sigman;
				
				% one symbol delay because of Viterbi algorithm
				if(k>1)
					x(k-1, i) = un;
				end
				
				% suboptimum decision for last symbol
				if(k==len_x)
					if(lambda0>lambda1)
				    	x(k,i)=mod(0-sigmanminus1,2);
					else 
				    	x(k,i)=mod(1-sigmanminus1,2);
				   	end
				end
				
				comp_low = min(comp_low + FsDFd, len_y);
				comp_upp = min(comp_upp + FsDFd, len_y);
			end % whether plotting eye diagram
		end % through k symbols
	end % through all columns of x
elseif ( strncmpi(method, 'qask', 4) | strncmpi(method, 'qam', 3) |...
         strncmpi(method, 'qsk', 3) | strncmpi(method, 'psk', 3) )
    if findstr(method, '/ar')       % arbitrary constellation
        if nargin < opt_pos
            error('Incorrect format for METHOD=''qask/arbitrary''.');
        end
        I = M;
        Q = opt1;
        if nargin < opt_pos + 2
            num = 1;
            den = 1;
        else
            num = opt2;
            den = opt3;
        end
        M = length(I);
	elseif findstr(method, '/ci')   % multi-circular constellation
		if nargin < opt_pos - 1
		    error('Incorrect format for METHOD=''qask/cir''.');
		end
		NIC = M;
		M = length(NIC);
		if nargin < opt_pos
			AIC = [1 : M];
		else
			AIC = opt1;
		end
		if nargin < opt_pos + 1
			PIC = NIC * 0;
		else
			PIC = opt2;
		end
        if nargin < opt_pos + 3
            num = 1;
            den = 1;
        else
            num = opt3;
			den = opt4;
		end
		inx = apkconst(NIC, AIC, PIC);
		I = real(inx);
		Q = imag(inx);
		M = sum(NIC);
	elseif strncmpi(method, 'psk', 3)   % PSK
        if nargin < opt_pos - 1
            error('M-ary number must be specified for psk demap.');
        end
        NIC = M;
        AIC = [1 : M];
        PIC = 0;
        if nargin < opt_pos + 1
            num = 1;
            den = 1;
        else
            num = opt1;
            den = opt2;
        end
        inx = apkconst(NIC, AIC, PIC);
		I = real(inx);
		Q = imag(inx);
    else    % square constellation
        [I, Q] = qaskenco(M);
        if nargin < opt_pos + 1
            num = 1;
            den = 1;
        else
            num = opt1;
            den = opt2;
        end
    end
    y = ademodce(y, [Fs, ini_phase], 'qam', num, den);

    % Integrate to remove double freq component and replicate average 
    % over symbol
	sizey = size(y);
	y = integ(y, FsDFd, offset);
	y = repmat(y(:), 1, FsDFd);
	y  = reshape(y.', sizey(1), sizey(2)); 

    if findstr(method, '/eye')
        ddemodce(y, [Fd, offset], [Fs, ini_phase], 'eye')
    end
    if findstr(method, '/sca')
        ddemodce(y, [Fd, offset], [Fs, ini_phase], 'sca')
    end
    if findstr(method, '/nomap')
        x = y;
    else
        x = demodmap(y, [Fd offset], Fs, 'qask/arb', I, Q);
    end
elseif strncmpi(method, 'samp', 4)
    % This is for converting an input signal from sampling frequency Fd
    % to sampling frequency Fs.
	x = demodmap(y, [Fd, offset], Fs, 'sample');
elseif strncmpi(method, 'eye', 3)
    % generate eye diagram (set offset to be the sample of a symbol)
    eyediagram(y, FsDFd, 1, rem(offset-1+FsDFd,FsDFd));
elseif strncmpi(method, 'sca', 3)
    % generate scatterplot (set offset to be the sample of a symbol)
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
        '\t''sample'' Convert sample frequency Fd input to sample frequency Fs output.']));
end
	
if r==1 & ~isempty(x)
	x = x.';
end

%------------------------------------------------------------------
function y = integ(x, osr, offset)
%INTEG Integrator.
%   INTEG integrates the analog demodulated signal x for 1 symbol period,
%   then output 1 value into y. osr is the oversampling rate (number of 
%   samples for 1 symbol). offset is the timing offset (starting point of
%   integration).

[xRow, xCol] = size(x);

% Shift x upward due to timing offset
x = [x((offset+1):end, :); zeros(offset, xCol)];

% Integration & dump = taking mean value of samples of each symbol
x = mean(reshape(x, osr, xRow*xCol/osr), 1);
    
y = reshape(x, xRow/osr, xCol);

% [EOF]
