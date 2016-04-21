%ACCDM2 Demo of the 1990 ACC benchmark problem.
%   Demonstration of the design of the 1990 ACC
%   benchmark problem. Adapted from ACCDEMO.

%   R. Y. Chiang & M. G. Safonov
%   Adapted for the Expo: Denise Chen, August 1993.
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/11 00:11:38 $

% Demo initialization ====================
if ~exist('SlideShowGUIFlag'), figNumber=0; end;

% Initialize the start-up screen===================================

xpsubplt(1,1,1);
set(gca, 'Units','normalized', ...
         'Visible','off', ...
         'xlim',[0 1], ...
         'ylim',[0.2 0.8]);

cla;
hold on;
drawacc;        % call script to draw the ACC schematic
set(gcf,'color',get(gcf,'color'));      % refresh the screen

if ssinit(figNumber)
  xstr= ...
      ['                                                            '
       ' Press the "Start" button to see a demonstration of a robust'
       ' control system.                                            '
      ];
  ssdisp(figNumber,xstr);
  if figNumber, return; end;
end

% Beginning of the demo ==================
xstr= ...
    ['                                                           '
     ' This is an example from an American Controls Conference   '
     ' benchmark consisting of two frictionless carts connected  '
     ' by a spring.                                              '];
ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

labelacc;       % call script to label the ACC schematic and add forces
set(kHndl,'Color','c');
set(uHndl,'Color','c');

hold off;
xstr= ...
    ['                                                                '
     ' The spring constant k has a specific nominal value, but is     '
     ' considered uncertain and can vary between known limits.        '
     '                                                                '
     ' A control force u drives the first cart.                       '
     '                                                                '];
ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

set(kHndl,'Color','w');
set(uHndl,'Color','w');
set(dHndl,'Color','c');

xstr= ...
    ['                                                         '
     ' There is an external impulse disturbance w on the second'
     ' cart that varies with time.                             '
     '                                                         '
     ' The only sensor in the system measures the displacement '
     ' of the second cart alone. There is noise in this sensor.'
     '                                                         '];
ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================
set(dHndl,'Color','w');
set(uHndl,'Color','c');

xstr= ...
    ['                                                              '
     ' We want to find u, a minimum-phase controller, that is       '
     ' robust to variations in spring rate, so that we can guarantee'
     ' a stable system. This is a challenging problem because       '
     ' there are large phase lags due to the sensor set-up. More    '
     ' conventional methods of design fail due to a lack of         '
     ' robustness.                                                  '
     '                                                              '
     '                                                              '];
ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

set(uHndl,'Color','w');
xstr= ...
    ['                                                           '
     ' The Robust Control Toolbox provides commands to help      '
     ' you augment the nominal plant with an internal model for  '
     ' uncertainities. The commands "series" and "mksys" simplify'
     ' this task. The command "hinf" performs the calculations   '
     ' to find the H-infinity controller.                        '
     '                                                           '];
ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

xstr= str2mat('',' We''ll use the additional assumptions above in our design.');

cla;
text(0.05,0.8,'Left Mass = Right Mass = 1.0');
text(0.05,0.7,'Spring Constant k');
text(0.1,0.62,'Nominal Value = 1.0');
text(0.1,0.54,'Varies between k = 0.5 and k = 2.0');
text(0.05,0.44,'Sensor Noise: v(t) = 0.001*sin(100*t)');
text(0.05,0.34,'Settling Time for the Nominal: 15 seconds');

ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

xstr= ...
    [' We are now ready to do the H-infinity design using the'
     ' Robust Control Toolbox.                               '];
xstr = str2mat('',xstr);

cla;
hold on;
drawacc;
hold off;

ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

ssdisp(figNumber,'One moment...');

%================ Beginning of ACCDEMO adaptation ==================
% Use ACCDEMO's Design 1 and Min Phase
flag = 1;
Lag = 0;
spring = [1 0.5 2];
k = 1; m1 = 1; m2 = 1;
ag = [0      0     1     0
      0      0     0     1
   -k/m1   k/m1    0     0
    k/m2  -k/m2    0     0];
bg = [0 0 1/m1 0]'; cg = [0 1 0 0]; dg = 0;
lamg = eig(ag);
%---------------------------------------
% Augment Plant for H-Inf Design:
%
itcha = 4;

% Use the suggested values for Gam and Rho
Gam = 0.75;
Rho = 0.02;

k0 = 1.25;
A  = [   0       0     1     0
         0       0     0     1
        -k0/m1   k0/m1     0     0
         k0/m2  -k0/m2     0     0];
B1 = [0 0 -1/m1  1/m2]'; B2 = -[0 0 1/m1 0]';
C1 = Gam*[1 -1 0 0];   C2 = [0 1 0 0];
D11 = 0; D12 = 0; D21 = 0; D22 = 0;
C1 = [C1;0 0 0 0]; D11 = [D11;0]; D12 = [D12;Rho];

% Use suggested value for the Min. Phase Controller
p1 = -0.35;
cirpt1 = p1;
cirpt = [-100 cirpt1];
%
no_u1 = size(B1)*[0;1]; no_u2 = size(B2)*[0;1];
no_y1 = size(C1)*[1;0]; no_y2 = size(C2)*[1;0];
   B = [B1 B2]; C = [C1;C2]; D = [D11 D12;D21 D22];
   [aa,bb,cc,dd] = bilin(A,B,C,D,1,'Sft_jw',cirpt);
   A = aa; B1 = bb(:,1:no_u1); B2 = bb(:,no_u1+1:no_u1+no_u2);
   C1 = cc(1:no_y1,:); C2 = cc(no_y1+1:no_y1+no_y2,:);
   D11 = dd(1:no_y1,1:no_u1); D12 = dd(1:no_y1,no_u1+1:no_u1+no_u2);
   D21 = dd(no_y1+1:no_y1+no_y2,1:no_u1);
   D22 = dd(no_y1+1:no_y1+no_y2,no_u1+1:no_u1+no_u2);
%
verbose = 0;    %suppress printing in HINF
      [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo] = hinf(...
                              A,B1,B2,C1,C2,D11,D12,D21,D22,verbose);
%
acceva2;
%================ End of ACCDEMO adaptation ==================

%===================================
xstr= str2mat(...
     ' ', ...
     ' Here are plots of the resulting loop transfer function.', ...
     '  ', ...
     ' The blue line corresponds to k = 1 (nominal k).', ...
     ' The green line corresponds to k = 0.5 (minimum k).', ...
     ' The red line corresponds to k = 2.0 (maximum k).');
cla;
xpsubplt(2,1,1);
semilogx(w,gl); xlabel('Rad/Sec'); ylabel('Gain (dB)');
set(gca,'xlim',[1e-1 1e1]);

xpsubplt(2,1,2);
semilogx(w,pl);
xlabel('Rad/Sec');ylabel('Phase (deg)')
set(gca,'xlim',[1e-1 1e1]);

ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

xstr=str2mat(...
     '                                                          ',...
     ' Here are plots of the impulse response for the H-infinity',...
     ' controller.                                              ',...
     '                                                          ',...
     ' The blue line corresponds to k = 1 (nominal k).          ',...
     ' The green line corresponds to k = 0.5 (minimum k).       ',...
     ' The red line corresponds to k = 2.0 (maximum k).         ',...
     '                                                          ');
ssdisp(figNumber,xstr);

xpsubplt(2,1,1);
plot(t,x1_ipw2);grid;
title('Position of Cart 1');  xlabel('Sec');
set(gca,'xlim',[0 15]);

xpsubplt(2,1,2);
plot(t,x2_ipw2);grid
title('Position of Cart 2');   xlabel('Sec');
set(gca,'xlim',[0 15]);

ssdisp(figNumber,xstr);
if sspause(figNumber), return; end;

%===================================

xstr= ...
    ['                                                   '
     ' This concludes our American Controls Conference   '
     ' benchmark problem.                                '
     '                                                   '
     ' To examine the Robust Control Toolbox solution in '
     ' greater detail, please see the file "accdemo.m".  '];

xpsubplt(1,1,1);
set(gca, 'Units','normalized', ...
         'Visible','off', ...
         'xlim',[0 1], ...
         'ylim',[0.2 0.8]);
hold on;
drawacc;        % call script to draw the ACC schematic
hold off;

ssdisp(figNumber,xstr);

% End of the demo ========================
