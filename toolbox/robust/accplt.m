%ACCPLT Script file for plotting the results of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  ACCPLT.M is a script file that produces the plots for the ACC
%     Benchmark problem.
% ---------------------------------------------------------------
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

clf
if flag == 2
      subplot(1,1,1)
      semilogx(w,[perttw;pertt]);
      title('Cost Function in "s~" and "s"');
      grid on;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
      msmw = max(perttw);
      msmw = 1/(10^(msmw/20)/gamopt)*100;
      msm  = max(pertt);
      msm  = 1/(10^(msm/20)/gamopt)*100;
      text(0.2,-5,['ADDITIVE MSM IN s~-DOMAIN: +-',num2str(msmw),' %']);
      text(0.2,-10,['ADDITIVE MSM IN s-DOMAIN : +-',num2str(msm),' %']);
      %prtsc
      pause
end

if flag ~= 3
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
%  if flag == 1
   text(0.35,0.5,'Dashed: k = 0.5','sc');
   text(0.35,0.4,'Solid:  k = 1.0','sc');
   text(0.35,0.3,'Dotted: k = 2.0','sc');
%  end
   %prtsc
   pause
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
%  if flag == 1
   text(0.35,0.5,'Dashed: k = 0.5','sc');
   text(0.35,0.4,'Solid:  k = 1.0','sc');
   text(0.35,0.3,'Dotted: k = 2.0','sc');
%  end
   %prtsc
   pause
else
   clf
   subplot(2,2,1)
   plot(t,dist_w);grid on
   title('Disturbance: sin(0.5*t) @ M2');
   xlabel('Sec');
   subplot(2,2,2)
   plot(t,u_w2);grid on;
   title('Control Energy (u)');
   xlabel('Sec');
   subplot(2,2,3)
   plot(t,x1_w2);grid on;
   title('x1');
   xlabel('Sensor Noise: 0.001sin(100t)');
   subplot(2,2,4)
   plot(t,x2_w2);grid on;
   title('x2 (z)');
   xlabel('Sec (k = 0.5(- -), 1(-), 2(.))');
   %prtsc
   pause
   clf
   subplot(2,2,1)
   plot(t,dist_w);grid on
   title('Disturbance: sin(0.5*t) @ M1');
   xlabel('Sec');
   subplot(2,2,2)
   plot(t,u_w1);grid on;
   title('Control Energy (u)');   xlabel('Sec');
   subplot(2,2,3)
   plot(t,x1_w1);grid on;
   title('x1');
   xlabel('Sensor Noise: 0.001sin(100t)');
   subplot(2,2,4)
   plot(t,x2_w1);grid on;
   title('x2 (z)');
   xlabel('Sec (k = 0.5(- -), 1(-), 2(.))');
   %prtsc
   pause
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
%if flag == 2
%   text(0.002,-100,['GM: ',num2str(gmin),' db']);
%else
   text(0.002,-50,['Min. GM: ',num2str(gmin),' db']);
   text(0.002,-150,['Max. GM: ',num2str(gmax),' db']);
%end
subplot(2,2,4)
semilogx(w,pl);
xlabel('Rad/Sec (k = 0.5(- -), 1(-), 2(.))');ylabel('Phase (deg)')
%if flag == 2
%   text(0.002,min(pl)+100,['PM: ',num2str(pmin),' deg']);
%else
   text(0.002,max(min(pl))+100,['Min. PM: ',num2str(pmin),' deg']);
   text(0.002,max(min(pl)),['Max. PM: ',num2str(pmax),' deg']);
%end
%prtsc
pause
% plot the root locus
%accroot
%
clc
disp(' ');
disp(' ');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  *                                                               *')
disp('  *      Your design is accomplished ..                           *');
disp('  *              Controller: (nuf,dnf).                           *');
disp('  *                                                               *');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
%
% ----------- End of ACCPLT.M % RYC/MGS %