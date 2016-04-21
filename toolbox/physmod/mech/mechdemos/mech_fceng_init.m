% ICEng Initialization

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/06/27 18:42:49 $

Ta      = 25;           % Ambiant Temperature (C)
Pa      = 1033.34;      % Atm Pressure (gms/cm2)
G       = 1.4;          % Index of Compression
R       = 5;            % Piston Radius(cm)
Q       = 46816;        % Heat energy of petrol (J/gm)
RoP     = 0.74;         % Density of petrol (gms/cc)
Vo      = pi*R*R*14;    % Volume when piston is at the BDC(cm^3)
Vtdc    = pi*R*R*2;     % Volume when piston is at the TDC(cm^3)
Cv      = 3;            % Specific heat of burnt air-fuel at const Volume(J/gC)
AirRo   = 1.2E-3;       % Density of air (gms/cc)
TDCVol  = 1*pi*R*R;     % TopDeadCenter Volume
Offset  = -pi/4;        % ICBlock Offset

