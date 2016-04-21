function wc = phasecross(z,p,k,Td,rtol,wc0)
%PHASECROSS  Finds all 180 degree crossings (continuous time).

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/06/11 17:27:37 $

% RE: * Assumes k~=0 
%     * Td always in seconds
%     * wc0 = 0dB crossing frequencies

nz = length(z);

% Phase at DC (s=0)
isder = (z==0);
isint = (p==0);
DCdeg = sum(isder)-sum(isint);
DCgain = k * real(prod(-z(~isder,:))) / real(prod(-p(~isint,:)));  
PhaseDC = (DCgain<0)*pi + DCdeg*pi/2;

% Quick exit for pure integrator/derivator 
if ~Td & (all(isder) & all(isint))
   if abs(mod(PhaseDC,2*pi)-pi)<pi/4
      % Flat phase = -180
      wc = abs(k)^(-1/DCdeg);  % pick crossing where gain=1
   else
      wc = zeros(1,0);
   end
   return
end
   
% Keep damping>=1e-5 for faster convergence
MINDAMP = 1e-5;
r = [z;p];
a = real(r);   
b = imag(r);
[wn,zeta] = damp(r); 
lowd = (abs(zeta)<MINDAMP);
zeta(lowd) = MINDAMP * sign(0.5-(zeta(lowd)<-100*eps));
a(lowd) = -zeta(lowd) .* wn(lowd);

% Determine adequate search range and initial set of intervals
[w,wc,wxint] = LocalInitSearch(wn,Td,PhaseDC,z,p,k,wc0);
intset = [[w(:,1:end-1) ; w(:,2:end)] , wxint];  % each column is an interval

while ~isempty(intset)
   % Estimate max error on each interval
   intsetnew = zeros(2,2*size(intset,2));
   intcount = 0;
   for wint=intset
      % Estimate max interpolation error in y=f(log(w)).  RE: output x = log(w)
      [y1,y2,x1,x2,eymax] = LocalMaxError(a,b,k,Td,nz,wint(1),wint(2));
      
      if abs(y2-y1)>=2*pi & x2-x1>2*eps*(abs(x1)+abs(x2))
         % Split in half (can only handle one crossing at a time)
         xc = (x1+x2)/2; 
         intsetnew(:,intcount+[1 2]) = exp([x1 xc;xc x2]);
         intcount = intcount+2;
      else
         % Find line pi+2*m*pi closest to (y1+y2)/2 and
         % look for crossings of this line
         m = round(((y1+y2)/2-pi)/2/pi);
         y1 = y1 - (2*m+1)*pi;
         y2 = y2 - (2*m+1)*pi;
         
         % Branch and bound
         [intnew,wcnew] = branchbound(x1,x2,y1,y2,eymax,rtol,1);
         
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


%%%%%%%%%%%%%%%%%%%%%
% LocalInitSearch %
%%%%%%%%%%%%%%%%%%%%%
function [w,wc,wxint] = LocalInitSearch(wn,Td,PhaseDC,z,p,k,wc0)

% Relative degree 
reldeg = length(z)-length(p);
wc = zeros(1,0);
wxint = zeros(2,0);  % extra search intervals for large delays

% Natural frequencies
wn = sort(wn(wn>0,:));
if isempty(wn),
   wn = 1;
end

% Determine start freq. W0 (keep w0*Td < 90 deg)
w0 = min([wn(1)/100 , (0.45*pi)./Td(:,Td>0)]);
if abs(mod(PhaseDC,2*pi)-pi)<pi/4,
   wc = [wc , 0];  % phase crossing at w=0
end

% Set last freq Winf to 100*fastest root
winf = 100*wn(end);
PhaseInf = (k<0) * pi + reldeg * pi/2;
if Td
   % Add one phase crossing past winf corresponding to 
   % min. gain margin.  The phase crossings are  
   %     PhaseInf - w*Td = -(2*m+1)*pi  for w>=winf 
   % and the corresponding gain is appx  k*s^reldeg.  Look for value of m 
   % minimizing gain margin 
   if reldeg
      minf = ceil((winf*Td-PhaseInf-pi)/2/pi); 
      w0db = abs(k)^(-1/reldeg);  % gain crossing freq 
      m0db = round((w0db*Td-PhaseInf-pi)/2/pi); 
      wc = [wc , (PhaseInf+(2*max(minf,m0db)+1)*pi)/Td]; 
   end      
   % For large delays, limit number of phase crossings to search for
   % by restricting search to vicinity of local minima of |log(|H(jw)|)| 
   % (crossings with minimum margin). See geck 130943 for example 
   w20 = 20*pi/Td;  
   if w20<winf
      wxint = LocalFindKeyCrossings(z,p,k,Td,w20,winf,wc0(wc0>w20 & wc0<Inf));
      winf = w20;
      wn = wn(wn<w20,:);
   end
elseif abs(mod(PhaseInf,2*pi)-pi)<pi/4,
   % Add phase crossing at w=Inf
   wc = [wc , Inf]; 
end

% Initial frequency grid
w = [w0 , wn.' , winf];
% Eliminate duplicates with some tolerance
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=1e3*eps*w(2:lw));
w(:,dupes) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalFindKeyCrossings %
%%%%%%%%%%%%%%%%%%%%%%%%%
function wxint = LocalFindKeyCrossings(z,p,k,Td,wmin,wmax,wc0)
% Pick frequency grid in range [wmin,wmax]
ws = freqpick({z},{p},0,Td,3,[wmin,wmax]);
lws = length(ws);
% Compute abs.log. of response magnitude
lgain(1:lws,1) = log(abs(k));
WarnState = warning('off');
for ct=1:lws
   jws = 1i*ws(ct);
   lgain(ct) = lgain(ct) + sum(log(abs(jws-z))) - sum(log(abs(jws-p)));
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
CrossingSep = 2*pi/Td;
LowerLimit = min(CrossingSep,(ws-[wmin;ws(1:end-1)])/2);
UpperLimit = min(CrossingSep,([ws(2:end);wmax]-ws)/2);
wxint = [ws - LowerLimit , ws + UpperLimit].';


%%%%%%%%%%%%%%%%%
% LocalMaxError %
%%%%%%%%%%%%%%%%%
function [y1,y2,x1,x2,eymax] = LocalMaxError(a,b,k,Td,nz,w1,w2)
% Estimates max gap between true phase and linear interpolant 
% (in semilogx scale) on frequency interval [w1,w2].
% Continuous-time case

np = length(a)-nz;  % number of poles
x1 = log(w1);
x2 = log(w2);
eymax = [];

% Phase contribution of each 1st-order component s-r at w1 and w2
% RE: Write jw-(a+jb) = j((w-b)+ja) to prevent phase wrapping
p1 = atan2(a,w1-b);   % true phase is p1+pi/2
p2 = atan2(a,w2-b);   % true phase is p2+pi/2
s = (p1-p2)/(x1-x2);  % slopes

% Total phase at w1 and w2
y1 = sum(p1(1:nz)) - sum(p1(nz+1:nz+np)) + (nz-np) * pi/2 + pi*(k<0) - w1*Td;
y2 = sum(p2(1:nz)) - sum(p2(nz+1:nz+np)) + (nz-np) * pi/2 + pi*(k<0) - w2*Td;
if abs(y2-y1)>=2*pi
   return
end
% Threshold out roundoff noise (to avoid spurious crossings in flat phase case)
y1 = (abs(y1)>1e3*eps) * y1;
y2 = (abs(y2)>1e3*eps) * y2;

% Error peaks at s solving s w^2 + 2 (a/2-b*s) w + s(a^2+b^2) = 0
alpha = s;
beta = b.*s-a/2;
gamma = s .* (a.^2+b.^2);
D = sqrt(max(eps,beta.^2-alpha.*gamma));
R = (sign(beta)+(~beta)) .* (abs(beta) + D);

% First root
alpha(~alpha) = eps;
w = R./alpha;
ok = (w>w1 & w<w2);
e1 = zeros(size(w));
e1(ok) = abs(atan2(a(ok),w(ok)-b(ok)) - p1(ok) - s(ok).* (log(w(ok))-x1));

% Second root
w = gamma./R;
ok = (w>w1 & w<w2);
e2 = zeros(size(w));
e2(ok) = abs(atan2(a(ok),w(ok)-b(ok)) - p1(ok) - s(ok).* (log(w(ok))-x1));

% Max error
eymax = sum(max(e1,e2));

% Add delay contribution (error peaks at w = (w2-w1)/(x2-x1))
if Td
   w = (w2-w1)/(x2-x1);
   s = (w2-w1)*Td/(x1-x2);
   eymax = eymax + abs((w1-w)*Td-s*(log(w)-x1));
end

