function [b,a] = fir2(nn, ff, aa, npt, lap, wind)
%FIR2   FIR arbitrary shape filter design using the frequency sampling method.
%   B = FIR2(N,F,A) designs an N'th order FIR digital filter with the
%   frequency response specified by vectors F and A, and returns the
%   filter coefficients in length N+1 vector B.  Vectors F and A specify
%   the frequency and magnitude breakpoints for the filter such that
%   PLOT(F,A) would show a plot of the desired frequency response.
%   The frequencies in F must be between 0.0 < F < 1.0, with 1.0
%   corresponding to half the sample rate. They must be in increasing
%   order and start with 0.0 and end with 1.0.
%
%   The filter B is real, and has linear phase, i.e., symmetric
%   coefficients obeying B(k) =  B(N+2-k), k = 1,2,...,N+1.
%
%   By default FIR2 windows the impulse response with a Hamming window.
%   Other available windows, including Boxcar, Hann, Bartlett, Blackman,
%   Kaiser and Chebwin can be specified with an optional trailing argument.
%   For example,
%   B = FIR2(N,F,A,bartlett(N+1)) uses a Bartlett window.
%   B = FIR2(N,F,A,chebwin(N+1,R)) uses a Chebyshev window.
%
%   For filters with a gain other than zero at Fs/2, e.g., highpass
%   and bandstop filters, N must be even.  Otherwise, N will be
%   incremented by one.  In this case the window length should be
%   specified as N+2.
%
%   See also FIR1, FIRLS, CFIRPM, FIRPM, BUTTER, CHEBY1, CHEBY2, YULEWALK,
%   FREQZ, FILTER.

%   Author(s): L. Shure, 3-27-87
%         C. Denham, 7-26-90, revised
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/13 00:17:50 $

%   Optional input arguments (see the user's guide):
%     npt - number for interpolation
%     lap - the number of points for jumps in amplitude


nargchk(3,6,nargin);

[nn,msg1,msg2] = firchk(nn,ff(end),aa);
error(msg1);
warning(msg2);

% Work with filter length instead of filter order
nn = nn + 1;

if (nargin > 3)
    if nargin == 4
        if length(npt) == 1
            if (2 .^ round(log(npt)/log(2))) ~= npt
                % NPT is not an even power of two
                npt = 2.^ceil(log(npt)/log(2));
            end
            wind = hamming(nn);
        else
            wind = npt;
            npt = 512;
        end
        lap = fix(npt/25);
    elseif nargin == 5
        if length(npt) == 1
            if (2 .^ round(log(npt)/log(2))) ~= npt
                % NPT is not an even power of two
                npt = 2.^ceil(log(npt)/log(2));
            end
            if length(lap) == 1
                wind = hamming(nn);
            else
                wind = lap;
                lap = fix(npt/25);
            end
        else
            wind = npt;
            npt = lap;
            lap = fix(npt/25);
        end
    end
elseif nargin == 3
    if nn < 1024
        npt = 512;
    else
        npt = 2.^ceil(log(nn)/log(2));
    end
    wind = hamming(nn);
    lap = fix(npt/25);
end

if nn ~= length(wind)
    error('The specified window must be the same as the filter length')
end

[mf,nf] = size(ff);
[ma,na] = size(aa);
if ma ~= mf || na ~= nf
    error('You must specify the same number of frequencies and amplitudes')
end
nbrk = max(mf,nf);
if mf < nf
    ff = ff';
    aa = aa';
end

if abs(ff(1)) > eps || abs(ff(nbrk) - 1) > eps
    error('The first frequency must be 0 and the last 1')
end

% interpolate breakpoints onto large grid

H = zeros(1,npt);
nint=nbrk-1;
df = diff(ff');
if (any(df < 0))
    error('Frequencies must be non-decreasing')
end

npt = npt + 1;   % Length of [dc 1 2 ... nyquist] frequencies.

nb = 1;
H(1)=aa(1);
for i=1:nint
    if df(i) == 0
        nb = nb - lap/2;
        ne = nb + lap;
    else
        ne = fix(ff(i+1)*npt);
    end
    if (nb < 0 || ne > npt)
        error('Too abrupt an amplitude change near end of frequency interval')
    end
    j=nb:ne;
    if nb == ne
        inc = 0;
    else
        inc = (j-nb)/(ne-nb);
    end
    H(nb:ne) = inc*aa(i+1) + (1 - inc)*aa(i);
    nb = ne + 1;
end

% Fourier time-shift.

dt = 0.5 .* (nn - 1);
rad = -dt .* sqrt(-1) .* pi .* (0:npt-1) ./ (npt-1);
H = H .* exp(rad);

H = [H conj(H(npt-1:-1:2))];   % Fourier transform of real series.
ht = real(ifft(H));            % Symmetric real series.

b = ht(1:nn);         % Raw numerator.
b = b .* wind(:).';   % Apply window.

a = 1;                % Denominator.
