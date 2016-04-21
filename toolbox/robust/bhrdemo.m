function bhrdemo
%BHRDEMO Demo of model reduction techniques (Hankel, Balanced, BST).

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.

clc
disp('    ')
disp(' ')
disp('      << Demo #4: Comparison of Basis-Free Model Reduction Techniques >>')
disp('  ')
disp(' ')
disp(' ')
disp('        ')
disp('              Technique 1). Schur Balanced Model Reduction')
disp('     ')
disp('              Technique 2). Optimal Descriptor Hankel MDA')
disp(' ')
disp('              Technique 3). Schur BST-REM')
disp('  ')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp(' ')
disp(' ')
disp('   We will compare these three "basis-free" model reduction techniques')
disp(' ')
disp('   via a SISO example. This nonminimal model has 7 states and one of the')
disp('  ')
disp('   modes has low damping (~ -45 db notch). After we truncate to 3-state')
disp(' ')
disp('   model, only Schur BST-REM technique matches well with the 50 db notch')
disp(' ')
disp('   and its associated phase angle. All the other methods fail to produce')
disp('  ')
disp('   a satisfactory fit to the original model.')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('Transfer function of the 7-state model to be reduced (stable & nonminimal) :')
format short e
n1 = [
5.4121e-02   4.3366e+01   5.5430e+01   3.2436e+01   2.4399e+01   6.4144e+00];
n2 = [   2.6329e+00   3.0046e-01];
num = [n1 n2];
d1 = [
1.0000e+00   1.2606e+01   5.3483e+01   9.0942e+01   7.1828e+01   2.7218e+01];
d2 = [4.7546e+00   3.0046e-01];
den = [d1 d2];
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('       0.05(s^7 + 801s^6 + 1024s^5 + 599s^4 + 451s^3 + 119s^2 + 49s + 5.55')
disp(' (s) = -----------------------------------------------------------------------')
disp('       s^7 + 12.6s^6 + 53.48s^5 + 90.94s^4 + 71.83s^3 + 27.22s^2 + 4.75s + 0.3')
disp(' ')
disp(' ')
disp(' ')
disp(' ss_ = ss(a,b,c,d); % Turn it into new system matrix!')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('   - - - Computing the Bode plot of the 7-state model - - -')
w = logspace(-3,4,200);
[ga,ph] = bode(num,den,w);
[a,b,c,d] = tf2ss(num,den);
ss_ = ss(a,b,c,d);
ga = 20*log10(ga);
disp(' ')
disp('  ')
disp('                       (strike a key to see the Bode plot of G(s)...)')
drawnow
pause
clf
semilogx(w,ga)
title('Original 7-State Model')
xlabel('Frequency - Rad/Sec')
ylabel('Gain - db')
grid
drawnow
pause

semilogx(w,ph)
title('Original 7-State Model')
xlabel('Frequency - Rad/Sec')
ylabel('Phase - deg')
grid
drawnow
pause

clc
disp('       -----------------------------------------------------------------')
disp('        [svh] = hksv(a,b,c);    % Computing Hankel singular values')
disp('       -----------------------------------------------------------------')
[svh] = hksv(a,b,c);
svh = svh';
format compact
svh
format loose
disp(' ')
disp(' ')
disp('        (strike a key to see a bar chart of the Hankel Singular Values ...)')
drawnow
pause

bar(svh)
title('Hankel Singular Values')
drawnow
pause

clc
disp(' ')
disp('  ')
disp('   ------------------------------------------------------------------')
disp('    First let us try Schur Balanced model reduction to get a 3-state')
disp('    reduced model ...')
disp(' ')
disp('    [ss_s,bnds,svhs] = schmr(ss_,1,3);      % Run SCHMR.M')
disp('   ------------------------------------------------------------------')
[ss_s,bnds,svhs] = schmr(ss_,1,3);
[as,bs,cs,ds] = ssdata(ss_s);
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('  ')
disp('   ------------------------------------------------------------------')
disp('    Let us try optimal descriptor Hankel model reduction to get a')
disp('    3-state reduced model ...')
disp(' ')
disp('    [ss_h,bndh,svhh] = ohklmr(ss_,1,3);    % Run OHKLMR.M')
disp('   ------------------------------------------------------------------')
[ss_h,bndh,svhh] = ohklmr(ss_,1,3);
[ah,bh,ch,dh] = ssdata(ss_h);
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('  ')
disp('   ------------------------------------------------------------------')
disp('    Let us try Schur BST-REM model reduction to get a 3-state model..')
disp(' ')
disp('    [ss_r,augr,svhr] = bstschmr(ss_,1,3);  % Run BSTSCHMR.M')
disp('   ------------------------------------------------------------------')
[ss_r,augr,svhr] = bstschmr(ss_,1,3);
[ar,br,cr,dr] = ssdata(ss_r);
disp(' ')
svhr = svhr';
format compact
svhr
format loose
disp(' ')
disp('        (strike a key to see a bar chart of the Phase Matrix Hankel SV`s ...)')
pause
bar(svhr)
title('Hankel Singular Values of the Phase Matrix')
drawnow
pause

clc
disp(' ')
disp(' ')
disp('         - - - Computing the Bode Plots - - - ')
[gs,phs] = bode(as,bs,cs,ds,1,w); gs = 20*log10(gs);
[gh,phh] = bode(ah,bh,ch,dh,1,w); gh = 20*log10(gh);
[gr,phr] = bode(ar,br,cr,dr,1,w); gr = 20*log10(gr);
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('                         (strike a key to see the Bode plots ..)')
pause
clf
disp(' ')
semilogx(w,ga,w,gs,w,gh,w,gr)
title('Schur BST-REM vs. Schur BT and Des. Hankel (7-state --> 3-state)')
xlabel('Frequency - Rad/Sec')
ylabel('Gain - db')
legend('original model','Schur-BT:  schmr(sys,1,3)',...
  'Optimal Des. Hankel MDA:  ohklmr(sys,1,3)',...
  'Schur BST-REM:  bstschmr(sys,1,3)',4);

grid
drawnow
pause

semilogx(w,ph,w,phs,w,phh,w,phr)
title('Schur BST-REM vs. Schur BT and Des. Hankel (7-state --> 3-state)')
xlabel('Frequency - Rad/Sec')
ylabel('Phase - deg')
legend('original model','Schur-BT:  schmr(sys,1,3)',...
   'Optimal Des. Hankel MDA:  ohklmr(sys,1,3)',...
   'Schur BST-REM:  bstschmr(sys ,1,3)',3);

grid

drawnow
pause


%
% ----- End of BHRDEMO.M --- RYC/MGS %
