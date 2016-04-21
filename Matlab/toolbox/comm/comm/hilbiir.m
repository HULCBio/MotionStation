function [aa, b, c, d, sv] = hilbiir(stp, dly, bandwidth, tol)
%HILBIIR Hilbert transform IIR filter design.
%   HILBIIR produces a plot showing the impulse responses of an ideal
%   Hilbert transform filter and a designed fourth order digital Hilbert
%   transform IIR filter. The filter sample time is 2/7 second. The filter
%   time delay is one second. The ideal Hilbert transform filter impulse
%   response of the system is 1/(t-1)/pi. No compensator is applied.
%
%   HILBIIR(TS) produces a plot showing the impulse responses of an ideal
%   theoretical Hilbert transform filter and a designed fourth order
%   digital Hilbert transform IIR filter. The filter sample time is
%   TS (sec). The filter group delay equals 3.5*TS (a suggested value).
%   The order of the filter is determined by using TOL=0.05. No
%   compensator is added. The filter is assumed to be used for bandwidth
%   1/TS/2 input signal.
%
%   HILBIIR(TS, DLY) produces a plot with the impulse response of a designed
%   Hilbert transform filter with sample time TS and group delay, DLY.
%   No compensator is used. For an accurate calculation, the parameters
%   should be chosen such that DLY is at least a few times larger than
%   TS, and rem(DLY, TS) = TS/2.
%
%   HILBIIR(TS, DLY, BANDWIDTH) produces a plot with the impulse response of
%   a designed Hilbert transform filter with sample time as TS, delay
%   DLY. The filter design uses a compensator for the input signal. The
%   input signal has bandwidth BANDWIDTH. When BANDWIDTH = 0 or
%   BANDWIDTH > 1/TS/2, no compensator is added.
%
%   HILBIIR(TS, DLY, BANDWIDTH, TOL) produces a plot with impulse response
%   of a designed Hilbert transform filter with sample time TS, delay
%   DLY, and bandwidth BANDWIDTH. TOL specifies the tolerance
%   in the filter design. The order of the filter is determined by
%   truncated-singular-value/maximum-singular-value < TOL; when TOL is
%   larger than or equal to one, TOL is the order of the filter. If
%   BANDWIDTH = 0 or BANDWIDTH > 1/TS/2, the filter order is exactly TOL,
%   since no compensator is added. Otherwise, the filter order is
%   TOL + max(3,ceil(TOL)/2) with a compensator added.
%
%   [NUM, DEN] = HILBIIR(...) outputs the transfer function NUM(z)/DEN(z).
%
%   [NUM, DEN, SV] = HILBIIR(...) outputs the additional parameter SV, the
%   singular value in the calculation.
%
%   [A, B, C, D] = HILBIIR(...) outputs state-space solution.
%
%   [A, B, C, D, SV] = HILBIIR(...) outputs state-space solution and
%   singular values.
%
%   See also GRPDELAY, RCOSIIR.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.3 $


if nargin < 1
    stp = 2/7;
    bandwidth = 0;
end;
if nargin < 2
    dly = stp*7/2;
    bandwidth = 0;
end;
if nargin < 3
    bandwidth = 0;
end;
if nargin < 4
    tol = 0.05;
end;
if nargin < 1
    bandwidth = 0;
end;
if isempty(stp)
    stp = 2/7;
end;
if isempty(dly)
    dly = stp*7/2;
end;
if isempty(bandwidth)
    bandwidth = 0;
end;
if isempty(tol)
    tol = 0.05;
end;
if bandwidth > 1/stp/2
    bandwidth = 0;
end;

% DLY must be positive
if dly <= 0
    error('The time delay factor for designing HILBIIR filter must be larger than 0')
end;

sz = max(2 * dly / stp, tol*1.3 + 2);
if dly / stp < 3
   warning('comm:hilbiir:smallDelay', ...
           'The time delay is too small comparing the step size in HILBIIR')
   sz = 6;
end;

% determine the time.
t = [-dly : stp : max(3 * dly, 2*sz*stp)];
ind = find(abs(t) < eps);
if ~isempty(ind)
    t(ind) = eps*ones(1,length(ind));
end

%impulse response of the system
x = 1 ./ t / pi;
if ~isempty(ind)
    x(ind) = zeros(1,length(ind));
    t(ind) = zeros(1,length(ind));
end

% discrete-time model realization.
if(length(x)>5000)
    warning('comm:hilbiir:longCompute', ...
    ['The filter coefficients may take a long time to compute. ' ...
     'Try reducing the length of the impulse response by increasing Ts or '...
     'decreasing the delay.']);
end

[a, b, c, d, sv] = imp2sys(x, tol);

% add a compensator to smooth the gain over the entire input signal frequency.
if bandwidth ~= 0
    [a, b] = ss2tf(a,b,c,d,1);
    bandwidth = min(bandwidth, 1/stp/2);
    [h, w] = freqz(a, b, [0:bandwidth*.01:bandwidth]*stp);
    [cn, cd] = yulewalk(ceil(max(3, length(b)/2)), [w(:); 1],...
            [1./abs(h(:)); 1/abs(h(length(h)))]);
    a = conv(a, cn);
    b = conv(b, cd);
    if nargout > 3
        [a, b, c, d] = tf2ss(a, b);
    else
        c = sv;
    end
elseif nargout < 4
    [a, b] = ss2tf(a, b, c, d, 1);
    c = sv;
end;

if nargout < 2
    [hh,t] = impz(a, b);
    h = ishold;
    tt = t * stp - dly;
    x = 1 ./ tt / pi;
    stem(t*stp,hh,'b');
    hold on
    plot(t*stp, x, 'r*')
    ax=get(get(gcf,'child'),'Ylim');
    plot([dly, dly], ax, 'k');
    xlabel('Time (second)')
    ylabel('Amplitude')
%    title('Impulse Response: yellow: IIR; red: ideal; blue symmetric line')
    title('Impulse Response: blue. Ideal Response: red. Axis of symmetry: black')
    if ~h
        hold off
    end
    return;
else
    aa = a;
end

