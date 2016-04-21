function x  = ademod(y, Fc, Fs, method, opt1, opt2, opt3, opt4, opt5)
%ADEMOD 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use AMDEMOD, FMDEMOD, PMDEMOD or SSBDEMOD instead.

%   Z = ADEMOD(Y, Fc, Fs, METHOD...) demodulates the modulated signal Y
%   with carrier frequency Fc (Hz) and sample frequency Fs (Hz), where
%   Fc > Fs. For information about METHOD and subsequent parameters, and
%   about using a specific demodulation technique, type one of these
%   commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE      DEMODULATION TECHNIQUE
%     ademod amdsb-tc      % Amplitude demodulation, double sideband
%                          % with transmission carrier
%     ademod amdsb-sc      % Amplitude demodulation, double sideband
%                          % suppressed carrier
%     ademod amssb         % Amplitude demodulation, single sideband
%                          % suppressed carrier
%     ademod qam           % Quadrature amplitude demodulation
%     ademod fm            % Frequency demodulation
%     ademod pm            % Phase demodulation
%
%   See also AMOD, DMOD, DDEMOD, AMODCE, ADEMODCE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   This function calls ademod.help for further help.

opt_pos = 5;
if nargin < 1
    disp('Usage: Z = ADEMOD(Y, Fc, Fs, METHOD, OPT1, OPT2, OPT3, OPT4, OPT5)');
    return;
elseif isstr(y) & nargin == 1
    % help lines for individual modulation method.
    method = deblank(y);
    if strcmp(method, 'am')
        method = 'amdsb-tc';
    end;
    addition = 'See also AMOD, DMOD, DDEMOD, AMODCE, ADEMODCE.';
    callhelp('ademod.hlp',method, addition);
    return;
end;
if nargin < 4
    disp('Usage: Z = ADEMOD(Y, Fc, Fs, METHOD, INI_PHASE, NUM, DEN, OPT1, OPT2, OPT3');
    return;
end;

method = lower(method);

[r, c] = size(y);
if r*c == 0
    y = [];
    return;
end;
if (r == 1)
    y = y(:);
    len = c;
else
    len = r;
end;

pi2 = 2 * pi;

if length(Fs) < 2
    ini_phase = 0;
else
    ini_phase = Fs(2);
    Fs = Fs(1);
end;

%begin the processing
%process amdsb-sc and amdsb-tc, am is the same as amdsb-tc.
if ~isempty(findstr(method, 'amdsb')) | ...
        ((length(method)==2) & strcmp(method(1:2), 'am')) | ...
        ~isempty(findstr(method, 'am/'))
    if findstr(method, 'amdsb-sc')
        if nargin < opt_pos+1
            [num,den] = butter(5, Fc*2/Fs);
        else
            num = opt1;
            den = opt2;
        end;
    else
        if nargin < opt_pos + 2
            [num,den] = butter(5, Fc*2/Fs);
        else
            num = opt2;
            den = opt3;
        end;
    end;
    if findstr(method, 'costas');
        %pre-process the filter.
        if abs(den(1)) < eps
            error('First denominator filter coefficient must be non-zero.');
        else
            num = num/den(1);
            if (length(den) > 1)
                den = - den(2:length(den)) / den(1);
            else
                den = 0;
            end;
            num = num(:)';
            den = den(:)';
        end;
        len_den = length(den);
        len_num = length(num);

        y = y * 2;
        for ii = 1:size(y,2)
            z1 = zeros(length(den), 1);
            z2 = z1;
            z3 = z1;
            s1 = zeros(len_num, 1);
            s2 = s1;
            s3=s1;
            intgl = 0;

            for i = 1:size(y,1);
                %beginning from the integration value.
                fm_out_i = cos(pi2 * intgl + ini_phase);
                fm_out_q = -sin(pi2 * intgl + ini_phase);
                s1 = [y(i, ii)*fm_out_i; s1(1:len_num-1)];
                s2 = [y(i, ii)*fm_out_q; s2(1:len_num-1)];
                x(i, ii) = num * s1 + den * z1;
                z1 = [x(i, ii); z1(1:len_den-1)];
                z2 = [num*s2+den*z2; z2(1:len_den-1)];
                s3 = [z1(1)*z2(1); s3(1:len_num-1)];
                z3 = [num*s3+den*z3; z3(1:len_den-1)];
                intgl = rem((z3(1) + Fc)/Fs + intgl, 1);
            end;
        end;
    else
        t = (0 : 1/Fs :(len-1)/Fs)';
        t = t(:, ones(1, size(y, 2)));
        x = y .* cos(pi2 * Fc * t + ini_phase);
        for i = 1 : size(y, 2)
            x(:, i) = filter(num, den, x(:, i)) * 2;
        end;
    end;
    if findstr(method, 'amdsb-tc')
        if ( nargin >= opt_pos & ~isempty(opt1) )
            for i = 1 : size(x, 2)
                x(:, i) = x(:, i) - opt1(min(length(opt1), i));
	    	end
        else
            for i = 1 : size(x, 2)
                x(:, i) = x(:, i) - mean(x(:, i));
            end
        end;
    end;
elseif strcmp(method, 'amssb')
    if nargin < opt_pos+1
        [num, den] = butter(5, Fc * 2 / Fs);
    else
        num = opt1;
        den = opt2;
    end;
    t = (0 : 1/Fs :(len-1)/Fs)';
    t = t(:, ones(1, size(y, 2)));
    x = y .* cos(pi2 * Fc * t + ini_phase);
    for i = 1 : size(y, 2)
        x(:, i) = filter(num, den, x(:, i)) * 2;
    end;
elseif strcmp(method, 'qam')
    if nargin < opt_pos+1
        [num, den] = butter(5, Fc * 2 / Fs);
    else
        num = opt1;
        den = opt2;
    end;
    t = (0 : 1/Fs :(len-1)/Fs)';
    t = t(:, ones(1, size(y, 2)));
    x = [y .* cos(pi2 * Fc * t + ini_phase) y.*sin(pi2*Fc*t + ini_phase)];
    wid_x = size(x, 2);
    tmp = [1:wid_x/2;wid_x/2+1:wid_x];
    tmp = tmp(:);
    x = x(:,tmp);
    for i = 1 : wid_x
        x(:, i) = filter(num, den, x(:, i)) * 2;
    end;
elseif strcmp(method, 'fm') | strcmp(method, 'pm')
    is_fm = strcmp(method, 'fm');
    if nargin < opt_pos+1
        [num, den] = butter(5, Fc * 2 / Fs);
    else
        num = opt1;
        den = opt2;
    end;
    if isempty(num)
        [num, den] = butter(5, Fc * 2 / Fs);
    end;
    if nargin > opt_pos+1
        vcoConst = opt3;
    else
        vcoConst = 1;
    end;
    ini_phase = ini_phase + pi/2;
    %pre-process the filter.
    if abs(den(1)) < eps
        error('First denominator filter coefficient must be non-zero.');
    else
        num = num/den(1);
        if (length(den) > 1)
            den = - den(2:length(den)) / den(1);
        else
            den = 0;
        end;
        num = num(:)';
        den = den(:)';
    end;
    len_den = length(den);
    len_num = length(num);

    x = y;
    y = 2 * y;
    for ii = 1 : size(y, 2)
        z1 = zeros(length(den), 1);
        s1 = zeros(len_num, 1);
        intgl = 0;

        memo = 0;
        for i = 1:size(y, 1)
            %start with the zero-initial condition integer.
            vco_out = cos(pi2 * intgl + ini_phase);
            if len_num > 1
                s1 = [y(i, ii) * vco_out; s1(1:len_num-1)];
            else
                s1 = y(i, ii);
            end
            tmp = num * s1 + den * z1;
            if len_den > 1
                z1 = [tmp; z1(1:len_den-1)];
            else
                z1 = tmp;
            end;
            %intg1 is the output of the integrator (vcoConst/s) in the VCO block
            intgl = rem(((tmp*vcoConst + Fc)/ Fs + intgl), 1);
            if is_fm
                x(i, ii) = tmp;
            else
                memo = memo + tmp * vcoConst / Fs; %vcoConst also acts as a final gain here
                x(i, ii) = memo * pi2;
            end;
        end;
    end;
else
    error(['Method ', method, ' is not a legal option in function ADEMOD.']);
end;

if (r == 1)
    x = x.';
end;
