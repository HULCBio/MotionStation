function updatelims(Editor)
%UPDATELIMS  Resets axis limits.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.22 $ $Date: 2002/04/10 05:05:26 $

% Return if Editor is inactive 
if strcmp(Editor.EditMode, 'off') | Editor.SingularLoop
   return
end
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
AutoX = strcmp(Axes.XlimMode,'auto');

% Enforce limit modes at HG axes level
set(PlotAxes,'XlimMode',Axes.XlimMode{1},'YlimMode',Axes.YlimMode{1})

% Acquire limits (automatically includes other objects such as constraints 
% and compensator poles and zeros)
Xlim = get(PlotAxes,'XLim');
Ylim = get(PlotAxes,'YLim');

% Adjust limits if grid is on (show full 180 degree sections)
PhaseExtent = Editor.xyextent('phase');
if strcmp(Axes.Grid,'on')
   if AutoX
      Xlim = niclims('phase', Xlim, Axes.XUnits);
      PhaseExtent = niclims('phase', PhaseExtent, Axes.XUnits);
   end   
   if strcmp(Axes.YlimMode,'auto')
      Ylim = niclims('mag', Ylim, 'dB');
   end
end

% Adjust phase ticks for units = degree
set(PlotAxes, 'XtickMode', 'auto')
if strcmpi(Axes.XUnits, 'deg')
   set(PlotAxes, 'Xlim', Xlim)
   Xticks = get(PlotAxes, 'XTick');
   if AutoX
      % Auto mode. Adjust limits taking into account true extent of phase data 
      [NewTicks, Xlim] = phaseticks(Xticks, Xlim, PhaseExtent);
   else
      % Fixed limit mode
      NewTicks = phaseticks(Xticks, Xlim);
   end
   set(PlotAxes, 'XTick', NewTicks)
end

% All low-level limit modes are manual 
set(PlotAxes, 'Xlim', Xlim, 'Ylim', Ylim)
