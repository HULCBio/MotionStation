function [num, den, z, p] = ellip(n, Rp, Rs, Wn, varargin)
%ELLIP Elliptic or Cauer digital and analog filter design.
%   [B,A] = ELLIP(N,Rp,Rs,Wn) designs an Nth order lowpass digital
%   elliptic filter with Rp decibels of peak-to-peak ripple and
%   a minimum stopband attenuation of Rs decibels. ELLIP returns the filter
%   coefficients in length N+1 vectors B (numerator) and A (denominator).  
%   The cutoff frequency Wn must be 0.0 < Wn < 1.0, with 1.0 corresponding 
%   to half the sample rate.  Use Rp = 0.5 and Rs = 20 as starting
%   points, if you are unsure about choosing them.
%
%   If Wn is a two-element vector, Wn = [W1 W2], ELLIP returns an 
%   order 2N bandpass filter with passband  W1 < W < W2.
%   [B,A] = ELLIP(N,Rp,Rs,Wn,'high') designs a highpass filter.
%   [B,A] = ELLIP(N,Rp,Rs,Wn,'low') designs a lowpass filter.
%   [B,A] = ELLIP(N,Rp,Rs,Wn,'stop') is a bandstop filter if Wn = [W1 W2].
%
%   When used with three left-hand arguments, as in
%   [Z,P,K] = ELLIP(...), the zeros and poles are returned in
%   length N column vectors Z and P, and the gain in scalar K. 
%
%   When used with four left-hand arguments, as in
%   [A,B,C,D] = ELLIP(...), state-space matrices are returned. 
%
%   ELLIP(N,Rp,Rs,Wn,'s'), ELLIP(N,Rp,Rs,Wn,'high','s') and 
%   ELLIP(N,Rp,Rs,Wn,'stop','s') design analog elliptic filters.  
%   In this case, Wn is in [rad/s] and it can be greater than 1.0.
%
%   See also ELLIPORD, CHEBY1, CHEBY2, BUTTER, BESSELF, FREQZ, FILTER.

%   Author(s): L. Shure, 4-29-88
%   	   T. Krauss, 3-25-93, revised
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/13 00:17:46 $

%   References:
%     [1] T. W. Parks and C. S. Burrus, Digital Filter Design,
%         John Wiley & Sons, 1987, chapter 7, section 7.3.3.

[btype,analog,errStr] = iirchk(Wn,varargin{:});
error(errStr)

if n>500
	error('Filter order too large.')
end

% step 1: get analog, pre-warped frequencies
if ~analog,
	fs = 2;
	u = 2*fs*tan(pi*Wn/fs);
else
	u = Wn;
end

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

% step 3: Get N-th order elliptic lowpass analog prototype
[z,p,k] = ellipap(n, Rp, Rs);

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

% step 5: Use Bilinear transformation to find discrete equivalent:
if ~analog,
	[a,b,c,d] = bilinear(a,b,c,d,fs);
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

