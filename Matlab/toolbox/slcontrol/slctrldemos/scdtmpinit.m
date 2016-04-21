
% Copyright 2004 The MathWorks, Inc.

dt = 0.5;
%%%%%%%%%%%%%%%  Primary refiner
mlp0=8.5;     %  Nominal load   (MW)
Cp0=0.40;     %  Consistency (percent)
dp0=170;      %  Dilution flow (L/m)
gp0=0.8;      %  Plate gap
vp0=30;       %  Feeder screw rotation (rpm)
Glv=0.1;
Gcd=-0.0015;
Gcv=0.012;
Fb0= -(Cp0^2)/vp0/Gcd;                           %  Fiber filling factor
ke= -(dp0-((vp0/Cp0)^2)*Fb0*Gcv)/(mlp0-vp0*Glv);  %  Evap. coeff.
Fbh0=(ke*mlp0-dp0+vp0*Fb0/Cp0)/vp0;              %  Fiber-water filling factor
kf=mlp0/(vp0*Fb0*Cp0*(1.2-0.3*gp0));
FrnInterval = 10;  % Interval for new freeness measurement
%%%%%%%%%%%%%%%  Secondary refiner
mls0=6.7;     %  Nominal load   (MW)
Cs0=0.35;     %  Consistency (percent)
ds0=120;      %  Dilution flow (L/m)
gs0=0.5;      %  Plate gap
m2=vp0*Fb0;                   %  Throughput from primary
M2=vp0*Fbh0+dp0-ke*mlp0;  %  Fiber+Moisture throughput from primary
kf2=mls0/(m2*Cs0*(1.2-0.3*gs0));
ke2=-((m2/Cs0)-M2-ds0)/mls0;
TAUg = 0.5;   % Time constant for gap
TAUd = 0.5;   % Time constant for dilution
TAUv = 0.5;   % Time constant for screw speed
TAUfb= 1.4;     % Time constant fiber filling factor disturbance
TAUfbh= 1.4;     % Time constant fiber-water filling factor disturbance
TAUse =10;    % Time constant of latency chest
ag=exp(-dt/TAUg);
ad=exp(-dt/TAUd);
av=exp(-dt/TAUv);
afb=exp(-dt/TAUfb);
afbh=exp(-dt/TAUfbh);
Bse = exp(-dt/TAUse);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transfer functions
ChipFeeder = ss(av,(1-av),1,0,dt);
PlateGapPrimary = ss(av,(1-ag),1,0,dt);
PlateGapSecondary = ss(ag,(1-ag),1,0,dt);
DilFlowPrimary = ss(ad,(1-ad),1,0,dt);
DilFlowSecondary = ss(ad,(1-ad),1,0,dt);
FiberFill = ss(afb,(1-afb),1,0,dt);
FiberWaterFill = ss(afbh,(1-afbh),1,0,dt);
UnitDelay = ss(0,1,1,0,dt);




T = .5;
zeta = .2;
wn = 2*pi/50;
sys=tf([wn^2 0 0],[(1/T)^2+2*zeta*wn/T+wn^2 -2/T^2-2*zeta*wn/T 1/T^2],.5);