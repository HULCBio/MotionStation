%   THERMDAT
%   This script runs in conjunction with the "thermo"
%   house thermodynamics demo.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $
%   Ned Gulley 4-9-92

% -------------------------------
% Problem constant
% -------------------------------
r2d = 180/pi;
% -------------------------------
% Define the house geometry
% -------------------------------
% House length = 30 m
lenHouse = 30;
% House width = 10 m
widHouse = 10;
% House height = 4 m
htHouse = 4;
% Roof pitch = 40 deg
pitRoof = 40/r2d;
% Number of windows = 6
numWindows = 6;
% Height of windows = 1 m
htWindows = 1;
% Width of windows = 1 m
widWindows = 1;
windowArea = numWindows*htWindows*widWindows;
wallArea = 2*lenHouse*htHouse + 2*widHouse*htHouse + ...
           2*(1/cos(pitRoof/2))*widHouse*lenHouse + ...
           tan(pitRoof)*widHouse - windowArea;
% -------------------------------
% Define the type of insulation used
% -------------------------------
% Glass wool in the walls, 0.2 m thick
kWall = 0.038;
LWall = .2;
RWall = LWall/(kWall*wallArea);
% Glass windows, 0.01 m thick
kWindow = 0.78;
LWindow = .01;
RWindow = LWindow/(kWindow*windowArea);
% -------------------------------
% Determine the equivalent thermal resistance for the whole building
% -------------------------------
Req = RWall*RWindow/(RWall + RWindow);
% c = cp of air (273 K) = 1005.4 J/kg-K
c = 1005.4;
% -------------------------------
% Enter the temperature of the heated air
% -------------------------------
% THeater = 30 deg C = 303 K
THeater = 303;
% ha = enthalpy of air at 40 deg C = 311400 J/kg
ha = THeater*c;
% Air flow rate Mdot = 0.1 kg/sec
Mdot = 0.1;
% -------------------------------
% Determine total internal air mass = M
% -------------------------------
% Density of air at sea level = 1.2250 kg/m^3
densAir = 1.2250;
M = (lenHouse*widHouse*htHouse+tan(pitRoof)*widHouse*lenHouse)*densAir;
% -------------------------------
% Enter the cost of electricity and initial internal temperature
% -------------------------------
% Assume the cost of electricity is $0.09 per kilowatt/hour
% Assume all electric energy is transformed to heat energy
% 1 kW-hr = 3.6e6 J
% cost = $0.09 per 3.6e6 J
cost = 0.09/3.6e6;
% TinIC = initial indoor temperature = 20 deg C
TinIC = 20;
