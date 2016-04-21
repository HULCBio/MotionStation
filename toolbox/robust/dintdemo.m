function dintdemo(w1c,alfa)
%DINTDEMO Demo of H-Infinity design of double integrator plant.
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.12.4.3 $
% All Rights Reserved.

clc
disp(' ')
disp(' ----------------------------------------------------------------')
disp('         << H-INF DESIGN FOR A DOUBLE INTEGRATOR PLANT >>')
disp(' ')
disp('   Model: a double integrator with moment inertia J (1/J/s/s)')
disp(' ')
disp('   For example: rigid body dynamics of a spacecraft (J = 5700)')
disp(' ')
disp('                           * * * * *')
disp('      * * * * * * * *      * space *      * * * * * * * *')
disp('      * solar panel * ---- * craft * ---- * solar panel *')
disp('      * * * * * * * *      *1/j/s/s*      * * * * * * * *')
disp('                           * * * * *')
disp('          ')
disp('   Objective: Find a stabilizing Mixed-Sensitivity H-Inf')
disp('              controller.')
disp(' ----------------------------------------------------------------')
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
den = conv([1 0],[1 0]);
[ag,bg,cg,dg] = tf2ss(1/5700,den);
clc
disp(' ' )
disp(' ----------------------------------------------------------------')
disp('                 << JW-AXIS POLES/ZEROS >>')
disp(' ')
disp('  One special feature of state-space MIXED-SENSITIVITY approach:')
disp('   ')
disp('     PLANT DOES NOT ALLOWED TO HAVE JW-AXIS POLE/ZERO !!')
disp('   ')
disp('  But this does not mean we can not deal with the situation.')
disp('  Simply use the jw-axis shifting technique to shift the poles:')
disp(' ')
disp('    Step 1:  Shift the plant (Ag <----- Ag + SIG * eye(Ag))')
disp('    Step 2:  Do a standard mixed-sensitivity H-Inf design')
disp('    Step 3:  Shift back the controller ')
disp('             (Acp <------ Acp - SIG * eye(Acp))')
disp('                       Done !!')
disp('  where SIG can be a small positive number (e.g., 0.1)')
disp(' ---------------------------------------------------------------')
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
SIG = 0.1;
ag0 = ag + SIG*eye(2);
disp('   ')
disp(' Poles of the plant/shifted plant:')
[eig(ag) eig(ag0)]
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
clc
disp(' ')
disp(' --------------------------------------------------------------------')
disp('               << W3 WEIGHTING & JW-AXIS ZEROS >>')
disp('')
disp('  We have dealt with the jw-axis plant POLES by shifting the axis.')
disp('  But there are still two plant ZEROS at infinity, which are also on ')
disp('  the jw-axis ....')
disp('  We can solve this problem via a clever W3 weighting:')
disp('  ')
disp('                        W3 = s^2 / 100')
disp('  ')
disp('  where the double differentiator makes the plant full rank at  ')
disp('  infinity, but also serves as the complementary sensitivity')
disp('  weighting function to control the system bandwidth.')
disp('  In our example, system bandwidth is set to be 10 rad/sec.')
disp(' ---------------------------------------------------------------------')
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
clc
disp(' ')
disp(' ---------------------------------------------------------------------')
disp('       << SENSITIVITY WEIGHTING (W1), THE H-INF DESIGN KNOB >>')
disp(' ')
disp('  By tuning W1 filter, we can find an H-Inf controller:')
disp('                          2                                2')
disp('            beta * [alfa*S + 2*zeta1*w1c*sqrt(alfa)*S + w1c ]')
disp('      W1 = ----------------------------------------------------')
disp('                          2                                2')
disp('                   [beta*S + 2*zeta2*w1c*sqrt(beta)*S + w1c ]')
disp('   ')
disp('  where ')
disp('      beta: DC gain of the filter (controls the disturbance rejection)')
disp('      alfa: high frequency gain (controls the peak overshoot)')
disp('      w1c: filter cross-over frequency')
disp('      zeta1, zeta2: damping ratios of the corner frequencies.')
disp(' ')
disp('  Inverse of W1 is the desired shape of the sensitivity function.')
disp('  Here, we choose 2nd order W1 filter for a uniform loop-shaping on ')
disp('  L(s) = G(s)*F(s).')
disp(' --------------------------------------------------------------------')
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
if nargin==0,
   w1c=input('Input the sensitivity cross-over frequency (try 3): ');
   if isempty(w1c),
      w1c = 3;
      disp('Using default cross-over (3 rad/sec)')
   end
end
beta = 100;
if nargin==0,
   alfa = input('Input the sensitivity upper bound "ALFA" (try 1.5): ');
   if isempty(alfa),
      alfa=1.5;
      disp('Using Default ALFA=1.5')
   end
end
alfa = 1/alfa;
zeta1 = 0.7; zeta2 = 0.7;
w1 = [beta*[alfa 2*zeta1*w1c*sqrt(alfa) w1c*w1c];...
           [beta 2*zeta2*w1c*sqrt(beta) w1c*w1c]];
w2 = [];
w3 = [1 0 0;0 0 100];
clc
disp(' -----------------------------------------------------------')
disp('                   << H-INF DESIGN >>')
disp(' ')
disp('   >> w1 = [beta*[alfa 2*zeta1*w1c*sqrt(alfa) w1c*w1c];..')
disp('                 [beta 2*zeta2*w1c*sqrt(beta) w1c*w1c]];')
disp('   >> w2 = [];')
disp('   >> w3 = [1 0 0;0 0 100];')
disp('   >> ss_g = ss(ag0,bg,cg,dg);')
disp('   >> TSS_ = augtf(ss_g,w1,w2,w3);')
disp('   >> [ss_cp,ss_cl,hinfo] = hinf(TSS_);')
disp('   >> [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('   >> [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp(' -----------------------------------------------------------')
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
disp(' ')
disp(' - - - Working Plant Augmentation - - - Wait - - -')
ss_g = ss(ag0,bg,cg,dg);
TSS_ = augtf(ss_g,w1,w2,w3);
clc
[ss_cp,ss_cl,hinfo] = hinf(TSS_);
[acp,bcp,ccp,dcp] = ssdata(ss_cp);
[acl,bcl,ccl,dcl] = ssdata(ss_cl);
acp = acp-SIG*eye(size(acp));
if max(real(eig(acl))) < 0
%  dinteva
%DINTEVA Script file for computing singular value plots for DINTDEMO.
%

w = logspace(-3,3);
%
disp(' ')
disp(' - - Computing the SV Bode plot of the plant open loop - -');
svg = sigma(ag,bg,cg,dg,1,w);
svg = 20*log10(svg);
%
disp(' ')
disp(' - - Computing the SV Bode plot of Ty1u1 - -');
svtt = sigma(acl,bcl,ccl,dcl,1,w);
svtt = 20*log10(svtt);
%
svw1i = bode(w1(2,:),w1(1,:),w); svw1i = 20*log10(svw1i);
svw3i = bode(w3(2,:),w3(1,:),w); svw3i = 20*log10(svw3i);
%
disp(' ')
disp(' - - Computing the SV Bode plot of Controller - -')
svcp = sigma(acp,bcp,ccp,dcp,1,w); svcp = 20*log10(svcp);
%
[al,bl,cl,dl] = series(acp,bcp,ccp,dcp,ag,bg,cg,dg);
%
[as,bs,cs,ds] = feedbk(al,bl,cl,dl,1);
disp(' ')
disp(' - - Computing the SV Bode plot of S - - ')
svs = sigma(as,bs,cs,ds,1,w);
%[svs,temp] = sort(-svs); svs = -svs;
svs = 20*log10(svs);
%
[at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
disp(' ')
disp(' - - Computing the SV Bode plot of I-S - - ')
svt = sigma(at,bt,ct,dt,1,w);
svt = 20*log10(svt);
%
disp(' ')
disp(' - - Computing the time response - - ')
t = 0:0.1:5;
y = step(at,bt,ct,dt,1,t);
%
% -------- End of DINTEVA.M --- RYC/MGS %
  disp(' ')
%DINTPLT Script file for plotting the SV Bode plot of DINTDEMO.
%

clf
subplot(2,2,1)
semilogx(w,svtt(1,:))
grid on
title('Cost Function: Ty1u1 ')
xlabel('Rad/Sec')
ylabel('db')
%
subplot(2,2,2)
semilogx(w,svw1i,w,svs);
grid on
title('1/W1 & S');
xlabel('Rad/Sec');
ylabel('db');
%
subplot(2,2,3)
semilogx(w,svw3i,w,svt);
grid on
title('1/W3 & T');
xlabel('Rad/Sec')
ylabel('db')
%
subplot(2,2,4)
plot(t,y)
grid on
title('Step Response')
xlabel('sec')
%
% -------- End of DINTPLT.M --- RYC/MGS %

%  dintplt
end
%
% ---------- End of DINTDEMO.M % RYC/MGS
