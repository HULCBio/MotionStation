function wc = dphasecross(z,p,k,Ts,Td,rtol,wc0)
%DPHASECROSS  Finds all 180 degree crossings (discrete time).

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/06/11 17:27:41 $

% RE: * Assumes k~=0 
%     * Td always in seconds

% Relative degree 
nz = length(z);

% Phase at DC (z=1)
isder = (z==1);
isint = (p==1);
DCdeg = sum(isder)-sum(isint);
DCgain = k * real(prod(1-z(~isder,:))) / real(prod(1-p(~isint,:)));  
PhaseDC = (DCgain<0)*pi + DCdeg*pi/2;

% Quick exit for flat phase (pure gain) 
if ~Td & (all(isder) & all(isint))
   if abs(mod(PhaseDC,2*pi)-pi)<pi/4
      % Flat phase = -180
      wc = 0;
   else
      wc = zeros(1,0);
   end
   return
end

% Keep damping>=1e-5 for faster convergence
MINDAMP = 1e-5;
r = [z;p];
rho = abs(r);  
phi = angle(r);
[wn,zeta] = damp(r,Ts);
lowd = (abs(zeta)<MINDAMP);
zeta(lowd) = MINDAMP * sign(0.5-(zeta(lowd)<-100*eps));
rho(lowd) = exp(-zeta(lowd).*wn(lowd)*Ts);

% Determine adequate search range and initial set of interval
[w,wc,wxint] = LocalInitSearch(wn,Ts,Td/Ts,PhaseDC,phi,z,p,k,wc0);
intset = [[w(:,1:end-1) ; w(:,2:end)] , wxint];  % each column is an interval

while ~isempty(intset)
   % Estimate max error on each interval
   intsetnew = zeros(2,2*size(intset,2));
   intcount = 0;
   for wint=intset
      w1 = wint(1);
      w2 = wint(2);
      
      % Estimate max interpolation error in y=f(w).  
      [y1,y2,eymax] = LocalMaxError(rho,phi,k,Ts,Td,nz,w1,w2);
      
      if abs(y2-y1)>=2*pi & log(w2/w1)>2*eps*(abs(log(w1))+abs(log(w2)))
         % Split in half (can only handle one crossing at a time)
         wm = sqrt(w1*w2); 
         intsetnew(:,intcount+[1 2]) = [w1 wm;wm w2];
         intcount = intcount+2;
      else
         % Find line pi+2*m*pi closest to (y1+y2)/2 and
         % look for crossings of this line
         m = round(((y1+y2)/2-pi)/2/pi);
         y1 = y1 - (2*m+1)*pi;
         y2 = y2 - (2*m+1)*pi;
         
         % Branch and bound
         [intnew,wcnew] = branchbound(w1,w2,y1,y2,eymax,rtol,0);
         
         % Update WC and interval list for next cycle
         wc = [wc,wcnew];
         lnew = size(intnew,2);  % # of new intervals
         intsetnew(:,intcount+1:intcount+lnew) = intnew;
         intcount = intcount+lnew;
      end
   end
   intset = intsetnew(:,1:intcount);
end

% Sort crossing values
wc = unique(wc);


%-------------- Local functions ---------------------

%%%%%%%%%%%%%%%%%%%
% LocalInitSearch %
%%%%%%%%%%%%%%%%%%%
function [w,wc,wxint] = LocalInitSearch(wn,Ts,nTd,PhaseDC,phi,z,p,k,wc0)
% RE: nTd = delay in number of sample periods
wc = zeros(1,0);
wxint = zeros(2,0);  % extra search intervals for large delays
nf = pi/Ts;          % Nyquist frequency

% Determine start freq. W0 (keep w0*nTd < 90 deg)
wmin = min(wn(wn>0,:)); 
if isempty(wmin),
   wmin = nf/10;
end
w0 = min([wmin/100 , (0.45*nf)./nTd(:,nTd>0)]);
if abs(mod(PhaseDC,2*pi)-pi)<pi/4,
   wc = [wc , 0];  % phase crossing at w=0
end

% Set last freq Winf to Nyquist frequency
% RE: Use value slightly above pi to prevent missing crossing at pi
winf = (1+1e5*eps)*nf;
if nTd
   % For large delays, limit number of phase crossings to search for
   % by restricting search to vicinity of local minima of |log(|H(jw)|)| 
   % (crossings with minimum margin). See geck 130943 for example 
   w20 = 20*nf/nTd;  
   if w20<winf
      wxint = LocalFindKeyCrossings(z,p,k,Ts,nTd,w20,winf,wc0(wc0>w20));
      winf = min(winf,w20);
   end
end

% Initial frequency grid consists of values angle(r)/Ts falling in [w0,winf]
phi = phi/Ts;
w = phi(phi>w0 & phi<winf,:);

% Initial frequency grid
w = sort([w0 , w.' , (1+sqrt(eps))*winf]);
% Eliminate duplicates with some tolerance
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=1e3*eps*w(2:lw));
w(:,dupes) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalFindKeyCrossings %
%%%%%%%%%%%%%%%%%%%%%%%%%
function wxint = LocalFindKeyCrossings(z,p,k,Ts,nTd,wmin,wmax,wc0)
% Note: all frequencies normalized for Ts=1
nf = pi/Ts;
% Pick frequency grid in range [wmin,wmax]
% RE: Add 10 points spaced by 2*pi/nTd near Nyquist frequency pi 
%     (can be local gain minimum)
ws = [freqpick({z},{p},Ts,nTd,3,[wmin,wmax]) ; nf-(2*nf/nTd)*(10:-1:1)'];
ws = ws(ws>=wmin);
lws = length(ws);
% Compute abs.log. of response magnitude
lgain(1:lws,1) = log(abs(k));
WarnState = warning('off');
for ct=1:lws
   zs = exp(1i*ws(ct)*Ts);
   lgain(ct) = lgain(ct) + sum(log(abs(zs-z))) - sum(log(abs(zs-p)));
end
warning(WarnState)
lgain = abs(lgain);
% Look for gain extrema where gain margin is small
% RE: Keep only frequencies within factor 4 of min
thresh = 0.6 + (isempty(wc0));
ws = ws(lgain<min(lgain)+thresh);  
% Add 0dB crossings and eliminate duplicates 
ws = sort([ws ; wc0(:)]);
w2ls = ws(2:end);
dupes = find(isfinite(w2ls) & w2ls-ws(1:end-1)<=1e5*eps*w2ls);
ws(dupes,:) = [];
% Construct set of extra test intervals
CrossingSep = 2*nf/nTd;
LowerLimit = min(CrossingSep,(ws-[wmin;ws(1:end-1)])/2);
UpperLimit = min(CrossingSep,([ws(2:end);wmax]-ws)/2);
wxint = [ws - LowerLimit , ws + UpperLimit].';


%%%%%%%%%%%%%%%%%
% LocalMaxError %
%%%%%%%%%%%%%%%%%
function [y1,y2,eymax] = LocalMaxError(rho,phi,k,Ts,Td,nz,w1,w2)
% Estimates max gap between true phase and linear interpolant 
% (in linear scale) on frequency interval [w1,w2].
% Discrete-time case

th1 = w1*Ts;
th2 = w2*Ts;
eymax = [];
pi2 = 2*pi;

% Contribution of each 1st-order component z-r at w1 and w2, 
% RE: To prevent phase wrapping, compute phase as angle(z)+angle(1-r/z) if |r|<1 
%     and angle(-r)+angle(1-z/r) if |r|>1
isgt1 = (rho>=1);
rz1 = rho .* exp(j*(phi-th1));  % r/z1 where z1 = exp(j*w1*Ts)
p1 = zeros(size(rho));
p1(~isgt1) = th1 + angle(1-rz1(~isgt1));   % angle(1-r/z1)
p1(isgt1) = pi + phi(isgt1) + angle(1-1./rz1(isgt1));

rz2 = rho .* exp(j*(phi-th2));  % r/z2 where z2 = exp(j*w2*Ts)
p2 = zeros(size(rho));
p2(~isgt1) = th2 + angle(1-rz2(~isgt1));
p2(isgt1) = pi + phi(isgt1) + angle(1-1./rz2(isgt1));

s = (p2-p1)/(th2-th1);  % slopes

% Total phase at w1 and w2
y1 = sum(p1(1:nz)) - sum(p1(nz+1:end)) + (k<0)*pi - w1*Td;
y2 = sum(p2(1:nz)) - sum(p2(nz+1:end)) + (k<0)*pi - w2*Td;
if abs(y2-y1)>=2*pi
   return
end
% Threshold out roundoff noise (to avoid spurious crossings in flat phase case)
y1 = (abs(y1)>1e3*eps) * y1;
y2 = (abs(y2)>1e3*eps) * y2;

% Error peaks at th=w*Ts solving cos(th-phi) = ((1+rho^2)*s-1)/rho/(2s-1)
alpha = (1+rho.^2).*s-1;
beta = rho.*(2*s-1);
beta(~beta) = eps;
ac = acos(max(-1,min(1,alpha./beta))); % in [0,pi]

% First root
th = phi-ac;
th = th - pi2*floor(th/pi2);
ok = (th>th1 & th<th2);
e1 = zeros(size(th));
okgt = find(ok & isgt1);
e1(okgt) = abs(pi + phi(okgt) + angle(1-exp(j*(th(okgt)-phi(okgt)))./rho(okgt)) - ...
   p1(okgt) - s(okgt).* (th(okgt)-th1));
oklt = find(ok & ~isgt1);
e1(oklt) = abs(th(oklt) + angle(1-rho(oklt).*exp(j*(phi(oklt)-th(oklt)))) - ...
   p1(oklt) - s(oklt).* (th(oklt)-th1));

% Second root
th = phi+ac;
th = th - pi2*floor(th/pi2);
ok = (th>th1 & th<th2);
e2 = zeros(size(th));
okgt = find(ok & isgt1);
e2(okgt) = abs(pi + phi(okgt) + angle(1-exp(j*(th(okgt)-phi(okgt)))./rho(okgt)) - ...
   p1(okgt) - s(okgt).* (th(okgt)-th1));
oklt = find(ok & ~isgt1);
e2(oklt) = abs(th(oklt) + angle(1-rho(oklt).*exp(j*(phi(oklt)-th(oklt)))) - ...
   p1(oklt) - s(oklt).* (th(oklt)-th1));

% Bound on interpolation error
eymax = sum(max(e1,e2));

