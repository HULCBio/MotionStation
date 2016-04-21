%DAP3DOFDATA Data for DAP3dof Model

% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/04/10 18:40:22 $

%  Inertias:
I1=10000;
I2=100000;
I3=110000;

I = diag([I1,I2,I3],0);

%  RCS jet Force:
Force =100;
%  RCS Jet moment arm:
L_arm=5.5;

% Accelerations about the three axes for the control system
alph1=Force*L_arm/I1;  % Yaw
alph2=Force*L_arm*sqrt(2)/2/I2;  % Pitch -- Pilot axis
alph3=Force*L_arm/I3;  % Roll -- Pilot axis

alphu=[sqrt(2) sqrt(2)]/2*[alph2 alph3]';  % u axis 
alphv=[-sqrt(2) sqrt(2)]/2*[alph2 alph3]';


% Pseudo acceleration at the off switch curve
alphs1 = 0.1*alph1;
alphsu = 0.1*alphu;
alphsv = 0.1*alphv;

% Clocks
clockt = 0.000625;
delt   = clockt*160;

% Deadband
DB = 0.3*pi/180;

% Minimum impulse firing time
tmin = 0.014;