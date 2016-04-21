function stepspec(this,T0,Y0,Yf,Specs)
% Constraints step response constraint.
% 
%   SPECS is a structure with fields RiseTime, SettlingTime,
%   OverShoot, UnderShoot, PercentRise, and PercentSettling.

% Author: P. Gahinet
% Copyright 1986-2003 The MathWorks, Inc.

% Error checking
if ~isscalar(T0) || ~isreal(T0)
   error('Step time must be a real scalar')
elseif ~isscalar(Y0) || ~isreal(Y0)
   error('Initial value must be a real scalar')
elseif ~isscalar(Yf) || ~isreal(Yf)
   error('Initial value must be a real scalar')
elseif Yf==Y0
   error('Initial and final values must be distinct.')
end

% SPECS fields
RiseTime = Specs.RiseTime;
SettleTime = Specs.SettlingTime;
if ~isscalar(RiseTime) || ~isreal(RiseTime) || RiseTime<=T0
   error('Rise time must be a scalar value greater than the step time.')
elseif ~isscalar(SettleTime) || ~isreal(SettleTime) || SettleTime<=RiseTime
   error('Settling time must be a scalar value greater than the rise time.')
elseif ~isscalar(Specs.PercentSettling) || ~isreal(Specs.PercentSettling) || ...
      Specs.PercentSettling<=0
   error('Percent settling must be a positive scalar.')
elseif ~isscalar(Specs.PercentRise) || ~isreal(Specs.PercentRise) || ...
      Specs.PercentRise<=0
   error('Percent rise must be a positive scalar.')
elseif ~isscalar(Specs.UnderShoot) || ~isreal(Specs.UnderShoot) || ...
      Specs.UnderShoot<=0
   error('Percent overshoot must be a positive scalar.')
elseif ~isscalar(Specs.OverShoot) || ~isreal(Specs.OverShoot) || ...
      Specs.OverShoot<=0
   error('Percent overshoot must be a positive scalar.')
end

% Final time and settling tolerance
ValueRange = Yf-Y0;
Tf = 1.5*SettleTime;
SettleTol = ValueRange*Specs.PercentSettling/100;

% Setup for the lower bound
Ymin = Y0-ValueRange*(Specs.UnderShoot/100);
Rise = Y0+ValueRange*(Specs.PercentRise/100);
SettleMin = Yf-SettleTol;

% Setup for the upper bound
Ymax = Yf+ValueRange*(Specs.OverShoot/100);
SettleMax = Yf+SettleTol;

% Specify bounds
lbx = [...
   T0 RiseTime;...
   RiseTime SettleTime;...
   SettleTime Tf];
lby = [...
   Ymin Ymin;...
   Rise Rise;...
   SettleMin SettleMin];
lbw = ones(3,1);
ubx = [...
   T0 SettleTime;...
   SettleTime Tf];
uby = [...
   Ymax Ymax;...
   SettleMax SettleMax];
ubw = ones(2,1);

if ValueRange>0
   this.LowerBoundX = lbx;
   this.LowerBoundY = lby;
   this.LowerBoundWeight = lbw;
   this.UpperBoundX = ubx;
   this.UpperBoundY = uby;
   this.UpperBoundWeight = ubw;
else
   this.LowerBoundX = ubx;
   this.LowerBoundY = uby;
   this.LowerBoundWeight = ubw;
   this.UpperBoundX = lbx;
   this.UpperBoundY = lby;
   this.UpperBoundWeight = lbw;   
end
   
