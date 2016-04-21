function xfocus = getfocus(this,xunits)
%GETFOCUS  Computes optimal X limits for time plots.
% 
%   XFOCUS = GETFOCUS(PLOT) merges the time ranges for all 
%   visible responses and returns the time focus in the current
%   time units (X-focus).  XFOCUS controls which portion of the
%   time response is displayed when the x-axis is in auto-range
%   mode.
%
%   XFOCUS = GETFOCUS(PLOT,XUNITS) returns the X-focus in the 
%   time units XUNITS.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:06 $

if nargin==1
   xunits = this.AxesGrid.XUnits;
end

if isempty(this.TimeFocus)
   % No user-defined focus. Collect individual focus for all visible MIMO
   % responses
   xfocus = cell(0,1);
   for rct = allwaves(this)'
      % For each visible response...
      if rct.isvisible
         idxvis = find(strcmp(get(rct.View, 'Visible'), 'on'));
         xfocus = [xfocus ; LocalGetFocus(rct.Data(idxvis))];
      end
   end
   
   % Merge into single focus
   xfocus = unitconv(LocalMergeFocus(xfocus),'sec',xunits);
   
   % Round it up
   % REVISIT: should depend on units.
   % Return something reasonable if empty.
   if isempty(xfocus)
      xfocus = [0 1];
   elseif xfocus(2)>xfocus(1)
      xfocus(2) = tchop(xfocus(2));
   elseif abs(xfocus(1))<1
      xfocus = [-1 1]
   else
      xfocus = xfocus(1) + abs(xfocus(1)) * [-1 1];
   end
else
   xfocus = unitconv(this.TimeFocus,'sec',xunits);
end


% ----------------------------------------------------------------------------%
% Purpose: Merge all ranges
% ----------------------------------------------------------------------------%
function focus = LocalMergeFocus(Ranges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct = 1:length(Ranges)
   focus = [focus ; Ranges{ct}];
   focus = [min(focus(:,1)) , max(focus(:,2))];
end


function xf = LocalGetFocus(data)
n = length(data);
xf = cell(n,1);
for ct=1:n
   xf{ct} = unitconv(data(ct).Focus,data(ct).TimeUnits,'sec');
end
