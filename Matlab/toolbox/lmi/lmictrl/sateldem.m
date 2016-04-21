%SATELDEM   Robust state-feedback control of satellite attitude (demo)
% 
%See also  LMIDEM, RADARDEM, MISLDEM

% Author: P. Gahinet
% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.2.3 $
echo off
clc

disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('                      DEMO  "SATELLITE" ');
disp('                      ****************  ');
disp(' ');
disp(' ');
disp('          ROBUST STATE-FEEDBACK CONTROL OF SATELLITE ATTITUDE');
disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('              (see user''s manual for further detail)');
disp(' ');
disp(' ');
disp(' ');

echo on

pause  % Strike any key to continue...
clc
%
%  DYNAMICAL EQUATIONS:
%
%          2
%         d x1           dx1   dx2
%      J1 ----   +  f  ( --- - --- )  +  k (x1-x2) = T + w
%         dt^2            dt    dt
%
%          2
%         d x2           dx2   dx1
%      J2 ----   +  f  ( --- - --- )  +  k (x2-x1) = 0
%         dt^2            dt    dt
%
%
%      T : control torque               w : disturbance
%
%          0.09 < k < 0.4        (nominal = 0.2450)
%        0.0038 < f < 0.04       (nominal = 0.0188)
%


pause  % Strike any key to continue...


%  GOAL:
%
%    Design a robust state-feedback law  T = K x  that minimizes
%    the effect of the disturbance w on x2.
%  
%  SPECIFICATIONS:
%  			
%     * Minimize the H-infinity norm of the transfer w -> x2
%     * Minimize the H-2 norm of the transfer w -> [x1,x2,T] 
%     * Robust alpha-stability  with alpha > 0.1
%     * Robust closed-loop damping > tan(pi/8)    (sector)
%


pause % Strike any key to continue...
%% System Data
J1=1; J2=0.1;
a0=[zeros(2) eye(2);zeros(2,4)];
e0=diag([1 1 J1 J2]);
ak=[zeros(2,4); [-1 1;1 -1] zeros(2)];
ad=mdiag(zeros(2),[-1 1;1 -1]);
b1=[0;0;1;0]; b2=b1;
c1=[0 1 0 0]; d11=0; d12=0;
c2=[1 0 0 0;0 1 0 0;0 0 0 0];d21=[0;0;0]; d22=[0;0;1];
clc
%
%  Specification of the pole placement region:
%
%  alpha-stability      ->  half-plane  x < -0.1
%  damping > tan(pi/8)  ->  sector with tip at x=0 and angle 3*pi/4
%
%  This is done interactively with LMIREG.  
%  Type q to skip this part and load the region defined above


region=lmireg;



pause % Strike any key to continue...
echo off
load sateldem
% Average value of the parameters
k=0.245;  
f=0.0188; 
% Nominal system
a=a0+k*ak+f*ad;
Pnom=ltisys(a,[b1 b2],[c1;c2],[d11 d12;d21 d22],e0);
echo on, clc
%
%  DESIGN FOR THE NOMINAL SYSTEM:  
%
%     k=0.2450,   f=0.0188   
%

%  Bode plot w -> x1,x2

fig1=figure;
splot(ssub(Pnom,1,2:3),'bo',logspace(-1,1,100))



pause % Strike any key to continue...


%  Compute the optimal H-infinity performance subject to 
%  the pole constraint


gopt=msfsyn(Pnom,[3 1],[0 0 1 0],region)


%  -> optimal performance near 0



pause % Strike any key to continue...

hinfnom=[];h2nom=[];h2bnom=[];
clc
%
%  Analyze the trade-off between the H-infinity and H-2 
%  performance  (given the pole placement constraint).
%
%  This is done by minimizing the H-2 norm for various 
%  values of the H-infinity performance.
%
%  We select the values  0.01,   0.1,   0.2,   0.5



pause % Strike any key to continue...


gammas=[.01 .1 .2 .5];

for t=gammas,

  disp(sprintf('\nRequired H-infinity performance: %6.2f',t));

  [gopt,h2opt,K,Pcl]=msfsyn(Pnom,[3 1],[t 0 0 1],region);
  hinfcl=norminf(ssub(Pcl,1,1));
  h2cl=norm2(ssub(Pcl,1,2:4));
  
  h2bnom=[h2bnom h2opt];     % computed bound on the H2 performance
  hinfnom=[hinfnom, hinfcl]; % true Hinf performance
  h2nom=[h2nom, h2cl];       % true H2 performance

  if t==0.1, Knom=K; Pclnom=Pcl;  end
end


%  plot the trade-off curve:

figure(fig1),clf
plot(hinfnom,h2nom); set(gca,'xlim',[0 .3])
xlabel('H-infinity performance'); ylabel('H2 performance'), hold on
plot(gammas,h2bnom,'-.');  
title('Trade-off curve (nominal): true values (-) and computed bounds (-.)')
hold off


%  the best compromise is obtained for gamma=0.1


pause % Strike any key to continue...
clc
%
%   ROBUST MULTI-MODEL SYNTHESIS:
%
%     0.09 < k < 0.4,     0.0038 < f < 0.04
%
%     same pole placement constraints
%


%  Extremal parameter values

k1=0.09; k2=0.4;
f1=0.0038; f2=0.04;
pv=pvec('box',[k1 k2;f1 f2]);


%  Polytopic representation of the uncertain system

P0=ltisys(a0,[b1 b2],[c1;c2],[d11 d12;d21 d22],e0);
Pk=ltisys(ak,zeros(4,2),zeros(4),zeros(4,2),0);
Pf=ltisys(ad,zeros(4,2),zeros(4),zeros(4,2),0);
P=psys(pv,[P0 Pk Pf]);





pause % Strike any key to continue...
h2rob=[];
clc
%
%  As before, we compute the trade-off curve between the 
%  H-2 and H-infinity performances:
%
%    for t=gammas,
%      [gopt,h2opt,K,Pcl]=msfsyn(P,[3 1],[t 0 0 1],region);
% 
%      h2rob=[h2rob h2opt];
%   
%      if t==0.1, Krob=K; Pclrob=Pcl; end
%    end
%
%  Load the result:

load sateldem



%  Compare with nominal results

figure(fig1),clf
plot(gammas,h2bnom,'y'); 
xlabel('H-infinity performance'); ylabel('H2 performance'), hold on
plot(gammas,h2rob,'r');  
title('Trade-off curves: nominal (yellow) and robust (red)')
hold off


pause % Strike any key to continue...
clc
%  
%  Comparison of the nominal and robust designs:
%
%  Plot the impulse response w -> x2



%  nominal design for gamma=0.1

figure(fig1),clf
splot(ssub(Pclnom,1,1),'im'); 
title('Impulse response  w -> x2  for the nominal design');



%  robust design for gamma=0.1  (impulse response for the 
%  extremal values of k,f)

figure(fig1+1), clf
for j=1:4,
   Pvert=psinfo(Pclrob,'sys',j);
   splot(ssub(Pvert,1,1),'im',[0:0.05:10]); hold on
end
title('Impulse responses  w -> x2  for the robust design'); 
hold off


pause % Strike any key to continue...
clc
% 
%  Check the pole placement constraints for the robust  
%  design (extremal values of k,f)

echo off 

colors='wrbg';
figure(fig1), clf
for j=1:4,
  plot(spol(psinfo(Pclrob,'sys',j)),['+' colors(j)]); hold on
end
set(gca,'ylim',[-10 10]);
% cone 
x=[-9:1:0]; plot(x,x/tan(pi/8),'y'); plot(x,-x/tan(pi/8),'y'); 
% half-plane
y=[-10:1:10]; plot(-0.1*ones(size(y)),y,'y'); hold off
title('Closed-loop poles for the four extremal sets of parameter values');

echo on

pause % Strike any key to continue...

echo off 
close all
return


