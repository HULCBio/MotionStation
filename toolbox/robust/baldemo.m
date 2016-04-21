function baldemo
%BALDEMO Demo of balanced model reduction techniques.

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.

clc
disp('    ')
disp(' ')
disp('           << Demo #1: Balanced Model Reduction Techniques >>')
disp('  ')
disp(' ')
disp('            This demo will show:')
disp(' ')
disp('             1). Schur Balanced Model Reduction Technique')
disp('     ')
disp('             2). Square-root Balanced Model Reduction Technique ')
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
disp('                   << Introduction of Balanced Methods >>')
disp('  ')
disp('  ')
disp('    The calculation of the balancing transformation required in Moore`s')
disp(' ')
disp('    "balanced-transformation" model reduction procedure tends to be badly')
disp(' ')
disp('    conditioned, especially for non-minimal models that stand to benefit')
disp(' ')
disp('    the most from model reduction. The Schur procedure described here can')
disp(' ')
disp('    directly compute the Moore "balanced" reduced model without balancing ')
disp(' ')
disp('    thereby completely circumventing the ill-conditioning problems that')
disp(' ')
disp('    had plagued Moore''s original algorithm.')
disp(' ')
disp('    The square-root method for some problems can be ill-conditioned as well.')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp(' State-space of the 10-state model to be reduced (stable & nonminimal):')
a =[-6    -1     0     0     0     0     0     0     0     0;
     1    -8     0     0     0     0     0     0     0     0;
     0     0   -10     3     0     0     0     0     0     0;
     0     0     1    -8     0     0     0     0     0     0;
     0     0     0     0   -13    -3     9     0     0     0;
     0     0     0     0     1    -8     0     0     0     0;
     0     0     0     0     0     1    -8     0     0     0;
     0     0     0     0     0     0     0   -14    -9     0;
     0     0     0     0     0     0     0     1    -8     0;
     0     0     0     0     0     0     0     0     0    -2];
b =[1         0;
    0         0;
    0         1;
    0         0;
    1         0;
    0         0;
    0         0;
    0         1;
    0         0;
    0.001     0.001];
c =[0 1 0 1 0 0 0 0 0 500000;
    0 0 0 0 0 0 -6 1 -2 500000];
d = [0 0;0 0];
a
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
format short e
clc
disp('               << Technique 1. Schur Balanced Model Reduction >>')
disp('      -----------------------------------------------------------------')
disp('       First let us compute the Hankel singular values of the model...')
disp('  ')
disp('       [svh] = hksv(a,b,c);    % Computing Hankel singular values')
disp('      -----------------------------------------------------------------')
[svh] = hksv(a,b,c);
svh = svh';
format compact
svh
format loose
disp(' ')
disp('      ----------------------------------------------------------------')
disp('       Obviously, the regular "balanced transformation" fails immedi-')
disp('       ately due to the last few Hankel singular values being "0" ...')
disp('      ----------------------------------------------------------------')
disp(' ')
disp('        (strike a key to see a bar chart of the Hankel Singular Values ...)')
pause
bar(svh)
title('Hankel Singular Values')
drawnow
pause
clc
disp(' ')
disp(' ')
disp('      ---------------------------------------------------------------')
disp('       If we truncate the model to 4-state, the infinity-norm error ')
disp('       bound can be computed beforehand ...')
disp(' ')
disp('       bndsch = 2*sum(svh(1,5:10));  % Infinity-norm error bound')
disp('      ---------------------------------------------------------------')
bndsch = 2*sum(svh(1,5:10))
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('  ')
disp('     ---------------------------------------------------------------------')
disp('      Let us start Schur Balanced Truncation (Schur-BT) to get a 4-state')
disp('      reduced model ...')
disp('  ')
disp('      [as,bs,cs,ds,agsh,svh,tlh,trh] = schbal(a,b,c,d,1,4); % Run SCHBAL.M')
disp('     ---------------------------------------------------------------------')
[as,bs,cs,ds,augsh,svh,tlh,trh] = schbal(a,b,c,d,1,4);
bndsch = augsh(1,2);
disp('                                               ^')
disp('        - - - Computing SV Bode plot of G(s) & G(s)- - - ')
w = logspace(-4,4,50);
svg = sigma(a,b,c,d,1,w); svg = 20*log10(svg);
svsch = sigma(as,bs,cs,ds,1,w); svsch = 20*log10(svsch);
[aser,bser,cser,dser] = addss(a,b,c,d,as,bs,-cs,-ds);
disp(' ')
disp('        - - - Computing SV Bode plot of the error system - - -')
sversch = sigma(aser,bser,cser,dser,1,w); sversch = 20*log10(sversch);
bndsch = 20*log10(bndsch)*ones(size(w));
disp(' ')
disp('                                                               ^')
disp('                       (strike a key to see the plot of G(s) & G(s)...)')
pause
clf
semilogx(w,svg,w,svsch)
title('Schur Balanced Truncation Technique')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
text(0.001,0,'ORIGINAL & REDUCED MODEL (SAME SV PLOTS)')
grid on
drawnow
pause
disp(' ')
disp('                                                    ^')
disp('            (strike a key to see the plot of G(s) - G(s) & its bound..)')
pause
clf
semilogx(w,bndsch,w,sversch)
title('Schur-BT Technique (Infinity-norm error bound)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
text(100,-50,'Error Bound')
text(1,-80,'Error')
drawnow
pause
clc
disp(' ')
disp('  ')
disp('                 << Technique 2. Square-Root Balanced Method >>')
disp('     --------------------------------------------------------------------')
disp('       Let us try the Square-Root method to get a 4-state model and compare')
disp('       with the Schur-BT method...')
disp(' ')
disp('       [aq,bq,cq,dq,agq,svh,tlq,trq] = balsq(a,b,c,d,1,4); % Run BALSQ.M')
disp('     --------------------------------------------------------------------')
[aq,bq,cq,dq,agq,svh,tlq,trq] = balsq(a,b,c,d,1,4);
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('      The singular values Bode plots are theoretically identical to ')
disp(' ')
disp('      the Schur-BT technique, therefore we omit them, but the condition')
disp('  ')
disp('      numbers of the final transformations differ a lot ......')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('   ')
disp('  ')
disp('            << Condition Number of Schur-BT vs. Square-Root BT >>')
disp(' ')
disp('                    Schur-BT               Square-Root BT')
disp('               -----------------         ------------------')
disp('                Slbig     Srbig           Slbig      Srbig')
disp('  ')
disp('                 6.1       6.1            27216      4049.5')
disp(' ')
disp(' ')
disp('      A smaller condition number means less sensitivity to numerical roundoff')
disp(' ')
disp('      errors, i.e., SCHMR is more numerically robust than BALMR.')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp(' ')
disp('  << Comparison of Schur and Square-Root with Finite Precision Arithmetic >>')
disp(' ---------------------------------------------------------------------------')
disp('   Let`s truncate the transformation matrices SLBIG & SRBIG of the two')
disp('   methods to 1/1000 th finite precision, then compare the results.')
disp(' ')
disp('   The plot shows that round-off error creates a "terrible" result for')
disp('   the Square-Root method as one would expect from its ill-conditioned ')
disp('   transformation matrices !!')
disp(' ---------------------------------------------------------------------------')
tlhrd = round(tlh*1000)/1000;
trhrd = round(trh*1000)/1000;
tlqrd = round(tlq*1000)/1000;
trqrd = round(trq*1000)/1000;
ass = tlhrd'*a*trhrd; bss = tlhrd'*b; css = c*trhrd; dss = ds;
aqq = tlqrd'*a*trqrd; bqq = tlqrd'*b; cqq = c*trqrd; dqq = dq;
svss = sigma(ass,bss,css,dss,1,w); svss = 20*log10(svss);
svqq = sigma(aqq,bqq,cqq,dqq,1,w); svqq = 20*log10(svqq);
disp(' ')
disp(' ')
disp(' ')
disp('                         (strike a key to see the comparison ..)')
pause
semilogx(w,svsch,w,svss,w,svqq)
title('Finite Precision Arithmetic (Schur vs. Square-Root)')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
legend('Schur method','rounded Schur','rounded Square-Root',3);
drawnow
pause

%
% ----- End of BALDEMO.M --- RYC/MGS %
