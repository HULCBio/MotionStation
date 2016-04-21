function linfdemo
%LINFDEMO Demo of L-Infinity control design for large space structure.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------
clc
disp('      << Linfdemo: MIMO Large Space Structure Design Example >>')
disp('                                          __________')
disp('         Secondary Mirror ---->   -ooo-         ^')
disp('                                 / \ / \        |')
disp('                                 |  X  |        |')
disp('                                 | / \ |        |')
disp('                                 -------        |')
disp('                                 | \ / |        |')
disp('                                 |  X  |        |')
disp('                                 | / \ |         ')
disp('                  Lense ------>  ---O---     7.4 Meters')
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
disp('   State-space of the large space structure')
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
disp(' - - - Computing singular value Bode plot of the open loop plant - - -')
w = logspace(-3,5,100);
svg = sigma(ag,bg,cg,dg,1,w); svg = 20*log10(svg);
disp('  ')
disp(' ')
disp(' ')
disp('                       (strike a key to see the open loop plant ...)')
pause
subplot
semilogx(w,svg)
title('MIMO Large Space Structure Open Loop')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
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
disp('                    -1       -1   0.01(1 + s/100)^2')
disp('                  W1(s) = Gam  * --------------------- *  I')
disp('                                     (1 + s/5000)^2        2x2')
disp('   ')
disp('          where "Gam" in our design goes from 1 --> 1.5.')
k = 2000;
nuw3i = [0 k]; dnw3i = [1 0];
svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
nuw1i = 0.01*conv([1/100 1],[1/100 1]); dnw1i = conv([1/5000 1],[1/5000 1]);
svw1i = bode(nuw1i,dnw1i,w); svw1i = 20*log10(svw1i);
disp('  ')
disp('  ')
disp('         (strike a key to see the plot of weighting functions ...)')
pause
subplot
axis([0 5 -40 40])
semilogx(w,svw1i,w,svw3i)
grid on
title('MIMO LSS Design Example -- Design Specifications')
xlabel('Frequency - Rad/Sec')
ylabel('1/W1 & 1/W3 - db')
text(2,-20,'Sensitivity Spec.-- 1/W1(s)')
text(2,10,'Robustness Spec.-- 1/W3(s)')
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
disp('                       |               -1|    |               |')
disp('                       |  W3*GF*(I + GF) |    |  W3 * (I - S) |')
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
disp('            *    [Step 2]. Do H-Inf synthesis (run LINF.M)            *')
disp('            *                                                         *')
disp('            *    [Step 3]. Redo the plant augmentation by setting     *')
disp('            *              a new "Gam" --> 1.5 and rerun LINF.M       *')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('  ')
disp('           Assign the cost coefficient "Gam" --> 1 ')
disp('       ')
disp('           This will serve as the baseline design ....')
disp('  ')
disp(' ')
Gam = input('             Input the cost coefficient "Gam" = ');
if isempty(Gam), Gam=1; disp('Using Gam=1 (default)'), end
disp('  ')
disp('     ------------------------------------------------------------------')
disp('         % Plant augmentation for the LSS:')
disp('           ss_g = ss(ag,bg,cg,dg);')
disp('           w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('           w2 = [];')
disp('           w3 = [dnw3i;nuw3i;dnw3i;nuw3i];')
disp('           TSS_  = augtf(ss_g,w1,w2,w3);')
disp('           [A,B1,B2,C1,C2,D11,D12,D21,D22] = branch(TSS_);')
disp('     ------------------------------------------------------------------')
ss_g = ss(ag,bg,cg,dg);
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
w2 = [];
w3 = [dnw3i;nuw3i;dnw3i;nuw3i];
TSS_ = augtf(ss_g,w1,w2,w3);
[A,B1,B2,C1,C2,D11,D12,D21,D22] = branch(TSS_);
[aa,bb,cc,mm,tt] = obalreal(A,[B1,B2],[C1;C2]);
A = aa; B1 = bb(:,1:2); B2 = bb(:,3:4); C1 = cc(1:4,:); C2 = cc(5:6,:);
disp('  ')
disp('     - - - State-Space (A,B1,B2,C1,C2,D11,D12,D21,D22) is ready for')
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
disp('    ---------------------------------------------------------------')
disp('     linf      % Running script file LINF.M for H-Inf optimization')
disp('    ---------------------------------------------------------------')
linf
syscp = [acp,bcp;ccp dcp]; xcp = size(acp)*[1;0];
syscl = [acl,bcl;ccl dcl]; xcl = size(acl)*[1;0];
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
pltopt           % Preparing singular values for plotting
svw1i1 = svw1i; hsvs1 = svs; hsvt1 = svt; hsvtt1 = svtt;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('  ')
disp('     After a few iterations, we found a new Gam of 1.5 can push the')
disp('  ')
disp('     H-Inf cost function close to its limit. ')
disp('  ')
disp('  ')
disp('            Input "Gam" --> 1.5, and try LINF again .....')
disp('  ')
disp('  ')
Gam = input('             Input the cost coefficient "Gam" = ');
if isempty(Gam), Gam=1.5; disp('Using Gam=1.5 (default)'), end
disp('  ')
disp('     ------------------------------------------------------------------')
disp('         % Adjust plant augmentation:')
disp('           w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('           TSS_ = augtf(ss_g,w1,w2,w3);')
disp('           [A,B1,B2,C1,C2,D11,D12,D21,D22] = branch(TSS_);')
disp('     ------------------------------------------------------------------')
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
TSS_ = augtf(ss_g,w1,w2,w3);
[A,B1,B2,C1,C2,D11,D12,D21,D22] = branch(TSS_);
[aa,bb,cc,mm,tt] = obalreal(A,[B1,B2],[C1;C2]);
A = aa; B1 = bb(:,1:2); B2 = bb(:,3:4); C1 = cc(1:4,:); C2 = cc(5:6,:);
disp('  ')
disp('     - - - State-Space (A,B1,B2,C1,C2,D11,D12,D21,D22) is ready for')
disp('           the Small-Gain problem - - -')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
linf
syscp = [acp,bcp;ccp dcp]; xcp = size(acp)*[1;0];
syscl = [acl,bcl;ccl dcl]; xcl = size(acl)*[1;0];
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
pltopt
svw1i2 = svw1i; hsvs2 = svs; hsvt2 = svt; hsvtt2 = svtt;
disp('  ')
disp('  ')
disp('                             (strike a key to see the plots ...)')
pause
semilogx(w,svw1i1,w,hsvs1,w,svw1i2,w,hsvs2)
title('H-Inf LSS Design -- W1 & Sensitivity S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.01,0,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
pause
axis([0 5 -40 40])
subplot
semilogx(w,svw3i,w,hsvt1,w,hsvt2)
title('H-Inf LSS Design -- W3 & Comp. Sensitivity I-S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(2,20,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
pause
axis
semilogx(w,hsvtt1(1,:),w,hsvtt2(1,:))
title('H-Inf LSS Design -- Cost function Ty1u1')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.001,-1.5,'H-Inf (Gam = 1) ---> H-Inf (Gam = 1.5)')
pause
clc
disp('  ')
disp('  ')
disp('               << H-Inf Controller (Gam = 1.5) >>')
disp('    ')
disp('    Poles of Controller :')
polecp = eig(acp)
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('    State-Space of the final H-Inf Controller:')
disp('   ')
acp
disp('                                 (strike a key to continue ...)')
pause
clc
bcp
disp('                                 (strike a key to continue ...)')
pause
clc
ccp
dcp
disp('                                 (strike a key to continue ...)')
pause
clc
disp('   ')
disp('    Poles of closed-loop TF matrix Ty1u1:')
poletyu = eig(acl)
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('  ')
disp('  ')
disp('                   * * * * * * * * * * * * * * * * *')
disp('                   *  End of LINFDEMO  ......      *')
disp('                   *                               *')
disp('                   * Good luck with your design !! *')
disp('                   * * * * * * * * * * * * * * * * *')
%
% ----- End of LINFDEMO.M --- RYC/MGS %
