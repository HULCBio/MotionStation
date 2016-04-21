% Numerical data for F-14 demo

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

g = 32.2;		% Acceleration of gravity in feet per second squared
Uo = 689.4000;		% Forward Velocity (ft/sec)
Vto = 690.4000;		% Vertical Velocity (ft/sec)

% Stability derivatives

Mw = -0.00592;			% Moment for unit w
Mq = -0.6571;			% Moment for unit q
Md = -6.8847;			% Moment for unit actuator deflection
Zd = -63.9979;			% Force for unit actuator deflection
Zw = -0.6385;			% Force for unit w

% Gains for Autopilot

cmdgain = 3.490954472728077e-02;
Ka = 0.6770;
Kq = 0.8156;
Kf = -1.7460;
Ki = -3.8640;

% Other constants

a = 2.5348;
Gamma = 0.0100;
b = 64.1300;
Beta = 426.4352;
Sa = 0.005236;
Swg = 3;
Ta = 0.0500;		% Time constant for actuator
Tal = 0.3959;		% Time constant for angle of attack filter
Ts = 0.1000;		% Time constant for pilot stick filter
W1 = 2.9710;		% Specifies zero location for pitch rate filter
W2 = 4.1440;		% Specifies pole location for pitch rate filter
Wa = 10;
deltat = 0.1;		% Nominal sample time for digital autopilot
deltat1 = 0.01;		% Nominal sample time for digital autopilot filters


% Create data for f14guide

design_number=0;
Value = 1;
Type={'zoh';'foh';'tustin'};
ap=0;

if exist('control','dir')==7; 
   % The Control toolbox exists so we can create the lti objects needed 
   % for the model
   
   %Create lti objects for the Simulink model
   [a1 b1 c1 d1] = linmod('f14autopilot'); % Get state space model for autopilot
   contap = ss(a1,b1,c1,d1);		   % Convert to lti object
   contap.InputName = {'Pilot Command';,...
		       'Angle of Attack Measurement';,...
		       'Pitch Rate Measurement'};
   contap.OutputName = {'Actuator Command'};
   contap.Notes = {['This f14 autopilot (analog) is a reference',...
		    'for the diital design']};
   
   % Convert continuous lti object "contap" to discrete object "discap"
   discap = c2d(contap,deltat,'tustin');  % Get discap lti object for 
                                          % use in Simulink diagram
   
end

% Read in the f14 and controller images:

load f14pix	   % Picture of the F14 stored in the variable rgb
load f14controlpix % Picture of a controller (hardware)
load f14weather    % Picture of clouds

% Display Message
disp('F-14 Data Has Been Loaded');






