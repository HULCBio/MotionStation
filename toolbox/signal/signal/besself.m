function [num, den, z, p] = besself(n, Wn, ftype, anaflag)
%BESSELF  Bessel analog filter design.
%   [B,A] = BESSELF(N,Wn) designs an N'th order lowpass analog
%   Bessel filter and returns the filter coefficients in length
%   N+1 vectors B and A.  The cut-off frequency Wn must be
%   greater than 0.
%
%   If Wn is a two-element vector, Wn = [W1 W2], BESSELF returns an 
%   order 2N bandpass filter with passband  W1 < W < W2.
%   [B,A] = BESSELF(N,Wn,'high') designs a highpass filter.
%   [B,A] = BESSELF(N,Wn,'stop') is a bandstop filter if Wn = [W1 W2].
%   
%   When used with three left-hand arguments, as in
%   [Z,P,K] = BESSELF(...), the zeros and poles are returned in
%   length N column vectors Z and P, and the gain in scalar K. 
%
%   When used with four left-hand arguments, as in
%   [A,B,C,D] = BESSELF(...), state-space matrices are returned.
%
%   See also BESSELAP, BUTTER, CHEBY1, CHEBY2, FREQZ, FILTER.

%   Author(s): T. Krauss, 3-24-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:09:29 $

%   References:
%     [1] T. W. Parks and C. S. Burrus, Digital Filter Design,
%         John Wiley & Sons, 1987, chapter 7, section 7.3.3.

btype = 1;
if (nargin >= 3)
% band-stop or high-pass
	btype = 3; 
end
if length(Wn) == 2
	btype = btype + 1;
end

% step 1: get analog, pre-warped frequencies
u = Wn;

% step 2: convert to low-pass prototype estimate
if btype == 1	% lowpass
	Wn = u;
elseif btype == 2	% bandpass
	Bw = u(2) - u(1);
	Wn = sqrt(u(1)*u(2));	% center frequency
elseif btype == 3	% highpass
	Wn = u;
elseif btype == 4	% bandstop
	Bw = u(2) - u(1);
	Wn = sqrt(u(1)*u(2));	% center frequency
end

% step 3: Get N-th order Bessel analog lowpass prototype
[z,p,k] = besselap(n);

% Transform to state-space
[a,b,c,d] = zp2ss(z,p,k);

% step 4: Transform to lowpass, bandpass, highpass, or bandstop of desired Wn
if btype == 1		% Lowpass
	[a,b,c,d] = lp2lp(a,b,c,d,Wn);

elseif btype == 2	% Bandpass
	[a,b,c,d] = lp2bp(a,b,c,d,Wn,Bw);

elseif btype == 3	% Highpass
	[a,b,c,d] = lp2hp(a,b,c,d,Wn);

elseif btype == 4	% Bandstop
	[a,b,c,d] = lp2bs(a,b,c,d,Wn,Bw);
end

if nargout == 4
	num = a;
	den = b;
	z = c;
	p = d;
else	% nargout <= 3
% Transform to zero-pole-gain and polynomial forms:
	if nargout == 3
		[z,p,k] = ss2zp(a,b,c,d,1);
		num = z;
		den = p;
		z = k;
	else % nargout <= 2
		den = poly(a);
                [z,k] = tzero(a,b,c,d);
                num = k * poly(z);
                num = [zeros(1,length(den)-length(num))  num];
	end
end

