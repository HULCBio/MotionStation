function refitAxisLimits(this)
%REFITAXISLIMITS
%   sets the axis limits so that the a 10 point border is maintained
%   around the axis. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:12:56 $

oldUnits = get(this,'Units');
set(this,'Units', 'pixels');
p = get(this,'Position');
set(this,'Units',oldUnits);

if prod(p(3:4)) > 0
    axisProportion = p(3)/p(4);
end

oldXlim = this.XLim;
oldYlim = this.YLim;
if (diff(oldXlim)/diff(oldYlim) < 0)
    return;
end

if ( diff(oldXlim)/diff(oldYlim) < axisProportion )
  % the x Axis lims need rescaling
  newLimRange = diff(oldYlim) * p(3)/p(4);
  this.XLim = sum(oldXlim)/2 + newLimRange * [-1/2, 1/2];
else
  newLimRange = diff(oldXlim) * p(4)/p(3);
  this.YLim = sum(oldYlim)/2 + newLimRange * [-1/2, 1/2];
end

