%RADARDEM   Loop-shaping design of the velocity loop of a 
%           radar antenna (demo)
% 
%See also  LMIDEM, SATELDEM, MISLDEM

% Author: P. Gahinet
% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.2.3 $
echo off
clc

disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('                      DEMO  "RADAR" ');
disp('                      ************* ');
disp(' ');
disp(' ');
disp('      LOOP-SHAPING DESIGN OF THE VELOCITY LOOP OF A RADAR ANTENNA  ');
disp(' ');
disp(' ');
disp(' ');
disp(' ');
disp('          (see user''s manual for further detail)');
disp(' ');
disp(' ');
disp(' ');

echo on

pause  % Strike any key to continue...
clc



% BODE PLOT OF THE NOMINAL SYSTEM  G0
% -----------------------------------

% plant transfer function 
n=3e4;
d=conv([1 .02],[1 .99 3.03e4]);
G0=ltisys('tf',n,d);

fig1 = figure;
splot(G0,'bo',logspace(0,3,100))



pause  % Strike any key to continue...
clc
%
%  TRACKING LOOP:
%
%                                            d
%                _______        _______      |
%   r        e   |     |   u    |     |      V  
%   ----->O----->|  K  |------->|  G  |------+---> y
%         |-     |_____|        |_____|      |
%         |                                  |
%         +----------------------------------+
%
%  Specifications:
%    * performance:  integral control 
%                    | GK | > 30 dB  at  1 rd/s
%    * 99% rejection of the disturbance  d  with frequency
%      band [0,1] rd/s
%    * robustness to a relative model uncertainty with
%      frequency-dependent bound   b(s) = s/100
%      
%  Loop-shaping criterion:
%
%         ||  w1 S  ||
%         ||        ||   <  1 ,    S = 1/(1+GK) ,   T = GK*S
%         ||  w2 T  ||oo


pause  % Strike any key to continue...

%
%  GRAPHICALLY specify the corresponding shaping filters
%  w1(s)  (performance) and  w2(s)  (robustness):
%
%  >> magshape
%
%  Each filter is specified by its name, order, and 
%  magnitude profile ...


echo off
magshape
echo on


pause  % Strike any key to continue...
echo off
clc
if any([exist('w1') exist('w2') input(['Enter 1 to continue with your filters, ' ...
          '0 to load pre-computed ones:  '])]~=1), load radardem, end
echo on,clc

%
%  H-INFINITY SYNTHESE :
%

%  Specify the control structure with SCONNECT:

inputs='r';
outputs='e=r-G0 ; G0';

[P,r]=sconnect(inputs,outputs,'K:e','G0:K',G0);
Paug=smult(P,sdiag(w1,w2,1));


pause  % Strike any key to continue...

%  Closing the augmented plant  PAUG  on the controller K
%  yields the closed-loop transfer function  (w1 S ; w2 T)
%
%  Call HINFRIC to test whether the design specifications 
%  are feasible, i.e., whether  || (w1 S ; w2 T) ||oo < 1 :


[gopt,K]=hinfric(Paug,r,1,1);



pause  % Strike any key to continue...
clc, clf
%
%  VALIDATION OF THE CONTROLLER  K(s): 
%

%  Plot the open-loop response GK


GK=smult(G0,K);
splot(GK,'bo',logspace(-2,2,50));
title('open loop GK')


pause  % Strike any key to continue...


%  Form the closed-loop system (w/o the filters!)
%  Its input is r and its outputs are  e,y

Pcl=slft(P,K);
sinfo(Pcl)


pause  % Strike any key to continue...


%  Plot the singular value of S,T

S=ssub(Pcl,1,1);
T=ssub(Pcl,1,2);

clf
splot(S,'sv',logspace(0,3,100)); hold
splot(T,'sv',logspace(0,3,100)); title('S and T'); 



pause  % Strike any key to continue...
clf, clc
%
%  Step response:

subplot(211);
splot(T,'st'); title('step response r -> y'); 



%  Rejection of a disturbance at the plant input

subplot(212);
splot(smult(S,G0),'im');
title('rejection of an impulse disturbance on u');




pause % Strike any key to continue...
clc
%
%  H-INFINITY  SYNTHESIS  WITH  POLE  PLACEMENT
%
%  
%  Chosen region:
%
%    disk with center (-1e3,0) and radius R=1e3
%


%  The (closed-loop) modes of  (w1 S; w2 T)  always
%  include the shaping filter dynamics!!  To prevent
%  interference with the pole placement objective, 
%  we use the loop-shaping structure:
%
%                     +----+                    +----+
%                     | w1 |---->               | w2 |----> 
%                     +----+                    +----+
%                        |                         |
%              _______ e |   _______      _______  |
%   r          |     |   |   |     |      |     |  |
%   ----->O--->| 1/s |---+-->|  K0 |----->|  G  |--+---> y
%         |-   |_____|       |_____|      |_____|  |
%         |                                        |
%         +----------------------------------------+
%
%
%  with 
%             s^2 +  16s + 200                     s
%     w1(s) = ----------------      w2(s) = 0.9 + ---
%             s^2 + 1.2s + 0.8                    200
%
%


pause % Strike any key to continue...
clc
%
%  Specify the control structure with SCONNECT:


% integrator  1/s
i0=ltisys('tf',1,[1 0]);


inputs='r';
outputs='I0; G';
[P,r]=sconnect(inputs,outputs,'K:I0','G:K',G0,'I0:e=r-G',i0);


pause  % Strike any key to continue...


%  Add the shaping filters:

% W1

w1=ltisys('tf',[1 16 200],[1 1.2 0.8]);
Paug=smult(P,sdiag(w1,1,1));


% W2=0.9+s/200

Paug=sderiv(Paug,2,[1/200 0.9]);



%  Closing the augmented plant  PAUG  on  K0  yields 
%  the desired criterion (w1/s * S ; w2 * T)



pause  % Strike any key to continue...
clc
%
%  Perform an H-infinity synthesis with pole placement in
%  the disk of center (-1000,0) and radius R = 1000 : 


%  specify this LMI region with LMIREG 
%                        (type q to skip this step) :

region=lmireg;


pause  % Strike any key to continue...
echo off 
if isempty(region), region=[-1000+2*sqrt(-1) 1000 0 0;1000 -1000 1 0]; end
echo on



%  perform the synthesis with HINFMIX : 

[gopt,xx,K0]=hinfmix(Paug,[0 r],[0 0 1 0],region);


pause  % Strike any key to continue...
echo off 
if isempty(K0), 
   disp('Your choice of region is infeasible. Aborting demo...')
   return
end
echo on
clc
%
%  VALIDATION OF THE CONTROLLER  K(s): 
%


%  Open-loop response GK

GK=smult(i0,K0,G0);

figure(fig1+1); clf;
splot(GK,'bo',logspace(-1,3,100)); title('open loop GK');



pause  % Strike any key to continue...


%  Form the closed-loop system (w/o the filters!)
%  The input is r and the outputs are e and y

Pcl=sconnect('r','e;y=GK','','GK:e=r-y',GK);



pause  % Strike any key to continue...
clc
%
%  Plot the singular values of S and T

S=ssub(Pcl,1,1);
T=ssub(Pcl,1,2);
clf
splot(S,'sv',logspace(0,3,100)); hold
splot(T,'sv',logspace(0,3,100)); title('S and T'); 




pause  % Strike any key to continue...
figure(fig1+1), clf, clc
%
%  Step response:

subplot(211);
splot(T,'st',[0:.001:.5]); title('Response to a step r'); 


%  Impulse response

subplot(212);
splot(smult(S,G0),'im',[0:.001:.5]); 
title('Response to an impulse disturbance on u');


pause  % Strike any key to continue...


%  Closed-loop poles

figure(fig1+2),clf
plot(spol(Pcl),'+'); 
title('Closed-loop poles');


%  The flexible modes of the system have been damped
%  and the rejection of a disturbance at the plant input
%  is now satisfactory

pause  % Strike any key to continue...

echo off
close all
return


