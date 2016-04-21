function actdemo(x)
%ACTDEMO Demo of digital H2/H-Inf hydraulic actuator design.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
% All Rights Reserved.
% $Revision: 1.7.4.3 $
% ---------------------------------------------------------------
clear
clc
disp('    ')
disp(' ')
disp('          << Demo #1: SISO Digital Hydraulic Actuator Design Example >>')
disp('  ')
disp(' ')
disp('  ')
disp('                         -------             -----        -----')
disp('        +        /      | H-Inf |     /     |     |      | Hyd.|')
disp('      --->(X)----  -----| Cont- | ----  --->| ZOH |----->|     |--------->')
disp('           ^ - Ts:0.01  | roller|   Ts:0.01 |     |      | ACT.|    |')
disp('           |      sec    -------       sec   -----        -----     |')
disp('           |                                                        |')
disp('           |________________________________________________________|')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
format short e
num = 9000;
den = [1 30 700 1000];
[a,b,c,d] = tf2ss(num,den);
clc
disp('  ')
disp('  ')
disp('   Hydraulic Actuator Open Loop:')
disp(' ')
disp('   ')
disp('                                 9000')
disp('             G(s) = -----------------------------')
disp('                     s^3 + 30 s^2 + 700 s + 1000')
disp('  ')
disp(' ')
disp('      Poles of the open loop plant:')
poleg = roots(den)
disp('  ')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('                          << Direct Z-Plane Design >>')
disp('  ')
disp('  ')
disp('           Let us digitize the plant using Tustin (sampling: 0.01 sec) ....')
disp(' ')
disp('  ')
disp('         ------------------------------------------------------------------')
disp('           [az,bz,cz,dz]=c2dm(........);       % Digitize the plant')
disp('         ------------------------------------------------------------------')
[az,bz,cz,dz] = c2dm(a,b,c,d,0.01,'tustin');
ag = az;bg = bz;cg = cz; dg = dz;
clc
disp(' ')
disp('     - - - Computing Bode plot of the open loop plant (in s & z) - - -')
w = logspace(-3,2,50);
svg = bode(a,b,c,d,1,w); svg = 20*log10(svg);
svz = dbode(ag,bg,cg,dg,0.01,1,w); svz = 20*log10(svz);
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('                             (strike a key to see the plot ...)')
pause
clf
plot(111)
semilogx(w,svg,w,svz)
title('SISO Hydraulic Actuator Open Loop (in s & z domain)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
text(150,-30,'Nyquist Freq.: 100pi, 50Hz')
grid on
drawnow
pause
clc
disp('  ')
disp('                       << Design Specifications >>  ')
disp(' ')
disp('      1). Robustness Spec. : closed loop bandwidth -- 30 r/s')
disp('          Associated Weighting:')
disp('     ')
disp('                    -1     3.16(1 + s/300)')
disp('                  W3(s) = -----------------')
disp('                             (1 + s/10)')
disp('   ')
disp(' ')
disp('      2). Performance Spec.: sensitivity reduction of at least 100:1')
disp('                             up to approx. 1 r/s')
disp('          Associated Weighting:')
disp(' ')
disp('                   -1         -1   0.01(1 + s)^2')
disp('                  W1(s) = Gam  * ---------------')
disp('                                   (1 + s/30)^2')
disp('   ')
disp('          where "Gam" in our design goes from 1(H2) --> 2.5(Hinf)')
nuw3i = 3.16*[1/300 1]; dnw3i = [1/10 1];
[nuw3iz,dnw3iz] = c2dm(nuw3i,dnw3i,0.01,'tustin');
svw3i = dbode(nuw3iz,dnw3iz,0.01,w); svw3i = 20*log10(svw3i);
nuw1i = 0.01*[1 2 1]; dnw1i = conv([1/30 1],[1/30 1]);
[nuw1iz,dnw1iz] = c2dm(nuw1i,dnw1i,0.01,'tustin');
svw1i = dbode(nuw1iz,dnw1iz,0.01,w); svw1i = 20*log10(svw1i);
disp('  ')
disp('  ')
disp('                   (strike a key to see the weightings in z ...)')
pause
clf
plot(111)
semilogx(w,svw1i,w,svw3i)
grid on
title('Sampled-Data Actuator Design Example -- Design Specifications')
xlabel('Frequency - Rad/Sec')
ylabel('1/W1 & 1/W3 - db')
text(0.005,-20,'Sensitivity Spec.-- 1/W1(s)')
text(100,0,'Robustness Spec.')
text(1000,-10,'1/W3(s)')
drawnow
pause
clc
disp('                      << Problem Formulation >>')
disp(' ')
disp('      Form an augmented plant P(z) with these two weighting functions:')
disp(' ')
disp('                 1). W1 penalizing error signal "e"')
disp('  ')
disp('                 2). W3 penalizing plant output "y"')
disp(' ')
disp('      and find a stabilizing controller F(z) such that the H2 norm')
disp('      is minimized. Moreover, on the 2nd iteration, the Hinf-norm')
disp('      of TF Ty1u1 is minimized and less than one, i.e.')
disp('  ')
disp('                         min |Ty1u1|   < 1,')
disp('                         F(z)       inf')
disp(' ')
disp('      where ')
disp('                       |               -1|')
disp('               Ty1u1 = | Gam*W1*(I + GF) |  = | Gam * W1 * S  |')
disp('                       |               -1|    |  W3 * (I - S) |')
disp('                       |  W3*GF*(I + GF) |')
disp('  ')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp(' ')
disp('                              << DESIGN PROCEDURE >>')
disp('  ')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('            *    [Step 1]. Do plant augmentation (run AUGTF.M or      *')
disp('            *              AUGSS.M)                                   *')
disp('            *                                                         *')
disp('            *    [Step 2]. Do discrete H2 and Hinf synthesis (run     *')
disp('            *              DH2LQG.M)                                  *')
disp('            *                                                         *')
disp('            *    [Step 3]. Redo the plant augmentation by setting     *')
disp('            *              new "Gam" --> 2.5 and run DHINF.M          *')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('           Assign the cost coefficient "Gam" --> 1 ')
disp('       ')
disp('           this will serve as the baseline design ....')
disp('  ')
disp('    ---------------------------------------------------------------')
disp('     % Plant augmentation of the actuator:')
disp('       w1 = [Gam*dnw1i;nuw1i];')
disp('       w3 = [dnw3i;nuw3i];')
disp('       w2 = [];')
disp('       ss_g  = ss(ag,bg,cg,dg);')
disp('       [TSS_]=augtf(ss_g,w1,w2,w3);')
disp('    ---------------------------------------------------------------')
Gam=1; %default
if nargin==0,
   Gam = input('           Input cost coefficient "Gam" = ');
   if isempty(Gam), Gam=1; display('Using Gam=1 (default)'), end
end
w1 = [Gam*dnw1iz;nuw1iz];
w3 = [dnw3iz;nuw3iz];
w2 = [];
ss_g = ss(ag,bg,cg,dg);
[TSS_] = augtf(ss_g,w1,w2,w3);
disp('  ')
disp('     - - - State-Space TSS_:=(A,B1,..,D21,D22) is ready for')
disp('           the H2 minimization...')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('   --------------------------------------------------------------- ')
disp('    [ss_cp,ss_cl,hinfo] = dh2lqg(TSS_);')
disp('    [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('    [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('                    % Running file DH2LQG.M for H2 optimization')
disp('   ---------------------------------------------------------------')
[ss_cp,ss_cl] = dh2lqg(TSS_,'schur');
[acph2,bcph2,ccph2,dcph2] = ssdata(ss_cp);
[aclh2,bclh2,cclh2,dclh2] = ssdata(ss_cl);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
%pltopt           % Preparing singular values for plotting

%PLTOPT Preparing plots for evaluating H2 or H-Inf design performance.
%
%             Inputs: ag,bg,cg,dg, nuw1i,dnw1i, nuw3i,dnw3i
%

% ----------------------------------------------------------------
clc
disp('  ')
disp('     ..... Evaluating performance ..... Please wait .....')
flagga = exist('Gam');
if flagga < 1
   Gam = input('   Input cost function coefficient "Gam" = ');
end
% -------------------------------------------------------------------
[rdg,cdg] = size(dg);
%
[al,bl,cl,dl] = series(acph2,bcph2,ccph2,dcph2,ag,bg,cg,dg);
  disp('  ')
  disp('     ..... Computing Bode plot of the cost function .....')
  svtt = dsigma(aclh2,bclh2,cclh2,dclh2,0.01,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['H2 OPTIMAL COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  drawnow
  pause
  disp('  ')
  disp(' ')
  disp('               (strike a key to continue or hit <CTRL-C> to quit ...)')
  pause
  disp(' ')
  disp('     ..... Computing Bode plots of Sens. & Comp. Sens. functions .....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = dsigma(als,bls,cls,dls,0.01,w); svs = 20*log10(svs);
  svt = dsigma(at,bt,ct,dt,0.01,w); svt = 20*log10(svt);
  svw1i = dbode(nuw1iz,Gam*dnw1iz,0.01,w); svw1i = 20*log10(svw1i);
  svw3i = dbode(nuw3iz,dnw3iz,0.01,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of Sens. & Comp. Sens. ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('H2 SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('H2 COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  drawnow
  pause
  dstep(at,bt,ct,dt)
  pause

svw1ih2 = svw1i; svsh2 = svs; svth2 = svt; svtth2 = svtt;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('  ')
disp('     Now try the Hinf synthesis. We found that a new Gam of 2.5 can push the')
disp('  ')
disp('     H-Inf cost function close to its W3 limit (enlarge the BW). ')
disp('  ')
disp('  ')
disp('            "Gam" --> 2.5, and try DHINF .....')
disp('  ')
disp('  ')
Gam=2.5;
if nargin==0,
   Gam = input('           Input cost coefficient "Gam" = ');
   if isempty(Gam), Gam=2.5; display('Using Gam=2.5 (default)'), end
end
w1 = [Gam*dnw1iz;nuw1iz];
w2 = [1.e-6;1];
[TSS_] = augtf(ss_g,w1,w2,w3);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
[ss_cp,ss_cl,hinfo] = dhinf(TSS_);
[acphf,bcphf,ccphf,dcphf] = ssdata(ss_cp);
[aclhf,bclhf,cclhf,dclhf] = ssdata(ss_cl);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause

%pltopt

%PLTOPT Preparing plots for evaluating H2 or H-Inf design performance.
%
%             Inputs: ag,bg,cg,dg, nuw1i,dnw1i, nuw3i,dnw3i
%

% ----------------------------------------------------------------
clc
disp('  ')
disp('     ..... Evaluating performance ..... Please wait .....')
flagga = exist('Gam');
if flagga < 1
   Gam = input('   Input cost function coefficient "Gam" = ');
end
% -------------------------------------------------------------------
[rdg,cdg] = size(dg);
%
[al,bl,cl,dl] = series(acphf,bcphf,ccphf,dcphf,ag,bg,cg,dg);

  disp('  ')
  disp('     ..... Computing Bode plot of the cost function .....')
  svtt = dsigma(aclhf,bclhf,cclhf,dclhf,0.01,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['H-Inf COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  drawnow
  pause
  disp('  ')
  disp(' ')
  disp('               (strike a key to continue or hit <CTRL-C> to quit ...)')
  pause
  disp(' ')
  disp('     ..... Computing the SV Bode plots of Sens. & Comp. Sens. .....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = dsigma(als,bls,cls,dls,0.01,w); svs = 20*log10(svs);
  svt = dsigma(at,bt,ct,dt,0.01,w); svt = 20*log10(svt);
  svw1i = dbode(nuw1iz,Gam*dnw1iz,0.01,w); svw1i = 20*log10(svw1i);
  svw3i = dbode(nuw3iz,dnw3iz,0.01,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of Sens. & Comp. Sens. ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('H-Inf SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('H-Inf COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
  dstep(at,bt,ct,dt)
  pause
svw1ihf = svw1i; svshf = svs; svthf = svt; svtthf = svtt;
disp('  ')
disp('  ')
disp('                  (strike a key to see the plots of the comparison ...)')
pause
clf
plot(111)
semilogx(w,svw1ih2,w,svsh2,w,svw1ihf,w,svshf)
title('Direct Z-plane H2/H-Inf Actuator Design -- 1/W1 & Sensitivity Func.')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,10,'H-Inf (Gam = 1) ---> H-Inf (Gam = 2.5)')
drawnow
pause
semilogx(w,svw3i,w,svth2,w,svthf)
title('Direct Z-plane H2/H-Inf Actuator Design -- 1/W3 & Comp. Sens. Func.')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,-30,'H-Inf (Gam = 1) ---> H-Inf (Gam = 2.5)')
drawnow
pause
semilogx(w,svtth2,w,svtthf)
title('H2/H-Inf W-Plane Actuator Design -- Cost function Ty1u1')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,-10,'H-Inf (Gam = 1) ---> H-Inf (Gam = 2.5)')
pause


clc
disp('  ')
disp('  ')
disp('               << H2/H-Inf Controller >>')
disp('    ')
disp('    Mag. of Poles of Controllers :')
disp(' ')
disp('  H2 Poles    Hinf Poles')
disp(' ----------- ------------')     
polecp = abs([eig(acph2) eig(acphf)])
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
disp(' ')
disp('  Mag. of Transmission Zeros of the Controllers :')
disp(' ')
disp('  Hinf T-Zeros   H2 T-Zeros')
disp(' ------------ --------------')
tzcph2 = tzero(acph2,bcph2,ccph2,dcph2);
tzcphf = tzero(acphf,bcphf,ccphf,dcphf);
[rf,cf]=size(tzcphf);
[r2,c2]=size(tzcph2);
disp('  H2 T-Zeros   Hinf T-Zeros')
disp(' ------------ --------------')
z1=min([rf,r2]);
z2=z1+1;
for i = 1:z1, disp(sprintf('  %1.4f       %1.4f',abs(tzcph2(i)),abs(tzcphf(i)))),end
for i = z2:rf,disp(sprintf('               %1.4f',abs(tzcphf(i)))),end
for i = z2:r2,disp(sprintf('  %1.4f',abs(tzcph2(i)))),end
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
svcph2 = dsigma(acph2,bcph2,ccph2,dcph2,0.01,w); svcph2 = 20*log10(svcph2);
svcphf = dsigma(acphf,bcphf,ccphf,dcphf,0.01,w); svcphf = 20*log10(svcphf);
semilogx(w,svcph2,'-',w,svcphf,'--')
title('Final Discrete 8-State Controllers')
legend('H2','Hinf')
xlabel('Rad/Sec')
ylabel('SV (db)')
drawnow
pause
clc
disp('    abs(Poles of the Cost Functions) :')
poletyu = [abs(eig(aclh2)) abs(eig(aclhf))]
disp('                                 (strike a key to continue ...)')
pause
%
% ----- End of DACTDEMO.M --- RYC/MGS %

