function x = ademodce(y, Fs, method, opt1, opt2, opt3)
%ADEMODCE 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use AMDEMOD, FMDEMOD, PMDEMOD or SSBDEMOD instead.

%   Z = ADEMODCE(Y, Fs, METHOD...) demodulates the complex envelope Y
%   of a modulated signal.  The sample frequency of Y is Fs (Hz).
%   For information about METHOD and subsequent parameters, and about
%   using a specific demodulation technique, type one of these commands
%   at the MATLAB prompt:
%
%   FOR DETAILS, TYPE     DEMODULATION TECHNIQUE
%     ademodce amdsb-tc    % Amplitude demodulation, double sideband
%                          % with transmission carrier
%     ademodce amdsb-sc    % Amplitude demodulation, double sideband
%                          % suppressed carrier
%     ademodce amssb       % Amplitude demodulation, single sideband
%                          % suppressed carrier
%     ademodce qam         % Quadrature amplitude demodulation
%     ademodce fm          % Frequency demodulation
%     ademodce pm          % Phase demodulation
%
%   See also AMODCE, DMODCE, DDEMODCE, AMOD, ADEMOD.

%       Copyright 1996-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.3 $
%       This function calls ademodce.hlp for further help.

error(nargchk(1,6,nargin));

if isstr(y) & nargin == 1
    method = deblank(y);
    if strcmp(method, 'am')
        method = 'amdsb-tc';
    end;
    addition = 'See also AMODCE, DMODCE, DDEMODCE, AMOD, ADEMOD.';
    callhelp('ademodce.hlp',method, addition);
    return;
end;
[r, c] = size(y);
if r * c == 0
    x = [];
    return;
end;
if r == 1
    y = y(:);
    len_y = c;
else
    len_y = r;
end;

if nargin < 3
    feval('help','ademodce')
    return;
end;

opt_pos = 4; %opt1 start at position 4

if length(Fs) >= 2
    ini_phase = Fs(2);
    Fs = Fs(1);
else
    ini_phase = 0;
    if length(Fs) < 1
        Fs = 1;
    end
end
samp_time = 1/Fs;

method = lower(method);

%begin the processing
%process amdsb-sc and amdsb-tc, am is the same as amdsb-sc.
if ~isempty(findstr(method, 'amdsb')) | ...
        ((length(method)==2) & strcmp(method(1:2), 'am')) | ...
        ~isempty(findstr(method, 'am/'))
    if findstr(method, 'amdsb-sc')
        if nargin > opt_pos
            num = opt1;
            den = opt2;
            flt_flg = 1;
        else
            num = 1;
            den = 1;
            flt_flg = 0;
        end
    else
        if nargin > opt_pos+1
            num = opt2;
            den = opt3;
            flt_flg = 1;
        else
            num = 1;
            den = 1;
            flt_flg = 0;
        end
    end;
    if findstr(method, 'costas');
        % costas method. reference to SIMULINK block diagram for the algorithm.
        %pre-process the filter.
        if abs(den(1)) < eps
            error('The first coefficient in the denominator of the filter must be non-zero.');
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

        x = real(y);
        for k = 1 : size(x, 2)
            z1 = zeros(length(den), 1);
            z2 = z1;
            z3 = z1;
            s1 = zeros(len_num, 1);
            s2 = s1;
            s3=s1;
            intgl = 0;
            fm_out = 1; %at initial point, fm_out = exp(j*0) = 1;

            for i = 1 : size(x, 1);
                tmp = y(i, k) * fm_out;
                s1 = [real(tmp); s1(1:len_num-1)];
                s2 = [imag(tmp); s2(1:len_num-1)];
                x(i, k) = num * s1 + den * z1;
                z1 = [x(i, k); z1(1:len_den-1)];
                z2 = [num*s2+den*z2; z2(1:len_den-1)];
                s3 = [z1(1)*z2(1); s3(1:len_num-1)];
                z3 = [num*s3+den*z3; z3(1:len_den-1)];
                intgl = z3(1) * samp_time + intgl;
                fm_out = exp(-j*(intgl*2*pi+ini_phase));
            end;
        end;
    else
        x = real(y * exp(-j * ini_phase));
        if flt_flg
            for i = 1 : size(x, 2)
                x(:, i) = filter(num, den, x(:, i));
            end;
        end
    end;
    if findstr(method, 'amdsb-tc')
        if (nargin >= opt_pos) & ~isempty(opt1)
            for i = 1 : size(x, 2)
                x(:, i) = x(:, i) - opt1(min(length(opt1), i));
            end;
        else
            for i = 1 : size(x, 2)
                x(:, i) = x(:, i) - mean(x(:, i));
            end;
        end;
    end;
elseif strcmp(method, 'amssb')
    y = y * exp(-j * ini_phase);
    x = real(y);
    if nargin > opt_pos
        num = opt1;
        den = opt2;
        for i = 1 : size(x, 2)
            x(:, i) = filter(num,den, x(:, i));
        end
    end;
elseif strcmp(method, 'qam')
    y = y * exp(-j * ini_phase);
    x = [];
    if nargin > opt_pos
        num = opt1;
        den = opt2;
        for i = 1 : size(y, 2)
            x = [x filter(num,den, real(y(:, i))) filter(num, den, imag(y(:, i)))];
        end;
    else
        for i = 1 : size(y, 2)
            x = [x real(y(:, i)) imag(y(:, i))];
        end;
    end;
elseif strcmp(method, 'fm') | strcmp(method, 'pm')
    is_fm = strcmp(method, 'fm');

    switch nargin-3
       case 0,
          num  = 1;
          den  = 1;
          gain = 1;
       case 1,
          num  = 1;
          den  = 1;
          gain = opt1;
       case 2,
          num  = opt1;
          den  = opt2;
          gain = 1;
       case 3,
          num  = opt1;
          den  = opt2;
          gain = opt3;
    end

    %pre-process the filter.
    if abs(den(1)) < eps
        error('The first coefficient in the denominator of the filter must be non-zero.');
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

    x = real(y);

    for k = 1 : size(x, 2)
        z1 = zeros(length(den), 1);
        s1 = zeros(len_num, 1);
        intgl = 0;
        cmplx_out = 1;

        for i = 1:size(x, 1)
            if len_num > 1
                s1 = [real(y(i, k))*imag(cmplx_out)+...
                      imag(y(i, k))*real(cmplx_out);...
                      s1(1:len_num-1)];
            else
                s1 = [real(y(i, k))*imag(cmplx_out)+...
                      imag(y(i, k))*real(cmplx_out)];
            end
            tmp = num * s1 + den * z1;
            if len_den > 1
                z1 = [tmp; z1(1:len_den-1)];
            else
                z1 = tmp;
            end
            intgl = - z1(1) * gain * samp_time * (2*pi) + intgl;
            if is_fm
                x(i, k) = tmp;
            else
                x(i, k) = -intgl;
            end;
            cmplx_out = exp(j *(intgl + ini_phase));
        end;
    end;
else
    disp(['Method ', method, ' is not a legal option in function ademodce.']);
end;
if r == 1
    x = x.';
end;

%end ademodce

