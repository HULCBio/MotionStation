function reframe(Axes,CurrentAxes,XRuler,YRuler,X,Y,Xm,Ym)
%REFRAME  Grows axes range during move or resize operations.
%
%   REFRAME enlarges the axes limits if the point(s) specified 
%   by (X,Y) fall outside the current range.  The rescaling
%   scheme is determined by XRuler and YRuler (see ENLARGE_VIEW 
%   for details). 

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:16 $
% Localize working axes in axes group
PlotAxes = getaxes(Axes,'2d');
[ir,ic] = find(reshape(CurrentAxes==PlotAxes,size(PlotAxes)));

% Compute range that includes (X,Y) points
Xlim = LocalGrowRange(get(CurrentAxes,'Xlim'),XRuler,X);
Ylim = LocalGrowRange(get(CurrentAxes,'Ylim'),YRuler,Y);

% Update X limits (conditioned by XlimMode)
EnlargeX = (~isempty(Xlim) & strcmp(Axes.XLimMode{ic},'auto'));
if EnlargeX
   % Protected set (no listener triggered nor XlimMode update)
   Axes.setxlim(Xlim,ic,'basic')
   % Custom ticks
   if strcmp(XRuler,'deg')
      CurrentAxes.XtickMode = 'auto';
      CurrentAxes.XTick = phaseticks(CurrentAxes.XTick,Xlim);
   end
end

% Update Y limits (conditioned by YlimMode)
% REVISIT: swap lines below when YlimMode always a cell array
EnlargeY = (~isempty(Ylim) & strcmp(Axes.YLimMode{ir},'auto'));
if EnlargeY
   % Protected set (no listener triggered nor XlimMode update)
   Axes.setylim(Ylim,ir,'basic')
   % Custom ticks
   if strcmp(YRuler,'deg')
      CurrentAxes.YtickMode = 'auto';
      CurrentAxes.YTick = phaseticks(CurrentAxes.YTick,Ylim);
   end
end

% Adjust pointer position
if EnlargeX | EnlargeY
   if nargin<7,
      % Use (X,Y) as mouse position if none supplied
      moveptr(CurrentAxes,'move',X,Y);
   else
      moveptr(CurrentAxes,'move',Xm,Ym);
   end
   % Notify that limit changed
   Axes.send('PostLimitChanged')
end

%---------------------- Local Functions -----------------------------

function Xlim = LocalGrowRange(Xlim,XRuler,X)
% Checks if position X is within scope and expands axis limits otherwise
%     XRuler:  axes ruler type (controls expansion rate)
%               ['lin', 'log', 'abs', 'dB', or 'deg']
%     X     :  specified point(s) to include
% RE: written for X, applies to Y as well
X1 = min(X);  X2 = max(X);
if (X1>=Xlim(1) & X2<=Xlim(2))
   % In range
   Xlim = [];  return
end
   
% Compute new limits
switch XRuler
case 'lin'
   % Dilate axis to 200% of current size
   HalfX = (Xlim(2)-Xlim(1))/2;
   Xlim = Xlim + [-HalfX,HalfX];
case 'log'
   % Log scale: Add a decade to the left or right
   Xlim(1) = Xlim(1)/10^(X1<Xlim(1));   
   Xlim(2) = Xlim(2)*10^(X2>Xlim(2));   
case 'abs'
   % Linear scale with X>0 constraint (mag axis)
   ExpandFlag = (X1>0);  
   if ExpandFlag
      Xlim(1) = Xlim(1) / 2^(X1<Xlim(1));
      Xlim(2) = Xlim(2) * 2^(X2>Xlim(2));
   end
case 'dB'
   % Linear scale with dB transform: add 40 dB up, 20 dB down
   Xlim(1) = Xlim(1) - 20 * (X1<Xlim(1));
   Xlim(2) = Xlim(2) + 40 * (X2>Xlim(2));
case 'deg'
   % Linear scale with degrees tick marks: add 90 degree up or down
   Xlim(1) = Xlim(1) - 90 * (X1<Xlim(1));
   Xlim(2) = Xlim(2) + 90 * (X2>Xlim(2));
end
