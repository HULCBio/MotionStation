function updategainF(Editor)
%UPDATEGAINF  Lightweight plot update when modifying the filter gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 05:03:43 $

% RE: Assumes gain does not change sign

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off')
    % Editor is inactive
    return
end

switch Editor.LoopData.Configuration  
case {1,2}
   % Filter is not in the closed-loop so do a minimal update
   % Compute new filter mag data = filter gain * normalized filter response
   GainMag = getzpkgain(Editor.EditedObject,'mag');  % filter gain
   MagData = unitconv(GainMag*Editor.Magnitude,'abs',Editor.Axes.YUnits{1});
   XFocus = getfocus(Editor);
   
   % Update mag plot vertical position
   set(Editor.HG.BodePlot(1),'Ydata',MagData); 
   % REVISIT: Update XlimIncludeData of BodePlot(1)
   set(Editor.HG.BodeShadow(1),'YData',...
      MagData(Editor.Frequency>=XFocus(1) & Editor.Frequency<=XFocus(2)))
   
   % Update pole/zero positions in mag plot
   Editor.interpy(MagData);
   
   % Update the closed-loop plot if visible
   if strcmp(Editor.ClosedLoopVisible,'on')
      MagData = unitconv(GainMag*Editor.ClosedLoopMagnitude,'abs',Editor.Axes.YUnits{1});
      set(Editor.HG.BodePlot(1,2),'Ydata',MagData); 
      % REVISIT: Update XlimIncludeData of BodePlot(1,2)
      set(Editor.HG.BodeShadow(1,2),'YData',...
         MagData(Editor.ClosedLoopFrequency>=XFocus(1) & Editor.ClosedLoopFrequency<=XFocus(2)))
   end
   
   % Update axis limits
   updateview(Editor)
   
case {3,4}
   % Filter is in the closed-loop so call update to do a full recalculation
   update(Editor)
end

