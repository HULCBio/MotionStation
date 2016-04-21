%MUPLT Script file for plotting the results of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  MUPLT.M is a script file that produces the plots for the ACC
%     Benchmark problem.
% ---------------------------------------------------------------
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

   clf
   subplot(2,1,1)
   semilogx(w,[perttw1;pertt1]);
   title('Ty1u1 in "s~" and "s"');
   grid on;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
   text(0.002,-5,['MSM in s~: +-',num2str(msmw1),' %']);
   text(0.002,-10,['MSM in s : +-',num2str(msm1),' %']);

   subplot(2,1,2)
   semilogx(w,[perttw;pertt]);
   title('Ty1u1 in "s~" and "s"');
   grid on;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
   text(0.002,-5,['MSM in s~: +-',num2str(msmw),' %']);
   text(0.002,-10,['MSM in s : +-',num2str(msm),' %']);
   pause
   ptid = input(' Do you want a hardcopy ? (1=yes,0=no)');
   if ptid == 1
     print
   end

   clf
   subplot(2,2,1)
   loglog(w,exp(diag_d))
   title('Diagonal Scaling D(s)')
   xlabel('Rad/Sec')
   ylabel('logd')

   subplot(2,2,2)
   loglog(w,exp(diag_d(1,:)),'x',w,ga1);
   title('D11(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')

   subplot(2,2,3)
   loglog(w,exp(diag_d(2,:)),'x',w,ga2);
   title('D22(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')

   subplot(2,2,4)
   loglog(w,exp(diag_d(3,:)),'x',w,ga3);
   title('D33(s)')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('logd')
   ptid = input(' Do you want a hardcopy ? (1=yes,0=no)');
   if ptid == 1
     print
   end
   pause

   clf
   subplot(2,2,1)
   plot(t,x1_ipw1);grid on;
   title('x1');       xlabel('Sec')

   subplot(2,2,2)
   plot(t,x2_ipw1);grid on;
   title('x2 (z)');   xlabel('Sec');

   subplot(2,2,3)
   plot(t,u_ipw1); grid on;
   title('Control (u)'); xlabel('Sec');

   subplot(2,2,4)
   text(0.3,0.8,'Impulse Response @ M1','sc');
   text(0.3,0.7,'Sensor Noise: 0.001*sin(100t)','sc')
   text(0.35,0.5,'Dashed: k = 0.5','sc');
   text(0.35,0.4,'Solid:  k = 1.0','sc');
   text(0.35,0.3,'Dotted: k = 2.0','sc');
   pause
   ptid = input(' Do you want a hardcopy ? (1=yes,0=no)');
   if ptid == 1
     print
   end

   clf
   subplot(2,2,1)
   plot(t,x1_ipw2);grid on;
   title('x1');  xlabel('Sec');

   subplot(2,2,2)
   plot(t,x2_ipw2);grid on
   title('x2 (z)');   xlabel('Sec');

   subplot(2,2,3)
   plot(t,u_ipw2); grid on;
   title('Control (u)'); xlabel('Sec');

   subplot(2,2,4)
   text(0.3,0.8,'Impulse Response @ M2','sc');
   text(0.3,0.7,'Sensor Noise: 0.001*sin(100t)','sc')
   text(0.35,0.5,'Dashed: k = 0.5','sc');
   text(0.35,0.4,'Solid:  k = 1.0','sc');
   text(0.35,0.3,'Dotted: k = 2.0','sc');
   pause
   ptid = input(' Do you want a hardcopy ? (1=yes,0=no)');
   if ptid == 1
     print
   end
%
clf
subplot(2,2,1)
semilogx(w,gf);title('Controller F(s)');
xlabel('Rad/Sec'); ylabel('Gain (db)')

subplot(2,2,3)
semilogx(w,pf);xlabel('Rad/Sec');ylabel('Phase (deg)')

subplot(2,2,2)
semilogx(w,gl); title('Loop TF G*F'); xlabel('Rad/Sec');
text(0.002,-50,['Min. GM: ',num2str(gmin),' db']);
text(0.002,-150,['Max. GM: ',num2str(gmax),' db']);

subplot(2,2,4)
semilogx(w,pl);
xlabel('Rad/Sec (k = 0.5(- -), 1(-), 2(.))');ylabel('Phase (deg)')
text(0.002,max(min(pl))+100,['Min. PM: ',num2str(pmin),' deg']);
text(0.002,max(min(pl)),['Max. PM: ',num2str(pmax),' deg']);
pause

ptid = input(' Do you want a hardcopy ? (1=yes,0=no)');
   if ptid == 1
     print
   end
%
clc
disp(' ');
disp(' ');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  *                                                         *')
disp('  *      Your design is accomplished ..                     *')
disp('  *              Controller: (af,bf,-cf,-df).               *')
disp('  *                                                         *')
disp('  *       (strike a key to go back to the main menu)        *')
disp('  *                                                         *')
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
pause
%
% ----------- End of MUPLT.M % RYC/MGS %