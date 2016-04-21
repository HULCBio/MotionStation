function clear(Editor)
%CLEAR  Clears open loop Bode plot.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:03:25 $

% REVISIT: Call bodeditor::clear for generic part

% Delete HG objects
HG = Editor.HG;
Handles = [HG.BodePlot(:);...
      HG.Compensator.Magnitude;...
      HG.Compensator.Phase;...
      HG.System.Magnitude;...
      HG.System.Phase];
delete(Handles(ishandle(Handles)))

% Also clear margin text when open-loop transfer is not defined
if Editor.SingularLoop & ~isempty(Editor.HG.GainMargin)
   GM = Editor.HG.GainMargin;
   PM = Editor.HG.PhaseMargin;
   % Hide persistent objects (needed when there is an algebraic inner loop)
   set([GM.Text,PM.Text],'String','')
   set([GM.hLine,GM.vLine,PM.hLine,PM.vLine],'Visible','off')
   set([GM.Dot,PM.Dot],'XData',NaN)
end
