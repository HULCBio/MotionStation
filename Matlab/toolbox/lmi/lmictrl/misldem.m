%MISLDEM   Gain-scheduling control of a missile autopilot (demo)
% 
%See also  LMIDEM, RADARDEM, SATELDEM

% Author: P. Gahinet
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.10.2.3 $
echo off
clc

disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('                     DEMO "MISSILE" ');
disp('                     ************** ');
disp(' ');
disp(' ');
disp('           GAIN-SCHEDULING OF A MISSILE AUTOPILOT   ');
disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('            (see user''s manual for more details)');
disp(' ');
disp(' ');

echo on

pause  % Strike any key to continue...
clc
%
%  TRACKING LOOP :
%
%                          
%                _______        _______
%   r        e   |     |        |     |-----------+----> azv 
%   ----->O----->|  K  |------->|  G  |           |
%         |-     |     |   u    |_____|----+      |
%         |   +->|_____|                   | q    | 
%         |   |                            |      |
%         |   |____________________________|      |
%         |_______________________________________|
%
%
%  Goal: settling time < 0.5 sec. for the step response of the
%        vertical acceleration azv 
%        
%  Loop-shaping formulation:
%
%         ||  w1 S   ||                          -1
%         ||         ||   <  1 ,       S = (1+GK) 
%         ||  w2 KS  ||oo



pause  % Strike any key to continue...
clc
%
%  CHOICE OF SHAPING FILTERS:
%
%  Filter w1 to shape S


n1=2.0101;
d1=[1.0000e+00   2.0101e-01];
w1=ltisys('tf',n1,d1);


fig1=figure;
splot(w1,'bo',logspace(-2,3,50));
title('filter for  S=1/(1+GK)  (performance)')



pause  % Strike any key to continue...


%  Filter w2 to shape KS 


n2=[9.6785e+00   2.9035e-02   0  0];
d2=[1.0000e+00   1.2064e+04   1.1360e+07   1.0661e+10];
w2=ltisys('tf',n2,d2);

splot(w2,'bo',logspace(2,4,50));
title('filter for  K/(1+GK)  (control action)')



pause  % Strike any key to continue...
clc
%
%  AFFINE PARAMETER-DEPENDENT MODEL OF THE MISSILE
%
%                      [ -Z_al  1 ]         [ 0 ] 
%           dx/dt  =   [          ]  x   +  [   ]  u
%                      [ -M_al  0 ]         [ 1 ] 
%
%    
%          [ azv ]     [ -1     0 ]
%      y = [     ] =   [          ]  x        (q = pitch rate)
%          [  q  ]     [  0     1 ]
%
%  where the aerodynamical coefficients Z_al and M_al
%  vary in
%
%        0.5 <= Z_al <= 4      0 <= M_al <= 106


%  Specify the range of parameter values (parameter box)

Zmin=.5;  Zmax=4;
Mmin=0;   Mmax=106;  
pv=pvec('box',[Zmin Zmax ; Mmin Mmax]);



%  Specify the parameter-dependent model with PSYS

s0=ltisys([0 1;0 0],[0;1],[-1 0;0 1],[0;0]);
s1=ltisys([-1 0;0 0],[0;0],zeros(2),[0;0],0);  % Z_al component
s2=ltisys([0 0;-1 0],[0;0],zeros(2),[0;0],0);  % M_al component
pdG=psys(pv,[s0 s1 s2]);



pause  % Strike any key to continue...
clc
%
%  Specify the loop-shaping control structure with SCONNECT


[pdP,r]=sconnect('r','e=r-G(1);K','K:e;G(2)','G:K',pdG);




%  Augment with the shaping filters


Paug=smult(pdP,sdiag(w1,w2,eye(2)));





pause  % Strike any key to continue...
clc
% 
%  LMI-BASED SYNTHESIS OF THE LPV CONTROLLER
%
%
%    Minimization of gamma for the loop-shaping criterion


[gopt,pdK]=hinfgs(Paug,r,0,1e-2);


pause  % Strike any key to continue...



%  Form the closed-loop system


pCL=slft(pdP,pdK);



pause  % Strike any key to continue...
clc
%
%  LTI SIMULATIONS FOR 15 RANDOM OPERATING POINTS:
%
%  The parameter vector p=(Z_al,M_al) is frozen to some
%  value in the parameter box, and the step response of
%  the resulting LTI system is simulated.
%
%      AZV  : vertical acceleration 
%       U   : fin deflection


AZV=[]; U=[]; t=[0:.01:1]';


%  Collect simulation data

for j=1:15,
   polyc=rand(1,4);  
   polyc=polyc/sum(polyc);  % random polytopic coordinates

   Pcl=psinfo(pCL,'eval',polyc);
   [acl,bcl,ccl,dcl]=ltiss(Pcl);
   y=step(acl,bcl,ccl,dcl,1,t);

   AZV=[AZV,1-y(:,1)]; U=[U,y(:,2)/20];
end


pause  % Strike any key to continue...
clc
%
%  Plot the step responses and fin deflections for the 15 
%  LTI plants:

figure(fig1), clf
subplot(211); plot(t,AZV);  grid;
title('Vertical acceleration azv'); 
subplot(212); plot(t,U);    grid; 
title('Control input (fin deflection)');  




pause  % Strike any key to continue...
clc
%
%  TIME-VARYING SIMULATION  
%
%    Step response of the autopilot when the aerodynamical
%    coefficients Z_al and M_al vary along a spiral in the 
%    parameter box
%


%  Parameter trajectory (defined by the function SPIRALT)

t0=[0:.001:.5];
pt=spiralt(t0);


figure(fig1);clf;
plot(pt(1,:),pt(2,:)); xlabel('Z-alpha');ylabel('M-alpha');
title('Parameter trajectory  (duration : 1 s)'); grid;



pause  % Strike any key to continue...


%  Simulate the step response for this parameter trajectory
%  with  PDSIMUL.  


[t,x,y]=pdsimul(pCL,'spiralt',.5);


figure(fig1+1);clf;
plot(t,1-y(:,1));xlabel(' time (s)');ylabel('azv');grid;
title('step response of the gain-scheduled autopilot');

figure(fig1+2);clf
plot(t,y(:,2)/20);xlabel(' time (s)');ylabel('u');grid;
title('control action (fin deflection in degrees)');



echo off




