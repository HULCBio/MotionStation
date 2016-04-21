function updatelims(this)
% Updates limits to frame entire constraint.
% (callback for @axes:ViewChanged event)

%   Author: Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
Axes = this.Axes;
ax = getaxes(Axes);
c = this.Constraint;

% Frame constraint X-extent exactly
% RE: Do not rely on constraint extent, which can be biased by initial
%     and user-specified limits (expands to occupy full X range)
if strcmp(Axes.XlimMode,'auto')
   % RE: Do not use SETXLIM in order to preserve XlimMode='auto'
   set(getaxes(Axes),'Xlim',this.XFocus);
end

% Set vertical height of patches based on Y extent of constraints
% RE: Needed so that limit picker sees patch of approximately the right size
ht = (max(c.UpperBoundY(:))-min(c.LowerBoundY(:)))/10;
for ct=1:length(this.LowerBound)
   h = this.LowerBound(ct).Surf;
   y = get(h,'Ydata');
   y([3 4]) = y([2 1])-ht;
   set(h,'Ydata',y)
end
for ct=1:length(this.UpperBound)
   h = this.UpperBound(ct).Surf;
   y = get(h,'Ydata');
   y([3 4]) = y([2 1])+ht;
   set(h,'Ydata',y)
end
   
% Update Y limits (in auto mode only)
Axes.updatelims('manual',[])

% Adjust constraint rendering
drawconstr(this)

