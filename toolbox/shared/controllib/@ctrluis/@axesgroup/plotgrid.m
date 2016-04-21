function GridHandles = plotgrid(this,GridType)
%PLOTGRID  Draws custom grids built in @axesgroup.

%    Authors: P. Gahinet
%    Copyright 1986-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:15 $
PlotAxes = getaxes(this);

switch GridType
case 'sgrid'
   % S grid
   set(PlotAxes, 'Xgrid', 'off', 'Ygrid', 'off')
   [GridLines,TextHandles] = feval('spchart',PlotAxes,this.GridOptions);
   GridHandles = [GridLines;TextHandles];
   
case 'zgrid'
   % Z grid
   set(PlotAxes, 'Xgrid', 'off', 'Ygrid', 'off')
   [GridLines,TextHandles] = feval('zpchart',PlotAxes,this.GridOptions);
   GridHandles = [GridLines;TextHandles];
   
case 'ngrid'
   % Nichols chart
   if prod(size(PlotAxes))==1
      % First clean up
      set(PlotAxes, 'Xgrid', 'off', 'Ygrid', 'off')
      % Create Nichols grid data
      Options = this.GridOptions;
      Options.PhaseUnits = this.XUnits;
      [GridHandles, TextHandles] = nicchart(PlotAxes,Options);
      GridHandles = [GridHandles; TextHandles];
   else
      % If units are not dB/deg, then show HG grid instead
      set(PlotAxes, 'XGrid', 'on', 'YGrid', 'on');
      GridHandles = [];
   end
   
case 'nyquist'
   % Nyquist grid
   if prod(size(PlotAxes))==1
      % Draw M and N circles
      % First clean up
      set(PlotAxes, 'Xgrid', 'off', 'Ygrid', 'off')
      % Create grid
      [GridHandles, TextHandles] = nyqchart(PlotAxes,this.GridOptions);
      GridHandles = [GridHandles; TextHandles];
   else
      % If units are not dB/deg, then show HG grid instead
      set(PlotAxes, 'XGrid', 'on', 'YGrid', 'on');
      GridHandles = [];
   end
   
end