function wc = dgaincross(z,p,k,Ts,rtol)
%DGAINCROSS  Finds all 0dB crossings (discrete time).

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/06/11 17:27:46 $

% RE: Assumes k~=0 

% Determine adequate search range and initial set of intervals
nz = length(z);
r = [z;p];
phi = angle(r);
rho = abs(r);  
rho(rho==1) = 1-1e2*eps;
[w,wc] = LocalInitSearch(z,p,k,Ts,phi,rtol);
intset = [w(1:end-1) ; w(2:end)];  % each column is an interval

while ~isempty(intset)
   % Estimate max error on each interval
   intsetnew = zeros(2,2*size(intset,2));
   intcount = 0;
   for wint=intset
      % Estimate max interpolation error in y 
      [y1,y2,eymax] = LocalMaxError(rho,phi,k,Ts,nz,wint(1),wint(2));
      
      % Branch and bound
      [intnew,wcnew] = branchbound(wint(1),wint(2),y1,y2,eymax,rtol,0);
      
      % Update WC and interval list for next cycle
      wc = [wc,wcnew];
      lnew = size(intnew,2);  % # of new intervals
      intsetnew(:,intcount+1:intcount+lnew) = intnew;
      intcount = intcount+lnew;
   end
   intset = intsetnew(:,1:intcount);
end

% Sort crossing values
wc = unique(wc);   


%-------------- Local functions ---------------------

%%%%%%%%%%%%%%%%%%%
% LocalInitSearch %
%%%%%%%%%%%%%%%%%%%
function [w,wc] = LocalInitSearch(z,p,k,Ts,phi,rtol)

wc = zeros(1,0);

% Natural frequencies
wn = damp([z;p],1);  % normalized freqs for Ts=1
wmin = min(wn(wn>0,:)); 
if isempty(wmin),
   wmin = 1;
end

% Find adequate start frequency W0
% RE: Behavior near w=0 is log(mag) = t + reldeg * log(2*sin(w*Ts/2))
iz = (z==1);  ip = (p==1);
reldeg = sum(iz)-sum(ip);
t = sum(log(abs(1-z(~iz)))) - sum(log(abs(1-p(~ip)))) + log(abs(k));
if reldeg==0
   % Use mag(w=a*w0) = mag(0) + o(a) for root of mag w0
   w0 = wmin * rtol;
   % Include w=0 in WCG if mag at w=0 is nearly 1
   if abs(t)<sqrt(eps), 
      wc = [wc,0];
   end
else
   % Compute W* such that t + reldeg * log(2*sin(W*/2)) = 0 and 
   % set W0 = min(WMIN,W*)/10
   w0 = min(wmin,2*asin(exp(-t/reldeg)/2))/10;  % for Ts=1
end

% End frequency WINF is Nyquist frequency pi/Ts
winf = pi;  % for Ts=1

% Initial frequency grid consist of phi falling in [w0,winf]*Ts
w = phi(phi>w0 & phi<winf,:);

% Finalize W
w = sort([w0 , w.' , (1+sqrt(eps))*winf])/Ts;
% Eliminate duplicates with some tolerance
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=1e3*eps*w(2:lw));
w(:,dupes) = [];


%%%%%%%%%%%%%%%%%
% LocalMaxError %
%%%%%%%%%%%%%%%%%
function [y1,y2,eymax] = LocalMaxError(rho,phi,k,Ts,nz,w1,w2)
% Estimates max gap between true magnitude and linear interpolant 
% (in linear-log scale) on frequency interval [w1,w2]
% Discrete-time case

th1 = w1*Ts;
th2 = w2*Ts;
pi2 = 2*pi;

% Contribution of each 1st-order component (s-r) at w1 and w2, and slope inbetween
r = rho .* exp(j*phi);
y1 = log(abs(exp(j*th1)-r));
y2 = log(abs(exp(j*th2)-r));
s = (y1-y2)/(th1-th2);   

% Error peaks at th=w*Ts solving sin(th-phi)+2*s*cos(th-phi) = s(1+rho^2)/rho
% Rewrite as cos(th-phi-psi) = s(1+rho^2)/rho/sqrt(1+4*s^2)
psi = atan2(1,2*s);
alpha = s.*(1+rho.^2);
beta = rho.*sqrt(1+4*s.^2);
beta(beta==0) = eps;
ac = acos(max(-1,min(1,alpha./beta)));

% First root of peak error equation
th = phi+psi-ac;
th = th - pi2*floor(th/pi2);  % mod(th,2*pi)
ok = (th>th1 & th<th2);
e1 = zeros(size(th));
e1(ok) = abs(log(abs(exp(j*th(ok))-r(ok))) - y1(ok) - s(ok).* (th(ok)-th1));

% Second root
th = phi+psi+ac;
th = th - pi2*floor(th/pi2);  % mod(th,2*pi)
ok = (th>th1 & th<th2);
e2 = zeros(size(th));
e2(ok) = abs(log(abs(exp(j*th(ok))-r(ok))) - y1(ok) - s(ok).* (th(ok)-th1));

% Bound on total error
eymax = sum(max(e1,e2));

% Total value of log(mag) at w1 and w2
y1 = sum(y1(1:nz)) - sum(y1(nz+1:end)) + log(abs(k));
y2 = sum(y2(1:nz)) - sum(y2(nz+1:end)) + log(abs(k));

% Threshold out roundoff noise (to eliminate spurious crossings in allpass case)
y1 = (abs(y1)>1e3*eps) * y1;
y2 = (abs(y2)>1e3*eps) * y2;
