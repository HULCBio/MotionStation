function josedemo(Gam)
%JOSEDEMO Demo of H-Infinity design for Large space structure.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.14.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------
clear
clc
disp('         << Demo #3: MIMO Large Space Structure Design Example >>')
disp('                                          __________')
disp('         Secondary Mirror ---->   -ooo-         ^')
disp('                                 / \ / \        |')
disp('                                 |  X  |        |')
disp('                                 | / \ |        |')
disp('                                 -------        |')
disp('                                 | \ / |        |')
disp('                                 |  X  |        |')
disp('                                 | / \ |         ')
disp('                   Lens ------>  ---O---     7.4 Meters')
disp('                                |       |        ')
disp('                               |  \   /  |      |')
disp('                               |   \ /   |      |')
disp('                               |    X    |      |')
disp('                              |    / \    |     |')
disp('                              |   /   \   |     |')
disp('                             /   /     \   \    |')
disp('        Primary Mirror -->  (_OOOOOO____\___)   |')
disp('                             \             /    |')
disp('                              \___________/ ____v___')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
format short e
ag =[-9.9005e-01   4.7491e-04   4.8994e-01   1.9219e+00;
      9.0643e-04  -9.8765e-01   1.9010e+00  -4.9180e-01;
     -4.9605e-01  -1.9005e+00  -3.1170e+02   4.9716e+00;
     -1.9215e+00   4.9069e-01  -7.7879e+00  -3.9831e+02];
bg = [7.8273e-01  -6.1398e-01;
      6.1298e-01   7.8260e-01;
      7.8349e-01   5.9597e-01;
      6.0685e-01  -7.8784e-01];
cg = [7.8291e-01   6.1279e-01  -7.8163e-01  -6.0610e-01;
     -6.1438e-01   7.8200e-01  -5.9841e-01   7.8842e-01];
dg = [0     0;
      0     0];
clc
disp('  ')
disp('   State-space matrices of the large space structure')
disp('   (after collocated rate feedback and model reduction):')
ag
bg
disp('                                 (strike a key to continue ...)')
pause
clc
cg
dg
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('    Poles of the plant (stable):')
disp('  ')
disp('    ---------------------------------------------------------------')
disp('       poleg = eig(ag)      % Computing the poles of the plant')
disp('    ---------------------------------------------------------------')
poleg  = eig(ag)
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('    ')
disp('    Transmission zeros of the plant (minimum phase):')
disp('  ')
disp('    -------------------------------------------------------------------')
disp('      tzerog = tzero(ag,bg,cg,dg)   % Computing the transmission zeros')
disp('    -------------------------------------------------------------------')
tzerog = tzero(ag,bg,cg,dg)      % Computing the transmission zeros
disp('  ')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('     - - - Computing SV Bode plot of the open loop plant - - -')
w = logspace(-3,5,50);
svg = sigma(ag,bg,cg,dg,1,w); svg = 20*log10(svg);
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('                    (strike a key to see the SV Bode plot of G(s) ...)')
pause
clf
semilogx(w,svg)
title('MIMO Large Space Structure Open Loop')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
drawnow
pause
clc
disp('  ')
disp('                         << Design Specifications >>  ')
disp(' ')
disp('      1). Robustness Spec. : closed loop bandwidth -- 2000 r/s (300 hz)')
disp('          Associated Weighting:')
disp('     ')
disp('                    -1     2000')
disp('                  W3(s) = ------ * I       (fixed Gam=1)')
disp('                             s      2x2')
disp('   ')
disp(' ')
disp('      2). Performance Spec.: sensitivity reduction of at least 100:1')
disp('                             up to approx. 100 r/s')
disp('          Associated Weighting:')
disp(' ')
disp('                   -1        -1   0.01(1 + s/100)^2')
disp('                  W1(s) = Gam  * --------------------- *  I')
disp('                                     (1 + s/5000)^2        2x2')
disp('   ')
disp('          where "Gam" in our design goes from 1 --> 1.5.')
k = 2000;
nuw3i = [0 k]; dnw3i = [1 0];
svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
nuw1i = conv([1/100 1],[1/100 1]); dnw1i = 100*conv([1/5000 1],[1/5000 1]);
svw1i = bode(nuw1i,dnw1i,w); svw1i = 20*log10(svw1i);
disp('  ')
disp('  ')
disp('                 (strike a key to see the plot of the weightings ...)')
pause
axis([0 5 -40 40])
semilogx(w,svw1i,w,svw3i)
grid on
title('MIMO LSS Design Example -- Design Specifications')
xlabel('Frequency - Rad/Sec')
ylabel('1/W1 & 1/W3 - db')
text(2,-20,'Sensitivity Spec.-- 1/W1(s)')
text(2,10,'Robustness Spec.-- 1/W3(s)')
drawnow
pause
axis
clc
disp('                      << Problem Formulation >>')
disp(' ')
disp('      Form an augmented plant P(s) with the two weighting functions')
disp(' ')
disp('                 1). W1 penalizing error signal "e"')
disp('  ')
disp('                 2). W3 penalizing plant output "y"')
disp(' ')
disp('      and find a stabilizing controller F(s) such that the Hinf-norm')
disp('      of TF Ty1u1 is minimized and less than one, i.e.')
disp('  ')
disp('                         min |Ty1u1|   < 1,')
disp('                         F(s)       inf')
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
disp('            *    [Step 1]. Do plant augmentation (run AUGSS.M or      *')
disp('            *              AUGTF.M)                                   *')
disp('            *                                                         *')
disp('            *    [Step 2]. Do H-Inf synthesis (run HINF.M)            *')
disp('            *                                                         *')
disp('            *    [Step 3]. Redo the plant augmentation by setting     *')
disp('            *              a new "Gam" --> 1.5 and rerun HINF.M       *')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('           Assign the cost coefficient "Gam" --> 1 ')
disp('       ')
disp('           This will serve as the baseline design ....')
disp('  ')
disp(' ')
if nargin==0,
   Gam = input('             Input the cost coefficient "Gam" = ');
   if isempty(Gam), Gam=1; disp('Using Gam=1 (default)'), end
else
   Gam=1;
end
disp('  ')
disp('     ----------------------------------------------------------------')
disp('         % Plant augmentation for the LSS:')
disp('           ss_g = ss(ag,bg,cg,dg);')
disp('           w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('           w2 = [];')
disp('           w3 = [dnw3i;nuw3i;dnw3i;nuw3i];')
disp('           [TSS_] = augtf(ss_g,w1,w2,w3);')
disp('     ----------------------------------------------------------------')
ss_g = ss(ag,bg,cg,dg);
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
w2 = [];
w3 = [dnw3i;nuw3i;dnw3i;nuw3i];
[TSS_]=augtf(ss_g,w1,w2,w3);
disp('  ')
disp('     - - - State-Space TSS_:=(A,B1,B2,..,D21,D22) is ready for')
disp('           the Small-Gain problem - - -')
disp(' ')
disp(' ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('  ')
disp('   --------------------------------------------------------------- ')
disp('    [ss_cp,ss_cl,hinfo] = hinf(TSS_);')
disp('    [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('    [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('                    % Running file HINF.M for H-Inf optimization')
disp('   ---------------------------------------------------------------')
[ss_cp,ss_cl,hinfo] = hinf(TSS_);
[acp,bcp,ccp,dcp] = ssdata(ss_cp);
[acl,bcl,ccl,dcl] = ssdata(ss_cl);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
%pltopt           % Preparing singular values for plotting

%PLTOPT Preparing plots for evaluating H2 or H-inf design performance.
%
%             Inputs: ag,bg,cg,dg, nuw1i,dnw1i, nuw3i,dnw3i
%


% ----------------------------------------------------------------
clc
disp('  ')
disp('     ..... Evaluating performance ..... Please wait .....')
flagga = exist('Gam');
if flagga < 1
   Gam=[];
   while isempty(gam),
      Gam = input('   Input cost function coefficient "Gam" = ');
   end
end
% -------------------------------------------------------------------
[rdg,cdg] = size(dg);
%
[al,bl,cl,dl] = series(acp,bcp,ccp,dcp,ag,bg,cg,dg);
if rdg == 1 & cdg == 1
  disp('  ')
  disp('     ..... Computing Bode plot of the cost function .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  pause
  disp('  ')
  disp(' ')
  if nargin==0,
     xxxx=input('               (press <enter> to continue, or Q to quit ...)','s');
     if isequal(upper(xxxx) ,'Q'), return, end
  end
  pause
  disp(' ')
  disp('     ..... Computing Bode plots of sensitivity & complementary sensitivity  .....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = bode(als,bls,cls,dls,1,w); svs = 20*log10(svs);
  svt = bode(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity and complementary sensitivity ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on , drawnow
  pause
  disp(' ')
  disp('     ..... Computing Nichols plot & stability margin .....')
  [gal,phl] = bode(al,bl,cl,dl,1,w);
  [Gmarg,Pmarg,Wcg,Wcp] = margin(gal,phl,w);
  Gmarg = 20*log10(Gmarg);
  gal = 20*log10(gal);
  disp(' ')
  disp(' ')
  disp('                 (strike a key to see the Nichols plot of L(s) ...)')
  pause
  clf
  plot(phl,gal)
  maxphl = max(phl);  minphl = min(phl);  delphl = abs(maxphl-minphl);
  maxgal = max(gal);  mingal = min(gal);  delgal = abs(maxgal-mingal);
  text(minphl,mingal+delgal/2,...
  [' GAIN MARGIN  = ' num2str(Gmarg) ' db at ' num2str(Wcg) ' rad/sec'])
  text(minphl,mingal+delgal/4,...
  [' PHASE MARGIN = ' num2str(Pmarg) ' deg at ' num2str(Wcp) ' rad/sec'])
  title('NICHOLS PLOT')
  xlabel('Phase -- deg')
  ylabel('Gain -- db')
  grid on
  drawnow
  pause
else
  disp('  ')
  disp('     ..... Computing the SV Bode plot of Ty1u1 .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  drawnow
  pause
  disp('  ')
  disp(' ')
  if nargin==0,
     xxxx=input('               (press <enter> to continue, or Q to quit ...)','s');
     if isequal(upper(xxxx) ,'Q'), return, end
  end
  pause
  disp(' ')
  disp('     ..... Computing the SV Bode plots of sensitivity and complementary sensitivity .....')
  svs = sigma(al,bl,cl,dl,3,w); svs = -20*log10(svs);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svt = sigma(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity and complementary sensitivity ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
end
%
if rdg == 1 & cdg == 1
   disp('  ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ frequency (rad/sec)')
   disp(' gal, phl ---- gain & phase of L(jw) (loop transfer function)')
   disp(' svs ---- Bode plot of S(jw) (sensitivity)')
   disp(' svt ---- Bode plot of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- Bode plot of the cost function (Ty1u1(jw))')
   disp(' svw1i --- Bode plot of 1/W1(jw) weighting function')
   disp(' svw3i --- Bode plot of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
else
   disp(' ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ frequency (rad/sec)')
   disp(' svs ---- singular values of S(jw) (sensitivity)')
   disp(' svt ---- singular values of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- singular values of the cost function (Ty1u1(jw))')
   disp(' svw1i --- singular values of 1/W1(jw) weighting function')
   disp(' svw3i --- singular values of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
end
%
% -------- End of PLTOPT.M --- RYC/MGS

svw1i1 = svw1i; hsvs1 = svs; hsvt1 = svt; hsvtt1 = svtt;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('     After a few iterations, we found a new Gam of 1.5 can push the')
disp('  ')
disp('     H-Inf cost function close to its limit. ')
disp('  ')
disp('  ')
disp('            Input "Gam" --> 1.5, and try HINF again .....')
disp(' ')
disp(' ')
if nargin==0,
   Gam = input('             Input the cost coefficient "Gam" = ');
   if isempty(Gam), Gam=1.5; disp('Using Gam=1.5 (default)'), end
else
   Gam=1.5;
end
disp('  ')
disp('     ---------------------------------------------------------------')
disp('         % Adjust plant augmentation:')
disp('           w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('           [TSS_] = augtf(ss_g,w1,w2,w3);')
disp('     ---------------------------------------------------------------')
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
[TSS_]=augtf(ss_g,w1,w2,w3);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('   --------------------------------------------------------------- ')
disp('    [ss_cp,ss_cl,hinfo] = hinf(TSS_);')
disp('    [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('    [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('                    % Running file HINF.M for H-Inf optimization')
disp('   ---------------------------------------------------------------')
[ss_cp,ss_cl,hinfo] = hinf(TSS_);
[acp,bcp,ccp,dcp] = ssdata(ss_cp);
[acl,bcl,ccl,dcl] = ssdata(ss_cl);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
%pltopt

%PLTOPT Preparing plots for evaluating H2 or H-inf design performance.
%
%             Inputs: ag,bg,cg,dg, nuw1i,dnw1i, nuw3i,dnw3i
%

% ----------------------------------------------------------------
clc
disp('  ')
disp('     ..... Evaluating performance ..... Please wait .....')
flagga = exist('Gam');
if flagga < 1
   Gam=[];
   while isempty(Gam),
      Gam = input('   Input cost function coefficient "Gam" = ');
   end
end
% -------------------------------------------------------------------
[rdg,cdg] = size(dg);
%
[al,bl,cl,dl] = series(acp,bcp,ccp,dcp,ag,bg,cg,dg);
if rdg == 1 & cdg == 1
  disp('  ')
  disp('     ..... Computing Bode plot of the cost function .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  drawnow
  pause
  disp('  ')
  disp(' ')
  if nargin==0,
     xxxx=input('               (press <enter> to continue, or Q to quit ...)','s');
     if isequal(upper(xxxx) ,'Q'), return, end
  end
  pause
  disp(' ')
  disp('     ..... Computing Bode plots of sensitivity and complementary sensitivity.....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = bode(als,bls,cls,dls,1,w); svs = 20*log10(svs);
  svt = bode(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity and complementary sensitivity ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  drawnow
  pause
  disp(' ')
  disp('     ..... Computing Nichols plot & stability margin .....')
  [gal,phl] = bode(al,bl,cl,dl,1,w);
  [Gmarg,Pmarg,Wcg,Wcp] = margin(gal,phl,w);
  Gmarg = 20*log10(Gmarg);
  gal = 20*log10(gal);
  disp(' ')
  disp(' ')
  disp('                 (strike a key to see the Nichols plot of L(s) ...)')
  pause
  clf
  plot(phl,gal)
  maxphl = max(phl);  minphl = min(phl);  delphl = abs(maxphl-minphl);
  maxgal = max(gal);  mingal = min(gal);  delgal = abs(maxgal-mingal);
  text(minphl,mingal+delgal/2,...
  [' GAIN MARGIN  = ' num2str(Gmarg) ' db at ' num2str(Wcg) ' rad/sec'])
  text(minphl,mingal+delgal/4,...
  [' PHASE MARGIN = ' num2str(Pmarg) ' deg at ' num2str(Wcp) ' rad/sec'])
  title('NICHOLS PLOT')
  xlabel('Phase -- deg')
  ylabel('Gain -- db')
  grid on
  drawnow
  pause
else
  disp('  ')
  disp('     ..... Computing the SV Bode plot of Ty1u1 .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  drawnow
  pause
  disp('  ')
  disp(' ')
  if nargin==0,
     xxxx=input('               (press <enter> to continue, or Q to quit ...)','s');
     if isequal(upper(xxxx) ,'Q'), return, end
  end
  pause
  disp(' ')
  disp('     ..... Computing the SV Bode plots of sensitivity and complementary sensitivity .....')
  svs = sigma(al,bl,cl,dl,3,w); svs = -20*log10(svs);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svt = sigma(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity and complementary sensitivity ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  drawnow
  pause
end
%
if rdg == 1 & cdg == 1
   disp('  ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ frequency (rad/sec)')
   disp(' gal, phl ---- gain & phase of L(jw) (loop transfer function)')
   disp(' svs ---- Bode plot of S(jw) (sensitivity)')
   disp(' svt ---- Bode plot of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- Bode plot of the cost function (Ty1u1(jw))')
   disp(' svw1i --- Bode plot of 1/W1(jw) weighting function')
   disp(' svw3i --- Bode plot of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
else
   disp(' ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ frequency (rad/sec)')
   disp(' svs ---- singular values of S(jw) (sensitivity)')
   disp(' svt ---- singular values of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- singular values of the cost function (Ty1u1(jw))')
   disp(' svw1i --- singular values of 1/W1(jw) weighting function')
   disp(' svw3i --- singular values of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
end
%
% -------- End of PLTOPT.M --- RYC/MGS

svw1i2 = svw1i; hsvs2 = svs; hsvt2 = svt; hsvtt2 = svtt;
disp('  ')
disp('  ')
disp('                 (strike a key to see the plots of the comparison ...)')
pause
clf
semilogx(w,svw1i1,w,hsvs1,w,svw1i2,w,hsvs2)
title('H-Inf LSS Design -- 1/W1 & Sensitivity S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,0,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
drawnow
pause
semilogx(w,svw3i,w,hsvt1,w,hsvt2)
title('H-Inf LSS Design -- 1/W3 & Comp. Sensitivity I-S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,0,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
pause
semilogx(w,hsvtt1(1,:),w,hsvtt2(1,:))
title('H-Inf LSS Design -- Cost function Ty1u1')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,-10,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
drawnow
pause
clc
disp('  ')
disp('  ')
disp('             << H-Inf Controller (Gam = 1.5) >>')
disp('    ')
disp('    Poles of Controller :')
polecp = eig(acp)
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
disp(' ')
disp('    Transmission zeros of the controller :')
tzcp = tzero(acp,bcp,ccp,dcp)
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
svcp = sigma(acp,bcp,ccp,dcp,1,w); svcp = 20*log10(svcp);
semilogx(w,svcp)
title('Final 8-State H-Inf Controller')
xlabel('Rad/Sec')
ylabel('SV (db)')
pause
clc
disp('    Poles of the cost function :')
poletyu = eig(acl)
disp('                                 (strike a key to continue ...)')
pause
%
% ----- End of JOSEDEMO.M --- RYC/MGS %
