function zp = project(Editor, x, y, xline, yline, zline)
% Project point (x,y) on polyline (xline,yline) at (xp,yp) and
% find the corresponding zp on zline.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:05:21 $

% Handles
PlotAxes = getaxes(Editor.Axes);

%---If line is single point, just return the point
if length(xline) == 1
  xp = xline;
  yp = yline;
  zp = zline;
  ip = 1;
  return;
end

%---Transform log-scale data for linear scanning
IsLogX = strcmpi(get(PlotAxes, 'XScale'), 'log');
IsLogY = strcmpi(get(PlotAxes, 'YScale'), 'log');
if IsLogX
      x = log2(x);
  xline = log2(xline);
end
if IsLogY
      y = log2(y);
  yline = log2(yline);
end

% Perform 'XY' tracking (good for data which crosses back on itself in x)
[xp, yp, ip] = lproject(x, y, xline, yline, PlotAxes);

% Reconvert for log scale data
if IsLogX
  xp = pow2(xp);
end
if IsLogY
  yp = pow2(yp);
end

% Assumes ip lies within valid range of data (zline)
i1 = floor(ip);
i2 = ip-i1;

% Prevents indexing error for case i1 = size(zline,1);
if i2
  zp = zline(i1) * (1-i2) + zline(i1+1) * i2;
else
  zp = zline(i1);
end
