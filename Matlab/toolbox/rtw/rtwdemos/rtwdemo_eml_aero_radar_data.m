%RADDAT sets up data needed to run Simulink radar model "radmod".

% Copyright 1990-2004 The MathWorks, Inc.
% Program developed by Dr. Richard Gran, September 1, 1996.
% $Revision: 1.1.6.1 $ $Date: 2004/02/11 19:36:15 $

g = 32.2;    % Acceleration due to gravity (ft/sec^2)
tauc = 5;    % Correlation time of aircraft cross axis acceleration
tauT = 4;    % Correlation time of aircraft thrust axis acceleration
Speed = 400; % Initial speed of aircraft in y direction feet/sec
deltat = 1;  % Radar update rate (also hard-coded in extkalman.m)
