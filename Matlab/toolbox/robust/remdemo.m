%REMDEMO Demo of Balanced Stochastic Truncation (BST) method.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% -------------------------------------------------------------------------
clc
disp('    ')
disp(' ')
disp('            << Demo #3: Schur BST-REM Model Reduction Technique >>')
disp('  ')
disp(' ')
disp(' ')
disp(' ')
disp('          Example: 16-State nonminimal MIMO model reduced to 7-States')
disp('     ')
disp('  ')
disp(' ')
disp('  ')
disp('  ')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('                   << Introduction to Schur BST-REM >>')
disp('  ')
disp('  ')
disp('    The Schur Relative Error Method (REM) for state-space model order reduction')
disp(' ')
disp('    is described. Our algorithm is based on Desai`s Balanced Stochastic')
disp(' ')
disp('    Truncation (BST) technique for which Wang and Safonov have obtained')
disp(' ')
disp('    an L-inf norm relative-error bound. However, unlike previous methods,')
disp(' ')
disp('    the Schur method completely circumvents the numerically delicate initial')
disp(' ')
disp('    step of obtaining a minimal balanced stochastic realization (BSR) of the')
disp(' ')
disp('    power spectrum matrix G(s)G`(-s).')
disp(' ')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
format short e
disp(' State-space of the 16-state model to be reduced (stable & nonminimal):')
a1 = [
  -2.0000e+03  -1.1493e+00   1.4858e+03  -6.0345e+02   7.7992e+02   4.5933e+02;
   1.3549e-13  -2.0981e-02  -2.3740e+00   1.2214e+00  -2.4659e+00  -1.1860e+00;
   3.0579e-14  -1.2737e-14  -5.6757e+00   2.2035e+00   2.0629e+01   1.0031e+01;
  -1.5913e-14   5.1825e-15   8.1765e-06  -2.5785e-01   3.6547e+00   3.3445e+00;
   7.7097e-15  -6.4280e-15  -1.0629e-05   7.4497e-05  -3.0000e+01  -1.5516e-04;
   4.0211e-15  -3.9663e-15  -5.2035e-06   3.8799e-05   5.3245e-06  -3.0000e+01;
   1.0512e-26  -1.3191e-26   7.4402e-18  -1.8651e-18  -2.4512e-16  -2.4600e-16;
   1.5017e-26  -6.5896e-27   3.7201e-18  -9.3252e-19  -1.2256e-16  -1.2300e-16;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0;
            0            0            0            0            0            0];
a2 = [
   1.1539e-09   5.7695e-10            0            0            0            0;
   7.5319e-13   3.7660e-13            0            0            0            0;
  -4.0627e-12   2.4833e-12            0            0            0            0;
  -2.2146e-12  -2.9492e-12            0            0            0            0;
   1.0331e-11   7.4681e-12            0            0            0            0;
   6.3843e-12   4.5653e-12            0            0            0            0;
  -1.0000e-02   3.9925e-24            0            0            0            0;
   2.9281e-25  -1.0000e-02            0            0            0            0;
            0            0  -1.6184e+01   1.5083e+02   4.8353e+02  -3.7230e+02;
            0            0  -2.1463e+01  -1.1303e+02  -3.9936e+02   4.5213e+02;
            0            0   1.0421e+01   7.2968e+01   2.5251e+02  -2.6766e+02;
            0            0   4.2729e+00   5.0112e+01   1.6975e+02  -1.6710e+02;
            0            0   1.3789e+01   1.0265e+02   3.5676e+02  -3.7530e+02;
            0            0  -5.9738e+01  -3.3114e+02  -1.1675e+03   1.2905e+03;
            0            0   2.0960e+03   1.1873e+04   4.1764e+04  -4.5988e+04;
            0            0   1.6822e+03  -1.6399e+04  -5.2599e+04   4.0665e+04];
a3 = [
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
            0            0            0            0;
   2.3930e-01  -3.3054e-01  -6.5690e-03   1.2279e+00;
  -6.8475e+00   6.3611e+00   1.5087e+00   4.1866e-02;
   2.6085e+00  -2.4529e+00  -5.6231e-01   3.1315e-01;
   5.9270e-01  -5.8463e-01  -1.1822e-01   3.5004e-01;
   2.9069e+00  -5.8875e+00  -9.0978e-01   8.2380e-01;
  -1.1292e+01   1.7963e+01   2.2323e+00   5.8339e-01;
   3.6532e+02  -5.8425e+02  -4.9193e+01   1.9730e-01;
  -9.0859e+00   9.8929e+00   1.0133e+00  -3.2254e+01];
a = [a1 a2 a3];
b =[
  -9.3933e+02   1.1326e+03;
   6.3293e+01  -1.5312e+01;
  -2.7062e-04   4.0846e-03;
   2.6371e-03   1.5393e-03;
  -5.5859e-04   8.9453e-04;
  -3.6171e-04   5.5788e-04;
   7.5916e-16  -1.3986e-15;
   3.7954e-16  -6.9930e-16;
   1.5533e-02  -1.5516e-01;
   1.7881e-01   5.2796e-03;
  -8.6917e-02  -1.8393e-02;
  -3.9949e-02  -2.3137e-02;
  -1.2324e-01  -2.8050e-02;
   4.7783e-01   3.8904e-02;
  -1.6720e+01  -1.5469e+00;
  -1.5476e+00   1.6728e+01];
c1 = [
  -9.1517e-08  -5.2591e-11   3.1223e-03  -1.2700e-03  -1.9162e-05  -4.5190e-04;
   9.8922e-07   5.6846e-10  -1.7184e-03   6.9980e-04   9.5218e-04   5.0433e-04];
c2 = [
   3.6519e-16  -2.0788e-17  -2.0891e+01  -1.1933e+02  -4.1720e+02   4.6024e+02;
   9.2135e-16   1.6474e-15  -1.6124e+01   1.6319e+02   5.2691e+02  -4.0617e+02];
c3 = [
  -4.8842e+00   5.2742e+00   1.4817e+00   7.4520e-03;
  -2.8106e+00  -1.8255e+00  -4.2506e-02   1.3483e+00];
c = [c1 c2 c3];
d = [
   1.6729e-01   1.5477e-02
   1.5477e-02  -1.6729e-01];
disp('     First 6 column of the A matrix:')
a1
disp('                                 (strike a key to continue ...)')
pause
clc
disp('     Column 7 to 12 of the A matrix:')
a2
disp('                                 (strike a key to continue ...)')
pause
clc
disp('     Column 13 to 16 of the A matrix:')
a3
disp('                                 (strike a key to continue ...)')
pause
clc
b
disp('                                 (strike a key to continue ...)')
pause
clc
c
disp('                                 (strike a key to continue ...)')
pause
clc
d
disp('                                 (strike a key to continue ...)')
pause
clc
disp('   ---------------------------------------------------------------------')
disp('    Let us start Schur BST-REM model reduction to get a 7-state reduced')
disp('    order model ...')
disp(' ')
disp('    [ar,br,cr,dr,aug,svh] = bstschmr(a,b,c,d,1,7); % Run BSTSCHMR.M')
disp('   ---------------------------------------------------------------------')
[ar,br,cr,dr,aug,svh] = bstschmr(a,b,c,d,1,7);
svh = svh';
format compact
svh
format loose
disp(' ')
disp('      ----------------------------------------------------------------')
disp('       The regular "balanced" stochastic truncation/relative rrror')
disp('       method would fail in this case due to the last Hankel singular ')
disp('       value of the "phase matrix" being "0".  But, the Schur BST/REM')
disp('       algorithm BSTSCHMR works well ...')
disp('      ----------------------------------------------------------------')
disp(' ')
disp('        (strike a key to see a bar chart of the Hankel Singular Values ...)')
pause
clf
bar(svh)
title('Hankel Singular Values of the Phase Matrix')
pause
clc
disp(' ')
disp(' ')
disp('                                                 ^')
disp('        - - - Computing SV Bode plot of G(s) and G(s) - - - ')
%w = logspace(0,4,100);
w = logspace(0,4,100);
svg = sigma(a,b,c,d,1,w); svg = 20*log10(svg);
svrem = sigma(ar,br,cr,dr,1,w); svrem = 20*log10(svrem);
disp(' ')
disp('        - - - Computing SV Bode plot of the relative error - - -')
[arer,brer,crer,drer] = addss(a,b,c,d,ar,br,-cr,-dr);
[ai,bi,ci,di] = ssinv(a,b,c,d);
%[arer,brer,crer,drer] = series(arer,brer,crer,drer,ai,bi,ci,di);
sverrem = sigma(arer,brer,crer,drer,1,w); sverrem = 20*log10(sverrem);
remdb = 20*log10(aug(1,2))*ones(size(w));
disp('  ')
disp('                                                              ^')
disp('                    (strike a key to see the plot of G(s) and G(s) ...)')
pause
clf
semilogx(w,svg,w,svrem)
title('Schur BST-REM Model Reduction (16-state --> 7-state)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
text(14,-30,'Original 16-State and 7-State Approximation')
% text(0.1,-60,'7-State Approximation')
drawnow
grid
pause
disp(' ')
disp(' ')
disp('  (strike a key to see the plot of the error ...)')
pause
hold
%clf
%semilogx(w,remdb,w,sverrem)
semilogx(w,sverrem)
% title('Schur BST-REM Model Reduction (16-State ---> 7-State)')
% xlabel('Frequency - Rad/Sec')
%ylabel('SV - db')
%grid
% text(10,40,'Relative Error Bound')
text(300,-120,'Error:    G_{16-state} - G_{7-state}')
drawnow
pause
hold off
%
% ----- End of REMDEMO.M --- RYC/MGS %
