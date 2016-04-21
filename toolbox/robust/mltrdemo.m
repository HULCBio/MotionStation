function mltrdemo
%MLTRDEMO Demo of LQG/LTR control design (MIMO case).
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
clear
clc
format short e
disp(' ')
disp('  ')
disp('  ')
disp('                << LQG/LTR Demo: MIMO Fighter Design Example >>')
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
disp('    Poles of the plant (unstable phugoid modes):')
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
disp('     - - - Computing SV Bode plot of the open loop plant - - -')
w = logspace(-4,4,100);
svg = sigma(ag,bg,cg,dg,1,w); svg = 20*log10(svg);
disp(' ')
disp(' ')
disp('                   (strike a key to see the SV Bode plot of G(s) ...)')
pause
clf
semilogx(w,svg)
title('MIMO Fighter Pitch Axis Open Loop')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
drawnow
pause
disp('                      << Problem Formulation >>')
disp(' ')
disp('     The LQG/LTR procedure described here does loop transfer recovery')
disp('     at the plant output:')
disp(' ')
disp('        Given a transfer function G(s), find a stabilizing controller')
disp('        F(s) such that the "Kalman Filter Loop Transfer Function" --')
disp('                                     -1')
disp('                       Lq(s) = C(Is-A) Kf')
disp('        is recovered with the "control weighting"  Q replaced by')
disp('                                 T')
disp('              Q <------ Q + q*C*C   and "q" goes to infinity.')
disp('   ')
disp('     The "recovered" Kalman filter loop gain results in the following nice ')
disp('     properties in each of the feedback loops:')
disp('                   1). Infinite gain margin')
disp('                   2). +- 60 deg. phase margin')
disp('     However, the LQG/LTR procedure works only if the plant')
disp('              1). is minimum phase, and')
disp('              2). has at least as many inputs as outputs.')
disp(' ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
clc
disp('  ')
disp(' ')
disp('                              << DESIGN PROCEDURE >>')
disp('  ')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('            *   [Step 1]. Select noise weightings Xi & Th such that   *')
disp('            *             they achieve a desirable Kalman filter gain *')
disp('            *             (e.g., Xi = BB`, Th = I, or anything better)*')
disp('            *                                                         *')
disp('            *   [Step 2]. Assign a set of recovery gains for Q         *')
disp('            *             (e.g., q = [1, 1e5, 1e10, 1e15])            *')
disp('            *                                                         *')
disp('            *   [Step 3]. Run M-file LTRY.M with initial Q = C`C and  *')
disp('            *             R = I, then the recovered Kalman gain will  *')
disp('            *             be presented in the command window          *')
disp('            * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('                         << Start Computation >>')
disp('     ------------------------------------------------------------------')
disp('       Xi = bg*bg`; Th = I;           % Assign noise weighting')
disp('       q  = [1 1e5 1e10 1e15];        % Assign recovery gain for Q')
disp('       Q = cg`*cg; R = I;             % Assign initial control wt. ')
disp('       XiTh = diagmx(Xi,Th)           % Put Xi & Th into compact form')
disp('       [Kf] = lqrc(ag`,cg`,XiTh);     % Solve Kalman filter gain')
disp('       Kf = Kf`                       % using duality with LQR')
disp('       svk = sigma(ag,Kf,cg,zeros(2,2),1,w); % Compute singular value ')
disp('                                               Bode plot')
disp('     ------------------------------------------------------------------')
Xi = bg*bg'; Th = eye(2);                 % Assign noise weighting
q  = [1 1e5 1e10 1e15];              % Assign recovery gain for Q
Q = cg'*cg; R = eye(2);                   % Assign initial control wt.
XiTh = diagmx(Xi,Th);                % Put Xi & Th into compact form
disp('   ')
disp('     - - - Solving Riccati for the Kalman filter gain - - -')
[Kf] = lqrc(ag',cg',XiTh);           % Solve Kalman filter gain
Kf = Kf';                            % using duality with LQR
disp(' ')
disp('     - - - Computing SV Bode Plot of the Kalman filter loop-gain - - -')
svk = sigma(ag,Kf,cg,zeros(2),1,w);   svk = 20*log10(svk);
disp(' ')
disp(' ')
disp('    (strike a key to see the SV Bode plot of the Kalman filter loop-gain...)')
pause
clf
semilogx(w,svk)
title('Singular Value Bode Plot of the Kalman filter loop-gain')
xlabel('Frequency - Rad/Sec')
ylabel('SV - db')
grid on
drawnow
pause
clc
disp('  ')
disp('  ')
disp('                  << LQG/LTR Procedure at Plant Output >>')
disp('    ------------------------------------------------------------------')
disp('       ss_g = system(ag,bg,cg,dg); % G(s) ---> system matrix')
disp('       [ss_f,svl] = ltry(ss_g,Kf,Q,R,q,w,svk); % LQG/LTR at y')
disp('       [af,bf,cf,df] = branch(ss_f);')
disp('    ------------------------------------------------------------------')
[af,bf,cf,df,svl] = ltry(ag,bg,cg,dg,Kf,Q,R,q,w,svk); % LQG/LTR at y
disp(' ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
disp(' ')
disp('  - - - Computing the SV of Controller - - -')
svf = sigma(af,bf,cf,df,1,w); svf = 20*log10(svf);
semilogx(w,svf)
title('LQG/LTR Controller')
xlabel('Rad/Sec')
ylabel('SV (db)')
drawnow
pause
clc
disp('   ')
disp('  ')
disp('   Poles of the controller:')
polf = eig(af)
disp(' ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('   ')
disp('   Poles of the closed-loop TF:')
[al,bl,cl,dl] = series(af,bf,cf,df,ag,bg,cg,dg);
[acl,bcl,ccl,dcl] = feedbk(al,bl,cl,dl,2);
polcl = eig(acl)
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
%
% ------- End of MLTRDEMO.M --- RYC/MGS %
