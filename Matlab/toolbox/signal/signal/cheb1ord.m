function [order,wn] = cheb1ord(wp,ws,rp,rs,opt)
%CHEB1ORD Chebyshev Type I filter order selection.
%   [N, Wn] = CHEB1ORD(Wp, Ws, Rp, Rs) returns the order N of the lowest 
%   order digital Chebyshev Type I filter that loses no more than Rp dB 
%   in the passband and has at least Rs dB of attenuation in the stopband.  
%   Wp and Ws are the passband and stopband edge frequencies, normalized 
%   from 0 to 1 (where 1 corresponds to pi radians/sample). For example,
%       Lowpass:    Wp = .1,      Ws = .2
%       Highpass:   Wp = .2,      Ws = .1
%       Bandpass:   Wp = [.2 .7], Ws = [.1 .8]
%       Bandstop:   Wp = [.1 .8], Ws = [.2 .7]
%   CHEB1ORD also returns Wn, the Chebyshev natural frequency to use with 
%   CHEBY1 to achieve the specifications.
%
%   [N, Wn] = CHEB1ORD(Wp, Ws, Rp, Rs, 's') does the computation for an 
%   analog filter, in which case Wp and Ws are in radians/second.
%
%   See also CHEBY1, CHEB2ORD, BUTTORD, ELLIPORD.

%   References: Rabiner and Gold, p 241.

%   Author(s): L. Shure, 6-9-88
%              T. Krauss, 11-13-92, revised
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/11/21 15:47:03 $

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
	WPA=tan(pi*wp/2);
	WSA=tan(pi*ws/2);
else  % don't have to if analog already
	WPA=wp;
	WSA=ws;
end

% next, transform to low pass prototype with passband edge of 1 and stopband
% edges determined by the following: (see Rabiner and Gold, p.258)
if ftype == 1	% low
	WA=WSA/WPA;
elseif ftype == 2	% high
	WA=WPA/WSA;
elseif ftype == 3	% stop
	fo = optimset('display','none');
	wp1 = lclfminbnd('bscost',WPA(1),WSA(1)-1e-12,fo,1,...
                      WPA,WSA,rs,rp,'cheby');
	WPA(1) = wp1;
	wp2 = lclfminbnd('bscost',WSA(2)+1e-12,WPA(2),fo,2,...
                      WPA,WSA,rs,rp,'cheby');
	WPA(2) = wp2;
	WA=(WSA*(WPA(1)-WPA(2)))./(WSA.^2 - WPA(1)*WPA(2));
elseif ftype == 4	% pass
	WA=(WSA.^2 - WPA(1)*WPA(2))./(WSA*(WPA(1)-WPA(2)));
end

% find the minimum order cheby. type 1 filter to meet the more demanding spec:
WA=min(abs(WA));
order=ceil(acosh(sqrt((10^(.1*abs(rs))-1)/(10^(.1*abs(rp))-1)))/acosh(WA));
% ref: M.E. Van Valkenburg, "Analog Filter Design", p.232, eqn 8.39

% natural frequencies are simply the passband edges (WPA).
% finally, transform frequencies from analog to digital if necessary:
if strcmp(opt,'z')	% digital
    wn = wp;
else
	wn = WPA;
end
