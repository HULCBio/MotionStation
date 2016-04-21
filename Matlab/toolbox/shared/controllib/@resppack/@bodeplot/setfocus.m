function setfocus(this,xfocus,xunits,Domain)
%SETFOCUS  Specifies X-focus for Bode plots.
% 
%   SETFOCUS(PLOT,XFOCUS) specifies the frequency range 
%   to be displayed when the x-axis is in auto-range 
%   mode.  XFOCUS is specified in the current frequency
%   units. 
%
%   SETFOCUS(PLOT,XFOCUS,XUNITS) specifies the frequency 
%   range in the frequency units XUNITS.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:27 $
ni = nargin;
if ni<3
   xunits = this.AxesGrid.XUnits;
end
if ni<4 || strcmpi(Domain,'frequency')
   this.FreqFocus = unitconv(xfocus,xunits,'rad/sec');
end
