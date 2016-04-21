function sltrdemo
%SLTRDEMO Demo of LQG/LTR control design (SISO case).
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
clear
clc
disp(' ')
disp('  ')
disp('  ')
disp('                << LQG/LTR Demo: SISO Fighter Design Example >>')
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
bg = bg(:,1); cg = cg(2,:); dg = 0;
disp('  ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('   TF of the fighter pitch axis (trimmed @ 25000 ft, 0.9 mach):')
disp('   (from elevon actuator to attitude angle output)')
disp('  ')
disp('  ')
disp('                  -(948.12 s^3 + 30325 s^2 + 56482 s + 1215.3)')
disp('G(s) = ------------------------------------------------------------------------')
disp('        s^6 + 64.554 s^5 + 1167 s^4 + 372.86 s^3 - 5495.4 s^2 + 1102 s + 708.1')
[num,den] = ss2tf(ag,bg,cg,dg,1);
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('  ')
disp('  ')
disp('    Poles of the plant (unstable phugoid modes):')
disp('  ')
disp('    ---------------------------------------------------------------')
disp('       poleg = roots(den)      % Computing the poles of the plant')
disp('    ---------------------------------------------------------------')
poleg  = roots(den)
disp(' ')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('  ')
disp('    Zeros of the plant (minimum phase):')
disp('  ')
disp('    -------------------------------------------------------------------')
disp('      tzerog = roots(num)     % Computing the zeros')
disp('    -------------------------------------------------------------------')
tzerog = roots(num(1,4:7))
disp('  ')
disp(' ')
disp(' ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp(' ')
disp('         - - - Computing Nyquist plot of the open loop plant - - -')
w = logspace(-4,5,200);
lenw = length(w);
[reg,img] = nyquist(ag,bg,cg,dg,1,w);
reg = [reg;reg(lenw:-1:1,:)];img = [img;-img(lenw:-1:1,:)];
disp(' ')
disp(' ')
disp('                     (strike a key to see the Nyquist plot of G(s) ...)')
pause
clf
plot(reg,img)
title('Fighter Pitch Axis Open Loop')
xlabel('real(G(s))')
ylabel('imag(G(s))')
grid on
drawnow
pause
clc
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
disp('       Xi = bg*bg`; Th = 1;           % Assign noise weighting')
disp('       q  = [1 1e5 1e10 1e15];        % Assign recovery gain for Q')
disp('       Q = cg`*cg; R = 1;             % Assign initial control wt. ')
disp('       XiTh = diagmx(Xi,Th)           % Put Xi & Th into compact form')
disp('       [Kf] = lqrc(ag`,cg`,XiTh);     % Solve Kalman filter gain')
disp('       Kf = Kf`                       % using duality with LQR')
disp('       [re,im] = nyquist(ag,Kf,cg,0,1,w); % Compute Nyquist plot ')
disp('       lenw = length(w);              % length of w')
disp('       svk = [ [re;re(lenw:-1:1,:)] [im;-im(lenw:-1:1,:)] ];')
disp('                                      % Pack frequency response')
disp('     ------------------------------------------------------------------')
Xi = bg*bg'; Th = 1;                 % Assign noise weighting
q  = [1 1e5 1e10 1e15];              % Assign recovery gain for Q
Q = cg'*cg; R = 1;                   % Assign initial control wt.
XiTh = diagmx(Xi,Th);                % Put Xi & Th into compact form
disp('   ')
disp('     - - - Solving Riccati for the Kalman filter gain - - -')
[Kf] = lqrc(ag',cg',XiTh);           % Solve Kalman filter gain
Kf = Kf';                            % using duality with LQR
disp(' ')
disp('     - - - Computing Nyquist Plot of the Kalman filter loop-gain  - - -')
[rek,imk] = nyquist(ag,Kf,cg,0,1,w);   % Compute Nyquist plot
rek = [rek;rek(lenw:-1:1,:)]; imk = [imk;-imk(lenw:-1:1,:)];
svk = [rek imk];
disp(' ')
disp(' ')
disp('   (strike a key to see the Nyquist plot of the Kalman filter loop-gain  ...)')
disp('(Note: The 2 encirclements CW of -1 are due to the two unstable plant poles)')
pause
clf
plot(rek,imk)
title('Nyquist Plot of the Kalman filter loop-gain ')
xlabel('real(L(s))')
ylabel('imag(L(s))')
grid on
drawnow
pause
clc
disp('  ')
disp('  ')
disp('                  << LQG/LTR Procedure at Plant Output >>')
disp('    ------------------------------------------------------------------')
disp('       ss_g = ss(ag,bg,cg,dg); % G(s) ---> system matrix')
disp('       [ss_f,svl] = ltry(ss_g,Kf,Q,R,q,w,svk); % LQG/LTR at y')
disp('       [af,bf,cf,df] = ssdata(ss_f);')
disp('    ------------------------------------------------------------------')
ss_g = ss(ag,bg,cg,dg);
[ss_f,svl] = ltry(ss_g,Kf,Q,R,q,w,svk); % LQG/LTR at y
[af,bf,cf,df] = ssdata(ss_f);
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
pause
clc
format short e
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
% ------- End of SLTRDEMO.M --- RYC/MGS %
