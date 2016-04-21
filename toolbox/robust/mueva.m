%MUEVA Script file for evaluation of 1990 ACC benchmark problem (MU-Synthesis).
%
% ---------------------------------------------------------------
%  MUEVA.M is a script file that evaluates the performance of
%     the ACC Benchmark problem.
% ---------------------------------------------------------------
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

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
disp('      [af,bf,cf,hsv] = obalreal(aff,bff,cff); df = dff;')
disp('   ----------------------------------------------------------------------')
disp(' ')
disp(' ')
disp('                     (strike a key to continue)')
pause
[acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,'Sft_jw',cirpt);
[aff,bff,cff,dff] = bilin(acp,bcp,ccp,dcp,-1,'Sft_jw',cirpt);
[af,bf,cf,hsv] = obalreal(aff,bff,cff); df = dff;
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
         disp('      Closed-Loop unstable - - -');
      else
         disp('      Closed-Loop stable - - -');
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