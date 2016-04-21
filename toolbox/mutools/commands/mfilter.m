% function sys = mfilter(fc,ord,type,psbndr)
%
%  Calculates, as a SYSTEM, a single-input, single-output
%  analog filter.  The cutoff frequency (Hertz) is FC and the
%  filter order is ORD.  The string variable, TYPE,
%  specifies the type of filter and may be one of the
%  following.
%
%    'butterw'     Butterworth
%    'cheby'       Chebyshev
%    'bessel'      Bessel
%    'rc'          series of resistor/capacitor filters
%
%  The dc gain of each filter (except even order Chebyshev)
%  is set to unity.   The argument PSBNDR specifies the
%  Chebyshev passband ripple (in dB).  At the cutoff frequency,
%  the magnitude is -PSBNDR dB.  For even order Chebyshev
%  filters the DC gain is also -PSBNDR dB.
%
%  The Bessel filters are calculated
%  using the recursive polynomial formula.  This is
%  poorly conditioned for high order filters (order > 8).
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = mfilter(fc,ord,type,psbndr)

if nargin ~= 3 & nargin ~= 4,
    disp('Usage: sys = mfilter(fc,ord,type,psbndr)')
    return
    end

if ~isstr(type),
    error('Filter type must be specified with a string variable')
    return
    end

omegac = 2*pi*fc;
if strcmp(type,'butterw'),
    dang = 2*pi/(2*ord);
    pang = [(pi+dang)/2:dang:(3*pi-dang)/2];
    pls = omegac*exp(sqrt(-1)*pang);
    zrs = [];
    sys = zp2sys(zrs,pls);
elseif strcmp(type,'bessel'),
    b1 = [1/omegac,1];
    b2 = [1/omegac^2,3/omegac,1];
    if ord == 1,
        sys = nd2sys(1,b1);
    elseif ord == 2,
        sys = nd2sys(1,b2);
    else
        bn2 = b1;
        bn1 = b2;
        for i = 3:ord,
            bn = [0, (2*i-1)*bn1] + [1/(omegac^2)*bn2,0,0];
            bn2 = bn1;
            bn1 = bn;
            end
        sys = nd2sys(1,bn);
        end
elseif strcmp(type,'cheby'),
    if nargin ~= 4,
        error('passband ripple must be specified for Chebyshev')
        return
        end
    peps = sqrt(10^(abs(psbndr)/10) - 1);
    alpha = 1/peps + sqrt(1+1/peps^2);
    a = (alpha^(1/ord) - alpha^(-1/ord))/2;
    b = (alpha^(1/ord) + alpha^(-1/ord))/2;
    dang = 2*pi/(2*ord);
    pang = [(pi+dang)/2:dang:(3*pi-dang)/2];
    ipls = imag(b*omegac*exp(sqrt(-1)*pang));
    rpls = (omegac*a)^2*(1 - (ipls/(omegac*b)).^2);
    rpls = -1*sqrt(rpls);
    pls = rpls + sqrt(-1)*ipls;
    zrs = [];
    sys = zp2sys(zrs,pls);
elseif strcmp(type,'rc');
    pls = -1*ones(1,ord)*omegac;
    zrs = [];
    sys = zp2sys(zrs,pls);
else
    error('filter specification not recognized')
    end

%	set the dc gain to unity

[a,b,c,d] = unpck(sys);
if strcmp(type,'cheby'),
    fcmag = abs(d + c*inv(sqrt(-1)*omegac*eye(ord)-a)*b);
    gainfact = (1/sqrt(1+peps^2))/fcmag;
else
    gainfact = 1/(d-c/a*b);
    end
gain = sqrt(abs(gainfact));
gainsgn = sign(gainfact);
b = b.*gain;
c = c.*gain.*gainsgn;
d = d.*gain.*gain.*gainsgn;
sys = pck(a,b,c,d);

%--------------------------------------------------------------------
%
%