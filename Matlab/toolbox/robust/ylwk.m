function [B,A] = ywlk(na, ff, aa, npt, lap)
%YWALK  Recursive filter design using a least-squares method.
%
%       [B,A] = YWLK(N,F,M) finds the N-th order recursive filter
%       coefficients B and A such that the filter:
%                                     -1             -(n-1)
%                  B(z)   b(1) + b(2)z + .... + b(n)z
%                  ---- = ---------------------------
%                                     -1             -(n-1)
%                  A(z)    1   + a(1)z + .... + a(n)z
%
%       matches the magnitude frequency response given by vectors F and M.
%       Vectors F and M specify the frequency and magnitude breakpoints for
%       the filter such that PLOT(F,M) would show a plot of the desired
%       frequency response. The frequencies in F must be between 0.0 and 1.0,
%       with 1.0 corresponding to half the sample rate. They must be in
%       increasing order and start with 0.0 and end with 1.0.
%
%       See also FIR1, BUTTER, CHEBY, FREQZ and FILTER (in the Signal
%       Processing Toolbox).

%   The YWLK function performs a least squares fit in the time domain.
%   The denominator coefficients {a(1),...,a(NA)} are computed by the
%   so called "modified Yule Walker" equations, using NR correlation
%   coefficients computed by inverse Fourier transformation of the specified
%   frequency response H.
%   The numerator is computed by a four step procedure. First, a numerator
%   polynomial corresponding to an additive decomposition of the power
%   frequency response is computed. Next, the complete frequency response
%   corresponding to the numerator and denominator polynomials is evaluated.
%   Then a spectral factorization technique is used to obtain the
%   impulse response of the filter. Finally, the numerator polynomial
%   is obtained by a least squares fit to this impulse response.
%   For a more detailed explanation of the algorithm see
%   B. Friedlander and B. Porat, "The Modified Yule-Walker Method
%   of ARMA Spectral Estimation," IEEE Transactions on Aerospace
%   Electronic Systems, Vol. AES-20, No. 2, pp. 158-173, March 1984.

%       B. Friedlander 7-16-85
%       Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
%       Modified 3-5-87 LS
%       Modified 1-8-93 LS, for use in Robust Control
%       Toolbox (no Hamming window is applied).

if (nargin < 3 | nargin > 5)
   error('Wrong number of input parameters.')
end
if (nargin > 3)
   if round(2 .^ round(log(npt)/log(2))) ~= npt
        % NPT is not an even power of two
      npt = round(2.^ceil(log(npt)/log(2)));
   end
end
if (nargin < 4)
   npt = 512;
end
if (nargin < 5)
   lap = fix(npt/25);
end

[mf,nf] = size(ff);
[mm,nn] = size(aa);
if mm ~= mf | nn ~= nf
   error('You must specify the same number of frequencies and amplitudes.')
end
nbrk = max(mf,nf);
if mf < nf
   ff = ff';
   aa = aa';
end

if abs(ff(1)) > eps | abs(ff(nbrk) - 1) > eps
   error('The first frequency must be 0 and the last 1.')
end

% interpolate breakpoints onto large grid

npt = npt + 1;  % For [dc 1 2 ... nyquist].
Ht = zeros(1,npt);

nint=nbrk-1;
df = diff(ff');
if (any(df < 0))
   error('Frequencies must be non-decreasing.')
end

nb = 1;
Ht(1)=aa(1);
for i=1:nint
    if df(i) == 0
       nb = nb - lap/2;
       ne = nb + lap;
    else
       ne = fix(ff(i+1)*npt);
    end
    if (nb < 0 | ne > npt)
       error('Too abrupt an amplitude change near end of frequency interval.')
    end
    j=nb:ne;
    if ne == nb
        inc = 0;
    else
        inc = (j-nb)/(ne-nb);
    end
    Ht(nb:ne) = inc*aa(i+1) + (1 - inc)*aa(i);
    nb = ne + 1;
end
Ht = [Ht Ht(npt-1:-1:2)];
n = max(size(Ht));
n2 = fix((n+1)/2);
nb = na;
nr = 4*na;
nt = 0:1:nr-1;

% compute correlation function of magnitude squared response

R = real(ifft(Ht .* Ht));

R  = R(1:nr).*(.54+.46*cos(pi*nt/(nr-1)));

% Form window to be used in extracting the right "wing" of two-sided
% covariance sequence.
Rwindow = [1/2 ones(1,n2-1) zeros(1,n-n2)];

% in-line denf, polystab, numf and freqz
%A = polystab(denf(R,na));              % compute denominator
%denf
Rm = toeplitz(R(na+1:nr-1),R(na+1:-1:2));
Rhs = - R(na+2:nr);
a = [1 Rhs/Rm'];
%polystab
v = roots(a);
i = find(v~=0);
vs = 0.5*(sign(abs(v(i))-1)+1);
v(i) = (1-vs).*v(i) + vs./conj(v(i));
A = a(1)*poly(v);
if ~any(imag(a))
        A = real(A);
end

%Qh = numf([R(1)/2,R(2:nr)],A,na);      % compute additive decomposition
h = [R(1)/2,R(2:nr)];
nh = length(h);
impr = filter(1,A,[1 zeros(1,nh-1)]);
Qh = h/toeplitz(impr,[1 zeros(1,na)])';

% in-line freqz
%Ss = 2*real(freqz(Qh,A,n,'whole'))';    % compute impulse response
%freqz
nn = n;
b = Qh;
na = length(A);
nb = length(b);
a = A;
s = 1;
if s*n < na | s*n < nb
   nfft = lcm(n,max(na,nb));
   h = (fft([b zeros(1,s*nfft-nb)]) ./ fft([a zeros(1,s*nfft-na)])).';
   h = h(1+(0:n-1)*nfft/n);
else
   h = (fft([b zeros(1,s*n-nb)]) ./ fft([a zeros(1,s*n-na)])).';
   h = h(1:n);
end
Ss = 2*real(h)';

hh = ifft(exp(fft(Rwindow.*ifft(log(Ss)))));
% in-line numf
%B  = real(numf(hh(1:nr),A,nb));
impr = filter(1,A,[1 zeros(1,nr-1)]);
B = hh(1:nr)/toeplitz(impr,[1 zeros(1,nb-1)])';
B = real(B);
%End of YWLK