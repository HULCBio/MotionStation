function updatelims(Editor,varargin)
%UPDATELIMS  Limit picker for Bode editors.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/10 04:57:13 $

if strcmp(Editor.EditMode,'off') | Editor.SingularLoop
   % Editor is inactive or has no data (algebraic inner loop)
   return
end
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);

% Enforce limit modes at HG axes level
set(PlotAxes(1),'XlimMode',Axes.XlimMode{1},'YlimMode',Axes.YlimMode{1})
set(PlotAxes(2),'XlimMode',Axes.XlimMode{1},'YlimMode',Axes.YlimMode{2})

% Acquire common X limits
Xlim = get(PlotAxes,'Xlim');
Xlim = [min(Xlim{1}(1),Xlim{2}(1)) , max(Xlim{1}(2),Xlim{2}(2))];
% Show only positive frequencies (can get here after zoom w/ linear x scale)
Xlim(1) = max(0,Xlim(1));  
set(PlotAxes,'Xlim',Xlim)

% Acquire Y limits
YlimM = get(PlotAxes(1),'Ylim');
YlimP = get(PlotAxes(2),'Ylim');
if strcmpi(Axes.YUnits{1},'abs')
   YlimM(1) = max(0,YlimM(1));
end

% Adjust phase ticks and limits for units = degrees
set(PlotAxes(2),'YtickMode','auto')
if strcmpi(Axes.YUnits{2},'deg')
   Yticks = get(PlotAxes(2),'YTick');
   if strcmp(Axes.YlimMode{2},'auto')
      % Auto mode. Check tight phase extent (limit picker may round up 180 to 200)
      [NewTicks,NewLims] = phaseticks(Yticks,YlimP,Editor.yextent('phase'));
      YlimP = NewLims + [-0.01 0.01] * (NewLims(2)-NewLims(1));
   else
      % Fixed limits
      NewTicks = phaseticks(Yticks,YlimP);
   end
   set(PlotAxes(2),'YTick',NewTicks)
end

% All low-level limit modes are manual 
set(PlotAxes(1),'Ylim',YlimM)
set(PlotAxes(2),'Ylim',YlimP)
