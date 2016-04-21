function [Ysim,Yexp,Tcom] = getLogData(this, ExpLog, SimLog)
% GETLOGDATA 

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/04 03:39:00 $

% Experiment data
t  = ExpLog.Time;
y  = ExpLog.Data;

% Simulation data
tr = SimLog.Time;
yr = SimLog.Data;

if isempty(t) || isempty(y)
  yr = []; y = []; ts = [];
else
  nd = length(ExpLog.Dimensions);
  if nd > 1
    y  = reshape( permute(y, [nd+1,1:nd]), [length(t), prod(ExpLog.Dimensions)]);
    yr = reshape( permute(yr,[nd+1,1:nd]), [length(tr),prod(ExpLog.Dimensions)]);
  end
  
  % Merge the time bases
  tmin = max( t(1),   tr(1) );
  tmax = min( t(end), tr(end) );
  ts = t(t>=tmin & t<=tmax);
  
  % Interpolate
  y  = interp1(t, y, ts);
  yr = interp1(tr,yr,ts);
end

% Outputs
Ysim = yr;
Yexp = y;
Tcom = ts;
