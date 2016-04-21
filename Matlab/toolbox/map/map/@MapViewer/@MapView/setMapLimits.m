function setMapLimits(this,bbox)
%SETMAPLIMITS

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:57:08 $

this.Axis.XLim = bbox(:,1);
this.Axis.YLim = bbox(:,2);