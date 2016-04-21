function wc = gaincross(z,p,k,rtol)
%GAINCROSS  Finds all 0dB crossings (continuous time).

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/06/11 17:27:45 $

% RE: Assumes k~=0 

% Determine adequate search range and initial set of intervals
nz = length(z);
r = [z;p];
a = real(r);   
b = imag(r);
a(~a) = -eps;
[w,wc] = LocalInitSearch(z,p,k,rtol);
intset = [w(1:end-1) ; w(2:end)];  % each column is an interval

while ~isempty(intset)
   % Estimate max error on each interval
   intsetnew = zeros(2,2*size(intset,2));
   intcount = 0;
   for wint=intset
      % Estimate max interpolation error in y (here x = log(w))
      [y1,y2,x1,x2,eymax] = LocalMaxError(a,b,k,nz,wint(1),wint(2));
      
      % Branch and bound
      [intnew,wcnew] = branchbound(x1,x2,y1,y2,eymax,rtol,1);
      
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
function [w,wc] = LocalInitSearch(z,p,k,rtol)

wc = zeros(1,0);

% Natural frequencies
wn = abs([z;p]);     
wn = sort(wn(wn>0,:)); 
if isempty(wn),
   wn = 1;
end

% Find adequate start frequency W0
% RE: Behavior near w=0 is log(mag) = t + reldeg * log(w)             
iz = (z==0);  ip = (p==0);
reldeg = sum(iz)-sum(ip);
t = sum(log(abs(z(~iz)))) - sum(log(abs(p(~ip)))) + log(abs(k));
if reldeg==0
   % Use mag(w=a*w0) = mag(0) + o(a) for root of mag w0
   w0 = wn(1) * rtol;
   % Include w=0 in WCG if mag at w=0 is is nearly 1
   if abs(t)<sqrt(eps), 
      wc = [wc,0];
   end
else
   % Compute W* such that t + reldeg * log(W*) = 0 and set W0 = min(W(1),W*)/10
   w0 = min(wn(1),exp(-t/reldeg))/10;
end

% Find adequate end frequency Winf
% RE: Behavior near w=Inf is log(mag) = t + reldeg * log(w)  
reldeg = length(z)-length(p);
t = log(abs(k));
if reldeg==0
   winf = wn(end)/rtol;
   % Include w=Inf in WCG if mag at w=Inf is below RTOL
   if abs(t)<rtol, 
      wc = [wc,Inf];
   end
else
   % Compute W* such that t + reldeg * log(W*) = 0 and set 
   % Winf = 10*max(W(end),W*)
   winf = 10 * max(wn(end),exp(-t/reldeg));
end

% Initial frequency grid consist of root natural frequencies
w = [w0 , wn.' , winf];
% Eliminate duplicates with some tolerance
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=1e3*eps*w(2:lw));
w(:,dupes) = [];


%%%%%%%%%%%%%%%%%
% LocalMaxError %
%%%%%%%%%%%%%%%%%
function [y1,y2,x1,x2,eymax] = LocalMaxError(a,b,k,nz,w1,w2)
% Estimates max gap between true magnitude and linear interpolant 
% (in log-log scale) on frequency interval [w1,w2]
% Continuous-time case

x1 = log(w1);
x2 = log(w2);
a2 = a.^2;

% Contribution of each 1st-order component (s-r) at w1 and w2, and slope inbetween
y1 = log(a2+(w1-b).^2)/2;
y2 = log(a2+(w2-b).^2)/2;
s = (y1-y2)/(x1-x2);   

% Error peaks at w solving (s-1)*w^2 + 2*b*(1/2-s)*w + s*(a^2+b^2) =0
alpha = s-1;
beta = b .* (s-0.5);
gamma = s .* (a2+b.^2);
D = sqrt(max(eps,beta.^2-alpha.*gamma));
R = (sign(beta)+(beta==0)) .* (abs(beta) + D);

% First root
alpha(alpha==0) = eps;
w = R./alpha;
ok = (w>w1 & w<w2);
e1 = zeros(size(w));
e1(ok) = abs(log(a2(ok)+(w(ok)-b(ok)).^2)/2 - y1(ok) - s(ok).* (log(w(ok))-x1));

% Second root
w = gamma./R;
ok = (w>w1 & w<w2);
e2 = zeros(size(w));
e2(ok) = abs(log(a2(ok)+(w(ok)-b(ok)).^2)/2 - y1(ok) - s(ok).* (log(w(ok))-x1));

% Max error
eymax = sum(max(e1,e2));

% Total value of log(mag) at w1 and w2
y1 = sum(y1(1:nz)) - sum(y1(nz+1:end)) + log(abs(k));
y2 = sum(y2(1:nz)) - sum(y2(nz+1:end)) + log(abs(k));

% Threshold out roundoff noise (to eliminate spurious crossings in allpass case)
y1 = (abs(y1)>1e3*eps) * y1;
y2 = (abs(y2)>1e3*eps) * y2;
