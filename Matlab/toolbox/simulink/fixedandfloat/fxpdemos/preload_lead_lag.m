%
% Define default parameters for 
%  Fixed Point Lead And Lag Demo
%

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 19:02:37 $

%
% Define Storage-Data-Types
%
ntemp = 8;
ShortType    = sfix(1*ntemp);
BaseType     = sfix(2*ntemp);
LongType     = sfix(4*ntemp);
ExtendedType = sfix(8*ntemp);

%
% Define default Sample Time
%
SampleTime = 0.05;   % sec

%
% Define default filter specs in the S-Plane
%
PoleS = -2;          % radians/sec

LeadZeroS = 0.4*PoleS;

LagZeroS = 3*PoleS;

LeadKdc = 0.5;   % output units / input units

LagKdc = 1.5;   % output units / input units

%
% Derive default filter specs in the Z-Plane
%
PoleZ     = exp( SampleTime * PoleS     );
LeadZeroZ = exp( SampleTime * LeadZeroS );
LagZeroZ  = exp( SampleTime * LagZeroS  );
