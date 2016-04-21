function [num, den, tim] = rcosiir(r, T_delay, rate, T, tol, fil_type, col)
%RCOSIIR Design a raised cosine IIR filter.
%   [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL) designs an IIR 
%   approximation of the equivalent FIR raised cosine filter with a specified
%   rolloff factor R. T_DELAY specifies the delay which must be an integer
%   multiple of T.  RATE is the number of sample points in each interval T, 
%   or the sampling rate of the filter is T/RATE. The default value of RATE 
%   is 5. T is the symbol interval. The order of the IIR filter is determined 
%   by TOL when it is an integer greater than 1. If TOL is less than 1, 
%   it is considered as the relative tolerance in the SVD computation in 
%   selecting the order. The default value of TOL is 0.01.
%   The time response of the raised cosine filter has the form of
%
%     h(t) = sinc(t/T) cos(pi R t/T)/(1 - 4 R^2 t^2 /T^2)
%
%   The frequency domain has the spectrum
%
%             / T                                 when 0 < |f| < (1-r)/2/T
%             |         pi T         1-R    T           1-R         1+R
%     H(f) = < (1 + cos(----) (|f| - ----) ---    when  --- < |f| < ---
%             |           r           2T    2           2 T         2 T
%             \ 0                                 when |f| > (1+r)/2/T
%
%   [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL, FILTER_TYPE) designs an IIR
%   approximation of the equivalent FIR square root raised cosine filter if
%   FILTER_TYPE == 'sqrt'.
%
%   RCOSIIR(...) plots the time response and frequency response of
%   the raised cosine filter
%
%   RCOSIIR(..., COLOR) plots the time response and frequency response using
%   the color specified in the string variable COLOR. The string in COLOR
%   can be any type as defined in PLOT.
%
%   [NUM, DEN, SAMPLE_TIME] = RCOSIIR(...) returns the IIR filter and the
%   sample time for the filter.
%
%   See also RCOSFIR, RCOSFLT, RCOSINE, RCOSDEMO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.16 $

%routine check
if nargin < 1
    error('Not enough input variables for RCOSIIR')
elseif nargin < 2
    T_delay = 3; rate = 5; T = 1; tol = 0.01; fil_type='normal';
elseif nargin < 3,
    rate = 5; T = 1; tol = 0.01; fil_type='normal';
elseif nargin < 4,
    T = 1; tol = 0.01; fil_type='normal';
elseif nargin < 5,
    tol = 0.01; fil_type='normal';
elseif nargin < 6
    fil_type = 'normal';
end;

[T_delay, rate, T, tol, fil_type] = checkinp(T_delay, rate, T, tol, fil_type,...
                                             3,       5,    1, 0.01, 'normal');

if (rate < 1) | (ceil(rate) ~= rate)
    error('RATE in RCOSIIR must be a positive integer')
end

%calculation
[b, tim] = rcosfir(r, [T_delay, 3*T_delay], rate, T, fil_type);
[num, den] = imp2sys(b, tol);

% In case needs a plot
if nargout < 1
    if nargin < 7
        col = '';
    end;

    cal_time = [-T_delay: tim : T_delay] / T;
    % the time response part
    hand = subplot(211);
    out = filter(num, den, [1, zeros(1, length(cal_time) - 1)]);
    plot(cal_time, out, col)
    % if not hold, change the axes
    hol = get(hand,'NextPlot');
    if (hol(1:2) ~= 'ad') | (max(get(hand,'Ylim')) < max(b))
        grid on;
        axis([min(cal_time), max(cal_time), min(out) * 1.1, max(out) * 1.1]);
        xlabel('time');
        title(['Impulse Response of ',num2str(length(den)),'th order Raised Cosine IIR Filter (',num2str(cal_time(1)),' sec shift)'])
    end;

    % the frequency response part
    hand = subplot(212);
    len = length(out);
    P = abs(fft(out)) * 2 * T_delay / len;
    f = (0 : len / 2) / len * rate / T;
    ind = find(f < 1.5 / T);
    f = f(ind);
    P = P(ind);
    plot(f, P, col);
    hol = get(hand, 'NextPlot');
    if hol(1:2) ~= 'ad'
        grid on;
        xlabel('frequency');
        ylabel('Amplitude');
        title('Frequency Response of the Raised Cosine Filter (Normalized)')
    end;
end;

%---end rcosiir.m---
