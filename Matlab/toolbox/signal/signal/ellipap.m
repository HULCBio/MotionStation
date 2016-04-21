function [z,p,k] = ellipap(n, rp, rs)
%ELLIPAP Elliptic analog lowpass filter prototype.
%   [Z,P,K] = ELLIPAP(N,Rp,Rs) returns the zeros, poles, and gain
%   of an N-th order normalized prototype elliptic analog lowpass
%   filter with Rp decibels of ripple in the passband and a
%   stopband Rs decibels down.

%   Author(s): L. Shure, 3-8-88
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:11:13 $

%   References:
%     [1] T. W. Parks and C. S. Burrus, Digital Filter Design,
%         John Wiley & Sons, 1987, chapter 7, section 7.3.7-8.

if n == 1,     % special case; for n == 1, reduces to Chebyshev Type I
	z = [];
	p = -sqrt(1/(10^(rp/10)-1));
	k = -p;
	return
end

epsilon = sqrt(10^(0.1*rp)-1);	%rp, dB of passband ripple
k1 = epsilon/sqrt(10^(0.1*rs)-1);	%rs, dB of stopband ripple
k1p = sqrt(1-k1^2);
if k1p == 1
	error('Cannot design filter, Rp and Rs specifications are too strict.')
end
wp = 1;	% passband edge - normalized
if abs(1-k1p^2) < eps
	krat = 0;
else
	capk1 = ellipke([k1^2,k1p^2]);
	krat = n*capk1(1)/capk1(2);	% krat = K(k)/K'(k) -- need to find relevant k
end

% try to find m, elliptic parameter, so that K(m)/K'(m) = krat -- K, complete
% elliptic integral of first kind
fopt = optimset('maxfunevals',250,'maxiter',250,'display','none');
m = fminsearch('kratio',.5,fopt,krat); 
if m<0 | m>1
    m = fminbnd('kratio',0,1,fopt,krat);
end

capk = ellipke(m);
ws = wp/sqrt(m);	% stopband edge (=> transition band is ws-wp in width)
m1 = 1 - m;

% find zeros; they are purely imaginary and paired in complex conjugates
j = (1-rem(n,2)):2:n-1;
[ij,jj] = size(j);
% s is Jacobi elliptic function sn(u)
[s,c,d] = ellipj(j*capk/n,m*ones(ij,jj));
is = find(abs(s) > eps);
z = 1 ./(sqrt(m)*s(is));
z = i*z(:);	% make column vector
z = [z ; conj(z)];
% order the zeros for convenience later on
z = cplxpair(z);

% poles; one purely real if n is odd - the remainder are complex conjugate pairs
% calculate v0, a 'fundamental' parameter for the poles related to inverse sc
% function . I.e. find r so sn(r)/cn(r) = 1/epsilon for the given parameter mp
r = fminsearch('vratio', ellipke(1-m),fopt,1/epsilon,k1p^2);
v0 = capk*r/(n*capk1(1));
[sv,cv,dv] = ellipj(v0,1-m);
p = -(c.*d*sv*cv + i*s*dv)./(1-(d*sv).^2);
p = p(:);   % make column vector
% check to see if there is a real pole
if rem(n,2)
	ip = find(abs(imag(p)) < eps*norm(p));
	[pm,pn] = size(p);
	pp = 1:pm;
	pp(ip) = [];
	p = [p ; conj(p(pp))];
else
	p = [p; conj(p)];
end
p = cplxpair(p);	% order poles for later use

% gain
k = real(prod(-p)/prod(-z));
if (~rem(n,2))	% n is even order so patch gain
	k = k/sqrt((1 + epsilon^2));
end
