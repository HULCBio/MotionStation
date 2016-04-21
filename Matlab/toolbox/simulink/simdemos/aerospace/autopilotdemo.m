function autopilotdemo()

% Opens the correct version of the Auto Pilot demo based on whether
% Dials & Gauges is licensed. 

% Copyright 1994-2002 The MathWorks, Inc.
%
% $RCSfile: autopilotdemo.m,v $
% $Revision: 1.1 $

if ispc & exist(fullfile(matlabroot,'toolbox','dials'))
  autopilot13dng;
else
  autopilot13ndng;
end