function [order,wn] = ellipord(wp,ws,rp,rs,opt)
%ELLIPORD Elliptic filter order selection.
%   [N, Wn] = ELLIPORD(Wp, Ws, Rp, Rs) returns the order N of the lowest 
%   order digital elliptic filter that loses no more than Rp dB in the
%   passband and has at least Rs dB of attenuation in the stopband.  
%   Wp and Ws are the passband and stopband edge frequencies, normalized 
%   from 0 to 1 (where 1 corresponds to pi radians/sample). For example,
%       Lowpass:    Wp = .1,      Ws = .2
%       Highpass:   Wp = .2,      Ws = .1
%       Bandpass:   Wp = [.2 .7], Ws = [.1 .8]
%       Bandstop:   Wp = [.1 .8], Ws = [.2 .7]
%   ELLIPORD also returns Wn, the elliptic natural frequency to
%   use with ELLIP to achieve the specifications.
%
%   [N, Wn] = ELLIPORD(Wp, Ws, Rp, Rs, 's') does the computation for an 
%   analog filter, in which case Wp and Ws are in radians/second.
%
%   NOTE: If Rs is much much greater than Rp, or Wp and Ws are very close, 
%   the estimated order can be infinite due to limitations of numerical 
%   precision.
%       
%   See also ELLIP, BUTTORD, CHEB1ORD, CHEB2ORD.

%   Author(s): L. Shure, 6-9-88
%              T. Krauss, 11-18-92, updated
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/11/21 15:47:02 $

%   Reference(s):
%       [1] Rabiner and Gold, p 241.

error(nargchk(4,5,nargin));
error(nargoutchk(0,2,nargout));

if nargin == 4
	opt = 'z';
elseif nargin == 5
	if ~strcmp(opt,'z') & ~strcmp(opt,'s')
		error('Invalid option for final argument.');
	end
end

msg=freqchk(wp,ws,opt);
error(msg);

ftype = 2*(length(wp) - 1);
if wp(1) < ws(1)
	ftype = ftype + 1;	% low (1) or reject (3)
else
	ftype = ftype + 2;	% high (2) or pass (4)
end

% first, prewarp frequencies from digital (unit circle) to analog (imag. axis):
if strcmp(opt,'z')	% digital
	WP=tan(pi*wp/2);
	WS=tan(pi*ws/2);
else  % don't have to if analog already
	WP=wp;
	WS=ws;
end

% next, transform to low pass prototype with passband edge of 1 and stopband
% edges determined by the following: (see Rabiner and Gold, p.258)
if ftype == 1	% low
	WA=WS/WP;
elseif ftype == 2	% high
	WA=WP/WS;
elseif ftype == 3	% stop
	fo = optimset('display','none');
	wp1 = lclfminbnd('bscost',WP(1),WS(1)-1e-12,fo,1,WP,WS,rs,rp,'ellip');
	WP(1) = wp1;
	wp2 = lclfminbnd('bscost',WS(2)+1e-12,WP(2),fo,2,WP,WS,rs,rp,'ellip');
	WP(2) = wp2;
	WA=(WS*(WP(1)-WP(2)))./(WS.^2 - WP(1)*WP(2));
elseif ftype == 4	% pass
	WA=(WS.^2 - WP(1)*WP(2))./(WS*(WP(1)-WP(2)));
end

% find the minimum order elliptic filter to meet the more demanding spec:
WA = min(abs(WA));
epsilon = sqrt(10^(0.1*rp)-1);
k1 = epsilon/sqrt(10^(0.1*rs)-1);
k = 1/WA;
capk = ellipke([k^2 1-k^2]);
capk1 = ellipke([(k1^2) 1-(k1^2)]);
order = ceil(capk(1)*capk1(2)/(capk(2)*capk1(1)));

% if both warnings are in effect, only print the first one
if (1-k1.^2) == 1
   warning('(ellipord) attenuation too strenuous, estimated order is infinite.')
elseif k^2 == 1
   warning('(ellipord) band edges too close, estimated order is infinite.')
end

% natural frequencies are simply the passband edges (WP).
% finally, transform frequencies from analog to digital if necessary:
if strcmp(opt,'z')	% digital
	wn = wp;
else
	wn = WP;
end
