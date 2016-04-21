function y = amodce(x, Fs, method, opt1, opt2, opt3)
%AMODCE 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use AMMOD, FMMOD, PMMOD or SSBMOD instead.

%   Y = AMODCE(X, Fs, METHOD...) outputs the complex envelope of
%   the modulation of the message signal X.  The sample frequency
%   of X and Y is Fs (Hz). For information about METHOD and
%   subsequent parameters, and about using a specific modulation
%   technique, type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE     MODULATION TECHNIQUE
%     amodce amdsb-tc      % Amplitude modulation, double sideband
%                          % with transmission carrier
%     amodce amdsb-sc      % Amplitude modulation, double sideband
%                          % suppressed carrier
%     amodce amssb         % Amplitude modulation, single sideband
%                          % suppressed carrier
%     amodce qam           % Quadrature amplitude modulation
%     amodce fm            % Frequency modulation
%     amodce pm            % Phase modulation
%
%   See also ADEMODCE, DMODCE, DDEMODCE, AMOD, ADEMOD.

%       Copyright 1996-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.3 $
%       This function calls amodce.hlp for help

opt_pos = 4;
if isstr(x)
    method = deblank(x);
    if strcmp(method, 'am')
        method = 'amdsb-tc';
    end;
    addition = 'See also ADEMODCE, DMODCE, DDEMODCE, AMOD, ADEMOD.';
    callhelp('amodce.hlp',method, addition);
    return;
end;
[r, c] = size(x);
if r * c == 0
    y = [];
    return;
end;
if r == 1
    x = x(:);
    len_x = c;
else
    len_x = r;
end;

if nargin < 1
    feval('help', 'amodce');
    return;
elseif nargin < 2
    Fs = 1;
    method = 'am';
elseif nargin < 3
    method = 'am'
end;
method = lower(method);

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

%begin of the calculation.
if strcmp(method, 'amdsb-sc')
    y = x * exp(j*ini_phase);
elseif strcmp(method, 'amdsb-tc') | strcmp(method, 'am')
    if nargin < 4
        opt1 = min(min(x));
    end;
    y = (x + opt1) * exp(j*ini_phase);
elseif findstr(method, 'amssb')
    % need to use Hilbert transform filter.
    if isempty(findstr(method, '/time'))
        % do the Hilbert transform in frequence domain.
        y = x;
        for i = 1 : size(x, 2)
            y(:, i) = (x(:, i) + j*imag(hilbert(x(:, i))))*exp(j*ini_phase);
        end;
    else
        % do the Hilber transform in time domain.
        if nargin < opt_pos
            [num,den] = hilbiir(1/Fs);
        elseif nargin == opt_pos
            error('Both the numerator and denominator need to be specified.')
        else
            num = opt1;
            den = opt2;
        end;
        y = x;
        for i = 1 : size(x, 2)
            y(:, i) = filter(num, den, x(:, i));
            y(:, i) = (x(:, i) + j * y(:, i)) * exp(j * ini_phase);
        end;
    end;
elseif strcmp(method, 'qam')
    y = [];
    wid_x = size(x, 2);
    if ceil(wid_x/2) ~= wid_x/2
        error('There must be an even number of columns in the input X.');
    end;
    for i = 1 : 2 : wid_x
        y = [y (x(:, i) + j*x(:, i+1))*exp(j * ini_phase)];
    end;
elseif strcmp(method, 'fm')
    if nargin >= opt_pos
        x = opt1 * x;
    end;
    x = 2 * pi / Fs * x;
%   question here, should add an zero or not.
    x = [zeros(1, size(x, 2)); cumsum(x(1:size(x, 1)-1, :))];
%    x = cumsum(x);
    y = exp(j*(x+ini_phase));
elseif strcmp(method, 'pm')
    if nargin >= opt_pos
        x = opt1 * x;
    end;
    y = exp(j*(x+ini_phase));
elseif strcmp(method, 'ask')
    if nargin < 4
        opt1 = max(max(x)) + 1;
        opt1 = 2^(ceil(log(opt1)/log(2)));
    end;
    if nargin < 5
        opt2 = 1;
    end;
    x = (x - (opt1-1)/2)*2*opt2/(opt1 - 1)
    y = x*exp(j*ini_phase);
elseif strcmp(method, 'psk')
    if nargin < 4
        opt1 = max(max(x)) + 1;
        opt1 = 2^(ceil(log(opt1)/log(2)));
    end;
    x = 2 * pi * x / opt1;
    y = exp(j * (x + ini_phase));
elseif strcmp(method, 'qask')
    if nargin < 4
        opt1 = max(max(x)) + 1;
        opt1 = 2^(ceil(log(opt1)/log(2)));
    end;
     [s1,s2] = qaskenco([1:opt1], opt1);
    if min(min(x)) < 0
        error('The input signal for AMODCE has an illegal element.');
    elseif max(max(x)) > opt1-1
        error('The input signal for AMODCE has an element larger than the given limit.');
    end;
    x = x + 1;
    y = (s1(x) + j * s2(x)) * exp(j*ini_phase);
elseif strcmp(method, 'apk')
    if nargin < 6
        error('Not enough input parameters.');
    end;
    z = sigsetpl(opt1, opt2, op3);
    y = z(x+1) * exp(j * ini_phase);
elseif strcmp(method, 'fsk')
    % check the parameters
    if nargin < 4
        opt1 = max(max(x)) + 1;
        opt1 = 2^(ceil(log(opt1)/log(2)));
    end;
    if nargin < 5
        opt2 = 2;
    end;
    if nargin < 6
        opt3 = 1/opt1;
    end;
    % modulation.
    x = x(:)';
    len_x = length(x);
    y = cumsum([0, x(1:opt2:len_x-opt2)]);
    y = y(ones(1, opt2), :);
    y = ([1/opt2:1/opt2:1]'*x(1:opt2:len_x) + y) * pi * opt3;
    y = y(:);
    y = exp(j*(ini_phase+y));
elseif strcmp(method, 'msk')
    if nargin < 4
        opt1 = 2;
    end;
    % it is a special case of fsk.
    y = amodce(x, 'fsk', ini_phase, 2, opt1, 1/2);
else
    disp(['Modulation method ', method, ' is not a legal option in function AMODCE.'])
    disp('The current available methods are:');
    disp('  amdsb-tc Amplitude modulation, double sideband with transmission carrier.')
    disp('  amdsb-sc Amplitude modulation, double sideband suppressed carrier.')
    disp('  amssb Amplitude modulation, single side band suppressed carrier.')
    disp('  qam Quadrature Amplitude modulation.')
    disp('  pm Phase modulation.')
    disp('  ask Amplitude shift keying modulation.')
    disp('  psk Phase shift keying modulation.')
    disp('  qask Quadrature amplitude shift-keying modulation.')
    disp('  apk Amplitude shift keying/phase shift keying modulation.')
    disp('  fsk Frequency shift keying modulation.')
    disp('  msk Minimum shift keying modulation.')
    return;
end;
if r == 1
    y = y.';
end

