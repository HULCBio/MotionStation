function [numd,dend]=cp2dp(num,den,T,Td)

%CP2DP	Convert a continuous SISO transfer function to discrete.
%	[numd,dend]=cp2dp(num,den,delt,delay)
%
% CP2DP converts a continuous SISO transfer function with numerator
% and denominator polynomials "num" and "den", respectively,
% into the corresponding discrete-time versions, "numd" and "dend".
% "delt" is the sampling period.
% "delay" is the time delay (>= 0) in same units as "delt".
%
% See also POLY2TFD.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  [numd,dend]=cp2dp(num,den,delt,delay)')
   return
elseif nargin < 3
   error('CP2DP requires at least 3 input arguments')
elseif nargin < 4
   Td=0;
end

[mden,n]=size(den);
if all(den == 0)
   error('DEN must be non-zero')
elseif isempty(den) | isempty(num)
   error('NUM or DEN is an empty matrix')
elseif mden > 1
   error('DEN has more than 1 row')
end

% Strip leading zeros from denominator, removing equal number
% from numerator.

[nrow,ncol]=size(num);
if ncol < n
   num=[zeros(nrow,n-ncol) num];    % pad numerator if necessary
end
inz = find(den ~= 0);
den = den(inz(1):n);
[mden,n] = size(den);
if nrow ~= 1 | mden ~= 1
    error('Transfer function polynomials must have only 1 row')
end
nextra=ncol-n;
while nextra > 0
   if any(num(:,1) > 0)
      error('Order of numerator greater than denominator')
   end
   num(:,1)=[];
   nextra=nextra-1;
end

% Convert to continuous state-space

[a,b,c,d]=tf2ssm(num,den);

% Account for fractional time delay using formulas in Astrom
% and Wittenmark, 1984, pages 40-42.

kd=fix(Td/T);
del=Td-kd*T;
if abs(del) < eps
    del=0;
end
[n,n] = size(a);
s = expm([[a b]*T; zeros(1,n+1)]);
phi = s(1:n,1:n);
gam = s(1:n,n+1);
if del > 0
   s = expm([[a b]*(T-del); zeros(1,n+1)]);
   phi0 = s(1:n,1:n);
   gam0 = s(1:n,n+1);
   s = expm([[a b]*del; zeros(1,n+1)]);
   phi1 = s(1:n,1:n);
   gam1 = s(1:n,n+1);
   gam1=phi0*gam1;
   phi=[  phi         gam1
        zeros(1,n)      0  ];
   gam=[ gam0
           1  ];
   c=[c 0];
end

% Convert to discrete transfer function

if isempty(gam)
   numd=d;
   dend=1;
else
   [numd,dend]=ss2tf2(phi,gam,c,d,1);
end

% Add pure time delay

if kd > 0
    numd=[ zeros(1,kd)    numd    ];
    dend=[   dend      zeros(1,kd)];
end

%%% end of function cp2dp.m %%%%