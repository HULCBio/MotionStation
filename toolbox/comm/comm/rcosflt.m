function [y, t] = rcosflt(x, Fd, Fs, type_flag, R, Delay, tol)
%RCOSFLT Filter the input signal using a raised cosine filter.
%   Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, R, DELAY) filters the input signal X
%   using a raised cosine FIR filter. The sample frequency for the input, X,
%   is Fd (Hz).  The sample frequency for the output, Y, is Fs (Hz).  Fs must be
%   an integer multiple of Fd.  The TYPE_FLAG gives specific filter design
%   or filtering options.  The rolloff factor, R, determines the width of the
%   transition band of the filter.  DELAY is the time delay from the beginning
%   of the filter to the peak of the impulse response.
%
%   R, the rolloff factor specifies the excess bandwidth of the filter.  R must
%   be in the range [0, 1]. For example, R = .5 means that the bandwidth of the
%   filter is 1.5 times the input sampling frequency, Fd.  This also means that
%   the transition band of the filter extends from .5 * Fd and 1.5 * Fd.  Since
%   R is normalized to the input sampling frequency, Fd, it has no units.
%   Typical values for R are between 0.2 to 0.5.
%
%   DELAY determines the group delay of the filter.  The group delay is the
%   opposite of the change in filter phase with respect to frequency.  For linear
%   phase filters, the group delay is also the time delay between the input
%   signal and the peak response of the filter.  DELAY also determines the
%   length of the filter impulse response used to filter X.  This delay is
%       Fs/Fd * (2 * DELAY + 1).
%
%   Y is the output of the upsampled, filtered input stream X.  The length of
%   vector Y is
%       Fs/Fd * (length(X) + 2 * DELAY).
%
%   TYPE_FLAG is a string which may contain any of the option strings listed
%   below delimited by a '/'  For example, the 'iir' and 'Fs' flags may
%   be combined as 'iir/Fs'.  While some of the pairs of option substrings
%   are mutually exclusive, they are not mutually exclusive in general.
%
%   'fir'    Design an FIR filter and use it to filter X.  When the 'filter'
%            TYPE_FLAG is not used, an FIR filter is designed and used to
%            filter X.  See the 'filter' TYPE_FLAG description for the behavior
%            when the 'fir' and 'filter' TYPE_FLAGs are used together.  This
%            option is exclusive of the 'iir' substring.
%
%   'iir'    Design an IIR filter and use it to filter X.  When the 'filter'
%            TYPE_FLAG is not used, an IIR approximation to the equivalent FIR
%            filter is designed and used to filter X.  See the 'filter'
%            TYPE_FLAG description for the behavior when the 'iir' and 'filter'
%            TYPE_FLAGs are used together.  This option is exclusive of the
%            'fir' substring.
%
%   'normal' Design a normal raised cosine filter and use it to filter X.  The
%            filter coefficients are normalized so the peak coefficient is one.
%            This option is exclusive of the 'sqrt' substring.
%
%   'sqrt'   Design a square root raised cosine filter and use it to filter X.
%            The filter coefficients are normalized so that the impulse
%            response of this filter when convolved with itself will result
%            in an impulse response that is approximately equal to the 'normal'
%            raised cosine filter.  The difference in this approximation is due
%            to finite filter length.  This is a useful option when the raised
%            cosine filtering is split between transmitter and receiver by
%            using the 'sqrt' filter in each device. This option is exclusive
%            of the 'normal' substring.
%
%   'Fs'     X is input with sample frequency Fs (i.e., the input signal has
%            Fs/Fd samples per symbol). In this case the input signal is not
%            upsampled from Fd to Fs but is simply filtered by the raised
%            cosine filter.  This is useful for filtering an oversampled data
%            stream at the receiver.  When using the 'Fs' substring, the length
%            of vector, Y is
%               length(X) + Fs/Fd * 2 * DELAY.
%
%   'filter' Means the filter is provided by the user.  When using the 'filter'
%            TYPE_FLAG, the input parameters are:
%
%            Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, NUM) - filters with a user-
%            supplied FIR filter.  When the TYPE_FLAG contains 'filter' and
%            the 'fir' type substrings, the FIR filter indicated by NUM is
%            used to filter X.
%
%            Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, NUM, DEN, DELAY) - filters with
%            a user-supplied IIR filter.  When TYPE_FLAG contains both 'filter'
%            and 'iir' type substrings, the IIR filter defined by numerator,
%            NUM, and denominator, DEN, is used as to filter X.  The DELAY
%            parameter is used to force RCOSFLT to behave as if the filter were
%            designed by RCOSFLT using the same DELAY parameter.  The DELAY
%            parameter should match the DELAY parameter used to design the
%            filter defined by NUM and DEN in the RCOSINE function.  The default
%            value of DELAY is 3.
%
%            The raised cosine filter should be designed using the RCOSINE
%            function.
%
%   Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, R) filters the input signal X
%   using a raised cosine filter and default DELAY parameter, 3.
%
%   Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG) filters the input signal X using a
%   raised cosine filter and the following default parameters
%       DELAY = 3
%       R = .5
%
%   Y = RCOSFLT(X, Fd, Fs) filters the input signal X using a raised cosine
%   filter and the following default parameters
%       DELAY = 3
%       R = .5
%       TYPE_FLAG = 'fir/normal'
%
%   Y = RCOSFLT(X, Fd, Fs, TYPE_FLAG, R, DELAY, TOL) specifies the
%   tolerance in IIR filter design. The default value for TOL is .01.
%
%   [Y, T] = RCOSFLT(...) returns the time vector in T.
%
%   See also RCOSINE, RCOSFIR, RCOSIIR, RCOSDEMO.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $

%default tolerance
if nargin < 7
    tol = .01;
end;

%default delay
if nargin < 6
    Delay = 3;
elseif isempty(Delay)
    Delay = 3;
elseif Delay <= 0
    error('DELAY must be a positive integer in RCOSFLT.')
elseif ceil(Delay) ~= Delay
    error('DELAY in RCOSFLT must be an integer.')
end;

%default rolloff factor
if nargin < 5
    R = .5;
elseif R < 0
    error('The rolloff factor in RCOSFLT cannot be a negative number.')
elseif R > 1
    error('The rolloff factor in RCOSFLT cannot be greater than 1.')
end;

%default type_flag
if nargin < 4
    type_flag = '';
elseif ~isstr(type_flag) & ~isempty(type_flag)
    error('TYPE_FLAG in RCOSFLT must be a string.');
end;

%Too few input variables.
if nargin < 3
    error('Too few input variables for RCOSFLT.')
end;

%process the input variable x
if isempty(x)
    y = [];
    return;
end;
[len_x_o, wid_x_o] = size(x);
if min(len_x_o, wid_x_o) == 1
    x = x(:);
end;
[len_x, wid_x] = size(x);

FsDFd = Fs/Fd;
if ceil(FsDFd) ~= FsDFd
    error('Fs/Fd must be an integer.')
end;
type_flag = lower(type_flag);

%filter type.
if findstr(type_flag, 'sqrt')
    filt_type = 'sqrt';
else
    filt_type = 'normal';
end;

% select filter type and design logic.
if findstr(type_flag, 'fir')
    % this is an FIR filter
    if findstr(type_flag, 'filter')
        % get the filter numerator using arg 5
        if nargin < 5
            error('Too few input variables. ''NUM'' must be defined for the FIR filter')
        else
            num = R;
        end
        Delay = floor(length(num)./ 2./FsDFd);
    else
        %design a filter
        num = rcosfir(R, Delay, FsDFd, 1/Fd,filt_type);
    end;
    den = 1;
elseif findstr(type_flag, 'iir')
    % this is an IIR filter
    if findstr(type_flag, 'filter')
        % get the filter numerator and denominator using args 5 and 6
        if nargin < 6
            error('Too few input variables. ''NUM'' and ''DEN'' must be defined for the IIR filter')
        else
            num = R;
            den = Delay;
        end
        if nargin < 7
            Delay = 3;   % no other information so go with the default
        elseif tol <= 0
            error('DELAY must be a positive integer in RCOSFLT.')
        elseif ceil(tol) ~= tol
            error('DELAY in RCOSFLT must be an integer.')
        else
            Delay = tol;
        end
    else
        %design a filter
        [num, den] = rcosiir(R, Delay, FsDFd, 1/Fd, tol,filt_type);
    end;
else
    %back to the default (either fir or iir depending on # of args
    if findstr(type_flag, 'filter')
        if nargin < 5
            error('Too few input variables. ''NUM'' must be defined for the FIR filter')
        else
            % get the filter numerator using arg 5
            num = R;
        end
        if nargin < 6
            % this is an FIR filter - estimate the delay from the filter NUM
            den = 1;
            Delay = floor(length(num)./ 2./FsDFd);
        else
            % this is an IIR filter - get the filter denominator using arg 6
            den = Delay;
            if nargin < 7
                Delay = 3;   % no other information so go with the default
            elseif tol <= 0
                error('DELAY must be a positive integer in RCOSFLT.')
            elseif ceil(tol) ~= tol
                error('DELAY in RCOSFLT must be an integer.')
            else
                Delay = tol;
            end
        end
    else
        %design a filter
        num = rcosfir(R, Delay, FsDFd, 1/Fd, filt_type);
        den = 1;
    end
end

% Upsample input, x, to sample rate, Fs. 'fs' is here for backward compatibility
if findstr(type_flag, 'fs') | findstr(type_flag, 'Fs')
    % input signals are arriving at rate, Fs
    xx = zeros(len_x + (Delay .* 2 .* FsDFd), wid_x);

    xx(1:len_x, :) = x(1:len_x, :);
else
     % input signals are arriving at rate, Fd
     xx = zeros((len_x + Delay .* 2) * FsDFd , wid_x);
     for i = 1 : len_x
        xx((i - 1) * FsDFd + 1, :) = x(i, :);
     end;
end

% Drive the filter function
for i = 1:wid_x
    y(:, i) = filter(num, den, xx(:, i));
end;
t = [0:size(xx, 1)-1]/Fs;

% warnings for obsolete stuff
if findstr(type_flag, 'wdelay')
    warning('comm:rcosflt:obsWdelay', ...
            'The FILTER_TYPE argument, "wdelay" is now obsolete.');
end;
%--end of rcosflt.m--
