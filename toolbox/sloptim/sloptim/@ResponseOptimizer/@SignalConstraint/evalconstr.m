function c = evalconstr(this,t,y,gamma)
% Evaluates constraint for given simulation

% Author: P. Gahinet
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:51 $
% Copyright 1986-2004 The MathWorks, Inc.
ns = length(t);
nch = prod(this.SignalSize);
nbnd = size(this.LowerBoundX,1) + size(this.UpperBoundX,1);
if ~hasConstraint(this)
   c = zeros(0,1);
   return
elseif ns==1 && isnan(t)
   % Quick exit if sim failure
   c(1:(nbnd+1)*nch,1) = 1e4 + i;  % greater than REALMAX with log cut off
   return
end

% Initialize C
% RE: Always one row per constraint segment, even if some segments are 
%     beyond T(END). Otherwise size of C is indefined when t=NaN (failure)
c = zeros(nbnd+1,nch);
c(:) = -1;

% Extrapolate lower bound to t(end), discard intervals beyond t(end)
idx = find(this.LowerBoundX(:,1)<t(ns));
lbx = this.LowerBoundX(idx,:);
lby = this.LowerBoundY(idx,:);
lbw = this.LowerBoundWeight(idx);
nlb = size(lbx,1);
if lbx(end)<t(ns)
   slope = diff(lby(nlb,:))/diff(lbx(nlb,:));
   lbx(nlb,2) = t(ns);
   lby(nlb,2) = lby(nlb,1) + slope * (t(ns)-lbx(nlb,1));
end

% Extrapolate upper bound to t(end)
idx = find(this.UpperBoundX(:,1)<t(ns));
ubx = this.UpperBoundX(idx,:);
uby = this.UpperBoundY(idx,:);
ubw = this.UpperBoundWeight(idx);
nub = size(ubx,1);
if ubx(end)<t(ns)
   slope = diff(uby(nub,:))/diff(ubx(nub,:));
   ubx(nub,2) = t(ns);
   uby(nub,2) = uby(nub,1) + slope * (t(ns)-ubx(nub,1));
end

% Compute absolute scale (excluding asymptotes)
yscale = max(abs(lby(:,1))) + max(abs(uby(:,1)));

% Compute normalized violation for each lower bound segment
%   cj = max_{t in Ij} ylb-y(t)-(1-wlb)*gamma
for ct=1:nlb
   idx = find(t>=lbx(ct,1) & t<=lbx(ct,2));
   if isempty(idx)
      c(ct,:) = -1;
   else
      if lby(ct,1)==lby(ct,2)
         ylb = lby(ct,1);
      else
         ylb = interp1(lbx(ct,:),lby(ct,:),t(idx));
      end
      ynorm = abs(ylb) + 0.01 * yscale;
      for ctc=1:nch
         c(ct,ctc) =  max((ylb-y(idx,ctc))./ynorm) - (1-lbw(ct)) * gamma;
      end
   end
end

% Compute violation for each upper bound segment
%   cj = max_{t in Ij} y-yub-(1-wub)*gamma
for ct=1:nub
   idx = find(t>=ubx(ct,1) & t<=ubx(ct,2));
   if isempty(idx)
      c(nlb+ct,:) = -1;
   else
      if uby(ct,1)==uby(ct,2)
         yub = uby(ct,1);
      else
         yub = interp1(ubx(ct,:),uby(ct,:),t(idx));
      end
      ynorm = abs(yub) + 0.01 * yscale;
      for ctc=1:nch
         c(nlb+ct,ctc) =  max((y(idx,ctc)-yub)./ynorm) - (1-ubw(ct)) * gamma;
      end
   end
end

% Safeguard against instability
idx = (c>10);
c(idx) = 10*(1+log(c(idx)/10));

% Add stability constraint
if t(end)>max(this.LowerBoundX(end,1),this.UpperBoundX(end,1))
   for ct=1:nch
      c(end,ct) = 100 * localStabilityConstraint(this,t,y(:,ct));
   end
end

% Vectorize
c = c(:);

%---------------------- Local Functions ------------------------------

function sc = localStabilityConstraint(this,t,y)
% Penalty against unstable asymptotic behavior
ns = length(t);

% Compute equation y = alb*x + blb of lower asymptote
lbx = this.LowerBoundX;
lby = this.LowerBoundY;
nlb = size(lbx,1);
alb = diff(lby(nlb,:))/diff(lbx(nlb,:));
blb = lby(nlb,1) - alb * lbx(nlb,1);

% Compute equation y = aub*x + bub of upper asymptote
ubx = this.UpperBoundX;
uby = this.UpperBoundY;
nub = size(ubx,1);
aub = diff(uby(nub,:))/diff(ubx(nub,:));
bub = uby(nub,1) - aub * ubx(nub,1);

% Extract portion of signal in asymptote region [ta,t(end)]
ta = max(this.LowerBoundX(end,1),this.UpperBoundX(end,1));
idx = find(t>=ta);
t = t(idx);
y = y(idx);

% Check if signal lies inside feasible region
isFeasible = all(y<=aub*t+bub & y>=alb*t+blb);

% Compute deviation from asymptote
a = (alb+aub)/2;
b = (blb+bub)/2;
dy = (y-(a*t+b)).^2;

% Scaling factor
Escale = (max(abs(alb*t+blb)+abs(aub*t+bub))/2)^2;

% Compute energy E(t) of error signal dy
E = cumsum(diff(t).*(dy(1:end-1)+dy(2:end))/2);

% Constraint is E <= Emax where Emax is the max energy of a signal that
% stays within the specified bound
dy = ((aub-alb)*t+(bub-blb)).^2/4;
Emax = sum(diff(t).*(dy(1:end-1)+dy(2:end))/2);

% Delete points where E=0
idx = find(E>0);
E = E(idx);
t = t(1+idx);

% Fit linear model y = a*t+b to log(E(t)) and use this model to estimate
% e=log(E(t(end)))
if isempty(E)
   Ef = 0;
else
   ab = [t ones(size(t))]\log(E);
   Ef = exp([t(end) 1]*ab);
end
% sc = Ef-Emax;
sc = log(1+Ef/Escale)-log(1+Emax/Escale);

% Watch for NaN when goes unstable
if ~isfinite(sc)
   sc = 1e4 + i;
elseif isFeasible
   % Protect against inconsistent positive value due to errors on Ef estimate
   % (cf g200430)
   sc = min(sc,0);  
end
