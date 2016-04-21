function hmatdemo(Gam)
%HMATDEMO H-Infinity Fighter Design Demonstration (HIMAT).
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.14.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------
% clear
clc
disp(' ')
disp('  ')
disp('  ')
disp('                << Demo #2: MIMO Fighter Design Example >>')
disp(' ')
disp(' ')
disp('                        ----')
disp('                         \  \          ----')
disp('                       == \ = \         \  \')
disp('                          /     \        \  \')
disp('                    / ---------------------------- \')
disp('                   |    NASA HIMAT "FIGHTER"        >>>> -----')
disp('                    \ ---------------------------- /')
disp('                          \     /        /  /')
disp('                       == / = /         /  /')
disp('                         /  /          ----')
disp('                        ----')
format short e
ag =[
-2.2567e-02  -3.6617e+01  -1.8897e+01  -3.2090e+01   3.2509e+00  -7.6257e-01;
9.2572e-05  -1.8997e+00   9.8312e-01  -7.2562e-04  -1.7080e-01  -4.9652e-03;
1.2338e-02   1.1720e+01  -2.6316e+00   8.7582e-04  -3.1604e+01   2.2396e+01;
0            0   1.0000e+00            0            0            0;
0            0            0            0  -3.0000e+01            0;
0            0            0            0            0  -3.0000e+01];
bg = [0     0;
      0     0;
      0     0;
      0     0;
     30     0;
      0    30];
cg = [0     1     0     0     0     0;
      0     0     0     1     0     0];
dg = [0     0;
      0     0];
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('   State-Space of the fighter pitch axis (trimmed @ 25000 ft, 0.9 mach):')
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
disp('    Poles of the plant (unstable Phugoid modes):')
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
disp(' ')
disp('  ')
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
disp('      - - - Computing SV Bode plot of the open loop plant - - -')
w = logspace(-3,5,50);
svg = sigma(ag,bg,cg,dg,1,w); svg = 20*log10(svg);
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('                (strike a key to see the SV Bode plot of G(s) ...)')
pause
clf
semilogx(w,svg)
title('MIMO Fighter Pitch Axis Open Loop')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
drawnow
pause
clc
disp('  ')
disp('                    << Design Specifications >>  ')
disp(' ')
disp('      1). Robustness Spec. : -2 roll-off, -20 db @ 100 Rad/Sec.')
disp('          Associated Weighting:')
disp('     ')
disp('                    -1     1000')
disp('                  W3(s) = ------ * I       (fixed Gam=1)')
disp('                            s^2     2x2')
disp('   ')
disp(' ')
disp('      2). Performance Spec.: minimizing the sensitivity function')
disp('                             as much as possible.')
disp('          Associated Weighting:')
disp(' ')
disp('                    -1       -1   s + 0.01')
disp('                  W1(s) = Gam  * ----------- *  I')
disp('                                     1           2x2')
disp('   ')
disp('          where "Gam" in our design goes from 1 --> 8.4 --> 16.8.')
k = 1000; tau = 5.0000e-04; mn = [2 2];
nuw3i = [0 0 k]; dnw3i = [1 0 0];
svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
nuw1i = [1.0000e+00   1.0000e-02]; dnw1i =[0 1];
svw1i = bode(nuw1i,dnw1i,w); svw1i = 20*log10(svw1i);
disp('  ')
disp('  ')
disp('                   (strike a key to see the plot of the weightings ...)')
pause
semilogx(w,svw1i,w,svw3i)
grid on
title('MIMO Fighter Design Example -- Design Specifications')
xlabel('Frequency - Rad/Sec')
ylabel('1/W1 & 1/W3 - db')
text(0.003,-70,'Sensitivity Spec.')
text(0.003,-100,'1/W1(s)')
text(200,-20,'Robustness Spec.')
text(1000,-50,'1/W3(s)')
drawnow
pause
clc
disp('                      << Problem Formulation >>')
disp(' ')
disp('    Form an augmented plant P(s) with the two weighting functions')
disp(' ')
disp('               1). W1 penalizing error signal "e"')
disp('  ')
disp('               2). W3 penalizing plant output "y"')
disp('  ')
disp('    and find a stabilizing controller F(s) such that the H2 or H-Inf norm')
disp('    of TF Ty1u1 is minimized and its H-Inf norm is less than one, i.e.')
disp('  ')
disp('                        min |Ty1u1|   < 1,')
disp('                        F(s)       inf')
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
disp('            *    [Step 2]. Do H2 synthesis (run H2LQG.M)              *')
disp('            *                                                         *')
disp('            *    [Step 3]. Redo the plant augmentation for a          *')
disp('            *              new "Gam" --> 8.4 and rerun H2LQG.M        *')
disp('            *                                                         *')
disp('            *    [Step 4]. Redo the plant augmentation for a          *')
disp('            *              higher "Gam" --> 16.8, then run HINF.M     *')
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
disp('            ----------------------------------------------------------')
disp('             % Plant augmentation for the fighter:')
disp('             ss_g = ss(ag,bg,cg,dg);')
disp('             w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('             w2 = [];')
disp('             w3 = [0 1 0 0;0 0 0 k;tau 1 0 0;0 0 0 k];')
disp('             [TSS_] = augtf(ss_g,w1,w2,w3);')
disp('            ----------------------------------------------------------')
disp('   ')
disp(' ')
Gam=1;
if nargin==0,
   Gam = input('           Input the cost coefficient "Gam" = ');
   if isempty(Gam), Gam=1; disp('Using Gam=1 (default)'), end
end
ss_g = ss(ag,bg,cg,dg);
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
w2 = [];
w3 = [0 1 0 0;0 0 0 k;tau 1 0 0;0 0 0 k];
[TSS_]=augtf(ss_g,w1,w2,w3);
disp(' ')
disp('     - - - State-Space TSS_:=(A,B1,B2,..,D21,D22) is ready for')
disp('           the Small-Gain problem - - -')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('    --------------------------------------------------------------')
disp('     [ss_cp,ss_cl] = h2lqg(TSS_);  % Running H2LQG.M')
disp('     [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('     [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('    --------------------------------------------------------------')
[ss_cp,ss_cl] = h2lqg(TSS_);
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
     xxxx=input('               (strike a key to continue or hit Q <enter> to quit ...)','s');
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
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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
  disp('     ..... Computing the SV Bode plots of sensitivity  & complementary sensitivity .....')
  svs = sigma(al,bl,cl,dl,3,w); svs = -20*log10(svs);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svt = sigma(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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

svw1i1 = svw1i; h2svs1 = svs; h2svt1 = svt; h2svtt1 = svtt;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('    After a few iterations without changing the dynamics of the weights,')
disp(' ')
disp('    we found a new Gam of 8.4 can push the H2 cost function close to its')
disp('  ')
disp('    "shaping limit". ')
disp('  ')
disp('  ')
disp('            Input "Gam" --> 8.4, and try H2LQG again .....')
disp('  ')
disp('  ')
Gam=8.4;
if nargin==0,
   Gam = input('           Input the cost coefficient "Gam" = ');
   if isempty(Gam), Gam=8.4; disp('Using Gam=8.4 (default)'), end
end
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
[TSS_]=augtf(ss_g,w1,w2,w3);
disp(' ')
disp('     - - - New state-space TSS_ is ready for')
disp('           the Small-Gain problem - - -')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('    --------------------------------------------------------------')
disp('     [ss_cp,ss_cl] = h2lqg(TSS_);  % Running H2LQG.M')
disp('     [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('     [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('    --------------------------------------------------------------')
[ss_cp,ss_cl] = h2lqg(TSS_);
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
if flagga < 1,
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
  disp('     ..... Computing Bode plots of Sens. & Comp. Sens. functions .....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = bode(als,bls,cls,dls,1,w); svs = 20*log10(svs);
  svt = bode(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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

svw1i2 = svw1i; h2svs2 = svs; h2svt2 = svt; h2svtt2 = svtt;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('               Now let us try H-Inf synthesis .....')
disp('   ')
disp('    After a few iterations on the parameter "Gam", we found "Gam" can be')
disp(' ')
disp('    increased to 16.8, which is twice the H2 value!!  That is, using')
disp('   ')
disp('    H-Inf "Gam-iteration", one can squeeze more from a particular design')
disp(' ')
disp('    specifications than with H2, and hence, cause the singular values to ')
disp('  ')
disp('    more precisely meet frequency-domain "loop-shaping" objectives.')
disp('  ')
disp('    Note that for H-Inf synthesis, the D11 matrix (i.e. W1(inf)) can')
disp('  ')
disp('    be NONZERO now (--> denominator of W1 = [0.01 1];).')
disp(' ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
dnw1i = [0.01 1];
disp('            ----------------------------------------------------------')
disp('             % Plant augmentation of the fighter:')
disp('             w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];')
disp('             [TSS_]=augtf(ss_g,w1,w2,w3);')
disp('            ----------------------------------------------------------')
disp('   ')
disp('             Input "Gam" --> 16.8, and try HINF.M ....')
disp(' ')
Gam=16.8;
if nargin==0,
   Gam = input('           Input the cost coefficient "Gam" = ');
   if isempty(Gam), Gam=16.8; disp('Using Gam=16.8 (default)'), end
end
w1 = [Gam*dnw1i;nuw1i;Gam*dnw1i;nuw1i];
[TSS_]=augtf(ss_g,w1,w2,w3);
disp(' ')
disp('     - - - State-Space TSS_ is ready for')
disp('           the Small-Gain problem - - -')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
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
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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
  disp('           (strike a key to see the plots of sensitivity & complementary sensitivity ...)')
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

svw1i3 = svw1i; hinfsvs = svs; hinfsvt = svt; hinfsvtt = svtt;
disp('  ')
disp('  ')
disp('                  (strike a key to see the plots of the comparison ...)')
pause
clf
semilogx(w,svw1i1,w,h2svs1,w,svw1i2,w,h2svs2,w,svw1i3,w,hinfsvs)
title('H2 & H-Inf Fighter Design -- 1/W1 & Sensitivity S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,30,'H2 (Gam = 1) ---> H2 (Gam = 8.4) ---> H-Inf (Gam = 16.8)')
drawnow
pause
semilogx(w,svw3i,w,h2svt1,w,h2svt2,w,hinfsvt)
title('H2 & H-Inf Fighter Design -- 1/W3 & Comp. Sensitivity I-S(s)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.005,100,'H2 (Gam = 1) ---> H2 (Gam = 8.4) ---> H-Inf (Gam = 16.8)')
drawnow
pause
semilogx(w,h2svtt1,w,h2svtt2,w,hinfsvtt)
title('H2 & H-Inf Fighter Design -- Cost function Ty1u1')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(0.002,-25,'H2 (Gam = 1) ---> H2 (Gam = 8.4) ---> H-Inf (Gam = 16.8)')
drawnow
pause
clc
disp('  ')
disp('  ')
disp('             << 8-State H-Inf Controller (Gam = 16.8) >>')
disp('    ')
disp('    Poles of the Controller :')
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
title('8-State H-Inf Controller (Gam = 16.8)')
xlabel('Rad/Sec')
ylabel('SV (db)')
grid on
drawnow
pause
clc
disp('    Poles of the cost function :')
poletyu = eig(acl)
disp('                                 (strike a key to continue ...)')
pause
%
% ------ End of HIMATDEMO.
