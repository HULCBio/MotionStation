function milldemo
%MILLDEMO  LQG regulator for a hot steel rolling mill.
%
%   This demo shows how to design a MIMO LQG regulator to 
%   control the horizontal and vertical thickness of a steel 
%   beam.  The LQG regulator consists of a state-feedback 
%   gain and a Kalman filter that estimates the thickness 
%   variations.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 06:40:32 $

try 
	% Open Simulink model if Simulink is installed
	open_system('rolling_mill');
catch
	% Run standalone slideshow 
	milldemo_sls;
end