%
% Define default parameters for 
%  Fixed Point Derivative Demo
%

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 19:02:47 $

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
% Define default filter specs in the Z-Plane
%
PoleZ     = 0.85;
