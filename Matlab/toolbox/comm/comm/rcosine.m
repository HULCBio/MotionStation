function [num, den] = rcosine(Fd, Fs, type_flag, R, Delay, tol)
%RCOSINE Design raised cosine filter.
%   NUM = RCOSINE(Fd, Fs) designs an FIR raised cosine filter to filter a
%   digital signal with the digital transfer sampling frequency Fd. The
%   filter sampling frequency is Fs. Fs/Fd must be a positive integer.
%	The default rolloff factor is 0.5, and the default filter delay
%	is 3/Fd seconds.
%
%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG) gives specific filter design
%   instructions. TYPE_FLAG can be 'iir', 'sqrt', or a combination
%   such as 'iir/sqrt'. The order of the arguments is not important.
%     'fir'    Design FIR raised cosine filter (default).
%     'iir'    Design an IIR approximation to the FIR raised cosine filter.
%     'normal' Design the regular raised cosine filter (default).
%     'sqrt'   Design square root raised cosine filter.
%     'default' Use the default (FIR, Normal raised cosine filter).
%
%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R) specifies the
%   rolloff factor in R, which is a real number in the range [0, 1].
%
%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY) specifies the filter
%	delay in DELAY, which must be a positive integer. DELAY/Fd is the
%	filter delay in seconds.
%
%   [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY, TOL) specifies the
%   tolerance in TOL for IIR filter design. The default value is 0.01.
%
%   When the designed filter is an FIR filter, the output in DEN is 1.
%
%   See also RCOSFLT, RCOSIIR, RCOSFIR, RCOSDEMO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

%assigned default value
if nargin < 6
    tol = .01;
end;

%default delay
if nargin < 5
    Delay = 3;
elseif Delay <= 0
    error('DELAY must be a positive integer in RCOSINE.')
elseif ceil(Delay) ~= Delay
    error('DELAY in RCOSINE must be an integer.')
end;

%default rolloff factor
if nargin < 4
    R = .5;
elseif (R < 0) | (R > 1) | ~isreal(R)
    error('The Rolloff factor, R, in RCOSINE must be a real number in the range, [0, 1].')
end;

%default type_flag
if nargin < 3
    type_flag = 'default';
elseif ~isstr(type_flag) & ~isempty(type_flag)
    error('TYPE_FLAG in RCOSINE must be a string.');
end;

%not enough input varible.
if nargin < 2
    error('Not enough input variables for RCOSINE.')
end;

type_flag = lower(type_flag);

%filter type.
if findstr(type_flag, 'sqrt')
    filt_type = 'sqrt';
else
    filt_type = 'normal';
end;

% check the oversampling rate
FsDFd = Fs/Fd;
if (ceil(FsDFd) ~= FsDFd) | (FsDFd <= 1) | ~isreal(FsDFd)
    error('Fs/Fd in RCOSINE must be an integer greater than 1.')
end;

%design the filter.
if findstr(type_flag, 'iir')
    [num, den] = rcosiir(R, Delay, FsDFd, 1/Fd, tol, filt_type);
else
    num = rcosfir(R, Delay, FsDFd, 1/Fd, filt_type);
    den = 1;
end;
%end of RCOSINE.
