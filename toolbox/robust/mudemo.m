function mudemo(minpha,hdcopy)
%MUDEMO Demo of MU-synthesis on 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  MUDEMO.M is a script file that demonstrates the design of
%     1990 ACC benchmark problem using MU-SYNTHESIS.
% ---------------------------------------------------------------

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.13.4.3 $
% All Rights Reserved.
if nargin<2, hdcopy=0; end % set default
clc
% clear
disp(' ')
disp('                      << Benchmark Problem >>')
disp('  ');
disp('                           |--> x1        |--> x2 = z (measurement)');
disp('         (control)    ------     k   ------');
disp('           u -------> | M1 | -/\/\/\-| M2 | ------> w (disturbance)');
disp('                      ------         ------');
disp('                       0  0           0  0');
disp('   ===============================================================');
disp('                     [ Design Specifications ]');
disp('    ------------------------------------------------------------');
disp('    | Design | Robustness   | Settling Time | Disturbance w(t) |')
disp('    ---------+--------------+---------------+-------------------');
disp('    |   2    | maximize MSM | Ts ~= 15 sec  |     impulse      |');
disp('    |        | for nominal  | for nominal   |                  |');
disp('    ------------------------------------------------------------');
disp('   ')
disp('                                  (strike a key to continue ...)');
pause
disp(' ')
disp(' ')
spring = [1 0.5 2];
%
clc
disp(' ')
disp('  -----------------------------------------------------------')
disp('    1. Set up the nominal system:');
disp(' ');
disp('       k = 1; m1 = 1; m2 = 1;');
disp('       ag = [0      0     1     0');
disp('             0      0     0     1');
disp('          -k/m1   k/m1    0     0');
disp('           k/m2  -k/m2    0     0];');
disp('       bg = [0 0 1/m1 0]`; cg = [0 1 0 0]; dg = 0;');
disp('  -----------------------------------------------------------')
k = 1; m1 = 1; m2 = 1;
%
ag = [0      0     1     0
      0      0     0     1
   -k/m1   k/m1    0     0
    k/m2  -k/m2    0     0];
bg = [0 0 1/m1 0]';
cg = [0 1 0 0];
dg = 0;
disp(' ');
disp('       Poles of G(s) - -')
lamg = eig(ag)
disp(' ')
disp('                       (strike a key to continue)')
pause
%---------------------------------------
% Augmented Plant for H-Inf Design:
%
clc
disp(' ')
   disp('  -----------------------------------------------------------');
   disp('    2. Set up the augmented plant for H-Inf design:');
   disp(' ')
   disp('       Two-port state-space:')
   disp('          (A,BB1,BB2,CC1,CC2,DD11,DD12,DD21,DD22)')
   disp(' ')
w2flag = 0;
%   w2flag = input('     Select W2: Dynamic (1); Constant (2): ');
if w2flag ~= 0
   disp('          Port 1: 3 uncertainties + W2 ')
   disp('          Port 2: controller')
   disp('  -----------------------------------------------------------');
   disp(' ')
   rho=[];
   while isempty(rho),
      rho = input('     Assign the DC of W2 weighting for control energy: ');
   end
   if w2flag == 1
      nuw2 = rho*[1/10 1]; dnw2 = [1/200 1];
      [aw2,bw2,cw2,dw2] = tf2ss(nuw2,dnw2);
   else
      aw2 = []; bw2 = []; cw2 = []; dw2 = rho;
   end
   AA = diagmx(ag,aw2);
   BB1 = [ 0     0    0     0;
           0     0    0     0;
         -1/m1 -1/m1  0    k/m1;
          1/m2   0  -1/m2 -k/m2;
          zeros(size(aw2)*[1;0],4)];
   BB2 = [0;0;1/m1;0;bw2];
   CC1 =  [ 1    -1   0 0;
          -k/m1  k/m1 0 0;
           k/m2 -k/m2 0 0;
            0     0   0 0];
   CC1 = [CC1 [zeros(3,size(cw2)*[0;1]);cw2]];
   CC2 = [0 1 0 0 zeros(1,size(cw2)*[0;1])];
   DD11 = [0 0 0 0;-1/m1 -1/m1 0 k/m1;1/m2 0 -1/m2 0; 0 0 0 0];
   DD12 = [0;1/m1;0;dw2]; DD21 = [0 0 0 1]; DD22 = 0;
else
   disp('          Port 1: 3 uncertainties')
   disp('          Port 2: controller')
   disp('  -----------------------------------------------------------');
   AA = ag; BB1 = [0 0 0;0 0 0;-1/m1 -1/m1 0;1/m2 0 -1/m2];
   BB2 = [0 0 1/m1 0]';
   CC1 = [1 -1 0 0;-k/m1 k/m1 0 0;k/m2 -k/m2 0 0]; CC2 = [0 1 0 0];
   DD11 = [0 0 0;-1/m1 -1/m1 0;1/m2 0 -1/m2]; DD12 = [0 1/m1 0]';
   DD21 = [0 0 0]; DD22 = 0;
end
%
disp(' ');
%
no_u1 = size(BB1)*[0;1]; no_u2 = size(BB2)*[0;1];
no_y1 = size(CC1)*[1;0]; no_y2 = size(CC2)*[1;0];
%
BB = [BB1 BB2]; CC = [CC1;CC2]; DD = [DD11 DD12;DD21 DD22];
%
disp(' ');
disp('       Poles of the augmented plant P(s) - -')
lamp = eig(AA)
disp('                (strike a key to continue)')
pause
% --------------------------------------
% JW-axis shifting from s -----> s~:
%
clf
bilexp
clc
disp(' ')
disp(' --------------------------------------------------------------------')
disp('    3. Transform the Augmented Plant to Shifted JW-Axis:')
disp(' ')
disp('       % pack the 2-port state-space ...')
disp('       BB = [BB1 BB2]; CC = [CC1;CC2]; DD = [DD11 DD12;DD21 DD22];')
disp('       % select the circle point for mapping ...')
disp('       [aa,bb,cc,dd] = bilin(AA,BB,CC,DD,1,`Sft_jw`,cirpt);')
disp('       % split the (aa,bb,cc,dd) to 2-port state-space (A,B1,B2,..);')
disp(' --------------------------------------------------------------------')
disp('      Input the circle point "p1" - - -')
if nargin==0,
   cirpt1 = input('     (-0.25: non-min. phase controller, -0.35: min. phase controller): ');
   if isempty(cirpt1), cirpt1=-0.25; disp('Doing non-min. phase controller design (default)'), end
elseif minpha==0,
    cirpt1=-0.25;
elseif minpha==1,
    cirpt1=-0.35;
end
cirpt = [-100 cirpt1];
[aa,bb,cc,dd] = bilin(AA,BB,CC,DD,1,'Sft_jw',cirpt);
A = aa; B1 = bb(:,1:no_u1); B2 = bb(:,no_u1+1:no_u1+no_u2);
C1 = cc(1:no_y1,:); C2 = cc(no_y1+1:no_y1+no_y2,:);
D11 = dd(1:no_y1,1:no_u1); D12 = dd(1:no_y1,no_u1+1:no_u1+no_u2);
D21 = dd(no_y1+1:no_y1+no_y2,1:no_u1);
D22 = dd(no_y1+1:no_y1+no_y2,no_u1+1:no_u1+no_u2);
disp(' ')
disp('       Poles of P(s~) - -')
lampp = eig(A)
disp(' ')
disp('                    (strike a key to continue)')
pause
clc
disp(' ')
disp('  ------------------------------------------------------------------')
disp('    4. Starting H-Inf design in "s~" domain:');
disp(' ')
disp('       TSS_ = rct2lti(mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,`tss`));')
disp('       % H-Inf GAMMA-Iteration for maximum MSM')
disp('       [gamopt,ss_cp,ss_cl]=hinfopt(TSS_);')
disp('       [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('       [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('  ------------------------------------------------------------------')
disp('  ')
disp('  ')
disp('                    (strike a key to continue)')
pause
format short e
[gamopt,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl]=hinfopt(...
                    A,B1,B2,C1,C2,D11,D12,D21,D22);
disp(' ')
disp(' ')
disp('                    (strike a key to continue)')
pause
[nucp,dncp] = ss2tf(acp,bcp,ccp,dcp,1);
w = logspace(-3,3,100);
[acp,bcp,ccp,dcp] = tf2ss(nucp,dncp);
% --------------------------------------------------------------------
% JW-axis shifting on H-Inf cost & controller from s~------>s
%
clc
disp(' ')
disp('   ----------------------------------------------------------------------')
disp('      Transform the cost & controller from "s~" to "s":')
disp(' ')
disp('      [acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,`Sft_jw`,cirpt);')
disp('      [af,bf,cf,df] = bilin(acp,bcp,ccp,dcp,-1,`Sft_jw`,cirpt);')
disp('   ----------------------------------------------------------------------')
disp(' ')
disp(' ')
disp('                     (strike a key to continue)')
pause
[acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,'Sft_jw',cirpt);
[af,bf,cf,df] = bilin(acp,bcp,ccp,dcp,-1,'Sft_jw',cirpt);
disp(' ')
disp('     - - Computing the cost function Ty1u1(s~) and Ty1u1(s) - -');
[perttw1,diag_d] = ssv(acl,bcl,ccl,dcl,w);
msmw1 = gamopt/max(perttw1)*100;
perttw1 = 20*log10(perttw1);
[pertt1,diag_dl]  = ssv(acll,bcll,ccll,dcll,w);
msm1 = gamopt/max(pertt1)*100;
pertt1  = 20*log10(pertt1);
clf
semilogx(w,[perttw1;pertt1]);
title('Cost Function Ty1u1 in "s~" and "s"');
grid off;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
text(0.2,-5,['ADDITIVE MSM IN s~-DOMAIN: +-',num2str(msmw1),' %']);
text(0.2,-10,['ADDITIVE MSM IN s-DOMAIN : +-',num2str(msm1),' %']);
%prtsc
disp(' ')
disp(' ')
disp('                     (strike a key to continue)')
drawnow
pause
clc
disp(' ')
disp('  ---------------------------------------------------------------')
disp('    5. Start to curve-fit the diagonal scaling matrix D(jw):')
disp('       (compute the cost function (acl,bcl,ccl,dcl) again)')
disp('    ')
disp('       w = logspace(-3,3,100);')
disp('       [SS_D] = rct2lti(fitd(diag_d,w,[3 2 2]));')
disp('     % Absorb the D(s) and inv(D(s)) into the augmented plant:')
disp('       [TSS_D] = augd(TSS_,SS_D);')
disp('  ----------------------------------------------------------------')
disp(' ')
disp(' ')
disp('                     (strike a key to continue)')
pause
%
if w2flag == 0
   ord_d = [3 2 2];
else
   ord_d = [2  2 2 3];
end
[AD,BD,CD,DD] = fitd(diag_d,w,ord_d);
[ga1,ph1] = bode(AD,BD(:,1),CD(1,:),DD(1,1),1,w);
[ga2,ph2] = bode(AD,BD(:,2),CD(2,:),DD(2,2),1,w);
[ga3,ph3] = bode(AD,BD(:,3),CD(3,:),DD(3,3),1,w);
if w2flag ~= 0
   [ga4,ph4] = bode(AD,BD(:,4),CD(4,:),DD(4,4));
end
SS_D = ss(AD,BD,CD,DD);
TSS_ = rct2lti(mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss'));
TSS_D = augd(TSS_,SS_D);
clc
disp(' ')
disp('  -------------------------------------------------------------------')
disp('    6. Design the H-Inf controller for the diagonally-scaled plant')
disp(' ')
disp('       [gamopt,ss_cp,ss_cl] = hinfopt(TSS_D);')
disp('       [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('       [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('  -------------------------------------------------------------------')
disp(' ')
disp(' ')
disp('                    (strike a key to continue)')
pause
[gamopt,ss_cp,ss_cl] = hinfopt(TSS_D);
[acp,bcp,ccp,dcp] = ssdata(ss_cp);
[acl,bcl,ccl,dcl] = ssdata(ss_cl);
disp(' ')
disp(' ')
disp('                    (strike a key to continue)')
pause
%
%mueva
%muplt

%MUEVA Script file for evaluation of 1990 ACC benchmark problem (MU-Synthesis).
%
% ---------------------------------------------------------------
%  MUEVA.M is a script file that evaluates the performance of
%     the ACC Benchmark problem.
% ---------------------------------------------------------------
%

clc
disp(' ');
disp('          << Start to Evaluate the Robust Performance >>');
%
%w = [w [0.1:0.1:2]];
%[w,wind] = sort(w);
%
% --------------------------------------------------------------------
% JW-axis shifting on H-Inf cost & controller from s~------>s
%
disp(' ')
disp('   ----------------------------------------------------------------------')
disp('      Transform the cost & controller from "s~" to "s":')
disp(' ')
disp('      [acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,`Sft_jw`,cirpt);')
disp('      [aff,bff,cff,dff] = bilin(acp,bcp,ccp,dcp,-1,`Sft_jw`,cirpt);')
disp('      Balancing the controller for better numerical property:')
disp('      [af,bf,cf,svh] = obalreal(aff,bff,cff); df = dff;')
disp('   ----------------------------------------------------------------------')
disp(' ')
disp(' ')
disp('                     (strike a key to continue)')
pause
[acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,'Sft_jw',cirpt);
[aff,bff,cff,dff] = bilin(acp,bcp,ccp,dcp,-1,'Sft_jw',cirpt);
[af,bf,cf,svh] = obalreal(aff,bff,cff); df = dff;
clc
disp(' ')
disp('     - - Computing the cost function Ty1u1(s~) and Ty1u1(s) - -');
[perttw,diag_dl] = ssv(acl,bcl,ccl,dcl,w);
msmw = gamopt/max(perttw)*100;
perttw = 20*log10(perttw);
[pertt,diag_dl] = ssv(acll,bcll,ccll,dcll,w);
msm = gamopt/max(pertt)*100;
pertt = 20*log10(pertt);
disp(' ')
disp('       - - Evaluating Controller - - ')
disp(' ')
lamf = eig(af);
if any(real(lamf)>0)
        disp('                Controller is unstable !!');
else
        disp('                Controller is stable - - -');
end
disp(' ')
tzf = tzero(af,bf,cf,df);
if any(real(tzf)>0)
           disp('                Controller is non-minimum phase !!');
else
           disp('                Controller is minimum phase - - -');
end
disp(' ')
disp('                             (strike a key to continue)')
pause
clc
disp(' ')
disp(' ')
disp('      - - Computing the gain/phase of F(s) & L(s) - -');
[gf,pf] = bode(af,bf,-cf,-df,1,w); gf = 20*log10(gf);
% --------------------------------------------------------------
% Evaluate the disturbance response from u,w ---> z
%
disp(' ')
disp('      - - Evaluating the disturbance response from w to z - -')
BB1 = BB1(:,1); DD21 = 0; DD22 = 0;
% ---------------------------------------------------------------
% Including the control energy, disturbance at M1 or M2:
%
BB1a = [0 0 0 1/m2]';         % disturbance at M2
BB1a = [BB1a,[0 0 0 0]'];     % add V(s)
BB1b = [0 0 1/m1 0]';         % disturbance at M1
BB1b = [BB1b,[0 0 0 0]'];     % add V(s)
CC2a = [1 0 0 0;0 1 0 0;0 0 0 0];
DD21a = [0 0;0 0;0 0]; DD22a = [0;0;1];
DD21  = [0 1]; DD22 = 0;
t = 0:0.1:30;
dist_w = sin(0.5*t)';
disp(' ')
disp('      - - Inject the sensor noise: v(t) = 0.001*sin(100*t) - -');
disp(' ')
nos_v  = 0.001*sin(100*t)';
[tmp1, tmp2]=size(t);
ipp = zeros(tmp1, tmp2)'; ipp(1,1) = 1/(t(2)-t(1));
U1 = [ipp nos_v];          % impulse + sensor noise
% -----------------------------------------------------------------------
%
no_spr = size(spring)*[0;1];
for k0no = 1:no_spr
      k0 = spring(k0no)
      AA = [   0       0     1     0
               0       0     0     1
          -k0/m1   k0/m1     0     0
           k0/m2  -k0/m2     0     0];
      % dist. at M2
      [aw2zu,bw2zu,cw2zu,dw2zu] = lftf(...
            AA,BB1a,BB2,CC2a,CC2,DD21a,DD22a,DD21,DD22,af,bf,cf,df);
      lamw2zu = eig(aw2zu);
      if any(real(lamw2zu)>0)
         disp('      Closed-loop unstable - - -');
      else
         disp('      Closed-loop stable - - -');
      end
      % dist. at M1
      [aw1zu,bw1zu,cw1zu,dw1zu] = lftf(...
            AA,BB1b,BB2,CC2a,CC2,DD21a,DD22a,DD21,DD22,af,bf,cf,df);
      imp_w2 = lsim(aw2zu,bw2zu,cw2zu,dw2zu,U1,t);
      x1_ipw2(:,k0no) = imp_w2(:,1);
      x2_ipw2(:,k0no) = imp_w2(:,2);
      u_ipw2(:,k0no)  = imp_w2(:,3);
      imp_w1 = lsim(aw1zu,bw1zu,cw1zu,dw1zu,U1,t);
      x1_ipw1(:,k0no) = imp_w1(:,1);
      x2_ipw1(:,k0no) = imp_w1(:,2);
      u_ipw1(:,k0no)  = imp_w1(:,3);
      svw2z(:,k0no) = bode(aw2zu,bw2zu,cw2zu(2,:),dw2zu(2,:),1,w);
      svw2z(:,k0no) = 20*log10(svw2z(:,k0no));
      disp(' ')
      ag = [0      0     1     0
            0      0     0     1
       -k0/m1   k0/m1    0     0
        k0/m2  -k0/m2    0     0];
      bg = [0 0 1/m1 0]';
      cg = [0 1 0 0]; dg = 0;
      [al,bl,cl,dl] = series(af,bf,-cf,-df,ag,bg,cg,dg);
      [nul(k0no,:),dnl(k0no,:)] = ss2tf(al,bl,cl,dl,1);
      [gl(:,k0no),pl(:,k0no)] = bode(al,bl,cl,dl,1,w);
      [gm(k0no,1),pm(k0no,1),wg(k0no,1),wp(k0no,1)] = ...
                     margin(gl(:,k0no),pl(:,k0no),w);
      gm = 20*log10(gm);
      gl(:,k0no) = 20*log10(gl(:,k0no));
end     % of spring constant loop
%
gmin = min(gm); pmin = min(pm);
gmax = max(gm); pmax = max(pm);
%
% ----- End of MUEVA.M %

%MUPLT Script file for plotting the results of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  MUPLT.M is a script file that produces the plots for the ACC
%     Benchmark problem.
% ---------------------------------------------------------------
%

   clf
   subplot(2,1,1)
   semilogx(w,[perttw1;pertt1]);
   title('Ty1u1 in "s~" and "s"');
   grid off;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
   text(0.002,-5,['MSM in s~: +-',num2str(msmw1),' %']);
   text(0.002,-10,['MSM in s : +-',num2str(msm1),' %']);

   subplot(2,1,2)
   semilogx(w,[perttw;pertt]);
   title('Ty1u1 in "s~" and "s"');
   grid off;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
   text(0.002,-5,['MSM in s~: +-',num2str(msmw),' %']);
   text(0.002,-10,['MSM in s : +-',num2str(msm),' %']);
   drawnow
   pause
   ptid=hdcopy;
   if nargin<2,
      ptid = input(' Do you want a hardcopy ? (1=yes,0=no(default))');
      if isempty(ptid), ptid=0; end
   end
   if ptid == 1
     print
   end

   clf
   subplot(2,2,1)
   loglog(w,exp(diag_d))
   title('Diagonal Scaling D(s)')
   xlabel('Rad/Sec')
   ylabel('logd')

   subplot(2,2,2)
   loglog(w,exp(diag_d(1,:)),'x',w,ga1);
   title('D11(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')

   subplot(2,2,3)
   loglog(w,exp(diag_d(2,:)),'x',w,ga2);
   title('D22(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')

   subplot(2,2,4)
   loglog(w,exp(diag_d(3,:)),'x',w,ga3);
   title('D33(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')
   ptid=hdcopy;
   if nargin<2,
      ptid = input(' Do you want a hardcopy ? (1=yes,0=no (default))');
      if isempty(ptid), ptid=0; end
   end
   if ptid == 1
     print
   end
   drawnow
   pause

   clf
   subplot(2,2,1)
   plot(t,x1_ipw1);grid on;
   title('x1');       xlabel('Sec')

   subplot(2,2,2)
   plot(t,x2_ipw1);grid on;
   title('state x2 vs. time (sec)'); 
   
   subplot(2,1,2)
   h=plot(t,u_ipw1); 
   grid on;
   title('Control (u)'); xlabel('Sec');
   h1=legend(...
      'k = 0.5',...
      'k = 1.0',...
      'k = 2.0',-1);
   set(h1,'Visible','off')
   v=axis;
   xx1=v(2)+0.05*(v(2)-v(1));
   yy1=v(4);
   xx2=v(2)+0.05*(v(2)-v(1));
   yy2=v(4)-0.1*(v(4)-v(3));
   text(xx1,yy1,'Impulse Response @ M1');
   text(xx2,yy2,'Sensor Noise: 0.001*sin(100t)')
   drawnow
   pause
   ptid=hdcopy;
   if nargin<2,
      ptid = input(' Do you want a hardcopy ? (1=yes,0=no (default))');
      if isempty(ptid), ptid=0; end
   end
   if ptid == 1
     print
   end

   clf
   subplot(2,2,1)
   plot(t,x1_ipw2);grid on;
   title('x1');  xlabel('Sec');

   subplot(2,2,2)
   plot(t,x2_ipw2);grid on
   title('x2 vs. time (sec)');

   subplot(2,1,2)
   h=plot(t,u_ipw2); 
   grid on;
   title('Control (u)'); xlabel('Sec');
   h1=legend(...
      'k = 0.5',...
      'k = 1.0',...
      'k = 2.0',-1);
   set(h1,'Visible','off')
   v=axis;
   xx1=v(2)+0.05*(v(2)-v(1));
   yy1=v(4);
   xx2=v(2)+0.05*(v(2)-v(1));
   yy2=v(4)-0.1*(v(4)-v(3));
   text(xx1,yy1,'Impulse Response @ M2');
   text(xx2,yy2,'Sensor Noise: 0.001*sin(100t)')
   drawnow
   pause
   ptid=hdcopy;
   if nargin<2,
      ptid = input(' Do you want a hardcopy ? (1=yes,0=no (default))');
      if isempty(ptid), ptid=0; end
   end
   if ptid == 1
     print
   end
%
clf
subplot(2,2,1)
semilogx(w,gf);title('Controller F(s)');
xlabel('Rad/Sec'); ylabel('Gain (db)')

subplot(2,2,3)
semilogx(w,pf);xlabel('Rad/Sec');ylabel('Phase (deg)')

subplot(2,2,2)
semilogx(w,gl); title('Loop TF G*F'); xlabel('Rad/Sec');
text(0.002,-50,['Min. GM: ',num2str(gmin),' db']);
text(0.002,-150,['Max. GM: ',num2str(gmax),' db']);

subplot(2,2,4)
semilogx(w,pl);
xlabel('Rad/Sec (k = 0.5(- -), 1(-), 2(.))');ylabel('Phase (deg)')
text(0.002,max(min(pl))+100,['Min. PM: ',num2str(pmin),' deg']);
text(0.002,max(min(pl)),['Max. PM: ',num2str(pmax),' deg']);
drawnow
pause
ptid=hdcopy;
   if nargin<2,
      ptid = input(' Do you want a hardcopy ? (1=yes,0=no (default))');
      if isempty(ptid), ptid=0; end
   end
   if ptid == 1
     print
   end
%
clc
disp(' ');
disp(' ');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  *                                                         *')
disp('  *      Your design is accomplished ..                     *')
disp('  *              Controller: (af,bf,-cf,-df).               *')
disp('  *                                                         *')
disp('  *       (strike a key to go back to the main menu)        *')
disp('  *                                                         *')
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
pause
%
% ----------- End of MUPLT.M % RYC/MGS %
%
% ------------ End of MUDEMO.M % RYC/MGS %
